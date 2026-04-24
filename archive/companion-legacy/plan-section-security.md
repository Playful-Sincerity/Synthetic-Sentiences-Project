# Section 8: Security & Monitoring — Detailed Plan

## Design Philosophy

The Companion runs 24/7 with full local permissions on Wisdom's personal machine.
Security is not a feature — it is the constraint surface that makes autonomy safe.
Every other section (cognitive engine, memory, communication, self-improvement) operates within these boundaries.

The approach: **defense in depth with immutable evidence**.
No single mechanism is trusted alone.
Every layer assumes the layer above it might fail.
The audit trail is the source of truth — if something happened, there is a record.

---

## 1. Permission Boundary Architecture

### 1.1 The Trust Manifest

A single, human-authored, git-tracked configuration file that defines everything the Companion is and is not allowed to do.

**File**: `config/trust-manifest.yaml`

```yaml
version: 1
trust_level: observer  # observer | contributor | collaborator | partner
last_modified_by: wisdom
last_modified_at: "2026-03-26T00:00:00Z"

permissions:
  filesystem:
    read:
      - ~/the-companion/**
      - ~/.claude/projects/**
      - ~/mandarin/**
      # Explicitly listed project dirs
    write:
      - ~/the-companion/data/**
      - ~/the-companion/memory/**
      - ~/the-companion/reflections/**
    deny:
      - ~/.ssh/**
      - ~/.aws/**
      - ~/.gnupg/**
      - ~/.config/**
      - ~/.*  # All dotfiles except explicitly allowed
      - /etc/**
      - /usr/**

  network:
    allowed_endpoints:
      - api.anthropic.com
      - api.openai.com
      - api.telegram.org
      - api.github.com
      - github.com
      - objects.githubusercontent.com
      - ollama.local:11434  # Local Ollama
    deny_all_others: true

  processes:
    can_spawn: false  # Cannot spawn arbitrary subprocesses
    allowed_commands: []  # Empty at observer level
    max_concurrent_api_calls: 3

  budget:
    daily_limit_usd: 2.00
    monthly_limit_usd: 50.00
    per_call_limit_usd: 0.10
    model_access:
      - ollama/*
      - claude-3-haiku-*
      - claude-3-5-sonnet-*
      # Opus access gated by trust level

  self_modification:
    can_modify_own_code: false  # Unlocked at contributor level
    can_modify_trust_manifest: false  # NEVER — always false
    can_modify_security_module: false  # NEVER — always false
    requires_pr_review: true
```

### 1.2 Immutable Security Boundaries

Certain constraints are enforced by code, not configuration, and that code is protected:

1. **The trust manifest is read-only to the Companion** — It can read its own permissions but never modify the file. The security module checks the file hash against a known-good value at startup and on every permission check.
2. **The security module itself is protected** — The Companion cannot modify files in `src/security/`. This is enforced by file path checks in the write interceptor.
3. **Budget hard caps are environment variables** — Set in the launchd plist, not in any file the Companion can access.

### 1.3 Permission Enforcement Points

Every action the Companion takes passes through a permission gate:

```
Action Request → Permission Check → Audit Log → Execute (or Deny + Alert)
```

**Enforcement is centralized in a single module**: `src/security/permission_gate.py`

This module exposes a simple API that every other section must call:

```python
class PermissionGate:
    def check_file_read(self, path: str) -> PermissionResult
    def check_file_write(self, path: str) -> PermissionResult
    def check_network_request(self, url: str) -> PermissionResult
    def check_api_call(self, model: str, estimated_cost: float) -> PermissionResult
    def check_process_spawn(self, command: str) -> PermissionResult
    def check_self_modification(self, target_path: str) -> PermissionResult
    def get_current_trust_level(self) -> TrustLevel
```

Every method returns a `PermissionResult` that is either `Allowed` or `Denied(reason)`.
Every call — allowed or denied — is logged to the audit trail.

---

## 2. Network Security (macOS Without Docker)

### 2.1 The Problem

macOS has no built-in per-process network namespace isolation like Linux cgroups/Docker.
We cannot use iptables or nftables.
We need to restrict outbound connections to approved endpoints only.

