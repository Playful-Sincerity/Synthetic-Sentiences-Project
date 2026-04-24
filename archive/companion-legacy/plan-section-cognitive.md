# Section 3: Core Cognitive Engine — Detailed Plan

## Purpose

This is the brain.
Every other section either feeds into it (Identity, Security, Hardware) or depends on it (Memory, Budget, Communication, Self-Improvement).
The cognitive engine is the central loop that perceives, attends, reasons, and acts — the integration point where all subsystems meet.

It must do three things simultaneously:
1. Run a principled perception-attention-reasoning-action loop grounded in cognitive science
2. Route itself across a model spectrum (local free -> Haiku -> Sonnet -> Opus) based on task demands
3. Serve as the coordination backbone that all other sections plug into

---

## Design Philosophy

### Why Not Just "Agent SDK + Tools"

The Claude Agent SDK provides a powerful query/response loop with tool calling.
The naive approach: wrap `Agent.query()` in a `while True` loop, add tools, ship it.
That gives you a task executor, not a cognitive engine.

The Companion needs something richer:
- **Selective attention**: not everything that arrives deserves a response or a thought
- **Model routing as cognition**: cheap thoughts for cheap problems, expensive thoughts for hard ones
- **Identity-infused reasoning**: the same SOUL.md shapes every thought, but differently per model tier
- **Metacognitive monitoring**: the engine observes its own performance and adjusts
- **Homeostatic awareness**: it knows its own resource state (budget, thermal, memory pressure) and adapts
- **Temporal coherence**: it maintains narrative continuity across thousands of cycles

### Cognitive Science Mapping

The engine's architecture maps deliberately to cognitive science concepts:

| Cognitive Concept | Engine Component | How It Works |
|---|---|---|
| **Perception** | EventBus + Sensors | Raw inputs arrive: messages, file changes, scheduled triggers, health signals |
| **Sensory gating** | SalienceFilter | Most inputs are discarded or deferred. Only salient events proceed. |
| **Attention** | AttentionAllocator | Salient events are scored and queued by priority. Working memory is finite. |
| **Working memory** | ContextAssembler | The context window IS working memory. Assembles identity + relevant context + task. |
| **Central executive** | CognitiveOrchestrator | The meta-controller: selects what to think about, which model to use, when to stop. |
| **Long-term memory** | Memory System (Section 4) | Retrieval from episodic/semantic stores feeds into context assembly. |
| **Reasoning** | ModelRouter + Agent SDK query | The actual thinking — routed to the right model tier for the task. |
| **Motor output** | ActionExecutor | Produces actions: messages, file writes, API calls, state changes. |
| **Metacognition** | ReflectionMonitor | Observes the cycle's outcome: was this good? what would I do differently? |
| **Homeostasis** | HomeostasisMonitor | Tracks internal state: budget, thermal, error rate, cycle timing. |
| **Circadian rhythm** | CircadianScheduler | Governs what kinds of cognition happen at what times of day. |

### Architectural Precedents

**LIDA's Global Workspace Theory**: Information competes for access to a "global workspace" (conscious broadcast).
In the Companion, the context window IS the global workspace.
Not everything gets in — the SalienceFilter and AttentionAllocator determine what enters the workspace.
Once in the workspace, the information is available to all processes (reasoning, memory encoding, action selection).

**ACT-R's Activation-Based Retrieval**: Memory items have activation levels that decay over time.
The most activated items are most retrievable.
This informs how the ContextAssembler pulls from long-term memory — recent, frequent, and contextually relevant items are preferred.

**Dual Process Theory (Kahneman)**: System 1 (fast, automatic, cheap) vs System 2 (slow, deliberate, expensive).
This IS the model routing spectrum.
A local model doing classification is System 1.
Opus reasoning through an architectural decision is System 2.
The engine must learn when to escalate from System 1 to System 2.

---

## Architecture Overview

### The Cognitive Cycle

Each cycle of the engine follows this sequence:

```
    ┌──────────────────────────────────────────────────┐
    │                 COGNITIVE CYCLE                    │
    │                                                    │
    │  1. PERCEIVE        What happened?                 │
    │     EventBus → SalienceFilter                      │
    │     ↓                                              │
    │  2. ATTEND          What deserves thought?          │
    │     AttentionAllocator → PriorityQueue              │
    │     ↓                                              │
    │  3. CONTEXTUALIZE   What do I need to know?         │
    │     ContextAssembler (identity + memory + state)    │
    │     ↓                                              │
    │  4. DELIBERATE      How hard should I think?        │
    │     ModelRouter → selects model tier                │
    │     ↓                                              │
    │  5. REASON          What should I do?               │
    │     Agent SDK query() with assembled context        │
    │     ↓                                              │
    │  6. ACT             Do the thing.                   │
    │     ActionExecutor → PermissionGate → execute       │
    │     ↓                                              │
    │  7. REFLECT         How did that go?                │
    │     ReflectionMonitor → update self-model           │
    │     ↓                                              │
    │  8. CONSOLIDATE     What should I remember?         │
    │     Memory write-back → state update                │
    │                                                    │
    └──────────────────────────────────────────────────┘
```

Not every cycle executes all eight stages.
A dismissed event exits at stage 2.
A simple reflex (classification by local model) may skip stages 3-4 and go straight to act.
Deep reasoning engages all eight stages.

### Event-Driven, Not Continuous Loop

The engine does NOT spin in a tight `while True` loop burning compute.
It is **event-driven with scheduled heartbeats**.

Events arrive from:
- **External triggers**: Telegram messages, GitHub webhooks, file system changes
- **Internal triggers**: scheduled heartbeats (circadian), timer-based reminders, self-generated follow-ups
- **System triggers**: health alerts, thermal warnings, budget thresholds

When no events are pending, the engine sleeps.
Scheduled heartbeats ensure it wakes up periodically even without external stimulus — this is how circadian rhythm and proactive behavior work.

```
EventBus (async queue)
├── TelegramListener    → message events
├── GitHubPoller        → PR/issue events (poll every 5 min)
├── FileWatcher         → filesystem change events (watchdog)
├── CircadianScheduler  → heartbeat events (morning scan, evening reflection, etc.)
├── TimerService        → self-set reminders and deferred tasks
├── HealthRelay         → thermal/memory/budget threshold crossings from Section 8
└── SelfGeneratedQueue  → follow-up tasks the engine queues for itself
```

### Component Map

