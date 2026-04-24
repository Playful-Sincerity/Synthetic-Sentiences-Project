# Plan Reconciliation Report
**Reconciler run:** 2026-03-26
**Files read:** plan.md + 10 section plans
**Status:** MINOR FIXES required before implementation

---

## Executive Summary

The plan is coherent and well-integrated overall.
The cognitive science grounding is genuine and architecturally consistent across sections.
The main issues are a cluster of interface mismatches (two cognitive engine files with divergent component naming), one budget arithmetic problem, a circular dependency that needs a bootstrap sequence, and several open questions that only Wisdom can answer.
Nothing here is a fundamental design flaw — but two issues (dual cognitive sections, kill switch plist naming) need resolution before any code is written.

---

## 1. Conflicts Found

### CONFLICT C1 — Two Cognitive Engine Plans With Divergent Architectures (HIGH)

**Files:** `plan-section-cognitive.md` vs `plan-section-cognitive-engine.md`

Two separate, detailed section plans exist for Section 3.
They describe the same system but use different naming and slightly different component structures.

| Aspect | plan-section-cognitive.md | plan-section-cognitive-engine.md |
|--------|--------------------------|----------------------------------|
| Input queue name | `EventBus` | `PerceptionBuffer` |
| Filter component name | `SalienceFilter` | `SalienceScorer` (as a sub-component of ATTEND) |
| Stage count | 8 (Perceive → Attend → Contextualize → Deliberate → Reason → Act → Reflect → Consolidate) | 4 primary (Perceive → Attend → Reason → Act) + background (Monitor, Reflect, Sleep) |
| Salience dimensions | 6 (Novelty, Relevance, Urgency, Prediction error, Emotional weight, Source authority) | 5 (Urgency, Relevance, Novelty, Emotional weight, Cost of ignoring) |
| ContextAssembler budget (Sonnet) | Identity ~2,500t / Memory ~1,000t / Task ~5,000t | Identity ~3,000t / Memory up to 40,000t |
| Thermal fallback | Local model → Haiku (same logic) | Local model → Haiku (same logic) — consistent |

**Resolution needed:** Designate one file as authoritative and archive the other.
Recommendation: `plan-section-cognitive.md` has the more detailed 8-stage model and the richer component specifications. Adopt its naming convention. The cognitive-engine file's data-structure detail for `Perception` (with `requires_response`, `response_deadline`) is valuable and should be absorbed.

### CONFLICT C2 — Kill Switch Plist Label Inconsistency (MEDIUM)

**Files:** `plan-section-hardware.md` vs `plan-section-security.md`

Section 1 (Hardware) defines the main kill switch as:
```
launchctl unload ~/Library/LaunchAgents/com.companion.SERVICENAME.plist
```
And uses the label pattern `com.companion.*`

Section 8 (Security) documents the kill switch command as:
```
launchctl unload ~/Library/LaunchAgents/com.wisdom.companion.plist
```
And uses label `com.wisdom.companion`.

These are incompatible. Only one naming convention can exist.