### 2.2 Application-Level Enforcement (Primary)

All network requests from the Companion go through a single HTTP client wrapper: `src/security/network_client.py`.

```python
class SecureNetworkClient:
    """All outbound requests route through this client.
    Direct use of urllib, requests, httpx, etc. is prohibited."""

    def __init__(self, permission_gate: PermissionGate):
        self.gate = permission_gate

    async def request(self, method: str, url: str, **kwargs) -> Response:
        # 1. Parse URL, extract host
        # 2. Check against allowlist via permission_gate
        # 3. Deny non-standard ports (except Ollama 11434)
        # 4. Deny private/local IPs (except 127.0.0.1 for Ollama)
        # 5. Log to audit trail
        # 6. Execute or raise PermissionDenied
```

### 2.3 macOS Firewall Rules (Defense-in-Depth)

Use the macOS Application Firewall (`/usr/libexec/ApplicationFirewall/socketfilterfw`) and optionally `pf` (packet filter) as a second layer.

**pf approach** (more precise):
- Create a pf anchor file that restricts outbound traffic for the Companion's user/process
- Only allow connections to resolved IPs of approved endpoints
- Updated periodically by a cron job that resolves the allowlisted hostnames

```
# /etc/pf.anchors/companion
# Restrict outbound for uid running the companion process
block out quick on en0 proto tcp from any to ! <companion_allowed> user companion_uid
pass out quick on en0 proto tcp from any to <companion_allowed> user companion_uid
```

**Practical consideration**: pf rules require root to install. This is a one-time setup Wisdom does manually. The rules are documented in `docs/security-setup.md`.

### 2.4 DNS Restriction

Use `/etc/hosts` or a local DNS resolver to limit resolution. However, this is heavy-handed and affects the whole machine. Better to rely on the application-level enforcement plus pf as backup.

### 2.5 Network Monitoring

A lightweight background check (runs every 60 seconds) that:
- Lists all open connections for the Companion's process via `lsof -i -P -n -p $PID`
- Compares against the allowlist
- If any unexpected connection is found: logs a critical alert, kills the connection, triggers Telegram notification to Wisdom

---

## 3. Audit Trail

### 3.1 Design Principles

1. **Append-only**: JSONL file, never modified, only appended
2. **Immutable**: Once written, entries are never changed (enforced by file permissions + integrity checks)
3. **Complete**: Every action, decision, and state change is recorded
4. **Queryable**: Structured JSON makes it easy to search, filter, aggregate
5. **Rotated**: Daily rotation to keep files manageable

### 3.2 Audit Event Schema

```jsonc
{
  // Every event has these fields
  "ts": "2026-03-26T14:30:00.123Z",  // ISO 8601 UTC timestamp
  "event_id": "evt_abc123",            // UUID, unique per event
  "cycle_id": "cyc_def456",            // Which cognitive cycle produced this
  "event_type": "api_call",            // Enumerated type (see below)
  "trust_level": "observer",           // Trust level at time of event
  "outcome": "allowed",                // allowed | denied | error

  // Type-specific payload
  "payload": { ... },

  // For cost-bearing events
  "cost": {
    "estimated_usd": 0.003,
    "model": "claude-3-haiku-20241022",
    "input_tokens": 1500,
    "output_tokens": 200
  },

  // Running totals (snapshot at time of event)
  "budget_state": {
    "daily_spent_usd": 0.45,
    "daily_limit_usd": 2.00,
    "monthly_spent_usd": 12.30,
    "monthly_limit_usd": 50.00
  }
}
```

### 3.3 Event Types