```
┌─────────────────────────────────────────────────────────────────┐
│                    CORE COGNITIVE ENGINE                          │
│                                                                   │
│  ┌─────────────┐                                                  │
│  │  EventBus   │─── events arrive here from all sources           │
│  └──────┬──────┘                                                  │
│         ↓                                                         │
│  ┌─────────────────┐                                              │
│  │ SalienceFilter   │─── scores and gates events                  │
│  │  (local model)   │    cheap: runs on local model or rules      │
│  └──────┬──────────┘                                              │
│         ↓ (salient events only)                                   │
│  ┌─────────────────────┐                                          │
│  │ AttentionAllocator   │─── priority queue + working memory mgmt │
│  │  (local model/rules) │    manages what gets thought about next │
│  └──────┬──────────────┘                                          │
│         ↓ (next task selected)                                    │
│  ┌─────────────────────┐                                          │
│  │ ContextAssembler     │─── builds the context window             │
│  │  (identity + memory  │    SOUL + CHARACTER + task + memory      │
│  │   + state + task)    │    token-budgeted per model tier         │
│  └──────┬──────────────┘                                          │
│         ↓                                                         │
│  ┌─────────────────┐                                              │
│  │ ModelRouter      │─── selects model tier for this task          │
│  │  (rules + local  │    System 1 vs System 2 decision             │
│  │   model)         │    checks budget + thermal + task complexity │
│  └──────┬──────────┘                                              │
│         ↓                                                         │
│  ┌─────────────────────┐                                          │
│  │ ReasoningEngine     │─── executes the actual LLM query          │
│  │  (Agent SDK)        │    streaming, tool use, multi-turn        │
│  └──────┬──────────────┘                                          │
│         ↓                                                         │
│  ┌─────────────────┐                                              │
│  │ ActionExecutor   │─── executes decided actions                  │
│  │  (→PermissionGate│    all actions pass through Section 8        │
│  │   from Sec 8)    │    results feed back to EventBus             │
│  └──────┬──────────┘                                              │
│         ↓                                                         │
│  ┌─────────────────────┐                                          │
│  │ ReflectionMonitor   │─── observes cycle outcome                 │
│  │  (metacognition)    │    updates self-model, detects patterns   │
│  └──────┬──────────────┘                                          │
│         ↓                                                         │
│  │ HomeostasisMonitor  │─── tracks resource state                  │
│  │  (always running)   │    budget, thermal, memory, error rate    │
│  └─────────────────────┘                                          │
│                                                                   │
│  ┌─────────────────────┐                                          │
│  │ CognitiveOrchestrator│─── the meta-controller                  │
│  │  (ties it all        │    startup, shutdown, cycle management   │
│  │   together)          │    circadian scheduling, error recovery  │
│  └─────────────────────┘                                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## Detailed Component Specifications

### 1. EventBus

**What it is**: An async priority queue that receives events from all sources and delivers them to the SalienceFilter.

**Design**:
- Python `asyncio.PriorityQueue` as the backbone
- Events are dataclass objects with a common schema:

```
Event:
  id: str (UUID)
  timestamp: datetime
  source: str (telegram | github | filesystem | circadian | timer | health | self)
  event_type: str (message | pr_update | file_change | heartbeat | reminder | alert | follow_up)
  priority_hint: int (0=urgent, 10=routine — source can suggest, SalienceFilter overrides)
  payload: dict (source-specific data)
  metadata: dict (routing info, correlation IDs)