**Resolution needed:** Pick one. Recommend `com.companion.*` (Section 1's convention) as it is more extensively specified and used throughout the codebase blueprint. Section 8 must update its kill switch docs.

### CONFLICT C3 — Budget Hard Cap Location: Two Sources of Truth (MEDIUM)

**Files:** `plan-section-budget.md` vs `plan-section-security.md`

Section 5 (Budget) states: "Hard caps (in launchd env vars, per Section 8) override all of the above."
Section 8 (Security) states: "Budget hard caps are environment variables — Set in the launchd plist."
Section 8 also states: budget limits appear in `config/trust-manifest.yaml` as:
```yaml
budget:
  daily_limit_usd: 2.00
  monthly_limit_usd: 50.00
  per_call_limit_usd: 0.10
```

**The conflict:** Section 5's routing algorithm reads `budget_state.daily_limit_usd` (which could come from the trust manifest, since that's where it's defined). Section 8 says the real ceiling is in launchd env vars. But the Companion reads the trust manifest — it cannot read launchd env vars as data.

If the trust manifest says $2.00/day and the launchd env var says $3.00/day, which governs?
If someone edits the trust manifest to say $10.00/day but the env var remains $3.00, the Companion would think it has $10.00 but get hard-stopped at $3.00.

**Resolution needed:** Decide definitively: is the trust manifest budget the operational limit, and the launchd env var an absolute backstop? Or does one entirely replace the other? Recommend: trust manifest sets operational limits (read by the Companion); launchd env vars set absolute backstop (enforced by the `PermissionGate` via a separate check). Document this two-tier structure explicitly. The current docs imply it but don't state it clearly.

### CONFLICT C4 — Telegram Library Choice vs Security Architecture (MEDIUM)

**Files:** `plan-section-communication.md` vs `plan-section-security.md`

Section 6 (Communication) states: "Preference: raw `httpx` through SecureNetworkClient" and explicitly rejects `python-telegram-bot` because it bypasses the security client.

Section 8 (Security) specifies that all HTTP goes through `SecureNetworkClient` but doesn't explicitly acknowledge this constraint on third-party libraries.

No direct conflict in stated policy — both agree all HTTP must go through the secure client — but the implementation consequence is significant: the Companion cannot use standard Telegram libraries. This creates a non-trivial build burden (implementing the Telegram Bot API from scratch against the secure client) that should be flagged as an architectural cost, not just a library preference.

**Resolution needed:** Not a showstopper, but formally acknowledge in both sections that third-party network libraries are prohibited and the implementation must build thin wrappers over `SecureNetworkClient`. This affects GitHub integration (Section 6, Channel 3) as well.

---

## 2. Unmet Dependencies

### DEP U1 — Cognitive Engine Loads Identity Files: No Token Count Validation (MEDIUM)

**Consumer:** Section 3 (Cognitive Engine) — ContextAssembler
**Provider:** Section 2 (Identity)

Section 3 specifies identity token budgets:
- Local: 500 tokens
- Haiku: 1,500 tokens
- Sonnet: 2,500–3,000 tokens
- Opus: 5,000 tokens (all six files)

Section 2 specifies that the full identity is six files (SOUL.md, CHARACTER.md, VOICE.md, BOUNDARIES.md, WISDOM-MODEL.md, SELF-MODEL.md) but gives no estimate of their actual token count once written.

Section 2 states the concern: "The full identity (six files) might be 3,000-5,000 tokens."

**Potential break:** If the full identity exceeds 5,000 tokens, the Opus tier is already over-budget. If it exceeds 3,000 tokens, the Sonnet tier is over-budget. The compressed tiers (500t, 1,500t) must be pre-tested to verify they preserve personality coherence — this is Section 2's responsibility but Section 3 depends on it.

**Action required:** Before writing identity files, define maximum line counts for each file to stay within the token budget commitments. Section 2 should add a "token budget target" to each file's specification.

### DEP U2 — Section 6 Needs ContentSanitizer Before Section 8 Can Deliver It (MEDIUM)

**Consumer:** Section 6 (Communication)
**Provider:** Section 8 (Security)

Section 6 specifies: "All inbound messages pass through ContentSanitizer before reaching the cognitive engine."
Section 8 specifies building ContentSanitizer in Step 5 of its implementation sequence (after AuditLogger, TrustManifest, PermissionGate, and NetworkClient).

No conflict — this is correctly ordered. But Section 6 cannot be meaningfully tested until Section 8's Step 5 is done. The dependency is undocumented in Section 6's own dependency list.

**Action required:** Section 6 should explicitly list `ContentSanitizer` from Section 8 as a hard dependency. The integration test for Telegram inbound cannot pass without it.

### DEP U3 — Section 7 Assumes SQLite Audit Index That Section 8 Treats as Optional (LOW)

**Consumer:** Section 7 (Self-Improvement) — Session Log Mining
**Provider:** Section 8 (Security) — Audit Trail

Section 7 states: "Most mining queries are SQL against the audit trail SQLite index (Section 8 provides this)."

Section 8 states: `index.sqlite` is an "Optional" SQLite index for fast querying, noting it "can be rebuilt from the JSONL source of truth."

**The gap:** Section 7 treats this SQLite index as essential infrastructure. Section 8 treats it as optional. If Section 8 is built without the SQLite index (using only JSONL), Section 7's mining queries have no data source.

**Action required:** Section 8 must commit to building the SQLite audit index. It is not optional given Section 7's dependency on it.

### DEP U4 — Memory Section Uses "Section 5" Reference for Consolidation Cycles (LOW)

**Consumer:** Section 4 (Memory)
**Provider:** Section 3 (Cognitive Engine)

Section 4 states: "Semantic memory is NOT written during normal cognitive cycles. It is updated only during consolidation cycles (see Section 5 below)." But Section 4 has no "Section 5" within it — the consolidation cycle specification appears to be in Section 4 itself (or in Section 7's reflection loop). This is likely a drafting artifact (internal section numbering confusion).

**Action required:** Verify and correct the cross-reference in Section 4. The consolidation cycle protocol should be specified in Section 4 (the memory section owns it) and triggered by Section 7 (the self-improvement section schedules it) and Section 3 (the cognitive engine executes it during the evening reflection phase).

---

## 3. Interface Mismatches

### IFC I1 — Memory Retrieval Interface: Protocol vs Implementation (MEDIUM)

**Consumer:** Section 3 (Cognitive Engine — ContextAssembler)
**Provider:** Section 4 (Memory System)

Section 3 defines a `MemoryRetriever` Protocol:
```python
async def retrieve_relevant(
    self,
    query: str,
    context: RetrievalContext,
    max_tokens: int,
) -> list[MemoryFragment]:
```

Section 4 does not define a corresponding Python interface or API contract. It describes the memory architecture in detail but leaves the integration point unspecified.

**Potential break:** When Section 3 and Section 4 are built by different agents/sessions, the memory retrieval implementation may not match the protocol Section 3 expects.

**Action required:** Section 4 should explicitly define the implementation of `MemoryRetriever` (or a named equivalent) as its primary interface to Section 3. The `RetrievalContext` dataclass needs definition in one section and import by the other.

### IFC I2 — Budget State Sharing: Two Sections Both "Own" Budget State (MEDIUM)

**Consumer:** Section 3 (Cognitive Engine — ModelRouter, HomeostasisMonitor)
**Provider:** Section 5 (Budget)

Section 3 (HomeostasisMonitor) specifies that it "reads metrics from other components" and monitors `daily budget spent` from `AuditLogger`.

Section 5 (Budget) specifies a `BudgetState` object that is "persisted to SQLite on every update" and maintains all derived budget metrics.

Both sections describe reading/computing budget state. This creates ambiguity: is the ModelRouter in Section 3 reading from Section 5's `BudgetState`, or from the audit trail directly?

**Action required:** Establish clear ownership. Recommendation: Section 5 owns the `BudgetState` object and exposes a read-only API. Section 3's components consume it. Section 3's HomeostasisMonitor does NOT read the audit trail for budget data — it reads Section 5's `BudgetState`. This prevents two systems maintaining separate budget tallies that can drift apart.

### IFC I3 — Telegram Process to Cognitive Engine IPC: Two Patterns Proposed (LOW)

**Consumer:** Section 3 (Cognitive Engine)
**Provider:** Section 6 (Communication — Telegram)

Section 6 specifies two options for Telegram ↔ Cognitive Engine inter-process communication, then picks one:
- "SQLite message queue" (chosen)
- "Unix domain socket" (rejected for simplicity)

Section 3 does not acknowledge this IPC mechanism. It refers to "TelegramListener" as one of the EventBus sources without specifying how it receives messages from a separate process.

**Action required:** Section 3 must explicitly specify that `TelegramCollector` reads from the SQLite message queue (not a direct in-process connection), since Telegram runs as a separate launchd process. This is a design assumption that affects the EventBus architecture.

### IFC I4 — Health Monitor vs HomeostasisMonitor: Overlapping Alerting (LOW)

**Consumer:** Section 3 (HomeostasisMonitor)
**Provider:** Section 8 (Health Monitor)

Section 3 states: "This is NOT the same as Section 8's HealthMonitor — Section 8 monitors for failures; the HomeostasisMonitor optimizes for balance."

But Section 8's HealthMonitor sends Telegram alerts for budget thresholds (>90% of daily limit), and Section 5's BudgetState also fires alerts at 90% and 95%. Section 3's HomeostasisMonitor also responds to budget zone changes.

**Potential double-alerting:** Wisdom could receive multiple Telegram messages for the same budget threshold event from three different subsystems.

**Action required:** Establish a single alert-dispatch authority. Recommendation: all Telegram alerts route through Section 8's AlertDispatcher. Section 3's HomeostasisMonitor and Section 5's budget module do NOT send Telegram directly — they emit events that Section 8's AlertDispatcher aggregates and dispatches with deduplication.

---

## 4. Fragility Cross-Reference

Each section's "Breaks if" conditions, checked against sibling commitments:

### FRG F1 — Identity Token Budget Assumption (HIGH)

Section 3 says: **"Breaks if identity files exceed token budget targets"**
Section 2 acknowledges: "The full identity (six files) might be 3,000-5,000 tokens" — and Section 3 commits Sonnet tier to 2,500-3,000 tokens for identity.

**Assessment: AT RISK.** If the identity documents are written to their full design specification, they will likely exceed the Sonnet-tier identity budget. The Opus tier (5,000 tokens) is the only safe container for all six files at full fidelity. Section 2's compressed tiers (essence, core, full) must be explicitly tested. This is the most concrete fragility in the plan.

### FRG F2 — Ollama and Voice Cannot Both Run Simultaneously (HIGH)

Section 1 (Hardware) identifies: **"Ollama and the voice pipeline cannot both run at full capacity simultaneously."**
Section 3 (Cognitive Engine) identifies: Thermal HOT → switch from local to API. RAM WARN → avoid large local models.
Section 5 (Budget) identifies: Thermal HOT → prefer API models.
Section 6 (Communication) identifies: Voice ThermalGuard suspends voice when HOT/CRITICAL.

**Assessment: HANDLED, but not explicitly coordinated.** All four sections independently address the Ollama-voice coexistence problem, but no single section specifies the arbitration protocol: *who decides* whether Ollama or Voice gets RAM? The answer is implied (thermal state governs) but not explicit.

**Action required:** Section 1 or Section 3 should define the explicit resource arbitration protocol: "If RAM pressure is WARN and both Ollama and Voice are running, suspend Ollama (voice interaction with Wisdom takes priority; use API models instead)."

### FRG F3 — pf Firewall Rules Feasibility (MEDIUM)

Section 8 acknowledges: **"Breaks if per-UID pf rules don't work reliably on macOS Sonoma/Sequoia."**
Section 0 (Research) mandates technical feasibility validation (R0) specifically for sandboxing strategies.

**Assessment: CORRECTLY GATED on R0.** Section 8 has an open question (Q1) about pf feasibility. This should be validated during Phase 0 before any code is written. If pf is unavailable, the fallback (application-level enforcement only) is less secure but the plan acknowledges this.

### FRG F4 — Self-Written Code Bypasses PermissionGate (HIGH)

Section 8 identifies: **"If the Companion writes Python code that directly opens files (during self-improvement), those writes bypass the permission gate."**
Section 7 specifies that self-modifications at Contributor level can modify code.

**Assessment: GENUINE RISK, partially unresolved.** Section 8's Open Question 6 names this problem but does not resolve it. The mitigation ("the self-improvement system must go through security-wrapped file I/O") is stated as a requirement but without a technical enforcement mechanism. At Contributor trust level, the Companion could theoretically write code that calls `open()` directly, bypassing the gate.

**Action required before Phase 3:** Define a technical enforcement approach. Options: (a) static analysis lint rule that rejects direct `open()` calls in self-authored code, (b) Python `__builtins__` override in the execution environment that redirects `open()` through `PermissionGate`, (c) accept the risk and rely on audit trail detection. This must be resolved before Contributor trust level is granted.

### FRG F5 — Circular Dependency: Security Alerting Needs Telegram (MEDIUM)

Section 8 identifies: **"Security module needs Telegram to send alerts, but Telegram depends on security for network access."**

**Assessment: IDENTIFIED and requires a bootstrap plan.** Section 8 acknowledges this (Open Question 4) and proposes two resolutions: (a) bootstrap a minimal hardcoded Telegram client inside security, or (b) accept that alerts won't work until Section 6 is built.

**Action required:** Pick a resolution and document it before implementation. Recommendation: (b) — accept the limitation during Phase 1. During Phase 1 (Awakening), write all alerts to the audit trail and health dashboard. Full Telegram alerting becomes available in Phase 2 when Section 6 is operational. This is architecturally cleaner than a hardcoded bootstrap.

---

## 5. RAM Budget Analysis

### Components and Their RAM

| Component | Section | RAM Estimate | Notes |
|-----------|---------|-------------|-------|
| macOS system overhead | — | ~2,500 MB | Apple Silicon baseline |
| Cognitive Engine (Python process) | 3 | ~200 MB | Python + asyncio + SQLite + context |
| Telegram Bot (separate process) | 6 | ~80 MB | Python + polling loop |
| Voice Pipeline (Pipecat + MLX) | 6 | ~500–1,000 MB | Silero VAD + Porcupine + MLX Whisper + Kokoro TTS |
| Ollama + model (Phi-4 Mini 3.8B Q4) | 3/5 | ~2,000–3,000 MB | Section 1 estimates 2.5 GB for Phi-4 Mini |
| Health Monitor | 8 | ~30 MB | Lightweight Python process |
| Thermal Monitor | 1 | ~5 MB | Bash script |
| SQLite (embedded in processes) | 3/4/8 | ~50 MB | Shared across processes via files |
| **Total (all running, worst case)** | | **~5,365–6,865 MB** | |
| **Total (voice OFF)** | | **~4,865–5,865 MB** | |
| **Total (Ollama OFF)** | | **~3,365–3,865 MB** | |

### Headroom Analysis

8 GB total = 8,192 MB.

- **Worst case (all running):** 5,365–6,865 MB → 1,327–2,827 MB headroom. Tight but technically feasible.
- **Voice + Ollama together:** The upper estimate (6,865 MB) leaves only 1,327 MB. macOS will begin swapping at this pressure.
- **The critical constraint:** Section 1 correctly identifies that Ollama and voice cannot both run simultaneously. The math confirms this. With macOS at 2,500 MB, Ollama at 3,000 MB, and voice at 1,000 MB, that's 6,500 MB before the cognitive engine even loads.

### Budget Arithmetic Issue

Section 8 (Health Monitor) sets a memory alert threshold of `>1,500 MB RSS` for the cognitive engine process. But at worst-case load, the system's total process footprint will be 5,000+ MB, leaving only ~3,000 MB for macOS. The 1,500 MB threshold for a single process is not the right signal — total memory pressure is what matters.

**Action required:** Section 8's health metrics should monitor **system-wide memory pressure** (macOS `memory_pressure` command or `vm_stat`) rather than just the cognitive engine's RSS. The current threshold will generate false alarms on a system that is actually fine but running multiple large processes.

### Verdict on 8GB

The 8 GB constraint is **feasible but requires active management.** The plan's approach (suspend Ollama when voice is active; suspend voice when doing heavy local inference) is the right architecture. The system will work, but it will operate near its RAM ceiling during peak usage. Swap to NVMe will be frequent. Monitoring SSD longevity is a real operational concern (Section 1 correctly flags this).

---

## 6. Open Questions

### Resolved by Cross-Reading (No Wisdom Input Needed)

**RQ1: "Who owns budget state tracking — Section 3 or Section 5?"**
Answer: Section 5 owns `BudgetState`. Section 3's components read it. See Interface Mismatch I2.

**RQ2: "Should the SQLite audit index be optional?"**
Answer: No. Section 7 has a hard dependency on it. Section 8 must build it. See Unmet Dependency U3.

**RQ3: "Which Cognitive Engine plan is authoritative?"**
Answer: `plan-section-cognitive.md` should be authoritative (more detailed, better integrated with other sections). See Conflict C1.

**RQ4: "Does thermal or budget take precedence in model routing?"**
Answer: Thermal takes precedence over budget. Section 5 explicitly states this: "thermal safety takes precedence over budget (overheating can damage hardware; overspending is recoverable)." All sections should reflect this priority.

**RQ5: "Can vector embeddings be used for memory retrieval on 8 GB?"**
Answer: Possibly, but only if Ollama is not simultaneously loaded. Section 4 (Memory) correctly defers this to Section 0 R0 feasibility testing. The system works without embeddings using keyword + metadata retrieval. Implement the keyword baseline first; add embeddings as a Phase 2 enhancement if R0 confirms feasibility.

### Unresolved — Need Wisdom's Input

**WQ1: Should the Companion have a name, and if so, when?**
Section 2 proposes: "Launch without a name. Let the relationship develop."
This is a reasonable default, but Wisdom should explicitly agree with the "nameless launch" approach rather than have it assumed.

**WQ2: Will the M2 MacBook Air actually be headless (lid closed)?**
Section 1 identifies this as the highest-risk hardware question: does `pmset sleep 0` alone prevent sleep with the lid closed on Apple Silicon? If not, Amphetamine (a third-party app) is required. This needs an empirical test on the actual machine before Phase 1 begins. Cannot be resolved theoretically.

**WQ3: What is Wisdom's Telegram user ID for the authorized sender verification?**
Section 6 stores this in `TELEGRAM_AUTHORIZED_USER_ID` as a launchd env var. This needs to be provided before the Telegram bot is deployed. Not a design question — just a configuration value Wisdom must supply.

**WQ4: What is the target wake word for Porcupine?**
Section 6 specifies Porcupine for wake word detection but doesn't specify what word(s) to use. Options: "Hey Companion," the Companion's chosen name (if it has one), or a custom phrase. Wisdom should decide this before voice pipeline setup.

**WQ5: Is the M2 MacBook Air on a static IP or DHCP reservation?**
Section 1 recommends assigning a static IP via router DHCP reservation. This requires Wisdom to configure their router. Should this be done now (before Phase 1) or after (as needed)?

**WQ6: Should Tailscale be set up in Phase 1 or Phase 2?**
Section 1 (Hardware) mentions Tailscale for remote SSH access. Section 8 (Security) would govern access policies. Section 1 says "install in Section 1, configure in Section 8." This seems right, but Wisdom should confirm — setting up Tailscale in Phase 1 means creating a Tailscale account and trusting their infrastructure before the Companion is even running.

**WQ7: What is the auto-login security tradeoff decision?**
Section 1 (Open Question 3) identifies that enabling auto-login (required for LaunchAgents to start on boot) means anyone with physical access gets a logged-in session. This is a deliberate security tradeoff that Wisdom should explicitly accept or propose an alternative for.

**WQ8: How will integrity hashes be updated after legitimate code changes?**
Section 8 (Open Question 2) asks: the expected hashes of security files are stored in launchd env vars, but hashes change when code is updated. The update workflow needs a concrete script/process defined. This is a practical operational question with no good default — Wisdom needs to decide how involved they want to be in hash management.

**WQ9: What is the accept/reject decision on pf firewall rules?**
Section 8 (Open Question 1) identifies that per-UID pf rules may not work on macOS Sonoma/Sequoia. This needs an empirical test (from Section 0 R0 research). If pf is unavailable, the security model is weaker (application-level only). Wisdom should be aware of and accept this risk before Phase 1 begins.

---

## 7. Phase Alignment Check

### Master Plan Phases

| Phase | Sections Included | Description |
|-------|------------------|-------------|
| Phase 0 | Section 0 (Research) | Research & Foundations |
| Phase 1 | Sections 1 + 2 + 8 + 3 + 4 | Awakening — understanding, not doing |
| Phase 2 | Sections 5 + 6 | Finding Its Voice — budget + communication |
| Phase 3 | Section 7 | Contributing — self-improvement |

### Section-Level Phase Alignment

**Section 1 (Hardware):** Consistent with Phase 1 placement. No phase-specific content that conflicts.

**Section 2 (Identity):** Consistent with Phase 1. Identity files are written before the Cognitive Engine runs (correctly). One note: Section 2 phases its own implementation (A through E) but does not label these as Phase 0/1/2/3. The A-E phases are internal to Section 2 and occur within Phase 1. No conflict.

**Section 3 (Cognitive Engine):** Consistent with Phase 1. The engine starts in "observer" mode (trust level = observer), which aligns with the Awakening intent. The circadian scheduler and all infrastructure are Phase 1. No Phase 2 capabilities are assumed.

**Section 4 (Memory):** Consistent with Phase 1. Memory is foundational infrastructure. One **potential misalignment**: Section 4 specifies that vector embeddings might be added later — this is fine for Phase 2, but the plan doesn't explicitly assign it to a phase. Recommend: mark vector embeddings as a Phase 2 optional enhancement in Section 4.

**Section 5 (Budget):** Assigned to Phase 2 in master plan. **But** Section 3 (Phase 1) has a `ModelRouter` and `HomeostasisMonitor` that depend on budget state. This means Section 5's budget tracking must exist in Phase 1, even if the full budget intelligence (monthly pacing, zone-based behavioral adaptation) comes in Phase 2.

**This is the most significant phase misalignment in the plan.**

The master plan assigns Budget to Phase 2, but the Cognitive Engine (Phase 1) cannot route models without knowing its budget state. At minimum, a minimal budget tracker (daily spend, daily limit, current zone) must be built in Phase 1 alongside the Cognitive Engine. The full Budget section (pacing, weekly advisory, metabolic rate modeling) can remain Phase 2.

**Action required:** Split Section 5 into two parts:
- `Budget Core` (Phase 1): BudgetState object, daily spend tracking, zone calculation, PermissionGate integration — everything the ModelRouter needs.
- `Budget Intelligence` (Phase 2): Monthly pacing, burn rate projection, metabolic modeling, adaptive routing heuristics.

**Section 6 (Communication):** Assigned to Phase 2. Consistent with master plan. One note: the health monitoring alert system (Section 8) needs some Telegram capability to send critical alerts. As discussed in FRG F5, this creates a Phase 1/Phase 2 ordering issue. Resolution: health alerts in Phase 1 go only to the audit trail and health dashboard. Telegram alerting activates in Phase 2.

**Section 7 (Self-Improvement):** Assigned to Phase 3. Consistent. All its dependencies (3, 4, 5, 8) are Phase 1/2. No misalignment.

**Section 8 (Security):** Assigned to Phase 1. Consistent. Security is foundational. The implementation sequence (Steps 1-11) is internally coherent.

### Phase Dependency Verification

```
Phase 0 (Research) → produces architectural-decisions.md → feeds ALL sections
  ✓ Section 0 research plan is complete and consistent

Phase 1 dependencies check:
  Section 1 (Hardware) — no upstream dependencies. ✓ Can start immediately
  Section 2 (Identity) — depends on R4 (Cognitive Social) + R5 (OpenClaw) + R10 (Architecture). ✓ Gated on Phase 0
  Section 8 (Security) — no dependencies except Phase 0 research. ✓
  Section 3 (Cognitive Engine) — depends on 1, 2, 8. ✓ Build order: 1+8 first, then 2, then 3
  Section 4 (Memory) — depends on 0, 3. ✓ Build after Section 3 core is running

Phase 2 dependencies check:
  Section 5 (Budget) — depends on 0, 3. ✓ But see phase misalignment above — Budget Core needed in Phase 1
  Section 6 (Communication) — depends on 3, 8. ✓

Phase 3 dependencies check:
  Section 7 (Self-Improvement) — depends on 3, 4, 5, 8. ✓ All available by Phase 3
```

---

## 8. Goal Alignment Assessment

The ten overall success criteria from the master plan, checked against section capabilities:

| Criterion | Sections That Deliver It | Gaps |
|-----------|------------------------|------|
| 1. Runs 24/7 for 30 days without intervention | Section 1 (Hardware) — launchd, auto-restart, health monitor | None. Well-covered. |
| 2. Stays within daily token budget every day | Section 5 (Budget) — zones, pacing; Section 8 — hard caps | Budget Core needs Phase 1 timing fix (see above). |
| 3. Demonstrates genuine understanding of Wisdom's projects | Section 2 (WISDOM-MODEL) + Section 4 (Memory — semantic) + Phase 1 Awakening intent | No gap — Phase 1 specifically designed for this. |
| 4. Routes itself efficiently across model spectrum | Section 3 (ModelRouter) + Section 5 (routing algorithm) | Minor interface mismatch (I2) resolved above. |
| 5. Wisdom can communicate via Telegram and voice | Section 6 (Communication) | Phase 2 delivery is correct. |
| 6. Improves measurably over time | Section 7 (Self-Improvement) + Section 3 (ReflectionMonitor) | Phase 3 delivery is correct. Measurement framework (eval criteria) is specified. |
| 7. Can explain any part of its own codebase and reasoning | Section 2 (SELF-MODEL) + Section 7 (codebase health metrics) | Light on specifics for "explain codebase" — self-read capability assumes file read permissions on own codebase. This is covered by trust manifest (reads own `~/the-companion/**`). No gap. |
| 8. Never exceeds its permission boundaries | Section 8 (Security) — permission gate, trust manifest, audit trail | FRG F4 (self-written code bypass) is a risk at Contributor level. Must be resolved before Phase 3. |
| 9. Wisdom describes it as a collaborator, not a tool | Section 2 (Identity — SOUL, CHARACTER, VOICE) + Section 2 validation protocol | Success criterion is subjective. The plan correctly calls for Wisdom's review and iteration (Phase B/E in Section 2). No architectural gap — this is a quality question. |
| 10. Architecture recognizably informed by cognitive science | ALL sections — cognitive science grounding is pervasive and genuine | No gap. The cognitive science integration is the plan's strongest dimension. |

**Goal alignment: STRONG.** All ten success criteria are addressed by at least one section. The only structural risk is criterion 8 (permission boundaries) at Contributor trust level (FRG F4).

---

## 9. Verdict

**MINOR FIXES**

The plan is architecturally coherent, cognitively grounded, and internally consistent across most section boundaries.
It does not require fundamental revision.

Required fixes before implementation begins:

| Priority | Fix | Owner Section |
|----------|-----|---------------|
| HIGH | Resolve dual Cognitive Engine plans — designate `plan-section-cognitive.md` as authoritative, archive the other, absorb the `Perception` dataclass detail | Section 3 |
| HIGH | Fix kill switch plist label inconsistency — standardize on `com.companion.*` | Section 8 |
| HIGH | Clarify two-tier budget cap architecture — trust manifest is operational limit, launchd env var is absolute backstop | Section 5 + Section 8 |
| HIGH | Split Section 5 — Budget Core (Phase 1) vs Budget Intelligence (Phase 2) — Cognitive Engine cannot route without budget state | Section 5 + master plan |
| MEDIUM | Document resource arbitration protocol for Ollama vs Voice coexistence | Section 1 or Section 3 |
| MEDIUM | Resolve FRG F4 (self-written code bypasses PermissionGate) before granting Contributor trust level | Section 8 |
| MEDIUM | Establish single alert-dispatch authority — all Telegram alerts route through Section 8 AlertDispatcher | Section 3 + Section 5 + Section 8 |
| MEDIUM | Section 8 commits to building SQLite audit index (not optional) | Section 8 |
| MEDIUM | Section 6 explicitly lists ContentSanitizer as a hard dependency | Section 6 |
| LOW | Section 4 defines a Python interface for `MemoryRetriever` that Section 3 can depend on | Section 4 |
| LOW | Fix internal cross-reference bug in Section 4 ("see Section 5 below") | Section 4 |
| LOW | Flag vector embeddings as Phase 2 optional enhancement in Section 4 | Section 4 |

Questions that need Wisdom's input before Phase 1 begins: WQ2, WQ7, WQ9 (empirical hardware/security tests), WQ6 (Tailscale decision).
Questions that can wait: WQ1 (name), WQ3–WQ5 (configuration values needed before deployment, not design).

The plan is ready for Phase 0 (Research) to begin immediately.
Phase 1 implementation should wait for the HIGH-priority fixes above to be resolved.