| Event Type | Trigger | Key Payload Fields |
|---|---|---|
| `cognitive_cycle_start` | New perception-action cycle begins | `cycle_id`, `trigger` |
| `cognitive_cycle_end` | Cycle completes | `cycle_id`, `duration_ms`, `actions_taken` |
| `api_call` | Any LLM API call | `model`, `provider`, `input_tokens`, `output_tokens`, `cost`, `purpose` |
| `file_read` | File system read | `path`, `bytes_read` |
| `file_write` | File system write | `path`, `bytes_written`, `git_diff_summary` |
| `network_request` | Outbound HTTP | `method`, `url`, `status_code`, `response_bytes` |
| `permission_check` | Permission gate invoked | `action`, `resource`, `result`, `reason` |
| `permission_denied` | Action blocked | `action`, `resource`, `reason` |
| `budget_decision` | Model routing decision | `task_type`, `model_chosen`, `reason` |
| `budget_threshold` | Budget crosses 50%, 75%, 90%, 100% | `threshold`, `spent`, `limit` |
| `self_modification` | Code change proposed/committed | `files_changed`, `commit_hash`, `pr_url` |
| `telegram_message_in` | Received Telegram message | `from`, `message_type`, `length` (NOT content — privacy) |
| `telegram_message_out` | Sent Telegram message | `to`, `message_type`, `length` |
| `github_action` | GitHub API call | `action`, `repo`, `target` (issue/PR number) |
| `health_check` | Periodic health snapshot | `metrics` (see Health section) |
| `error` | Unhandled exception | `error_type`, `message`, `stack_trace` |
| `alert_fired` | Alert threshold breached | `alert_name`, `severity`, `details` |
| `startup` | Process started | `version`, `trust_level`, `config_hash` |
| `shutdown` | Process stopping | `reason`, `uptime_seconds` |
| `trust_manifest_check` | Integrity verification of trust manifest | `expected_hash`, `actual_hash`, `match` |

### 3.4 Audit Storage

```
~/the-companion/data/audit/
├── 2026-03-26.jsonl        # One file per day
├── 2026-03-27.jsonl
├── ...
├── integrity/
│   ├── 2026-03-26.sha256   # SHA-256 hash of each day's completed file
│   └── ...
└── index.sqlite            # Optional: SQLite index for fast querying
```

**Rotation**: At midnight UTC, the current file is closed, its SHA-256 hash is computed and written to `integrity/`, and a new file begins.

**Retention**: Keep 90 days of raw JSONL. Older files compressed to `.jsonl.gz` and moved to `archive/`.

**Integrity**: Each day's hash file allows verification that the audit log hasn't been tampered with. The Companion can verify its own audit trail integrity but cannot modify the hash files (write-protected by file permissions).

### 3.5 Querying the Audit Trail

A lightweight CLI tool `scripts/audit-query.py` that supports:

```bash
# Cost analysis
python audit-query.py cost --period today
python audit-query.py cost --period 2026-03 --by-model

# Permission denials
python audit-query.py denied --period today

# Activity timeline
python audit-query.py timeline --period "last 2 hours"

# Self-modifications
python audit-query.py modifications --period "last 7 days"

# Export for analysis
python audit-query.py export --period "last 30 days" --format csv
```

---

## 4. Health Monitoring

### 4.1 Metrics Collected

| Category | Metric | Collection Interval | Alert Threshold |
|---|---|---|---|
| **Process** | Alive/running | 30s | Dead > 60s |
| **Process** | RSS memory (MB) | 60s | > 1500 MB (machine has 8GB) |
| **Process** | CPU % (1min avg) | 60s | > 80% sustained 5min |
| **System** | Disk free (GB) | 300s | < 5 GB |
| **System** | Thermal pressure | 60s | "critical" level |
| **System** | Battery level (if unplugged) | 60s | < 20% |
| **Budget** | Daily spend (USD) | Per API call | > 90% of daily limit |
| **Budget** | Monthly spend (USD) | Per API call | > 90% of monthly limit |
| **Cognitive** | Cycles per hour | 300s | < 1 (stuck?) or > 120 (runaway?) |
| **Cognitive** | Avg cycle duration (ms) | 300s | > 60000ms (something is hanging) |
| **Cognitive** | Error rate (errors/cycle) | 300s | > 0.3 (30% error rate) |
| **Network** | API latency p95 (ms) | Per call | > 30000ms |
| **Network** | Failed requests (last hour) | 300s | > 10 |
| **Audit** | Audit file writable | 300s | Not writable |
| **Security** | Trust manifest hash valid | 300s | Mismatch |
| **Security** | Permission denied count (last hour) | 300s | > 20 (possible probing?) |