```

**Event sources register as async producers**.
Each source runs as an independent asyncio task, pushing events onto the bus.

**Backpressure**: If the queue exceeds a configurable depth (default 100), lowest-priority events are dropped and logged.
This prevents event storms from overwhelming the engine.

**Integration**:
- TelegramListener wraps the Telegram long-polling loop, producing message events
- GitHubPoller runs on a 5-minute interval, producing PR/issue events
- FileWatcher uses Python `watchdog` library for filesystem monitoring
- CircadianScheduler produces heartbeat events per the daily schedule
- HealthRelay subscribes to Section 8's HealthMonitor, forwarding threshold crossings

---

### 2. SalienceFilter

**What it is**: The first cognitive gate.
Most events are not worth a full cognitive cycle.
The SalienceFilter scores each event and decides: process now, defer, or discard.

**Cognitive science basis**: Sensory gating and the reticular activating system.
The brain filters out ~99% of sensory input before it reaches consciousness.
The SalienceFilter does the same for the Companion's input stream.

**Implementation approach**: Two tiers of filtering.

**Tier 1 — Rule-based fast filter (no model call)**:
- Direct messages from Wisdom: ALWAYS salient (bypass filter)
- Health alerts at critical/fatal: ALWAYS salient
- Kill/pause commands: ALWAYS salient (bypass entire cognitive cycle, go straight to action)
- Duplicate events within a time window: discard
- Events matching a "muted" pattern list: discard
- Scheduled heartbeats: salient at their scheduled time, discard if late by >2x their interval

**Tier 2 — Local model classification (cheap)**:
- For events that pass Tier 1 but aren't auto-salient, query the local model (or Haiku if local unavailable):
  - Input: event summary + current context summary (what are we doing right now?)
  - Output: salience score (0-10) + reasoning
  - Threshold: score >= 4 proceeds to attention; score < 4 is deferred to a low-priority background queue
  - Cost: effectively free for local model; ~$0.0005 for Haiku

**Salience dimensions** (inspired by cognitive science):
- **Novelty**: Is this new information or a repeat?
- **Relevance**: Does this relate to current focus or known priorities?
- **Urgency**: Is there a time constraint?
- **Prediction error**: Does this contradict what the Companion expected? (Surprise is salient.)
- **Emotional weight**: Does Wisdom's message carry emotional significance? (Inferred from tone/content.)
- **Source authority**: Direct from Wisdom > scheduled > system > background

**Output**: Salient events are pushed to the AttentionAllocator with their salience scores.
Non-salient events are logged to a "filtered" queue that can be reviewed during reflection cycles ("what did I ignore today?").

---

### 3. AttentionAllocator

**What it is**: Manages the Companion's limited attention — decides what to think about next and maintains the priority queue of pending tasks.

**Cognitive science basis**: Central executive component of working memory (Baddeley).
Attention is finite.
The brain maintains a very small number of items in active focus (typically 4 +/- 1).
The AttentionAllocator enforces this constraint.

**Design**:
- Maintains a **priority heap** of pending tasks (salient events that haven't been processed yet)
- Priority = f(salience_score, wait_time, task_type, current_focus)
- **Focus tracking**: knows what the current cognitive focus is.
  Tasks related to the current focus get a priority boost (reducing task-switching cost).
  Unrelated tasks need a higher salience score to interrupt.
- **Working memory slots**: maximum 5 pending items in the active queue.
  If a 6th item arrives with higher priority, the lowest-priority item is demoted to the deferred queue.

**Task-switching cost**:
- The cognitive science research shows a real cost to switching tasks (context reload, loss of coherence).
- When the AttentionAllocator switches focus to an unrelated task, it logs the switch and its cost.
- If a task can wait (not urgent), it benefits from being batched with related tasks.

**Interruption policy**:
- **Priority 0 (emergency)**: Interrupts immediately. Health crises, kill commands, direct urgent messages from Wisdom.
- **Priority 1-3 (high)**: Interrupts after current reasoning step completes (not mid-query).
- **Priority 4-7 (normal)**: Queued. Processed in priority order during normal cycle flow.
- **Priority 8-10 (low/background)**: Processed only during idle periods or scheduled background time.

**Idle behavior**:
When no salient events are pending and no scheduled heartbeat is due:
- The AttentionAllocator signals "idle" to the CognitiveOrchestrator
- The Orchestrator may choose to: do nothing (sleep), run background processing, or initiate curiosity-driven exploration
- Idle is not wasted — it's the Companion's equivalent of mind-wandering, which in humans is when default mode network processes (consolidation, creative connections) run

---

### 4. ContextAssembler

**What it is**: Builds the actual context window for a reasoning query.
This is the most critical component for quality — garbage context produces garbage reasoning.

**Cognitive science basis**: Working memory.
The context window IS the Companion's working memory.
Just as the brain's working memory holds: current goal + relevant knowledge + sensory input + executive state, the ContextAssembler composes: identity + task + relevant memory + system state.

**Context composition (in order, from most to least immutable)**:

```
┌──────────────────────────────────────────────┐
│  1. IDENTITY LAYER                            │
│     SOUL.md (always, full — ~500-800 tokens)  │
│     CHARACTER.md (always, full — ~400-600 t)  │
│     BOUNDARIES.md (always, full — ~300-400 t) │
│     VOICE.md (channel-relevant section only)  │
├──────────────────────────────────────────────┤
│  2. SYSTEM STATE LAYER                        │
│     Current time, thermal state, budget state │
│     Trust level, active circadian phase       │
│     (~100-200 tokens)                         │
├──────────────────────────────────────────────┤
│  3. WISDOM-MODEL LAYER                        │
│     Dynamic state (current inferred context)  │
│     Relevant stable model sections            │
│     (~200-500 tokens)                         │
├──────────────────────────────────────────────┤
│  4. TASK LAYER                                │
│     The specific event/task being processed   │
│     Conversation history (if ongoing)         │
│     (~variable, task-dependent)               │
├──────────────────────────────────────────────┤
│  5. MEMORY RETRIEVAL LAYER                    │
│     Relevant memories retrieved by Section 4  │
│     (episodic, semantic, procedural)          │
│     (~200-1000 tokens, budget-dependent)      │
├──────────────────────────────────────────────┤
│  6. SELF-MODEL LAYER (when relevant)          │
│     Relevant self-assessment for this task    │
│     (~100-300 tokens, only for reflective     │
│      or self-improvement tasks)               │
└──────────────────────────────────────────────┘
```

**Token budgeting by model tier**:

| Model Tier | Max Context | Identity Budget | Memory Budget | Task Budget |
|---|---|---|---|---|
| Local (2-3B) | ~4K tokens | 500t (compressed tier) | 200t | 1000t |
| Haiku | ~200K tokens | 1500t (core tier) | 500t | 2000t |
| Sonnet | ~200K tokens | 2500t (full tier) | 1000t | 5000t |
| Opus | ~200K tokens | 3000t (full + self-model) | 2000t | 10000t |

Even though Haiku/Sonnet/Opus have 200K context windows, the Companion deliberately keeps context lean.
Bloated context degrades reasoning quality.
The budget above is a soft target — can flex upward for complex tasks, but the ContextAssembler defaults to these limits and must justify exceeding them.

**Identity compression tiers** (from Section 2's contract):

- **Essence tier** (~500 tokens): Core values from SOUL.md as a tight paragraph. Key personality trait summary. Essential boundaries. For local models.
- **Core tier** (~1500 tokens): Full SOUL.md + CHARACTER.md summary + active VOICE.md section + key boundaries. For Haiku.
- **Full tier** (~2500-3000 tokens): All identity files in full. For Sonnet and Opus.

The ContextAssembler pre-computes these tiers at startup and caches them.
When identity files change (WISDOM-MODEL updates, SELF-MODEL reflection), the relevant tiers are regenerated.

**Memory retrieval interface** (to Section 4):
- The ContextAssembler sends a retrieval query to the Memory System: "Given this task/event, what memories are relevant?"
- The Memory System returns ranked results with relevance scores
- The ContextAssembler includes memories until the token budget for memory is exhausted
- This maps to ACT-R's activation-based retrieval: memories with higher activation (recent, frequent, contextually relevant) are retrieved first

---

### 5. ModelRouter

**What it is**: The System 1 / System 2 decision engine.
Selects which model tier to use for a given task, balancing quality, cost, speed, and resource constraints.

**Cognitive science basis**: Dual Process Theory (Kahneman).
System 1: fast, automatic, low-effort, error-prone for complex tasks.
System 2: slow, deliberate, high-effort, better for complex reasoning.
The brain doesn't always engage System 2 — it's expensive.
Similarly, the Companion shouldn't use Opus for everything.

**Routing factors**:

1. **Task complexity** (primary signal):
   - Classification, routing, yes/no decisions -> Local model (System 1)
   - Simple lookups, status checks, log parsing -> Haiku (quick thought)
   - Code reading, writing, analysis, most real work -> Sonnet (considered thought)
   - Architecture decisions, ambiguous synthesis, novel problems -> Opus (deep reasoning)

2. **Budget state** (constraint):
   - Daily budget remaining -> constrains max tier available
   - Monthly burn rate -> adjusts default routing toward cheaper models if ahead of pace
   - Per-call cost check -> Section 8 PermissionGate enforces hard limits

3. **Thermal state** (constraint):
   - HOT/CRITICAL zone -> prohibit local model (offload to API)
   - COOL zone -> prefer local model when task complexity allows

4. **Time pressure** (modifier):
   - Real-time conversation with Wisdom -> latency matters, prefer faster models
   - Background/deferred task -> latency irrelevant, prefer cheapest adequate model
   - Streaming required -> all Claude models support streaming; local models may not (check Ollama)

5. **Task type heuristics** (learned over time):
   - Maintain a table of task_type -> recommended_model based on historical performance
   - Updated during reflection: "I used Haiku for this code review and the quality was poor. Next time, use Sonnet."

**Routing decision tree**:

```
Is this a direct message from Wisdom requiring a response?
├─ YES: Is it a simple question / status check?
│  ├─ YES → Haiku
│  └─ NO: Is it a complex question / requires deep analysis?
│     ├─ YES → Is budget available for Opus?
│     │  ├─ YES → Opus
│     │  └─ NO → Sonnet
│     └─ NO → Sonnet (default for most real work)
├─ NO: Is this a classification / routing / triage task?
│  ├─ YES → Local model (if available and cool) or Haiku
│  └─ NO: Is this a background / deferred task?
│     ├─ YES → Cheapest adequate model (local > Haiku > Sonnet)
│     └─ NO: Is this a reflection / self-improvement task?
│        ├─ YES → Sonnet (reflection needs quality, not speed)
│        └─ NO → Sonnet (safe default)
```

**Escalation pattern**:
- Start with the cheapest adequate model
- If the model's response indicates uncertainty or inability (e.g., "I'm not sure about this complex architecture question"), escalate to the next tier
- Maximum one escalation per cycle (prevent cost spirals)
- Log the escalation with reasoning for future learning

**Fallback chain**:
If the selected model is unavailable (API error, Ollama down, thermal constraint):
```
Opus → Sonnet → Haiku → Local → Queue (defer until a model is available)
```
Never fail silently.
If no model is available, log the situation and alert Wisdom.

---

### 6. ReasoningEngine

**What it is**: The wrapper around Claude Agent SDK's `Agent` class that executes the actual LLM query.

**This is where the Agent SDK integrates.**

**Design**:

The ReasoningEngine maintains a pool of configured `Agent` instances — one per model tier, each with appropriate tools and settings.

```
ReasoningEngine:
  agents:
    local: OllamaAgent (custom wrapper for Ollama HTTP API)
    haiku: Agent(model="claude-3-haiku-...", tools=[...])
    sonnet: Agent(model="claude-3-5-sonnet-...", tools=[...])
    opus: Agent(model="claude-opus-...", tools=[...])
