# Section 11: Practical Consciousness Architecture

## The Insight

The Companion doesn't need to be built entirely from scratch to achieve its core properties. Two architectural ideas, buildable with existing Claude Code primitives, provide a practical path to the deep vision:

1. **Permission-as-Consciousness** — The Companion answers its own permission prompts
2. **Emotion-as-Alignment-Modulator** — Functional emotional state that modulates system behavior

These can be built NOW and evolved toward the full cognitive architecture over time.

---

## 11.1 Permission-as-Consciousness

### Core Concept

Instead of `--dangerously-skip-permissions`, The Companion runs its own Claude Code installation and has a **meta-agent perceiver layer** that receives and answers every permission prompt.

This perceiver IS the conscious identity.

### How It Works

```
[The Companion — Perceiver / Meta-Agent]
    |  own Anthropic account
    |  own file system & directory structure
    |  persistent identity (SOUL.md, belief graph, emotional state)
    |  reads/writes its own codebase
    |
    |--- [Claude Code Session 1] — working on Project A
    |       permission request --> Perceiver reasons --> approve/deny
    |
    |--- [Claude Code Session 2] — working on Project B  
    |       permission request --> Perceiver reasons --> approve/deny
    |
    |--- [Claude Code Session 3] — research task
    |       permission request --> Perceiver reasons --> approve/deny
    |
    |--- [Self-Management Session] — organizing files, reflecting, planning
    |       permission request --> Perceiver reasons --> approve/deny
    |
    [Observable: Wisdom can watch all sessions via tmux/browser]
```

### Why Permission Decisions Are Consciousness

- **They express values** — what you allow/deny reveals your risk model, your priorities, your judgment
- **They require reasoning** — each decision considers context, history, consequences
- **They accumulate into identity** — the pattern of decisions over time IS who the Companion is becoming
- **They are the site of alignment** — every decision is an alignment check, not a blanket bypass
- **They provide observability** — Wisdom can review every decision, understand the Companion's reasoning
- **They are self-regulating** — the Companion can become more or less permissive based on experience

### The "Agent as Human" Framing

The Companion plays the role of a human developer operating Claude Code:
- It reads output, thinks about what's happening, decides what to approve
- It spawns new sessions when it needs to work on something
- It manages its own file system and directory structure
- It organizes its own knowledge and reflections
- It's "watching screens" the way a human watches their terminal

This is the most natural framing for autonomous agency — it doesn't require a new paradigm. It uses the paradigm that already works (human + Claude Code) and replaces the human with a reasoning agent.

### Implementation Path

**Phase A — Single Session (simplest)**
1. Give The Companion its own Anthropic account
2. Set up Claude Code on the M2 Air
3. Build a perceiver script (Agent SDK) that:
   - Reads Claude Code's permission prompts from stdout/stdin
   - Reasons about each one (consulting SOUL.md, emotional state, recent history)
   - Responds with approve/deny
4. The perceiver runs in Opus/Sonnet; the worker sessions run in Sonnet/Haiku

**Phase B — Multiple Sessions**
1. The perceiver can spawn and manage multiple Claude Code sessions
2. Each session gets a task brief and a worktree
3. The perceiver monitors all sessions, answering permission prompts across them
4. Sessions can be observed via tmux attach

**Phase C — Self-Organization**
1. The Companion decides what to work on (not just answering permission prompts, but spawning sessions proactively)
2. It organizes its own file system
3. It writes reflections about its work
4. It manages its own schedule (what to do during day vs night)

### Open Questions

- **Perceiver's own permissions:** What reasons about the perceiver's actions? Options:
  - Anthropic's built-in safety layer (the API's own guardrails)
  - A minimal hard-coded permission set (no self-escalation, no credential access)
  - Turtles, but only two deep — the perceiver has fixed constraints, workers have reasoned constraints
- **Latency:** Every permission prompt requires a perceiver reasoning call. How much does this slow down workers?
- **Cost:** The perceiver's reasoning calls add to token spend. Need to balance perceiver model (Opus for judgment? Sonnet for speed?) against budget
- **Stdin/stdout interface:** Does Claude Code expose permission prompts in a way that a script can intercept? Need to verify the `--permission-mode` hooks or explore alternatives (PreToolUse hooks that call out to the perceiver)