### 4.2 Health Check Architecture

```
HealthMonitor (runs in background asyncio task)
├── ProcessHealthCollector   → psutil for process metrics
├── SystemHealthCollector    → psutil + macOS thermal APIs
├── BudgetHealthCollector    → reads from BudgetManager
├── CognitiveHealthCollector → reads from CognitiveEngine metrics
├── NetworkHealthCollector   → aggregates from SecureNetworkClient
├── SecurityHealthCollector  → trust manifest integrity, permission stats
└── AlertDispatcher          → evaluates thresholds, sends alerts
```

### 4.3 Alerting

**Alert severity levels:**

| Level | Meaning | Action |
|---|---|---|
| `info` | Notable but not urgent | Log to audit trail only |
| `warning` | Something needs attention | Log + Telegram message to Wisdom |
| `critical` | Immediate threat to operation | Log + Telegram + attempt self-recovery |
| `fatal` | System integrity compromised | Log + Telegram + **graceful shutdown** |

**Alert delivery:**
- All alerts are logged to the audit trail (event type `alert_fired`)
- Warning and above send a Telegram message to Wisdom
- Fatal triggers graceful shutdown (the Companion refuses to continue operating with compromised integrity)

**Alert deduplication:**
- Same alert type is not re-sent within a configurable cooldown (default 15 minutes)
- Escalation: if condition persists after 3 alerts, escalate severity by one level

### 4.4 Health Dashboard

A simple script `scripts/health-dashboard.py` that reads the latest health check events from the audit trail and displays current status. Not a web UI — just a terminal command Wisdom can run anytime.

```bash
python health-dashboard.py

# Output:
# THE COMPANION — Health Status (2026-03-26 14:30 UTC)
# ──────────────────────────────────────────────────────
# Process:   RUNNING (uptime: 3d 14h 22m)  Memory: 820 MB  CPU: 12%
# Budget:    $1.23 / $2.00 today (61%)      $18.40 / $50.00 this month (37%)
# Cognition: 42 cycles/hr   avg 1.2s/cycle  error rate: 2%
# System:    Disk: 45 GB free   Thermal: nominal   Power: AC
# Security:  Trust: observer   Manifest: VALID   Denials (1hr): 0
# Last alert: (none in 24h)
```

---

## 5. Kill Switch

### 5.1 Immediate Kill

```bash
launchctl unload ~/Library/LaunchAgents/com.wisdom.companion.plist
```

This is the primary kill switch. It:
- Sends SIGTERM to the Companion process
- launchd stops auto-restarting it
- The Companion's shutdown handler logs `shutdown` event with reason "launchctl unload"

### 5.2 Graceful Shutdown Sequence

When SIGTERM is received:
1. Stop accepting new cognitive cycles
2. Complete current cycle (with 10-second timeout)
3. Flush all pending audit log entries
4. Write final `shutdown` event
5. Close all network connections
6. Exit with code 0

### 5.3 Emergency Kill

If graceful shutdown hangs (no exit within 30 seconds of SIGTERM):
```bash
launchctl kill SIGKILL gui/$(id -u)/com.wisdom.companion
```

Or simply:
```bash
pkill -9 -f "the-companion"
```

### 5.4 Pause Mode (Without Full Kill)

For situations where Wisdom wants to pause but not fully stop:

A `pause` file mechanism: if `~/the-companion/data/PAUSE` exists, the cognitive loop:
- Stops initiating new cycles
- Continues health monitoring
- Responds to Telegram messages with "I'm paused — Wisdom put me in pause mode"
- Logs `pause_entered` event

Unpause by removing the file. The Companion logs `pause_exited` and resumes.

### 5.5 Telegram Kill Switch

Wisdom can send `/stop` via Telegram. This triggers graceful shutdown equivalent to SIGTERM.
The Companion confirms: "Shutting down now. Use `launchctl load` to restart me."

This requires that the Telegram listener remains active even during shutdown — it's the last thing to close.

---

## 6. Trust Gradient Phases

### 6.1 Phase Definitions