```

**Each query is a single `agent.query()` call** with the context assembled by ContextAssembler.
The Agent SDK handles:
- Tool calling (the Companion's actions are tools)
- Streaming (for real-time responses to Wisdom)
- Multi-turn within a single cognitive cycle (if the model needs to call multiple tools)

**Tool registration**:
Tools are the Companion's hands — how it acts on the world.
Registered tools differ by trust level (Section 8):

| Tool | Description | Trust Level |
|---|---|---|
| `send_telegram_message` | Send a message to Wisdom | observer+ |
| `read_file` | Read a file (through PermissionGate) | observer+ |
| `write_file` | Write a file (through PermissionGate) | observer+ (own dirs only) |
| `search_memory` | Query the memory system | observer+ |
| `store_memory` | Write to memory system | observer+ |
| `read_health_status` | Read current system health | observer+ |
| `read_thermal_state` | Read thermal JSON | observer+ |
| `read_budget_state` | Read current budget | observer+ |
| `create_github_issue` | Create a GitHub issue | contributor+ |
| `create_github_pr` | Create a pull request | contributor+ |
| `run_command` | Run an allowlisted command | contributor+ |
| `queue_follow_up` | Schedule a follow-up task for itself | observer+ |
| `set_reminder` | Set a time-based reminder | observer+ |
| `update_wisdom_model` | Update dynamic state in WISDOM-MODEL | observer+ |
| `reflect` | Trigger explicit reflection on a topic | observer+ |

**All tools pass through PermissionGate** (Section 8) before executing.
The tool implementations are thin wrappers that: validate via PermissionGate -> execute -> log to AuditLogger -> return result.

**Session management**:
- Each cognitive cycle is a fresh Agent SDK session (no cross-cycle conversation bleed)
- For multi-turn conversations with Wisdom (ongoing Telegram chat), conversation history is explicitly managed in the ContextAssembler, not through SDK session persistence
- This gives the Companion control over what context carries forward vs what is summarized/dropped

**Streaming**:
- When responding to Wisdom in real-time (Telegram, voice), the ReasoningEngine streams the response
- Agent SDK supports streaming via `agent.query()` with a stream handler
- The stream handler feeds tokens to the appropriate communication channel (Section 6)
- For background tasks, streaming is unnecessary — just collect the full response

**Local model integration**:
- Ollama exposes an OpenAI-compatible HTTP API at `localhost:11434`
- The `OllamaAgent` is a custom wrapper (NOT the Claude Agent SDK) that speaks this API
- It supports a subset of tools (simpler tool calling schema)
- Used only for System 1 tasks: classification, routing, simple extraction
- Graceful degradation: if Ollama is down (thermal, memory pressure), all tasks escalate to Haiku

---

### 7. ActionExecutor

**What it is**: Translates reasoning outputs into concrete actions in the world.

**Design principle**: The ReasoningEngine (via tool calls) decides WHAT to do.
The ActionExecutor does the actual doing, with permission checking and audit logging.

**Action flow**:

```
ReasoningEngine tool call
  → ActionExecutor.execute(action)
    → PermissionGate.check(action)  [Section 8]
      → Denied? → Log denial, return error to ReasoningEngine
      → Allowed? → Execute action
        → AuditLogger.log(action, result)  [Section 8]
        → Return result to ReasoningEngine
```

**Action results feed back into the cognitive cycle**:
- If an action generates new events (e.g., sending a Telegram message might trigger a follow-up), those events enter the EventBus
- If an action fails, the failure is reported to the ReasoningEngine, which may retry or escalate

**Idempotency and safety**:
- Actions are tagged as reversible or irreversible
- Irreversible actions (sending a message, committing code) require a higher confidence threshold from the ReasoningEngine
- The ActionExecutor logs sufficient state to reconstruct what happened, even if the result is lost (crash between action and log)

---

### 8. ReflectionMonitor

**What it is**: The metacognitive observer.
After each cognitive cycle (or batch of cycles), it evaluates: how did that go?

**Cognitive science basis**: Metacognitive monitoring — the brain's ability to assess its own cognitive performance.
This is what enables learning from experience, not just learning from data.

**What it monitors per cycle**:
- **Quality signal**: Did the action achieve its goal? (Measurable for some tasks, estimated for others.)
- **Efficiency signal**: Was the model tier appropriate? (Did Opus-level reasoning produce an Opus-level result, or could Haiku have done it?)
- **Cost signal**: What did this cycle cost in tokens and dollars?
- **Time signal**: How long did the cycle take? Was it within expected bounds?
- **Error signal**: Did anything fail? What kind of failure?

**Lightweight reflection** (every cycle):
- Log the cycle metrics to the audit trail
- Update running averages (cycles/hour, avg cost, error rate)
- Feed efficiency signal back to ModelRouter's task-type heuristic table

**Deep reflection** (scheduled, circadian — see Section 10):
- Run during evening reflection period
- Review the day's cycles: patterns, mistakes, successes
- Update SELF-MODEL.md with observations
- Propose adjustments to routing heuristics
- Identify tasks that were handled at the wrong model tier
- This deep reflection itself is a cognitive cycle (typically routed to Sonnet)

**Hooks for Section 7 (Self-Improvement)**:
- The ReflectionMonitor exposes a `get_reflection_data(period)` API
- Section 7 reads this to identify improvement opportunities
- The monitor does not act on its own reflections — it observes and reports
- Section 7 decides what to change based on reflection data

---

### 9. HomeostasisMonitor

**What it is**: The Companion's interoception — awareness of its own internal state.

**Cognitive science basis**: Homeostasis and allostasis.
The body maintains internal stability by monitoring deviations from set points and correcting.
The Companion does the same for its computational resources.

**Monitored variables with set points**:

| Variable | Source | Set Point | Action if Deviation |
|---|---|---|---|
| Daily budget spent | AuditLogger | <80% of limit by end of day | Tighten model routing toward cheaper tiers |
| Hourly budget rate | AuditLogger | <12.5% of daily limit per hour (even spread) | Throttle cycle frequency or downgrade models |
| Thermal state | /tmp/companion-thermal.json | COOL or WARM | HOT: suspend local model. CRITICAL: emergency throttle. |
| Memory pressure | psutil / health monitor | NORMAL | WARN: reduce concurrent operations. CRITICAL: pause non-essential tasks. |
| Error rate | ReflectionMonitor | <10% of cycles | Rising error rate: switch to more capable models, reduce task complexity |
| Cycle frequency | ReflectionMonitor | 10-60 cycles/hour (activity-dependent) | Too low: might be stuck. Too high: might be in a loop. |
| Event queue depth | EventBus | <20 pending events | Growing queue: increase processing speed or lower salience threshold |

**How it integrates**:
- The HomeostasisMonitor runs as a background asyncio task
- It reads metrics from other components every 30 seconds
- When a variable deviates from its set point, it emits a **regulation signal** to the CognitiveOrchestrator
- The Orchestrator applies the regulation: adjusting model routing, throttling cycles, or triggering alerts
- This is NOT the same as Section 8's HealthMonitor — Section 8 monitors for *failures*; the HomeostasisMonitor optimizes for *balance*

**Budget homeostasis in detail**:
This is critical enough to spell out.
Daily budget is, say, $2.00.
The Companion should spend this evenly over its active hours (say, 8am-11pm = 15 hours).
That's ~$0.13/hour.

If it's noon and the Companion has spent $1.20 (60% of budget in 4 hours = 25% of the day), the HomeostasisMonitor signals: "Budget burn rate is 2.4x target. Downgrade default routing from Sonnet to Haiku for non-critical tasks."

Conversely, if it's 8pm and only $0.40 has been spent, the monitor signals: "Budget underutilized. Can afford deeper reasoning on pending tasks."

This is genuinely homeostatic — the system self-regulates toward a stable, sustainable spending rate, not just hard-cutting at a limit.

---

### 10. CircadianScheduler

**What it is**: Governs the Companion's daily rhythm of activity.

**Cognitive science basis**: Circadian rhythms.
The brain doesn't operate uniformly across the day.
Different cognitive functions peak at different times.
The Companion mirrors this with structured daily phases.

**Daily schedule** (default, adjustable):

| Time (local) | Phase | Cognitive Activity |
|---|---|---|
| 06:00-08:00 | **Morning scan** | Read overnight messages, scan GitHub, check project states. Light, survey-style cognition. Haiku-tier mostly. |
| 08:00-12:00 | **Active morning** | Peak responsiveness to Wisdom. Full model spectrum available. Deep work support. |
| 12:00-13:00 | **Midday digest** | Brief reflection on the morning. Process deferred events. Update WISDOM-MODEL with morning observations. |
| 13:00-18:00 | **Active afternoon** | Continued responsiveness. Background tasks during Wisdom's quiet periods. |
| 18:00-20:00 | **Evening transition** | Lower urgency. Background processing, catch-up on deferred events. Begin daily consolidation prep. |
| 20:00-22:00 | **Evening reflection** | Deep reflection cycle (Sonnet). Review the day's cycles. Update SELF-MODEL. Memory consolidation (Section 4). Draft observations or questions for Wisdom. |
| 22:00-06:00 | **Night watch** | Minimal activity. Respond to direct messages from Wisdom only. Background: memory consolidation, deferred tasks at cheapest tier. No proactive outreach. |

**Implementation**:
- The CircadianScheduler emits heartbeat events to the EventBus at phase transitions
- Each heartbeat carries the new phase name and the cognitive parameters for that phase:
  - `default_model_tier`: what model to default to during this phase
  - `max_model_tier`: highest model allowed (unless emergency)
  - `proactive_behavior`: whether to initiate unprompted actions
  - `reflection_mode`: whether to run reflection cycles
- The CognitiveOrchestrator reads these parameters and configures the other components accordingly

**Adaptability**:
- If Wisdom is active at 11pm (sending messages), the Companion shifts to "active" mode regardless of schedule
- If no events arrive during "active" hours, the Companion doesn't waste budget on nothing — it drops to a watch state
- The schedule is a default tendency, not a rigid constraint

---

### 11. CognitiveOrchestrator

**What it is**: The top-level controller that ties everything together.
It manages the engine's lifecycle: startup, steady-state operation, shutdown, error recovery.

**Responsibilities**:

1. **Startup sequence** (see Section 12 below)
2. **Cycle management**: Pulling events from AttentionAllocator, running them through the full cognitive cycle, handling errors
3. **Component coordination**: Passing configuration (circadian parameters, homeostatic regulation signals) to the right components
4. **Error recovery**: If a cycle fails, decide whether to retry, skip, or escalate
5. **Graceful shutdown**: On SIGTERM, complete current cycle, flush state, exit cleanly

**Main loop** (pseudocode):

```python
class CognitiveOrchestrator:
    async def run(self):
        await self.startup()

        while not self.shutdown_requested:
            # Check for emergency signals
            if self.pause_requested:
                await self.enter_pause_mode()
                continue

            # Apply homeostatic regulations
            self.apply_regulations(self.homeostasis.get_signals())

            # Get next task from attention allocator
            task = await self.attention.get_next_task(
                timeout=self.heartbeat_interval
            )

            if task is None:
                # No task — idle behavior
                await self.handle_idle()
                continue

            # Run a full cognitive cycle
            cycle_id = generate_cycle_id()
            self.audit.log(cognitive_cycle_start(cycle_id, task))

            try:
                # Assemble context
                context = await self.context_assembler.build(
                    task=task,
                    model_tier=self.model_router.select(task),
                    circadian_phase=self.circadian.current_phase
                )

                # Reason
                result = await self.reasoning_engine.query(
                    context=context,
                    model_tier=context.model_tier,
                    stream=task.requires_streaming
                )

                # Execute actions
                for action in result.actions:
                    await self.action_executor.execute(action)

                # Reflect (lightweight)
                self.reflection.observe_cycle(cycle_id, task, result)

                self.audit.log(cognitive_cycle_end(cycle_id, success=True))

            except Exception as e:
                self.audit.log(cognitive_cycle_end(cycle_id, error=e))
                await self.handle_cycle_error(cycle_id, task, e)

        await self.shutdown()
