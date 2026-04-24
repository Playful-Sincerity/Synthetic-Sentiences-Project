# Section 1: Hardware & OS Foundation — Detailed Plan

## Purpose

Make the M2 MacBook Air a reliable, always-on headless platform.
Everything else — the cognitive engine, memory, voice, communication — depends on a machine that stays awake, stays cool enough, stays reachable, and recovers from failures without human intervention.

---

## 1. Clamshell Mode & Power Management

### pmset Configuration

The machine must never sleep, never hibernate, and never spin down in a way that kills processes.
All settings applied via `sudo pmset -a` (applies to both battery and charger, though it will be plugged in permanently).

```bash
# Prevent system sleep entirely
sudo pmset -a sleep 0

# Prevent display sleep (irrelevant in clamshell, but belt-and-suspenders)
sudo pmset -a displaysleep 0

# Disable hibernation (writes RAM to disk, kills processes on wake)
sudo pmset -a hibernatemode 0

# Disable standby (deep sleep after prolonged idle)
sudo pmset -a standby 0

# Disable Power Nap (background wake/sleep cycling)
sudo pmset -a powernap 0

# Disable auto-power-off
sudo pmset -a autopoweroff 0

# Disable proximity wake (Open/Close lid sensors, Bluetooth)
sudo pmset -a proximitywake 0

# Enable auto-restart after power loss
sudo pmset -a autorestart 1

# Enable wake on network access (Wake-on-LAN for SSH recovery)
sudo pmset -a womp 1

# Disable TCP keepalive during sleep (since we never sleep)
sudo pmset -a tcpkeepalive 0
```

### Verification Script

A script to confirm all pmset flags are correctly set, run after initial setup and periodically by launchd health check:

```bash
#!/bin/bash
# verify-pmset.sh — Confirm all power settings are correct
EXPECTED=(
    "sleep 0"
    "displaysleep 0"
    "hibernatemode 0"
    "standby 0"
    "powernap 0"
    "autopoweroff 0"
    "proximitywake 0"
    "autorestart 1"
    "womp 1"
)

CURRENT=$(pmset -g custom)
FAIL=0
for setting in "${EXPECTED[@]}"; do
    key=$(echo "$setting" | cut -d' ' -f1)
    val=$(echo "$setting" | cut -d' ' -f2)
    actual=$(echo "$CURRENT" | grep -w "$key" | awk '{print $2}' | head -1)
    if [ "$actual" != "$val" ]; then
        echo "DRIFT: $key expected=$val actual=$actual"
        FAIL=1
    fi
done
[ $FAIL -eq 0 ] && echo "All power settings OK"
exit $FAIL
```

### Clamshell Mode Notes

- macOS allows clamshell mode when: external power connected + external display OR Bluetooth keyboard/mouse paired.
- Since The Companion is headless (no external display), we need a workaround.
- **Option A**: Use `Amphetamine` (free, App Store) or `InsomniaX` to prevent sleep with lid closed without an external display.
- **Option B**: Pair a Bluetooth device (even if not actively used) to satisfy macOS's clamshell requirement.
- **Option C**: Use `sudo pmset -a lidwake 0` combined with the sleep prevention above. Test whether macOS still sleeps on lid close despite `sleep 0`. On Apple Silicon, `sleep 0` alone may not prevent clamshell sleep.
- **Recommended approach**: Test `pmset sleep 0` with lid closed first. If the machine sleeps anyway, use Amphetamine as the simplest reliable solution. Document the outcome.

---

## 2. SSH Access

### sshd Configuration

Enable Remote Login via System Settings or command line:

```bash
# Enable SSH (Remote Login)
sudo systemsetup -setremotelogin on

# Verify
sudo systemsetup -getremotelogin
```

### SSH Hardening (file: `/etc/ssh/sshd_config.d/companion.conf`)