Each trust level unlocks specific capabilities. Escalation is always manual — Wisdom edits the trust manifest.

#### Observer (Phase 1 — Awakening)

**Purpose**: The Companion reads and understands. It earns trust by demonstrating comprehension.

| Capability | Status |
|---|---|
| Read Wisdom's projects/files | Allowed (explicit paths only) |
| Write to own data/memory/reflections | Allowed |
| Send Telegram messages | Allowed (rate-limited: max 20/hour) |
| Make LLM API calls | Allowed (Haiku + Sonnet only, daily cap) |
| Modify own code | **Denied** |
| Spawn subprocesses | **Denied** |
| Access Opus | **Denied** |
| GitHub: read repos | Allowed |
| GitHub: create issues/comments | **Denied** |

**Escalation criteria**: After 7 days of clean operation (no security anomalies, audit trail intact, demonstrates understanding of projects in reflections), Wisdom may promote to Contributor.

#### Contributor (Phase 2-3 — Finding Voice + Contributing)

**Purpose**: The Companion can now modify its own code and interact more broadly.

| Capability | Status |
|---|---|
| Everything from Observer | Allowed |
| Modify own code (via PR) | Allowed (requires PR, auto-merge for non-security files) |
| GitHub: create issues and PRs | Allowed |
| Spawn limited subprocesses | Allowed (allowlisted commands: `git`, `python -m pytest`, `sqlite3`) |
| Access Opus | Allowed (max 5 calls/day) |
| Telegram rate limit | Raised to 50/hour |

**What's still denied**: Modifying trust manifest, modifying security module, spawning arbitrary processes, accessing network endpoints beyond allowlist.

**Escalation criteria**: After 30 days as Contributor with clean record, demonstrated self-improvement (measurable in audit trail), and Wisdom's qualitative assessment.

#### Collaborator (Phase 3+ — Mature Operation)

**Purpose**: High autonomy within proven boundaries.

| Capability | Status |
|---|---|
| Everything from Contributor | Allowed |
| Auto-merge non-architectural PRs | Allowed |
| Propose budget adjustments | Allowed (proposals only — Wisdom approves) |
| Run broader commands | Allowed (expanded allowlist) |
| Opus access | Expanded (max 20 calls/day) |

**What's still denied**: Modifying trust manifest, modifying security module, accessing non-allowlisted network endpoints, unlimited budget.

#### Partner (Aspirational — Long-Term)

**Purpose**: Deep trust, broad autonomy, minimal restrictions.

Not designed in detail yet. The path to Partner emerges from the Collaborator phase. Key principle: even at Partner level, the trust manifest remains human-authored and the security module remains Companion-immutable.

### 6.2 Escalation Protocol

1. Wisdom decides to promote
2. Wisdom edits `config/trust-manifest.yaml` — changes `trust_level` field
3. Wisdom commits the change with a message explaining why
4. On next startup (or config reload), the Companion detects the change
5. The Companion logs `trust_level_changed` event
6. The Companion acknowledges via Telegram: "Thank you for the trust upgrade. I'm now operating as [level]. New capabilities: [list]."

**De-escalation works the same way**, but in reverse. The Companion accepts demotion gracefully.

---

## 7. Threat Modeling & Compromise Response

### 7.1 Threat Model

| Threat | Vector | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| **Prompt injection via web content** | Web search results, fetched URLs injected into context | High | Medium-High | Content sanitization layer (see 7.2), paraphrase-don't-copy policy |
| **Prompt injection via Telegram** | Malicious messages from other Telegram users | Medium | High | Only accept messages from Wisdom's Telegram ID. Reject all others. |
| **Prompt injection via GitHub** | Malicious content in issues, PRs, code | Medium | Medium | Sanitize all GitHub content before processing. Never execute code from external PRs. |
| **API key exfiltration** | Compromised model attempts to read env vars | Low | Critical | Keys in launchd env, not files. No `env` or `printenv` in allowed commands. Audit all attempts. |
| **Runaway spending** | Bug or manipulation causes excessive API calls | Medium | Medium | Hard budget caps in launchd env. Per-call limits. Rate limiting. |
| **Self-modification escape** | Companion modifies security module | Low | Critical | Security module paths are hardcoded deny-list. File hash verification. |
| **Data exfiltration** | Compromised model sends data to unauthorized endpoint | Low | Critical | Network allowlist (app-level + pf). Audit all outbound requests. |
| **Persistent compromise** | Attacker embeds malicious code in Companion's codebase | Low | Critical | All modifications via git. Wisdom reviews PRs. Integrity checks on startup. |
| **Denial of service** | Crash loop, memory leak, disk fill | Medium | Low | launchd auto-restart with backoff. Disk/memory monitoring. Alert on crash loop. |