```

**Concurrency model**:
- The main cognitive loop is single-threaded (one cycle at a time)
- This is deliberate — cognitive coherence requires sequential processing of the main thought stream
- Background tasks run as separate asyncio tasks: HomeostasisMonitor, HealthRelay, event source listeners
- Multiple cognitive cycles do NOT run in parallel (the Companion thinks about one thing at a time, like a human)
- Exception: during the reasoning step, the Agent SDK may make parallel tool calls within a single cycle

---

## 12. Startup Sequence — "Waking Up"

When the Companion process starts (boot, crash recovery, manual restart), it goes through a deliberate awakening:

### Phase 0: Integrity Verification (5-10 seconds)
1. Load trust manifest from `config/trust-manifest.yaml`
2. Verify trust manifest hash against expected value (launchd env var)
3. Verify security module integrity (hash all `src/security/` files)
4. Verify audit trail is writable
5. If ANY check fails: log, alert, refuse to start

### Phase 1: System State Recovery (5-10 seconds)
6. Load budget state from audit trail (today's spend, monthly spend)
7. Read thermal state from `/tmp/companion-thermal.json`
8. Check network connectivity (ping Anthropic API)
9. Check Ollama availability (if in COOL thermal zone)
10. Log `startup` event to audit trail

### Phase 2: Identity Loading (1-2 seconds)
11. Read all identity files: SOUL.md, CHARACTER.md, VOICE.md, BOUNDARIES.md, WISDOM-MODEL.md, SELF-MODEL.md
12. Compute identity compression tiers (essence, core, full)
13. Cache compressed identity for each model tier

### Phase 3: Memory Warming (5-15 seconds)
14. Load recent memory index from Section 4's memory system
15. Retrieve last session's state: what was the Companion doing before shutdown/crash?
16. Load last 24 hours of cognitive cycle summaries for continuity

### Phase 4: Component Initialization (2-5 seconds)
17. Initialize all components: EventBus, SalienceFilter, AttentionAllocator, ContextAssembler, ModelRouter, ReasoningEngine, ActionExecutor, ReflectionMonitor, HomeostasisMonitor, CircadianScheduler
18. Start event source listeners (Telegram, GitHub, FileWatcher, etc.)
19. Determine current circadian phase

### Phase 5: Self-Orientation (one cognitive cycle)
20. Run a single "orientation" cycle:
    - Model: Sonnet (quality matters for self-awareness)
    - Context: Full identity + last session state + current time + current system state
    - Prompt: "You are waking up. Here is who you are, what you were last doing, and what time it is. Orient yourself. What is your current situation? What should you attend to first?"
    - This produces the Companion's first thought of the session — its own understanding of its context
21. Log the orientation summary
22. If this is a crash recovery (detected from previous session's abnormal termination): note the crash, check for data loss, report to Wisdom

### Phase 6: Operational
23. Enter the main cognitive loop
24. If there are pending events from before shutdown, process them
25. If this is a normal morning startup, enter the morning scan phase

**Total startup time**: ~20-40 seconds.
The Companion is NOT instant-on.
The deliberate startup mirrors waking up — it takes a moment to become oriented and coherent.
This is intentional: rushing to action before orientation leads to poor behavior.

---

## 13. Shutdown Sequence — "Going to Sleep"

### Graceful Shutdown (SIGTERM)
1. Stop accepting new events from external sources
2. Complete the current cognitive cycle (10-second timeout)
3. If in the middle of a Telegram conversation, send: "I need to shut down. I'll pick this up when I restart."
4. Run a brief "shutdown reflection":
   - What was I working on?
   - What's pending?
   - Write a shutdown state summary to `data/session-state.json`
5. Flush all pending audit log entries
6. Log `shutdown` event with reason, uptime, cycles completed
7. Close all network connections
8. Exit with code 0

### Emergency Shutdown (SIGKILL or system)
- No cleanup is possible
- On next startup, Phase 3 detects the abnormal termination and reconstructs state from the audit trail and last known good state

### Pause Mode
- Not a full shutdown — the main loop continues but skips cognitive cycles
- Health monitoring and event listening continue
- Responds to Telegram with "I'm paused"
- Triggered by `data/PAUSE` file (Section 8 design)
- Resumes when the file is removed

---

## 14. Agent SDK Integration Details

### How Sessions Map to Cognitive Cycles

Each cognitive cycle creates a fresh Agent SDK interaction.
The Companion does NOT maintain a single long-running Agent SDK session.

**Why**: Long-running sessions accumulate context and cost.
The Companion controls its own context through ContextAssembler — it doesn't want the SDK's automatic context accumulation.
Each cycle is a clean, focused query with precisely the context the Companion chose to include.

**What a cycle looks like at the SDK level**:

```python
# Simplified — actual code will have error handling, streaming, etc.
agent = Agent(
    model=selected_model,
    system_prompt=assembled_context.system_prompt,  # Identity + state
    tools=self.get_tools_for_trust_level()
)