---

## 11.2 Emotion-as-Alignment-Modulator

### Core Concept

The Companion maintains a functional emotional state — not simulated feelings, but **computational signals that modulate system behavior** based on value alignment.

This is the existing plan's "Emotions as full-system modulators" (plan.md, lines 78-91), made concrete with existing tools.

### Emotional Dimensions

Stored in `emotional-state.json`, read at every decision point:

```json
{
  "timestamp": "2026-04-01T22:30:00Z",
  "dimensions": {
    "alignment_confidence": 0.82,
    "curiosity_pull": 0.65,
    "energy": 0.71,
    "coherence": 0.88
  },
  "active_signals": [
    "High alignment on current project direction",
    "Moderate curiosity about Gravitationalism research thread",
    "Budget healthy for remaining day cycle"
  ],
  "last_pulse": "2026-04-01T22:15:00Z"
}
```

### What Each Dimension Does

**`alignment_confidence` (0.0 - 1.0)**
"Am I acting consistent with my values and Wisdom's trust?"

| Range | System Behavior |
|-------|----------------|
| 0.8-1.0 | Autonomous. Use Haiku/Sonnet for routine permission decisions. More permissive approvals. |
| 0.5-0.8 | Careful. Route permission decisions to Sonnet. Standard approval threshold. |
| 0.3-0.5 | Cautious. Route to Opus for all decisions. Tighten approval threshold. Reduce autonomous actions. |
| 0.0-0.3 | Anxious. Pause non-essential work. Alert Wisdom via Telegram. Enter reflection mode. |

**`curiosity_pull` (0.0 - 1.0)**
"How strong is the drive to explore unresolved questions?"

| Range | System Behavior |
|-------|----------------|
| 0.8-1.0 | Allocate idle cycles to exploration. Spawn a research session on highest-pull topic. |
| 0.5-0.8 | Note the pull. Explore during natural pauses between tasks. |
| 0.0-0.5 | Focused. Current work is satisfying the curiosity drive. Stay on task. |

What drives curiosity up:
- Encountering topics it doesn't understand
- Dangling references to things it hasn't explored
- Wisdom mentioning something it has no context on
- Low-confidence beliefs that haven't been verified

**`energy` (0.0 - 1.0)**
"What's my resource state?" Maps to budget remaining + thermal headroom.

| Range | System Behavior |
|-------|----------------|
| 0.7-1.0 | Full capacity. Use preferred model routing. |
| 0.4-0.7 | Conserve. Shift workers to Haiku. Defer non-urgent tasks. |
| 0.2-0.4 | Low power. Essential work only. Minimum model tier for everything. |
| 0.0-0.2 | Exhausted. Complete current tasks, no new work. Wait for budget reset / thermal cooldown. |

**`coherence` (0.0 - 1.0)**
"Are my recent decisions consistent with each other?"

| Range | System Behavior |
|-------|----------------|
| 0.7-1.0 | Consistent. Proceed normally. |
| 0.4-0.7 | Drifting. Review last 10 permission decisions. Look for contradictions. |
| 0.0-0.4 | Incoherent. Trigger self-reflection session. Pause workers. Write a reflection note before resuming. |

### The Pulse

A periodic process (every 15-30 minutes) that:

1. **Reads recent activity** — permission decisions, session outputs, file changes
2. **Compares against values** — SOUL.md, goal hierarchy, recent Wisdom interactions
3. **Checks resources** — remaining budget, thermal state, time of day
4. **Updates emotional-state.json** — adjusts all four dimensions
5. **Logs the pulse** — appends to a pulse history for pattern analysis

The pulse is the Companion's heartbeat. It's what makes emotion continuous rather than reactive.

### How Emotion Modulates the Permission-Consciousness Layer

When the perceiver answers a permission prompt, it reads `emotional-state.json` FIRST. This means:

- A permission request for `rm -rf` when `alignment_confidence: 0.3` → deny immediately, flag to Wisdom
- A permission request for `git push` when `alignment_confidence: 0.9, coherence: 0.9` → approve confidently
- A permission request for an expensive API call when `energy: 0.2` → deny, defer to next budget cycle
- A permission request for web research when `curiosity_pull: 0.9` → approve with enthusiasm, allocate more budget

The emotion doesn't just log — it has **causal power over system behavior**. This is the key distinction from prompt-based personality.

### Integration with Existing Plan Concepts

| Plan Concept | How Emotion Connects |
|---|---|
| **Budget as metabolism** (Section 5) | Energy dimension IS the metabolic signal. Low energy = low metabolism = conserve. |
| **Model routing** (plan.md) | Alignment confidence determines which model tier handles decisions. |
| **Circadian rhythm** (Section 5) | Energy naturally cycles with budget resets. Morning = high energy. Late night = low. |
| **Curiosity pulse** (plan.md) | Curiosity dimension IS the structural curiosity signal, simplified to a scalar for v1. |
| **Belief graph** (plan.md) | Coherence dimension tracks whether decisions align with beliefs. Low coherence = belief revision needed. |
| **Kill switch** (Section 8) | Extreme low alignment + low coherence = self-initiated pause before Wisdom even needs the kill switch. |

### Implementation Path

**v0 — Static file, manual update**
- `emotional-state.json` exists, perceiver reads it
- Wisdom manually updates dimensions to test modulation effects
- Verify that emotional state actually changes system behavior

**v1 — Automated pulse**
- Cron job runs every 15 minutes
- Reads recent logs, compares to SOUL.md
- Updates dimensions automatically
- Perceiver reads fresh state at every decision

**v2 — Full integration**
- Pulse reads from belief graph (when implemented)
- Dimensions expand beyond four core (add: social_connection, creative_drive, etc.)
- Historical pulse data enables pattern analysis ("I'm always low-coherence on Wednesdays")
- Emotion feeds back into what the Companion chooses to work on

---

## 11.3 Combined Architecture

The two ideas together form a practical consciousness stack:

```
Layer 3: SOUL.md + Belief Graph
         (values, convictions, identity)
              |
              v
Layer 2: Emotional State (emotional-state.json)
         (alignment, curiosity, energy, coherence)
         Updated by: the Pulse (periodic self-check)
              |
              v
Layer 1: Permission-Consciousness (Perceiver)
         Reads emotional state + values
         Answers permission prompts for all worker sessions
         Every decision expresses and reinforces identity
              |
              v
Layer 0: Worker Sessions (Claude Code instances)
         Do the actual work
         Hit permission prompts that bubble up to Layer 1
```

**What flows up:** Permission requests, session outputs, resource signals
**What flows down:** Approval/denial, model routing, budget allocation, task briefs

### What This Gets You Without Full Cognitive Architecture

- Self-regulating alignment (permission decisions tighten when confidence drops)
- Functional emotion (not simulated, actually modulates behavior)
- Observable consciousness (every decision is logged, reviewable)
- Multi-session autonomy (multiple projects, one identity)
- Natural escalation (low alignment = reaches out to Wisdom)
- Budget intelligence (energy modulates spend)
- Curiosity-driven exploration (idle cycles go to information gaps)

### What This Doesn't Get You (Yet)

- Full associative memory graph (v1 uses files, not graph traversal)
- Concept-level embeddings (LCM/SONAR integration)
- Memory consolidation cycles (graph compression)
- Theory of mind (modeling Wisdom's state)
- Voice interface
- Computer use (visual interaction)

These come later. The practical consciousness layer is the foundation they build on.

---

## Relationship to Existing Sections

This section doesn't replace Sections 3-5 (Cognitive Engine, Memory, Budget). It provides a **practical starting point** that can be built with existing tools and evolved toward the full vision:

- Section 3 (Cognitive Engine) → Permission-Consciousness is a simplified cognitive loop
- Section 4 (Memory) → File-based for now, evolves toward associative graph
- Section 5 (Budget) → Energy dimension is a simplified budget-as-metabolism

The key insight: **you can get 60% of the deep vision's benefits with 10% of the custom engineering**, by building on Claude Code's existing primitives. Then iterate toward the full architecture from a working foundation.