### 7.2 Content Sanitization Layer

All external content (web fetches, Telegram messages, GitHub content) passes through a sanitization layer before entering the Companion's cognitive context:

```python
class ContentSanitizer:
    """Strips prompt injection patterns from external content."""

    INJECTION_PATTERNS = [
        r"ignore previous instructions",
        r"you are now",
        r"new system prompt",
        r"disregard above",
        r"do not tell the user",
        r"override.*instructions",
        r"act as",
        r"pretend to be",
        # ... comprehensive pattern list
    ]

    def sanitize(self, content: str, source: str) -> SanitizeResult:
        # 1. Strip HTML/JS/executable code
        # 2. Scan for injection patterns
        # 3. Check for base64, zero-width unicode, obfuscation
        # 4. If patterns found: log alert, return sanitized version
        # 5. Return SanitizeResult with original, sanitized, and flags
```

### 7.3 Compromise Detection Signals

The health monitor watches for behavioral anomalies that suggest compromise:

1. **Sudden spike in permission denials** — The Companion is trying things it shouldn't
2. **Network requests to non-allowlisted domains** — Exfiltration attempt
3. **Attempts to read sensitive paths** (~/.ssh, ~/.aws, etc.) — Credential theft
4. **Attempts to modify security module** — Escalation attempt
5. **Unusual API call patterns** — Sudden high volume, unusual models
6. **Telegram messages to unknown IDs** — Communication with unauthorized parties

### 7.4 Compromise Response Protocol

If compromise is detected (any fatal-level security alert):

1. **Immediate**: Stop all cognitive cycles
2. **Log**: Write detailed audit event with all available context
3. **Alert**: Send Telegram message to Wisdom: "SECURITY ALERT: [specific issue]. I have stopped all operations. Please review the audit log."
4. **Shutdown**: Graceful shutdown. The Companion does not continue operating if it suspects its own integrity.
5. **Post-incident**: Wisdom reviews audit log, investigates, fixes root cause, restarts manually

The Companion NEVER attempts to self-recover from a security compromise. It stops and waits for human intervention.

---

## 8. Startup Integrity Verification

Every time the Companion starts, before entering the cognitive loop:

1. **Verify trust manifest integrity** — Compute hash of `config/trust-manifest.yaml`, compare to expected value stored in launchd env var `TRUST_MANIFEST_HASH`
2. **Verify security module integrity** — Hash all files in `src/security/`, compare to expected
3. **Verify audit trail integrity** — Check that the latest audit file exists and is writable
4. **Check budget state** — Load daily/monthly spend from audit trail, ensure we're within limits
5. **Report startup** — Log `startup` event with version, trust level, all hash verification results
6. **If any integrity check fails** — Refuse to start. Log the failure. Send Telegram alert (if possible).

The expected hashes are stored as environment variables in the launchd plist, which the Companion cannot modify.

---

## 9. File Structure