```
# Key-based auth only — no password brute force
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no

# Only allow Wisdom's user
AllowUsers wisdomhappy

# Disable root login
PermitRootLogin no

# Idle timeout: 10 minutes (prevents stale sessions eating resources)
ClientAliveInterval 300
ClientAliveCountMax 2
```

### Client-Side SSH Config (on Wisdom's main machine: `~/.ssh/config`)

```
Host companion
    HostName <local-IP-or-hostname>.local
    User wisdomhappy
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

### Static IP / mDNS

- Assign a static IP on the local network (via router DHCP reservation), e.g. `192.168.1.100`.
- macOS Bonjour broadcasts `wisdomhappy-mba.local` automatically — usable as hostname if both machines are on the same network.
- For remote access (outside LAN): consider Tailscale (zero-config mesh VPN, no port forwarding needed, free for personal use). This is a Section 8 (Security) decision but noted here as relevant.

---

## 3. launchd Process Management

### Design Philosophy

launchd is the single source of truth for all Companion processes.
Every long-running process — the cognitive engine, Telegram bot, voice pipeline, Ollama, health monitor — gets a launchd plist.
This gives us:
- Automatic restart on crash (`KeepAlive`)
- Automatic start on boot (`RunAtLoad`)
- Centralized logging
- One-command kill switch (`launchctl unload`)

### Plist Location & Naming Convention

All plists live at: `~/Library/LaunchAgents/`
Naming convention: `com.companion.<service>.plist`

Examples:
- `com.companion.core.plist` — The main cognitive engine
- `com.companion.telegram.plist` — Telegram bot
- `com.companion.voice.plist` — Voice pipeline
- `com.companion.ollama.plist` — Local model server
- `com.companion.health.plist` — Health/thermal monitor

### Template Plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.companion.SERVICENAME</string>

    <key>ProgramArguments</key>
    <array>
        <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/.venv/bin/python</string>
        <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/src/SERVICENAME/main.py</string>
    </array>

    <!-- Start on boot / login -->
    <key>RunAtLoad</key>
    <true/>

    <!-- Auto-restart on crash -->
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>

    <!-- Throttle restart: wait 10 seconds between crash-restarts -->
    <key>ThrottleInterval</key>
    <integer>10</integer>

    <!-- Working directory -->
    <key>WorkingDirectory</key>
    <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion</string>

    <!-- Logging -->
    <key>StandardOutPath</key>
    <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/SERVICENAME.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/SERVICENAME.stderr.log</string>

    <!-- Environment variables (API keys injected here, never in code) -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>ANTHROPIC_API_KEY</key>
        <string>PLACEHOLDER</string>
        <key>COMPANION_SERVICE</key>
        <string>SERVICENAME</string>
    </dict>

    <!-- Resource limits -->
    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
    </dict>
</dict>
</plist>
```

### Process Registration Pattern

Other sections need a clean way to register their services with launchd.
The pattern:

1. Each section provides a plist template in its source directory (e.g., `src/telegram/com.companion.telegram.plist`).
2. A setup script (`scripts/install-services.sh`) symlinks or copies all plist files to `~/Library/LaunchAgents/`, substituting environment variables (API keys from a `.env.local` file that is `.gitignore`'d).
3. The setup script also creates the `logs/` directory.
4. Services are loaded/unloaded via wrapper scripts:

```bash
# scripts/companion-ctl.sh
# Usage: companion-ctl start|stop|restart|status [service]

case "$1" in
    start)
        if [ -z "$2" ]; then
            # Start all companion services
            for plist in ~/Library/LaunchAgents/com.companion.*.plist; do
                launchctl load "$plist"
            done
        else
            launchctl load ~/Library/LaunchAgents/com.companion.$2.plist
        fi
        ;;
    stop)
        if [ -z "$2" ]; then
            for plist in ~/Library/LaunchAgents/com.companion.*.plist; do
                launchctl unload "$plist"
            done
        else
            launchctl unload ~/Library/LaunchAgents/com.companion.$2.plist
        fi
        ;;
    restart)
        $0 stop "$2"
        sleep 2
        $0 start "$2"
        ;;
    status)
        launchctl list | grep com.companion
        ;;
esac
```

### Log Rotation

launchd does not rotate logs. We need a simple rotation mechanism:
- A launchd job (`com.companion.logrotate.plist`) runs daily.
- It rotates logs using `newsyslog` or a simple bash script that moves `*.log` to `*.log.1`, keeping the last 7 days.
- Config file: `/etc/newsyslog.d/companion.conf`

```
# logfilename                                          [owner:group] mode count size when  flags
/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/*.stdout.log     wisdomhappy:staff 644 7 1024 $D0   J
/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/*.stderr.log     wisdomhappy:staff 644 7 1024 $D0   J
```

Alternatively, a simpler Python-based log rotation within each service using `logging.handlers.RotatingFileHandler`, but the newsyslog approach keeps it OS-level and service-agnostic.

---

## 4. Thermal Monitoring

### Why This Matters

The M2 MacBook Air has no fan. Sustained CPU/GPU load (Ollama inference, voice processing, multiple API calls) will cause thermal throttling. The Companion needs to know its own temperature and back off before the machine becomes dangerously hot or throttled into uselessness.

### Reading Thermal Data

**Option A: `powermetrics` (built-in, requires sudo)**
```bash
sudo powermetrics --samplers smc -i 1000 -n 1 | grep "CPU die temperature"
# Output: CPU die temperature: 72.31 C
```
- Pro: Built-in, no dependencies.
- Con: Requires root. Running a sudo process continuously is undesirable.
- Workaround: Run periodically (every 30s) via a launchd plist that runs as root, writing temperature to a file that the Companion reads.

**Option B: `osx-cpu-temp` or similar open-source tool**
- Various GitHub tools can read SMC sensors without sudo.
- Risk: May not work on Apple Silicon / may need Rosetta.

**Option C: Python `psutil` + indirect measurement**
- `psutil` gives CPU usage percentage but not temperature on macOS.
- Can infer thermal state from CPU frequency throttling, but this is indirect.

**Option D: `iStats` Ruby gem**
```bash
gem install iStats
istats cpu temp
```
- May or may not work on M2 Apple Silicon.

**Recommended approach**: Use `powermetrics` run as a root launchd daemon (`/Library/LaunchDaemons/com.companion.thermal.plist`) that samples every 30 seconds and writes to a shared file (`/tmp/companion-thermal.json`). The Companion reads this file — no sudo needed for the main processes.

### Thermal State Model

```
Temperature Zones:
  COOL     (< 60C)  — Normal operation, all systems go
  WARM     (60-75C) — Normal under load, no action needed
  HOT      (75-85C) — Reduce concurrent workloads. Defer non-urgent tasks.
                      Skip local model inference, use API models instead.
  CRITICAL (85-95C) — Emergency throttle. Suspend Ollama. Suspend voice pipeline.
                      Only essential API calls. Alert Wisdom via Telegram.
  DANGER   (> 95C)  — Should never happen with proper management.
                      Kill all Companion processes. Alert Wisdom. Wait for cooldown.
```

### Thermal Monitor Daemon

```xml
<!-- /Library/LaunchDaemons/com.companion.thermal.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.companion.thermal</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/scripts/thermal-monitor.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/thermal.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/thermal.stderr.log</string>
</dict>
</plist>
```

The thermal monitor script:
```bash
#!/bin/bash
# thermal-monitor.sh — Runs as root via LaunchDaemon
# Samples CPU temperature every 30 seconds, writes to shared JSON

OUTPUT="/tmp/companion-thermal.json"

while true; do
    TEMP=$(powermetrics --samplers smc -i 1000 -n 1 2>/dev/null | \
           grep "CPU die temperature" | awk '{print $4}')
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [ -n "$TEMP" ]; then
        # Determine zone
        ZONE="COOL"
        if (( $(echo "$TEMP > 85" | bc -l) )); then ZONE="CRITICAL"
        elif (( $(echo "$TEMP > 75" | bc -l) )); then ZONE="HOT"
        elif (( $(echo "$TEMP > 60" | bc -l) )); then ZONE="WARM"
        fi

        cat > "$OUTPUT" << EOF
{"temperature_c": $TEMP, "zone": "$ZONE", "timestamp": "$TIMESTAMP"}
EOF
        chmod 644 "$OUTPUT"
    fi

    sleep 30
done
```

### Integration with Cognitive Engine (Section 3)

The cognitive engine reads `/tmp/companion-thermal.json` before making routing decisions:
- In HOT zone: prefer API models over Ollama (offload compute to the cloud).
- In CRITICAL zone: suspend Ollama, defer non-urgent work, alert Wisdom.
- The thermal state becomes part of the Companion's "homeostasis" — self-awareness of its physical state.

---

## 5. Process Inventory — What Needs to Stay Alive

Based on the full plan, these are the processes that will eventually run:

| Process | Section | RAM Estimate | CPU Pattern | Priority |
|---------|---------|-------------|-------------|----------|
| **Cognitive Engine** | 3 | ~200MB Python | Bursty (API calls) | Critical |
| **Telegram Bot** | 6 | ~80MB Python | Low (long-polling, idle mostly) | Critical |
| **Voice Pipeline** | 6 | ~500MB-1GB (MLX models) | High during listening/speaking | Optional (can be suspended) |
| **Ollama** | 3/5 | ~2-4GB (model dependent) | High during inference | Suspendable |
| **Health Monitor** | 8 | ~30MB bash/Python | Minimal (periodic) | Critical |
| **Thermal Monitor** | 1 | ~5MB bash | Minimal (periodic) | Critical |
| **Log Rotation** | 1 | ~5MB bash | Minimal (daily) | Low |
| **SQLite** | 3/4 | Embedded (no separate process) | N/A | N/A |

### RAM Budget (8GB total)

```
macOS system overhead:   ~2.5GB
Ollama (when active):    ~2-3GB  (Phi-4 Mini 3.8B at Q4 ≈ 2.5GB)
Voice pipeline:          ~0.5-1GB
Cognitive Engine:        ~0.2GB
Telegram + other:        ~0.2GB
Headroom:                ~1-2GB
```

**Key constraint**: Ollama and the voice pipeline cannot both run at full capacity simultaneously. The Companion must manage this — when voice is active, suspend Ollama; when doing heavy inference, voice can wait. This is a resource management decision for Section 5 (Budget) but the hardware section must surface it.

### Swap Considerations

- macOS uses compressed memory and swap aggressively on Apple Silicon.
- 8GB is tight. Swap to SSD is fast on M2 but degrades SSD lifespan over years.
- Monitor swap usage as part of health checks. Persistent heavy swap = the process mix needs adjustment.

---

## 6. Auto-Restart & Recovery

### Boot Recovery

1. `pmset autorestart 1` — machine restarts after power loss.
2. macOS login: Enable auto-login for `wisdomhappy` user (System Settings > Users & Groups > Login Options > Automatic Login). This is a security tradeoff — acceptable because:
   - The machine is physically in Wisdom's home
   - SSH is key-only
   - The Companion processes need a user session to run as LaunchAgents
3. LaunchAgent plists with `RunAtLoad` — all services start automatically after login.

### Crash Recovery

- `KeepAlive` with `SuccessfulExit: false` — launchd restarts any process that exits with non-zero.
- `ThrottleInterval: 10` — prevents crash loops from consuming resources (10 second minimum between restarts).
- A crash counter in the health monitor: if a service restarts more than 5 times in 10 minutes, stop trying and alert Wisdom.

### Network Recovery

- If internet drops, API-dependent processes (cognitive engine, Telegram) will error.
- They should handle network errors gracefully (retry with backoff), not crash.
- The health monitor checks network connectivity every 60 seconds.
- If network is down for > 5 minutes, alert Wisdom (if Telegram is available via cellular; otherwise queue the alert).

### State Recovery

- The cognitive engine must persist its state to disk (SQLite) frequently enough that a crash loses at most the current in-flight task.
- File-based state (memory, reflections) is written atomically (write to temp file, then rename) to prevent corruption on crash.

---

## 7. Kill Switch

### Design

The kill switch must be:
1. **Instant** — one command stops everything.
2. **Complete** — no Companion process survives.
3. **Reversible** — one command brings everything back.
4. **Accessible** — usable via SSH, and ideally via Telegram too.

### Implementation

```bash
# scripts/kill-switch.sh

#!/bin/bash
ACTION=${1:-status}

MARKER="/tmp/companion-killed"

case "$ACTION" in
    kill)
        echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") KILL activated by $(whoami)" >> \
            /Users/wisdomhappy/Playful Sincerity/PS Software/The Companion/logs/killswitch.log

        # Unload all companion LaunchAgents
        for plist in ~/Library/LaunchAgents/com.companion.*.plist; do
            launchctl unload "$plist" 2>/dev/null
        done

        # Unload thermal daemon (runs as root)
        sudo launchctl unload /Library/LaunchDaemons/com.companion.thermal.plist 2>/dev/null

        # Kill any stragglers (belt and suspenders)
        pkill -f "the-companion" 2>/dev/null

        # Stop Ollama if running
        pkill ollama 2>/dev/null

        # Leave a marker so health monitor doesn't restart things
        touch "$MARKER"

        echo "All Companion processes stopped."
        ;;

    revive)
        rm -f "$MARKER"

        sudo launchctl load /Library/LaunchDaemons/com.companion.thermal.plist
        for plist in ~/Library/LaunchAgents/com.companion.*.plist; do
            launchctl load "$plist"
        done

        echo "All Companion processes restarted."
        ;;

    status)
        if [ -f "$MARKER" ]; then
            echo "KILLED (manual kill switch active)"
        else
            echo "RUNNING"
            launchctl list | grep com.companion
        fi
        ;;
esac
```

### Telegram Kill Switch (Section 6 integration)

The Telegram bot (when running) should accept `/kill` and `/revive` commands from Wisdom only (authenticated by Telegram user ID). This calls the same kill-switch script. Obviously, `/kill` will also stop the Telegram bot itself — so `/revive` must be done via SSH.

### Hardware Kill Switch

Ultimate fallback: close the lid (if clamshell sleep is not fully disabled) or unplug power + let battery drain. This is the "pull the plug" option. The system should never need this.

---

## 8. Health Monitoring

### Health Check Script

A lightweight script that runs every 60 seconds via launchd:

```python
#!/usr/bin/env python3
"""companion-health.py — Periodic health check for all Companion services."""

import json
import subprocess
import time
from pathlib import Path
from datetime import datetime, timezone

SERVICES = [
    "com.companion.core",
    "com.companion.telegram",
    "com.companion.voice",
    "com.companion.ollama",
]

LOG_DIR = Path.home() / "the-companion" / "logs"
HEALTH_LOG = LOG_DIR / "health.jsonl"
THERMAL_FILE = Path("/tmp/companion-thermal.json")
KILL_MARKER = Path("/tmp/companion-killed")

def check_service(label):
    """Check if a launchd service is running."""
    result = subprocess.run(
        ["launchctl", "list", label],
        capture_output=True, text=True
    )
    return result.returncode == 0

def check_network():
    """Quick network connectivity check."""
    result = subprocess.run(
        ["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}",
         "--max-time", "5", "https://api.anthropic.com"],
        capture_output=True, text=True
    )
    return result.stdout.strip() in ("200", "401", "403")

def get_thermal():
    """Read thermal state from monitor."""
    try:
        return json.loads(THERMAL_FILE.read_text())
    except Exception:
        return {"temperature_c": -1, "zone": "UNKNOWN"}

def get_memory():
    """Get memory pressure."""
    result = subprocess.run(
        ["memory_pressure"],
        capture_output=True, text=True
    )
    output = result.stdout
    if "CRITICAL" in output:
        return "CRITICAL"
    elif "WARN" in output:
        return "WARN"
    return "NORMAL"

def main():
    if KILL_MARKER.exists():
        return  # Kill switch active, don't report

    timestamp = datetime.now(timezone.utc).isoformat()
    thermal = get_thermal()
    memory = get_memory()

    services = {}
    for svc in SERVICES:
        services[svc] = "running" if check_service(svc) else "stopped"

    network = "up" if check_network() else "down"

    report = {
        "timestamp": timestamp,
        "thermal": thermal,
        "memory_pressure": memory,
        "network": network,
        "services": services,
    }

    # Append to JSONL log
    with open(HEALTH_LOG, "a") as f:
        f.write(json.dumps(report) + "\n")

    # TODO (Section 6): If anything is CRITICAL, send Telegram alert

if __name__ == "__main__":
    main()
```

---

## 9. Directory Structure (This Section's Contribution)

```
~/Playful Sincerity/PS Software/The Companion/
  scripts/
    companion-ctl.sh          # Start/stop/restart/status all services
    kill-switch.sh             # Emergency kill and revive
    install-services.sh        # Deploy plists to ~/Library/LaunchAgents/
    verify-pmset.sh            # Check power management settings
    thermal-monitor.sh         # Root-level thermal sampling
  plists/
    com.companion.health.plist
    com.companion.logrotate.plist
    com.companion.thermal.plist  # (deployed to /Library/LaunchDaemons/)
    template.plist              # Template for other sections
  logs/                         # All service logs land here
    .gitkeep
  src/
    health/
      companion_health.py       # Health check script
```

---

## 10. Implementation Order

1. **Power management** — Set all pmset flags. Verify. Test clamshell behavior.
2. **SSH setup** — Enable sshd, harden config, test key-based access from another machine.
3. **Directory structure** — Create `scripts/`, `plists/`, `logs/`, skeleton files.
4. **Thermal monitor** — Write script, create LaunchDaemon plist, test temperature reading.
5. **Health monitor** — Write health check script, create LaunchAgent plist.
6. **companion-ctl** — Write the control script, test load/unload.
7. **Kill switch** — Write kill/revive script, test.
8. **Log rotation** — Configure newsyslog or write rotation script.
9. **Auto-login** — Configure, test full reboot cycle (machine restarts, auto-logs in, services start).
10. **Burn-in test** — Run health monitor and thermal monitor for 24 hours with lid closed, verify stability.

---

## Open Questions

1. **Clamshell without external display**: Does `pmset sleep 0` alone keep the machine awake with lid closed on Apple Silicon? If not, which lightweight workaround is best — Amphetamine, a dummy HDMI plug, or a Bluetooth device pairing trick? This must be tested empirically during implementation.

2. **Thermal monitoring tool choice**: `powermetrics` requires root. Is there a reliable non-root alternative for reading CPU die temperature on M2 Apple Silicon? If not, the root LaunchDaemon approach is fine but adds a privileged process.

3. **Auto-login security tradeoff**: Enabling auto-login means anyone with physical access to the machine gets a logged-in session. Acceptable for a machine in Wisdom's home? If not, we need an alternative approach to starting LaunchAgents without a user session (LaunchDaemons running as the user, or a login hook).

4. **Tailscale for remote SSH**: Should we set up Tailscale now (Section 1) or defer to Section 8 (Security)? It affects SSH configuration. Recommend: install in Section 1, configure access policy in Section 8.

5. **SSD wear from swap**: With 8GB RAM and multiple processes, macOS will swap. Should we add swap monitoring to health checks and set thresholds for when to reduce process count? Recommend: yes, monitor swap usage and alert if sustained > 2GB.