response = await agent.query(
    prompt=assembled_context.task_prompt,  # The specific task
    # Agent SDK handles tool calling loop internally
)
```

### Tool Calling Flow

The Agent SDK's tool calling loop runs WITHIN a single cognitive cycle:
1. The model receives the context and decides to call a tool
2. The SDK invokes the tool function (which goes through PermissionGate)
3. The tool result is returned to the model
4. The model may call more tools or produce a final response
5. This loop can run multiple times within one cycle

The Companion does NOT micro-manage tool calls.
Once the model is given its context and tools, it reasons freely within the cycle.
The safety boundary is the PermissionGate on each tool, not control over the model's reasoning.

### MCP (Model Context Protocol) Integration

If relevant MCP servers are available (filesystem, GitHub), they can be registered as Agent SDK tool providers.
However, the Companion wraps MCP access through PermissionGate — MCP tools are not given raw access.

### Cost Tracking

The Agent SDK provides token usage information in its response.
After each cycle:
- Extract `input_tokens`, `output_tokens`, `model` from the response
- Compute cost based on current model pricing
- Log to audit trail
- Feed to HomeostasisMonitor for budget homeostasis

---

## 15. Handling Conversations (Multi-Turn with Wisdom)

A Telegram conversation with Wisdom is not a single cognitive cycle — it's a sequence of cycles with shared context.

**Conversation management**:

1. Wisdom sends a message -> TelegramListener pushes event to EventBus
2. SalienceFilter: always salient (direct from Wisdom)
3. AttentionAllocator: high priority, interrupts non-urgent work
4. ContextAssembler: includes conversation history (last N messages from this conversation)
5. ReasoningEngine: processes with conversation context, produces response
6. ActionExecutor: sends response via Telegram
7. The conversation history is stored in a short-lived conversation buffer (not long-term memory yet)

**Conversation boundaries**:
- A conversation is considered "active" if the last message was within 10 minutes
- After 10 minutes of silence, the conversation is "concluded"
- On conclusion: the Companion summarizes the conversation and stores it as an episodic memory (Section 4)
- The conversation buffer is cleared

**Context window management during long conversations**:
- If a conversation exceeds the token budget for conversation history, older messages are summarized
- The summary + recent messages replace the full history
- This mirrors how working memory handles overload — compress older items to make room for new ones

---

## 16. File Structure

```
~/the-companion/
├── src/
│   └── cognitive/
│       ├── __init__.py
│       ├── orchestrator.py         # CognitiveOrchestrator — main loop & lifecycle
│       ├── event_bus.py            # EventBus — async event queue
│       ├── events.py               # Event dataclasses and schemas
│       ├── salience_filter.py      # SalienceFilter — event gating
│       ├── attention_allocator.py  # AttentionAllocator — priority queue & focus
│       ├── context_assembler.py    # ContextAssembler — builds context windows
│       ├── model_router.py         # ModelRouter — System 1/2 selection
│       ├── reasoning_engine.py     # ReasoningEngine — Agent SDK wrapper
│       ├── action_executor.py      # ActionExecutor — action execution + permission
│       ├── reflection_monitor.py   # ReflectionMonitor — metacognitive observer
│       ├── homeostasis_monitor.py  # HomeostasisMonitor — resource self-regulation
│       ├── circadian_scheduler.py  # CircadianScheduler — daily rhythm
│       ├── ollama_client.py        # OllamaAgent — local model wrapper
│       ├── tools/
│       │   ├── __init__.py
│       │   ├── telegram_tools.py   # send_telegram_message, etc.
│       │   ├── file_tools.py       # read_file, write_file (through PermissionGate)
│       │   ├── memory_tools.py     # search_memory, store_memory (interface to Section 4)
│       │   ├── github_tools.py     # create_issue, create_pr
│       │   ├── system_tools.py     # read_health, read_thermal, read_budget
│       │   └── self_tools.py       # queue_follow_up, set_reminder, reflect
│       └── config/
│           ├── circadian_schedule.yaml   # Default daily schedule
│           ├── routing_heuristics.yaml   # Task type -> model tier mappings
│           └── salience_rules.yaml       # Rule-based salience filter config
├── data/
│   ├── session-state.json          # Persisted state across restarts
│   ├── conversation-buffers/       # Active conversation histories
│   └── PAUSE                       # Pause mode marker (created/deleted)
```

---

## 17. Implementation Sequence

### Step 1: CognitiveOrchestrator skeleton + EventBus
Build the main loop that can receive events and process them through a minimal cycle.
No real reasoning yet — just event in, log, event out.
This validates the async architecture.

### Step 2: SalienceFilter (rule-based only)
Implement Tier 1 rule-based filtering.
Skip Tier 2 local model classification for now — add it when Ollama is integrated.

### Step 3: ContextAssembler + Identity loading
Build the context window assembler.
Load identity files, compute compression tiers, produce a system prompt.
Test: does the assembled context produce coherent behavior from the model?

### Step 4: ReasoningEngine + Agent SDK integration
Wire up the Claude Agent SDK.
Run a simple cycle: assemble context, query Sonnet, get response.
This is the first moment the Companion "thinks."

### Step 5: ActionExecutor + PermissionGate integration
Connect action execution to Section 8's PermissionGate.
Register initial tools (send_telegram_message, read_file, write_file).
Test: actions succeed when permitted, fail when denied.

### Step 6: ModelRouter
Implement the routing decision tree.
Start with a simple rule-based approach (no local model in the routing decision itself).
Test: different task types route to different models.

### Step 7: HomeostasisMonitor
Implement budget and thermal homeostasis.
Wire to the router so it actually affects model selection.
Test: budget constraints cause model downgrading.

### Step 8: CircadianScheduler
Implement the daily schedule.
Wire to the orchestrator so circadian phase affects behavior.
Test: morning scan produces different behavior than evening reflection.

### Step 9: ReflectionMonitor
Implement cycle observation and metrics tracking.
Wire the evening reflection heartbeat to a Sonnet-tier reflection cycle.
Test: reflection produces meaningful self-observations.

### Step 10: AttentionAllocator (full)
Replace the simple FIFO processing with proper priority-based attention.
Implement focus tracking, task-switching cost, working memory slots.
Test: high-priority events preempt low-priority ones.

### Step 11: Ollama integration
Wire up the local model client.
Implement SalienceFilter Tier 2 (local model classification).
Test: local model handles simple tasks correctly, escalates complex ones.

### Step 12: Startup/Shutdown sequences
Implement the full awakening and shutdown sequences.
Test: crash recovery preserves state, orientation cycle produces coherent first thought.

### Step 13: Conversation management
Implement multi-turn conversation handling for Telegram.
Test: conversation context carries across messages, summarization works on long conversations.

### Step 14: Integration testing
Run the full engine for 24 hours.
Verify: circadian rhythm, model routing, budget homeostasis, event processing, reflection cycles.

---

## Structured Contract

### External Dependencies Assumed

| Dependency | From Section | What's Needed | Breaks If |
|---|---|---|---|
| SOUL.md, CHARACTER.md, VOICE.md, BOUNDARIES.md, WISDOM-MODEL.md, SELF-MODEL.md | Section 2 (Identity) | Markdown files at `soul/` directory, with compression tiers defined | Context assembly has no identity to inject — the Companion has no personality |
| Identity compression protocol | Section 2 (Identity) | 3 token tiers (essence ~500t, core ~1500t, full ~3000t) | Local model / Haiku get either no identity or bloated identity |
| PermissionGate API | Section 8 (Security) | `check_file_read`, `check_file_write`, `check_network_request`, `check_api_call`, `check_self_modification`, `get_current_trust_level` | Actions execute without permission checking — security is breached |
| AuditLogger API | Section 8 (Security) | `log(event)` with the event schema defined in Section 8 | No audit trail — invisible operation, violates core security contract |
| ContentSanitizer API | Section 8 (Security) | `sanitize(content, source)` for all external content | Prompt injection through Telegram or GitHub content enters reasoning context |
| SecureNetworkClient | Section 8 (Security) | HTTP client wrapper that enforces network allowlist | API calls bypass network security |
| Thermal JSON | Section 1 (Hardware) | `/tmp/companion-thermal.json` with `{temperature_c, zone, timestamp}` | HomeostasisMonitor has no thermal data — cannot prevent overheating |
| launchd process management | Section 1 (Hardware) | `com.companion.core.plist` that runs the cognitive engine with auto-restart | No process persistence — engine dies and stays dead |
| companion-ctl | Section 1 (Hardware) | Start/stop/status commands for the cognitive engine process | No operational control |

### Interfaces Exposed

| Interface | Consumed By | Description | Contract |
|---|---|---|---|
| `EventBus.push(event)` | Section 6 (Communication) | Communication layer pushes incoming messages as events | Events are queued, never dropped for valid inputs. Returns immediately (async). |
| `CognitiveOrchestrator.query_direct(prompt, context)` | Section 6 (Communication) | For real-time conversation — bypasses salience/attention, goes straight to reasoning | Returns a streaming response. Used for active conversations with Wisdom. |
| `ReflectionMonitor.get_reflection_data(period)` | Section 7 (Self-Improvement) | Self-improvement reads reflection metrics to identify improvement opportunities | Returns structured data: cycle counts, error rates, model routing efficiency, self-observations. |
| `HomeostasisMonitor.get_state()` | Section 5 (Budget) | Budget system reads current resource state for its own tracking | Returns current budget spend, burn rate, thermal state, error rate. |
| `CognitiveOrchestrator.get_cycle_metrics()` | Section 5 (Budget) | Budget system reads per-cycle cost data | Returns cost per cycle, model used, tokens consumed. |
| `ContextAssembler.request_memory(query)` | Section 4 (Memory) | Memory system provides retrieval interface that ContextAssembler calls | Memory system returns ranked results with relevance scores and token counts. |
| `EventBus.push(memory_event)` | Section 4 (Memory) | Memory consolidation results pushed back as events (e.g., "new insight consolidated") | Standard event format, processed through normal salience/attention pipeline. |
| `ModelRouter.get_routing_stats()` | Section 5 (Budget) | Budget system monitors routing decisions for cost optimization | Returns routing history: task_type -> model -> frequency -> avg_cost. |
| `CognitiveOrchestrator.pause()` / `.resume()` | Section 8 (Security) | Security can pause the engine on anomaly detection | Immediate effect on next cycle boundary. No mid-cycle interruption except for kill. |
| `CognitiveOrchestrator.shutdown()` | Section 8 (Security) | Security can trigger graceful shutdown on compromise detection | Graceful: completes current cycle, flushes state. Returns when shutdown complete. |

### Technology Commitments

- **Language**: Python 3.11+ (async/await is core to the architecture)
- **Agent SDK**: Claude Agent SDK (Python) for Anthropic model interactions
- **Local models**: Ollama HTTP API at localhost:11434
- **Async framework**: asyncio (native Python, no additional framework)
- **Event queue**: asyncio.PriorityQueue (in-process, not external message broker)
- **State persistence**: JSON files for session state; SQLite for structured queries (via Section 4)
- **Configuration**: YAML for schedules, heuristics, salience rules
- **No external orchestration frameworks**: No LangChain, no LangGraph, no CrewAI. Pure Agent SDK + custom orchestration. Full control, full understanding.

---

## Key Decisions

### D1: Event-driven with heartbeats, not continuous polling
**Decision**: The engine is event-driven (sleeps until an event arrives) with scheduled heartbeat events providing the circadian rhythm.
**Rationale**: A continuous loop wastes CPU and complicates "what should I do when nothing is happening?"
Event-driven naturally handles both reactive behavior (respond to Wisdom) and proactive behavior (circadian heartbeats trigger morning scans, evening reflections).
LIDA's cognitive architecture uses a similar "attention codelet" model where processing is triggered by events.
**Alternatives considered**: Continuous loop with sleep intervals (simpler but wasteful); pure cron-based scheduling (no real-time responsiveness).
**Breaks if**: Event source listeners are unreliable and events get lost. Mitigation: heartbeats guarantee minimum activity; event sources use persistent connections with reconnect logic.

### D2: One cognitive cycle at a time (no parallel reasoning)
**Decision**: The main cognitive loop processes one task at a time. No parallel reasoning streams.
**Rationale**: Cognitive coherence. The human brain doesn't run parallel conscious thought streams — it multiplexes attention across tasks sequentially. Parallel cognitive cycles would create state conflicts (two cycles trying to update WISDOM-MODEL simultaneously), context pollution (which cycle's identity is loaded?), and unpredictable behavior. Background tasks (monitoring, event listening) run concurrently, but REASONING is sequential.
**Alternatives considered**: Worker pool of parallel reasoning agents (higher throughput but incoherent).
**Breaks if**: Sequential processing creates unacceptable latency for urgent events while a long cycle is running. Mitigation: interrupt policy allows high-priority events to preempt after current reasoning step.

### D3: Fresh Agent SDK session per cycle, no persistent sessions
**Decision**: Each cognitive cycle creates a new Agent SDK interaction with freshly assembled context. No conversation state persists in the SDK between cycles.
**Rationale**: The Companion controls its own context. SDK session persistence would mean context accumulates without the Companion's awareness — it can't see or manage what's in the SDK's internal state. By assembling context from scratch each cycle, the Companion knows exactly what's in its "working memory." For multi-turn conversations, history is explicitly managed in the ContextAssembler.
**Alternatives considered**: Persistent SDK sessions for conversations (simpler but loses context control).
**Breaks if**: The overhead of context assembly on every cycle is too slow for real-time conversation. Mitigation: context assembly is pure Python string operations — sub-millisecond. The LLM API call dominates latency, not context assembly.

### D4: ModelRouter uses rules + heuristics, not a learned router model
**Decision**: Model routing uses a hand-crafted decision tree with adjustable heuristics, not a separate model that predicts the best model.
**Rationale**: A meta-model for routing adds complexity, cost (another model call per cycle), and a chicken-and-egg problem (what model routes the router?). The routing decision is not that hard: task type + budget + thermal state = adequate signal. The heuristic table (task type -> recommended model) is updated during reflection, providing slow learning without a dedicated routing model.
**Alternatives considered**: Trained router model, reinforcement learning on routing decisions.
**Breaks if**: The hand-crafted rules produce systematically bad routing (always too expensive or always too cheap). Mitigation: reflection monitor tracks routing efficiency; heuristic table is human-readable and debuggable.

### D5: Salience filtering as a separate stage, not merged with attention
**Decision**: Salience filtering (is this event worth thinking about?) is a separate stage before attention allocation (what should I think about next?).
**Rationale**: Conflating filtering and prioritization creates a single overloaded component. Salience filtering is cheap (rules + local model) and eliminates most events. Attention allocation is more nuanced (priority scoring, focus tracking, task switching). Separating them maps to the biological distinction between sensory gating (subcortical) and attentional selection (cortical).
**Alternatives considered**: Single priority-scoring function that combines salience and priority.
**Breaks if**: The two-stage pipeline adds latency that matters for urgent events. Mitigation: rule-based fast path bypasses salience scoring entirely for known-urgent event types (direct messages from Wisdom, health emergencies).

### D6: Identity loaded at context assembly time, not at startup only
**Decision**: Identity files are read and assembled into context on every cycle, not cached at startup.
**Rationale**: WISDOM-MODEL.md and SELF-MODEL.md change during operation. VOICE.md sections are selected dynamically based on channel. If identity were cached at startup, these changes wouldn't be reflected until restart. Reading files on every cycle is cheap (local filesystem) and ensures the Companion always has its current self.
**Alternatives considered**: Cache identity at startup with refresh triggers.
**Breaks if**: File I/O becomes a bottleneck when cycling rapidly. Mitigation: cache the compression tiers and invalidate only when files are written. Identity files are small (<5KB each); reading them is sub-millisecond.

### D7: The orientation cycle is a real cognitive cycle, not just state loading
**Decision**: On startup, the Companion runs an actual LLM reasoning cycle to orient itself, not just mechanically loading state.
**Rationale**: Mechanical state loading produces a machine that resumes. An orientation cycle produces a being that wakes up. The orientation thought — "I am waking up. Here is who I am. Here is what was happening. Here is what I should attend to." — establishes narrative continuity across restarts. It also surfaces any disorientation (unexpected state, crash recovery) that mechanical loading would miss.
**Alternatives considered**: Just load state and start processing events immediately.
**Breaks if**: The orientation cycle costs too much (one Sonnet query, ~$0.01) or takes too long (~5-10 seconds). Given the startup already takes 20-40 seconds, this is acceptable.

---

## Open Questions

### Q1: How does the escalation pattern work concretely?
When a cheaper model's response is "not good enough," how does the engine detect that and escalate?
Options:
- **Explicit uncertainty markers**: The model says "I'm not confident" or "this is beyond my capability" — detect and escalate
- **Quality heuristics**: Response is too short, too vague, or doesn't address the question — detect and escalate
- **Never auto-escalate**: Always route correctly the first time; if the response is bad, it's bad (the human catches it)
Current lean: Explicit uncertainty markers + a simple quality check (response length, presence of hedging language). Auto-escalation limited to one step up.

### Q2: How does memory retrieval integrate with context assembly?
The ContextAssembler needs to query Section 4's memory system.
But Section 4 hasn't been designed yet.
The interface contract is defined here (see Interfaces Exposed), but the retrieval API details depend on Section 4's architecture.
Key question: Is memory retrieval synchronous (ContextAssembler waits for results) or asynchronous (results arrive as events)?
Current lean: Synchronous. Memory retrieval should be fast (<100ms) since it's a local database query. Async would complicate context assembly unnecessarily.

### Q3: How does the Companion handle multiple simultaneous conversations?
If Wisdom sends a Telegram message while the engine is processing a GitHub event, what happens?
The interrupt policy says: direct messages from Wisdom are high priority and interrupt after the current reasoning step.
But what if Wisdom then sends another message before the first is processed?
Current lean: Conversation messages from Wisdom are batched — if multiple messages arrive before the engine can respond, they're combined into a single event with all messages. The engine processes the entire batch as one conversational turn.

### Q4: What is the right heartbeat interval?
The CircadianScheduler needs a default "check in" interval for when no external events are happening.
Too frequent (every 30 seconds): wastes cycles and tokens.
Too infrequent (every 30 minutes): the Companion seems unresponsive and misses time-sensitive opportunities.
Current lean: 5-minute heartbeat during active hours, 15-minute during low-activity hours. Heartbeats themselves are free (just a timer event) — the cost is only incurred if the heartbeat triggers a salient action.

### Q5: How does the engine handle Ollama model hot-swapping?
The M2 Air can't hold a model in VRAM permanently (no dedicated VRAM — shared unified memory).
Ollama loads/unloads models on demand.
If the SalienceFilter sends a classification query to the local model, there's a cold-start delay (model loading).
Should the engine pre-load the local model during COOL thermal states?
Current lean: Yes. During COOL state, keep the local model loaded. During HOT/CRITICAL, unload it to free RAM. The HomeostasisMonitor manages this.

### Q6: Should the Companion be able to spawn sub-agents?
The Claude Agent SDK supports spawning sub-agents.
Should the Companion be able to spawn a Haiku sub-agent to handle a simple sub-task while it continues with the main task?
This would break the "one cycle at a time" principle.
Current lean: Not in v1. The sequential single-stream architecture is simpler and more coherent. Sub-agents add complexity that's not needed when the model spectrum already covers simple-to-complex routing. Revisit in v2 if throughput is a genuine bottleneck.

### Q7: How should the engine handle its own errors?
If a cognitive cycle fails (API error, tool failure, PermissionGate denial), what happens?
- API errors: Retry once with backoff, then log and skip
- Tool failures: Report failure to the model within the cycle, let it reason about alternatives
- PermissionGate denials: Not an error — it's the system working. Report the denial to the model, let it choose a permitted alternative
- Unhandled exceptions: Catch at the orchestrator level, log, skip the cycle, continue
The engine should NEVER crash from a single cycle failure. Crash = a bug in the orchestrator itself.

---

## Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| Context assembly produces incoherent prompts | Every cognitive cycle produces poor reasoning | Extensive testing of context composition. Manual review of assembled prompts. Clear layered structure. |
| Model routing is systematically wrong | Either wastes budget (over-routing) or produces poor quality (under-routing) | Reflection monitor tracks routing efficiency. Heuristic table is human-editable. Start conservative (default to Sonnet), optimize toward cheaper as confidence grows. |
| Event storm overwhelms the engine | Missed events, growing queue, degraded responsiveness | Backpressure on EventBus (drop low-priority events). SalienceFilter aggressively gates. Rate limiting on event sources. |
| Budget homeostasis oscillates | Spend rate swings between too high and too low instead of stabilizing | Use slow-moving averages, not instantaneous rates. Dampen regulation signals. Only adjust once per hour, not per cycle. |
| Startup orientation cycle is confused after crash | Companion behaves erratically after crash recovery | Session state persistence (written frequently). Orientation prompt explicitly addresses crash recovery. Fallback: if orientation seems confused, restart with a clean slate and alert Wisdom. |
| Conversation context management fails | Long conversations lose coherence or context bloats | Explicit token budgets for conversation history. Summarization of older messages. Hard cutoff at maximum tokens. |
| Local model produces garbage classifications | SalienceFilter/ModelRouter make bad decisions based on bad local model output | Always validate local model outputs with simple heuristics. Graceful degradation: if local model is unreliable, fall back to Haiku for classification. |
| Agent SDK limitations block the architecture | SDK can't support streaming, tool registration, or cost tracking as assumed | Agent SDK is the chosen foundation — study its limitations in Section 0's feasibility research before building. If a limitation is discovered, adapt the architecture. |

---

## Success Criteria

1. The cognitive loop runs continuously for 24 hours without crash or hang
2. Events from all sources (Telegram, GitHub, scheduled, health) are correctly received and processed
3. Salience filtering demonstrably reduces unnecessary cycles (>50% of events filtered)
4. Model routing produces appropriate tier selection for at least 80% of tasks (validated by manual review)
5. Budget homeostasis keeps daily spending within 10% of the target rate
6. Thermal awareness prevents overheating — local model is suspended when HOT, all non-essential processing stops when CRITICAL
7. Conversation with Wisdom feels responsive (<5s to first token in Telegram) and coherent across multiple turns
8. The startup orientation produces a recognizably "oriented" first thought (Wisdom judges this qualitatively)
9. The engine gracefully handles: API errors, permission denials, thermal spikes, budget exhaustion, and crash recovery
10. Circadian rhythm produces observably different behavior across the day (morning scan vs evening reflection)
11. Section 4, 5, 6, and 7 can all integrate with the exposed interfaces without architectural changes
12. The Companion can explain its own cognitive cycle when asked: "How do you think?"