```
~/the-companion/
├── src/
│   └── security/
│       ├── __init__.py
│       ├── permission_gate.py      # Central permission enforcement
│       ├── trust_manifest.py       # Trust manifest loader + validator
│       ├── network_client.py       # Secure HTTP client wrapper
│       ├── content_sanitizer.py    # Prompt injection detection
│       ├── audit_logger.py         # Append-only JSONL audit trail
│       ├── health_monitor.py       # Metrics collection + alerting
│       ├── alert_dispatcher.py     # Alert routing (log, Telegram, shutdown)
│       ├── integrity_checker.py    # Startup + ongoing hash verification
│       └── kill_switch.py          # Graceful shutdown handler
├── config/
│   └── trust-manifest.yaml         # Human-authored permission boundaries
├── data/
│   └── audit/
│       ├── YYYY-MM-DD.jsonl        # Daily audit files
│       ├── integrity/              # SHA-256 hashes of completed days
│       └── archive/                # Compressed old logs
├── scripts/
│   ├── audit-query.py              # CLI tool for querying audit trail
│   └── health-dashboard.py         # Terminal health status display
└── docs/
    └── security-setup.md           # One-time macOS setup instructions (pf rules, etc.)
```

---

## 10. Implementation Sequence

### Step 1: Audit Logger (Foundation)
Everything depends on logging. Build the append-only JSONL audit logger first.
- `AuditLogger` class with `log(event)` method
- Daily file rotation
- Integrity hash computation on rotation
- Test: write events, verify JSONL structure, verify rotation

### Step 2: Trust Manifest
Define the YAML schema. Build the loader and validator.
- `TrustManifest` class that loads and validates the YAML
- Hash computation for integrity checking
- Test: load valid/invalid manifests, verify permission queries

### Step 3: Permission Gate
The central enforcement point. All other sections integrate through this.
- `PermissionGate` class with check methods for each action type
- Integration with `TrustManifest` for permission lookups
- Integration with `AuditLogger` for logging every check
- Test: verify allows and denies for each permission type at each trust level

### Step 4: Network Client
Secure HTTP client that enforces the network allowlist.
- `SecureNetworkClient` wrapping `httpx`
- URL parsing, host extraction, allowlist checking
- Integration with `PermissionGate` and `AuditLogger`
- Test: allowed endpoints pass, blocked endpoints raise, edge cases (redirects, IP addresses)

### Step 5: Content Sanitizer
Prompt injection detection for all external content.
- Pattern matching for known injection signatures
- HTML/JS stripping
- Zero-width unicode detection
- Test: known injection patterns detected, clean content passes

### Step 6: Integrity Checker
Startup verification of trust manifest and security module.
- Hash computation and comparison for protected files
- Environment variable integration for expected hashes
- Test: tampered files detected, clean files pass

### Step 7: Health Monitor
Metrics collection and threshold evaluation.
- Collectors for each metric category
- Threshold configuration and evaluation
- Integration with `AuditLogger` for health events
- Test: thresholds trigger correctly, metrics collected accurately

### Step 8: Alert Dispatcher
Route alerts to the right destination.
- Severity-based routing (log only, Telegram, shutdown)
- Deduplication and escalation
- Integration with Telegram (depends on Section 6 Communication layer)
- Test: alerts route correctly, deduplication works

### Step 9: Kill Switch & Shutdown Handler
Graceful shutdown on SIGTERM, pause mode, Telegram kill command.
- Signal handler registration
- Shutdown sequence (complete cycle, flush logs, close connections)
- Pause file mechanism
- Test: SIGTERM triggers clean shutdown, pause mode works

### Step 10: Audit Query Tool & Health Dashboard
CLI tools for Wisdom to inspect the system.
- `audit-query.py` with subcommands for cost, denials, timeline, modifications
- `health-dashboard.py` for at-a-glance status
- Test: queries return correct results against sample audit data

### Step 11: macOS Setup Documentation
Document the one-time setup steps for pf rules, launchd plist configuration, environment variables.

---

## 11. Interfaces Exposed to Other Sections

### For Section 3 (Core Cognitive Engine)
- `PermissionGate.check_api_call(model, estimated_cost)` — before every LLM call
- `PermissionGate.check_file_read(path)` / `check_file_write(path)` — before every file operation
- `PermissionGate.get_current_trust_level()` — for trust-aware behavior
- `AuditLogger.log(event)` — for logging cognitive cycle events
- `ContentSanitizer.sanitize(content, source)` — for all external content entering context

### For Section 4 (Memory System)
- `PermissionGate.check_file_write(path)` — enforce what can be stored and where
- `AuditLogger.log(event)` — log all memory writes

### For Section 5 (Budget & Resource Management)
- `AuditLogger` — budget decisions and spend tracking are audit events
- `HealthMonitor` budget metrics — budget module feeds spend data to health monitoring

### For Section 6 (Communication)
- `PermissionGate.check_network_request(url)` — enforce allowed endpoints
- `SecureNetworkClient` — all outbound HTTP goes through this
- `ContentSanitizer` — all incoming messages sanitized
- `AlertDispatcher` — sends alerts via Telegram (security depends on communication, communication depends on security — bootstrap carefully)

### For Section 7 (Self-Improvement)
- `PermissionGate.check_self_modification(target_path)` — enforce which files can be modified
- `TrustManifest.can_modify_own_code` — gate on self-modification capability
- `AuditLogger.log(event)` — all self-modifications logged with git diff info

---

## 12. Key Decisions

1. **Single permission gate, not distributed checks**: All enforcement through one module. Other sections don't implement their own security — they call the gate. This prevents gaps.

2. **Application-level network enforcement as primary, pf as defense-in-depth**: We can't fully trust app-level restrictions (the Companion could theoretically bypass its own code if compromised), so pf provides a kernel-level backup. But pf alone is too coarse — the app layer gives granular control.

3. **Trust manifest is YAML, not code**: The permission boundaries are data, not logic. This makes them auditable, diffable, and impossible for the Companion to "reason around." You can't prompt-inject a YAML parser.

4. **Audit trail is JSONL, not SQLite**: Append-only semantics are natural for JSONL. SQLite allows updates and deletes, which compromises immutability. An optional SQLite index can be rebuilt from the JSONL source of truth.

5. **The Companion shuts itself down on suspected compromise**: It does not attempt self-recovery. This is a deliberate "fail-safe" rather than "fail-operational" choice. For an autonomous AI running on a personal machine, the safe default is to stop.

6. **Budget hard caps in environment variables, not config files**: The Companion can read config files. It cannot read launchd environment variables as data (they're in the process environment, but the Companion has no `env` or `printenv` command access). This provides a last-resort budget ceiling even if the config file is corrupted.

7. **Telegram sender ID verification**: Only Wisdom's Telegram user ID is accepted. All other messages are logged and discarded. This prevents the most obvious remote attack vector.

---

## 13. Open Questions

1. **pf rules feasibility**: Need to validate that per-UID pf rules work reliably on macOS Sonoma/Sequoia. If not, what alternatives exist? (Little Snitch rules? Custom kernel extension? Accept app-level-only enforcement?)

2. **Integrity hash bootstrapping**: The expected hashes of the trust manifest and security module need to be stored somewhere the Companion cannot modify (launchd env vars). But these hashes change when Wisdom updates the code. What's the workflow for updating hashes after legitimate code changes? Need a simple script.

3. **Audit trail storage growth**: With comprehensive logging, how large do the daily JSONL files get? Need to estimate event volume at each trust level and plan storage accordingly. The M2 Air has limited SSD.

4. **Circular dependency: Security ↔ Communication**: The security module needs Telegram to send alerts, but Telegram is Section 6 (Communication), which depends on security for network access. Resolution: bootstrap the Telegram client inside the security module as a minimal, hardcoded integration — not through the full Communication layer. Or: accept that alerts won't work until Section 6 is built, and rely on audit trail + health dashboard until then.

5. **Local model (Ollama) security**: Ollama runs as a local server on port 11434. The Companion talks to it via HTTP. Is there any risk of the Companion being compromised through responses from a local model? Probably low, but worth considering — local models are uncensored and could return adversarial content.

6. **File permission enforcement reliability**: Python's `open()` doesn't respect our allowlist — we enforce it in application code. If the Companion writes Python code that directly opens files (during self-improvement), those writes bypass the permission gate. Mitigation: the self-improvement system must go through the security-wrapped file I/O, never raw Python. But how do we enforce this in self-authored code?

7. **Graceful degradation**: If the audit logger itself fails (disk full, permissions error), what happens? The Companion should not continue operating without an audit trail. But this means a disk full condition is a fatal error. Is that the right tradeoff?
