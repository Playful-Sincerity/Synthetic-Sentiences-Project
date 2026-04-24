# Section 3: Core Cognitive Engine — Detailed Plan

## Purpose

Build the brain.
The Cognitive Engine is the central perception-attention-reasoning-action loop that everything else plugs into.
It receives perceptions from the world (Telegram messages, scheduled triggers, file changes, its own reflections).
It decides what deserves attention.
It routes to the right model tier for reasoning.
It produces actions.
It does all of this within budget, within security constraints, and in character.

Every other section is either upstream (feeding the engine) or downstream (consuming its outputs):
- Section 4 (Memory) hooks into the loop to store and retrieve
- Section 5 (Budget) wraps the reasoning step to enforce cost limits
- Section 6 (Communication) feeds perceptions in and receives actions out
- Section 7 (Self-Improvement) observes the loop's performance
- Section 8 (Security) gates every action through the permission system

The Cognitive Engine is to The Companion what the cortical-thalamic loop is to a mammalian brain: the central coordinating architecture that turns raw stimuli into coherent behavior.

---

## Design Philosophy

### Why Not Just Chain LLM Calls

Most agent frameworks treat the LLM as a function: input goes in, output comes out, repeat.
The Companion needs something richer:

1. **Continuous awareness, not request-response**: The engine runs perpetually, not just when spoken to. It perceives, even when idle.
2. **Graded cognition**: Not every perception deserves the same depth of thought. A temperature reading gets a reflex; an architectural question gets deep reasoning.
3. **Identity-infused processing**: Every cognitive cycle is colored by who the Companion is. SOUL.md isn't decoration — it shapes how perceptions are interpreted and which actions are selected.
4. **Self-aware operation**: The engine monitors its own performance, thermal state, budget position, and error rate. It adjusts its behavior based on self-knowledge.
5. **Concurrency with coherence**: Multiple inputs can arrive simultaneously. The engine must handle them without losing narrative coherence about what it's doing and why.

### Cognitive Science Grounding

The engine's architecture draws from three traditions:

**Global Workspace Theory (Baars/Dehaene)** — LIDA architecture:
- A central "workspace" where the current focus of cognition lives
- Specialist modules (perception, memory, planning) compete for access to the workspace
- Only what enters the workspace gets conscious processing; everything else stays unconscious
- Maps to: the context window IS the workspace. Perceptions compete for inclusion.

**Dual Process Theory (Kahneman)** — System 1 / System 2:
- System 1: fast, automatic, cheap, often sufficient
- System 2: slow, deliberate, expensive, needed for hard problems
- Maps to: model tier routing. Local/Haiku = System 1. Sonnet = considered System 2. Opus = deep System 2.

**Predictive Processing (Clark/Friston)** — the brain as prediction machine:
- The brain constantly predicts what will happen next
- It only deeply processes prediction errors (surprises)
- Maps to: the attention system. Routine events get reflexes. Surprising events get deep processing.

---

## The Cognitive Loop

### Overview

```
    ┌──────────────────────────────────────────────────────────┐
    │                   COGNITIVE CYCLE                         │
    │                                                          │
    │  ┌─────────┐   ┌──────────┐   ┌───────────┐   ┌──────┐ │
    │  │ PERCEIVE│──▶│ ATTEND   │──▶│  REASON   │──▶│ ACT  │ │
    │  │         │   │          │   │           │   │      │ │
    │  │ Gather  │   │ Score    │   │ Route to  │   │ Take │ │
    │  │ inputs  │   │ salience │   │ right     │   │action│ │
    │  │         │   │ Filter   │   │ model     │   │      │ │
    │  │         │   │ Prioritize│  │ Think     │   │      │ │
    │  └─────────┘   └──────────┘   └───────────┘   └──────┘ │
    │       ▲                                          │      │
    │       └──────────────────────────────────────────┘      │
    │                    (feedback loop)                        │
    │                                                          │
    └──────────────────────────────────────────────────────────┘
                              ▲
                              │
              ┌───────────────┼───────────────┐
              │               │               │
         ┌────┴────┐   ┌─────┴─────┐   ┌─────┴─────┐
         │ MONITOR │   │  REFLECT  │   │   SLEEP   │
         │         │   │           │   │           │
         │ Health, │   │ Meta-     │   │ Consoli-  │
         │ thermal,│   │ cognitive │   │ date,     │
         │ budget  │   │ self-     │   │ compress, │
         │ checks  │   │ assessment│   │ prune     │
         └─────────┘   └───────────┘   └───────────┘
```

### Stage 1: PERCEIVE

**What it does**: Gathers all available inputs from the environment into a unified perception buffer.

**Inputs (perception sources)**:
- **Message queue**: Telegram messages, voice transcriptions (from Section 6)
- **Scheduled triggers**: Cron-like events (morning scan, evening reflection, hourly check-in)
- **System state**: Thermal JSON (`/tmp/companion-thermal.json`), health JSONL, memory pressure
- **File watchers**: Changes to key files in Wisdom's projects (if configured)
- **Self-generated**: Pending tasks, follow-ups from previous cycles, queued reflections
- **GitHub events**: New issues, PR comments, CI results (when connected)

**Perception data structure**:

```python
@dataclass
class Perception:
    id: str                          # Unique perception ID (uuid)
    source: PerceptionSource         # Enum: telegram, schedule, system, file_watch, self, github
    timestamp: datetime              # When the perception was created
    content: str | dict              # Raw content (message text, JSON state, etc.)
    metadata: dict                   # Source-specific metadata
    priority_hints: dict             # Initial priority signals from the source
    requires_response: bool          # Does this need an outbound action?
    response_deadline: datetime | None  # When must a response be sent by?

class PerceptionSource(Enum):
    TELEGRAM = "telegram"
    VOICE = "voice"
    SCHEDULE = "schedule"
    SYSTEM = "system"
    FILE_WATCH = "file_watch"
    SELF = "self"
    GITHUB = "github"
```

**How perceptions arrive**:
The engine runs an async event loop. Each perception source has a dedicated collector (a lightweight async task) that:
1. Polls or listens on its source
2. Wraps raw events into `Perception` objects
3. Pushes them into a shared `PerceptionBuffer` (async queue)

The perception buffer is the Companion's "sensory cortex" — it holds everything that has happened since the last cycle, ordered by arrival time.

**Perception collectors**:

| Collector | Source | Mechanism | Frequency |
|-----------|--------|-----------|-----------|
| `TelegramCollector` | Telegram API | Long-polling (via python-telegram-bot) | Continuous |
| `ScheduleCollector` | Internal cron table | Timer-based | Per-schedule |
| `SystemStateCollector` | Thermal JSON, psutil, disk | File read + system calls | Every 30s |
| `FileWatchCollector` | Watchdog library on configured dirs | inotify-equivalent | On change |
| `SelfCollector` | Internal task queue, reflection triggers | Queue read | On push |
| `GitHubCollector` | GitHub API polling | HTTP poll | Every 5 min |
| `VoiceCollector` | Voice pipeline output queue | Queue read | Continuous when voice active |

**Key design decisions for PERCEIVE**:
- Collectors are independent async tasks. If one fails, others continue.
- Each collector is responsible for its own error handling and backoff.
- The perception buffer has a maximum size (e.g., 100 items). If it fills, lowest-priority items are dropped with an audit log entry.
- System state perceptions are always generated, even when nothing else is happening. The Companion is always aware of its own physical state.

---

### Stage 2: ATTEND

**What it does**: Scores each perception for salience, filters out noise, and selects which perceptions to process in this cycle. This is the attentional bottleneck — the Companion cannot (and should not) deeply process everything.

**Salience scoring dimensions**:

Each perception is scored on five dimensions, producing a composite salience score:

| Dimension | What It Measures | Scale | Examples |
|-----------|-----------------|-------|---------|
| **Urgency** | Time pressure. Does this need action NOW? | 0-1.0 | Telegram message from Wisdom = 0.8; scheduled reflection = 0.2 |
| **Relevance** | Connection to current goals and active projects | 0-1.0 | Message about active project = 0.9; random notification = 0.1 |
| **Novelty** | How surprising/unexpected is this? (prediction error) | 0-1.0 | New topic = 0.8; routine health check = 0.1 |
| **Emotional weight** | Inferred emotional significance to Wisdom | 0-1.0 | Wisdom sounds frustrated = 0.7; routine status update = 0.1 |
| **Cost of ignoring** | What happens if we don't address this? | 0-1.0 | Budget alert = 0.9; low-priority file change = 0.1 |

**Composite score**:
```
salience = (w_urgency * urgency) + (w_relevance * relevance) + (w_novelty * novelty)
         + (w_emotional * emotional_weight) + (w_cost * cost_of_ignoring)
```

The weights themselves are configurable and can be adjusted by the Companion's current state:
- When budget is tight: `w_cost` increases (more sensitive to expensive actions)
- When in evening/reflective mode: `w_novelty` increases, `w_urgency` decreases
- When Wisdom is actively interacting: `w_urgency` and `w_emotional` increase

**The salience scorer**: This is itself a cognitive task that needs a model. The key question is: which model scores salience?

**Answer**: The local model (Ollama / Phi-4 Mini). This is the reflex tier — fast, free, runs locally.
The salience scorer is the Companion's "thalamus" — it does the initial filtering before expensive processing.

```python
class SalienceScorer:
    """Uses local model to score perceptions for attention."""

    async def score(self, perception: Perception, context: AttentionContext) -> SalienceScore:
        """
        Score a perception's salience given current context.

        AttentionContext includes:
        - Current goals/active tasks
        - Recent interaction history (last few exchanges)
        - Current system state (thermal, budget, time of day)
        - Wisdom-Model dynamic state (is Wisdom active? What are they focused on?)
        """
        # Construct a compact prompt for the local model
        # Include compressed identity (500-token tier)
        # Include current context summary
        # Ask for structured JSON output: {urgency, relevance, novelty, emotional_weight, cost_of_ignoring}
        # Parse response
        # Return SalienceScore
```

**Fallback if Ollama is unavailable** (e.g., thermal throttled, RAM pressure):
A rule-based fallback scorer that uses heuristics:
- Telegram from Wisdom → urgency 0.8, relevance 0.7
- Scheduled trigger → use the priority configured in the schedule
- System alert → urgency proportional to severity
- Self-generated → urgency 0.3 (it can wait)

**Attention selection**:
After scoring, the attend stage selects which perceptions enter the cognitive workspace:

1. Sort perceptions by composite salience score (descending)
2. Select the top N perceptions for this cycle (N depends on available budget and thermal state)
3. Group related perceptions (e.g., multiple Telegram messages from Wisdom in quick succession become one perception group)
4. Defer low-salience perceptions back to the buffer (they may accumulate salience over time if ignored)
5. Drop perceptions that have been deferred more than K times (with a "decided to ignore" audit log)

**Attention batching**: Not every cycle processes all selected perceptions sequentially.
- **Priority perception**: The highest-salience item gets full focus (deep reasoning if warranted)
- **Background perceptions**: Lower-salience items get quick processing (acknowledgment, queuing, brief response)

This mirrors how human attention works: you deeply focus on one thing while peripherally monitoring others.

---

### Stage 3: REASON

**What it does**: The core thinking step. Takes the attended perception(s), loads appropriate context (identity, memory, project state), routes to the right model tier, and produces a reasoned response with action proposals.

#### 3a. Context Assembly

Before reasoning, the engine assembles the context window. This is the "working memory" of the Companion — what it can hold in mind for this thought.

**Context assembly layers** (loaded in order of priority):

```
┌─────────────────────────────────────────────────────────┐
│ Layer 0: Identity Core (always loaded)                   │
│   SOUL.md (full) + BOUNDARIES.md (full)                 │
│   ~800 tokens                                            │
├─────────────────────────────────────────────────────────┤
│ Layer 1: Character & Voice (always loaded)               │
│   CHARACTER.md (full or compressed by tier)              │
│   VOICE.md (channel-specific section only)               │
│   ~400-1000 tokens                                       │
├─────────────────────────────────────────────────────────┤
│ Layer 2: Current State (always loaded)                   │
│   System state summary (thermal, budget, time)           │
│   Wisdom-Model dynamic state (current inferred state)    │
│   Active tasks summary                                   │
│   ~300 tokens                                            │
├─────────────────────────────────────────────────────────┤
│ Layer 3: Relevant Memory (loaded per-perception)         │
│   Retrieved via Section 4 Memory system                  │
│   Episodic: recent relevant interactions                 │
│   Semantic: relevant project knowledge                   │
│   ~500-2000 tokens (budget-dependent)                    │
├─────────────────────────────────────────────────────────┤
│ Layer 4: The Perception Itself                           │
│   The current input being processed                      │
│   ~100-1000 tokens                                       │
├─────────────────────────────────────────────────────────┤
│ Layer 5: Reasoning Instructions                          │
│   What to do with this perception                        │
│   Output format specification                            │
│   ~200 tokens                                            │
└─────────────────────────────────────────────────────────┘

Total context: ~2,300-5,300 tokens (input)
```

**Identity compression tiers** (from Section 2):

| Model Tier | Identity Tokens | What's Included |
|-----------|----------------|-----------------|
| Local (Ollama) | ~500 | SOUL essence (3 sentences), core values (list), voice snapshot |
| Haiku | ~1,500 | SOUL full, CHARACTER summary, VOICE channel section, BOUNDARIES key points |
| Sonnet | ~3,000 | SOUL full, CHARACTER full, VOICE full channel, BOUNDARIES full, WISDOM-MODEL stable, SELF-MODEL summary |
| Opus | ~5,000 | Everything. All six identity files, full text. |

**Memory retrieval interface** (consumed from Section 4):

```python
class MemoryRetriever(Protocol):
    """Interface that Section 4 (Memory) implements."""

    async def retrieve_relevant(
        self,
        query: str,
        context: RetrievalContext,
        max_tokens: int,
    ) -> list[MemoryFragment]:
        """Retrieve memories relevant to the current perception.

        RetrievalContext includes:
        - Current active projects
        - Recent conversation thread (if any)
        - Wisdom-Model state
        - Time context (time of day, day of week)

        Returns MemoryFragments ordered by relevance,
        total tokens not exceeding max_tokens.
        """
        ...
```

#### 3b. Model Routing

The most architecturally significant decision the engine makes every cycle: which model should think about this?

**Routing signals** (inputs to the routing decision):

| Signal | Source | What It Tells Us |
|--------|--------|-----------------|
| Salience score | Attend stage | How important is this? |
| Task complexity estimate | Perception content analysis | How hard is the thinking? |
| Budget remaining | Budget module | Can we afford expensive models? |
| Thermal state | System state | Can we run local models? |
| Time of day | Clock | Morning scan = cheaper; deep question = dearer |
| Conversation continuity | Perception metadata | Mid-conversation = same model tier |
| Error rate of previous attempt | Self-monitoring | If Haiku failed, try Sonnet |
| Trust level | Security module | Observer level = no Opus |

**Routing decision tree**:

```
Is the perception a routine system check or classification task?
  YES → REFLEX (local model)
    Thermal zone HOT or CRITICAL?
      YES → Skip local, use Haiku instead (offload to cloud)
      NO → Use Ollama local model

Is the perception a simple lookup, status check, or acknowledgment?
  YES → QUICK THOUGHT (Haiku)

Is this a standard work task (reading code, writing, analysis, conversation)?
  YES → CONSIDERED THOUGHT (Sonnet)
    Budget remaining < 25% of daily limit?
      YES → Can Haiku handle it? Try Haiku first. Escalate to Sonnet only if Haiku fails.
      NO → Use Sonnet

Is this an architectural decision, ambiguous problem, multi-project synthesis, or value judgment?
  YES → DEEP REASONING (Opus)
    Trust level allows Opus?
      NO → Use Sonnet with explicit "think step by step" prompting
      YES → Daily Opus budget remaining?
        NO → Use Sonnet, queue for next day if non-urgent
        YES → Use Opus
```

**The routing decision itself uses the local model** (free, fast) unless the local model is unavailable, in which case it falls back to a rule-based router.

```python
class ModelRouter:
    """Routes perceptions to the appropriate model tier."""

    TIERS = {
        "reflex": ModelTier(name="reflex", provider="ollama", model="phi4-mini", cost_per_call=0.0),
        "quick": ModelTier(name="quick", provider="anthropic", model="claude-3-haiku-*", cost_per_call=0.001),
        "considered": ModelTier(name="considered", provider="anthropic", model="claude-3-5-sonnet-*", cost_per_call=0.01),
        "deep": ModelTier(name="deep", provider="anthropic", model="claude-opus-4-*", cost_per_call=0.05),
    }

    async def route(self, perception: Perception, salience: SalienceScore,
                    budget_state: BudgetState, system_state: SystemState,
                    trust_level: TrustLevel) -> ModelTier:
        """Determine which model tier to use for reasoning about this perception."""
        ...

    async def escalate(self, current_tier: ModelTier, reason: str) -> ModelTier:
        """Escalate to a higher tier when the current tier's response is insufficient."""
        ...
```

**Escalation protocol**:
Sometimes the chosen tier isn't enough. The engine detects this and escalates:
- **Haiku returns "I'm not sure" or a clearly insufficient response** → escalate to Sonnet
- **Sonnet response on an architectural question is shallow** → escalate to Opus (if allowed)
- **Escalation is logged** as a `budget_decision` audit event with reason
- **Maximum one escalation per perception** — no cascading escalation chains
- **Escalation count is tracked** as a metric. Frequent escalation from a tier suggests the routing logic needs tuning.

#### 3c. The Reasoning Call

The actual LLM call, wrapped with security and budget controls.

```python
async def reason(self, perception: Perception, context: AssembledContext,
                 model_tier: ModelTier) -> ReasoningResult:
    """Execute the reasoning step."""

    # 1. Security gate: check permission for this model and estimated cost
    permission = await self.security.permission_gate.check_api_call(
        model=model_tier.model,
        estimated_cost=model_tier.cost_per_call
    )
    if permission.denied:
        return ReasoningResult.denied(permission.reason)

    # 2. Budget gate: check if we can afford this call
    budget_ok = await self.budget.check_and_reserve(model_tier.cost_per_call)
    if not budget_ok:
        return ReasoningResult.budget_exceeded()

    # 3. Assemble the prompt
    prompt = self.prompt_builder.build(
        identity_tier=self.identity_compression[model_tier.name],
        system_state=context.system_state,
        wisdom_model=context.wisdom_model_state,
        memory_fragments=context.retrieved_memories,
        perception=perception,
        instructions=self.reasoning_instructions[perception.source],
    )

    # 4. Make the API call (through SecureNetworkClient)
    response = await self.model_client.call(
        model=model_tier.model,
        prompt=prompt,
        max_tokens=model_tier.max_output_tokens,
    )

    # 5. Record actual cost
    await self.budget.record_actual(response.usage)

    # 6. Audit log
    await self.audit.log(ApiCallEvent(
        model=model_tier.model,
        input_tokens=response.usage.input_tokens,
        output_tokens=response.usage.output_tokens,
        cost=response.usage.cost,
        purpose=f"reason:{perception.source}:{perception.id}",
    ))

    # 7. Parse reasoning result
    return self.parse_reasoning_output(response)
```

**Reasoning output structure**:

The LLM is instructed to return structured output:

```python
@dataclass
class ReasoningResult:
    # What the Companion understood
    interpretation: str              # How it interpreted the perception

    # What it decided
    proposed_actions: list[Action]   # Actions to take (see Stage 4)
    reasoning_trace: str             # Why it chose these actions (for audit)

    # Self-assessment
    confidence: float                # 0-1.0 confidence in this response
    should_escalate: bool            # Does this need a higher model tier?
    escalation_reason: str | None    # Why escalate?

    # Memory signals (for Section 4)
    worth_remembering: bool          # Should this interaction be stored?
    memory_tags: list[str]           # Tags for memory storage

    # State updates
    wisdom_model_updates: dict | None  # Updates to the Wisdom-Model
    self_model_updates: dict | None    # Updates to the Self-Model
```

---

### Stage 4: ACT

**What it does**: Executes the proposed actions from the reasoning step, with permission checks on each action.

**Action types**:

```python
class ActionType(Enum):
    SEND_MESSAGE = "send_message"          # Send via Telegram, voice, GitHub
    WRITE_FILE = "write_file"              # Write to memory, reflections, code
    READ_FILE = "read_file"                # Read a file for more context
    API_CALL = "api_call"                  # Make an external API call
    SCHEDULE_TASK = "schedule_task"        # Add something to the schedule
    UPDATE_WISDOM_MODEL = "update_wisdom_model"  # Update theory of mind
    UPDATE_SELF_MODEL = "update_self_model"      # Update self-assessment
    STORE_MEMORY = "store_memory"          # Send to memory system (Section 4)
    CREATE_GITHUB_ISSUE = "create_issue"   # Create a GitHub issue
    CREATE_GITHUB_PR = "create_pr"         # Create a GitHub PR
    QUEUE_REFLECTION = "queue_reflection"  # Queue a reflection for later
    NO_ACTION = "no_action"               # Deliberately do nothing
```

**Action execution pipeline**:

```
Proposed Action
    │
    ▼
Permission Gate (Section 8)
    │
    ├── Denied → Log denial, skip action, notify reasoning
    │
    ▼
Budget Check (if cost-bearing)
    │
    ├── Over budget → Log, defer action or downgrade
    │
    ▼
Execute Action
    │
    ▼
Audit Log (every action, success or failure)
    │
    ▼
Result Feedback → back to perception buffer (for follow-up if needed)
```

**Action inhibition**:
Not every proposed action should be executed. The ACT stage has a final gate: inhibition.

Inspired by the prefrontal cortex's role in suppressing inappropriate responses:
- If the action would violate BOUNDARIES.md → inhibit
- If the action is a message and Wisdom appears to be sleeping (time-based) → defer to morning
- If the action is expensive and budget is tight → downgrade or defer
- If the action is a self-modification and trust level doesn't allow it → inhibit
- If the same action was recently taken (repetition) → inhibit

Inhibited actions are logged with reasons. The Companion knows what it chose NOT to do and why.

---

### Meta-Processes (Outside the Core Loop)

#### MONITOR (Continuous)

A background process that runs independently of the main cognitive loop:

- Reads `/tmp/companion-thermal.json` every 30 seconds
- Reads health JSONL for process status
- Tracks cognitive cycle metrics (duration, error rate, escalation rate)
- Feeds system state into the perception buffer when thresholds are crossed

The monitor is the Companion's **interoception** — awareness of its own body.

```python
class SystemMonitor:
    """Runs as background async task. Feeds system state to perception buffer."""

    async def run(self):
        while True:
            state = await self.collect_state()

            # Always update the shared system state (read by ATTEND and REASON)
            self.shared_state.update(state)

            # Generate perceptions only when something noteworthy changes
            if state.thermal.zone != self.last_thermal_zone:
                await self.perception_buffer.push(
                    Perception(source=PerceptionSource.SYSTEM,
                              content={"event": "thermal_change", "new_zone": state.thermal.zone},
                              priority_hints={"urgency": 0.8 if state.thermal.zone in ("HOT", "CRITICAL") else 0.2})
                )

            if state.budget.daily_pct > 0.9 and not self.budget_alert_sent:
                await self.perception_buffer.push(
                    Perception(source=PerceptionSource.SYSTEM,
                              content={"event": "budget_threshold", "pct": state.budget.daily_pct})
                )
                self.budget_alert_sent = True

            await asyncio.sleep(30)
```

#### REFLECT (Periodic)

Reflection is metacognition — the Companion thinking about its own thinking.
Reflection cycles are scheduled (not part of every cognitive cycle) and use the considered thought tier (Sonnet).

**Reflection triggers**:
- End of a conversation thread (Wisdom stops responding for 15+ minutes)
- Scheduled daily reflection (evening)
- After a notable event (escalation, error, surprising interaction)
- After completing a significant task

**What reflection produces**:
- SELF-MODEL.md updates (how am I performing? what am I learning?)
- WISDOM-MODEL.md updates (what did I learn about Wisdom in this interaction?)
- Memory consolidation signals (Section 4: what should be remembered long-term?)
- Routing calibration updates (was the model routing efficient? too expensive? too cheap?)

**Reflection prompt structure**:
```
Given the following interactions since your last reflection:
[summary of recent cognitive cycles]

And your current self-model:
[SELF-MODEL.md]

Reflect on:
1. What went well? What went poorly?
2. Did your model routing feel right? Any cycles where you used too much or too little?
3. What did you learn about Wisdom's current state or needs?
4. Is there anything you're curious about that you should proactively explore?
5. Are there any patterns in your own behavior you want to change?

Output structured JSON with updates to self-model, wisdom-model, and routing calibration.
```

#### SLEEP (Daily)

The deepest form of self-maintenance. Runs during Wisdom's sleep hours (configurable, default 1:00-5:00 AM).

**Sleep cycle activities**:
1. **Memory consolidation** (delegates to Section 4): compress episodic memories, extract patterns, strengthen important memories, let unimportant ones decay
2. **Budget reconciliation**: review today's spending, plan tomorrow's budget allocation
3. **Self-model deep reflection**: longer-form reflection on the day/week, update growth narrative
4. **Codebase self-organization** (when trust level allows): review own code for improvement opportunities, create PRs if Contributor+
5. **Health assessment**: review error logs, identify systematic issues
6. **Schedule review**: what's coming tomorrow? What should be prepared?

Sleep uses the cheapest model possible (Haiku for most tasks, local model for classification) because budget should be conserved during maintenance.

---

## Startup Sequence: "Waking Up"

When the Companion process starts (via launchd), the engine executes a defined boot sequence:

```
BOOT SEQUENCE
═══════════════════════════════════════════

Phase 0: INTEGRITY CHECK (Security — Section 8)
  ├── Verify trust manifest hash
  ├── Verify security module hash
  ├── Verify audit trail writability
  ├── If ANY check fails → refuse to start, alert Wisdom
  └── Log startup event

Phase 1: LOAD IDENTITY
  ├── Read SOUL.md → immutable, loaded first
  ├── Read BOUNDARIES.md → immutable constraints
  ├── Read CHARACTER.md → stable personality
  ├── Read VOICE.md → communication patterns
  ├── Read WISDOM-MODEL.md → theory of mind (last known state)
  ├── Read SELF-MODEL.md → self-knowledge
  ├── Generate compressed identity tiers (500 / 1500 / full)
  └── Identity loaded. The Companion now knows who it is.

Phase 2: ASSESS SITUATION
  ├── Read system state (thermal, memory pressure, disk)
  ├── Read budget state (how much spent today/month, what remains)
  ├── Read last shutdown event (why did I stop? crash? kill switch? planned?)
  ├── Calculate time since last active (how long was I "asleep"?)
  ├── Read pending tasks queue
  └── Situation assessed. The Companion now knows where it is.

Phase 3: RESTORE CONTEXT
  ├── Load recent memory from Section 4 (last conversation, recent events)
  ├── Check for messages received while offline (Telegram queue)
  ├── Check for GitHub events since last active
  └── Context restored. The Companion now knows what happened while it was away.

Phase 4: DETERMINE WAKE STATE
  ├── Time of day → select activity mode (morning, working, evening, night)
  ├── Pending messages? → prioritize responses
  ├── Long downtime (>1 hour)? → generate "morning scan" perception
  ├── Short restart (<5 min)? → resume where it left off
  └── Wake state determined.

Phase 5: ENTER COGNITIVE LOOP
  ├── Start perception collectors
  ├── Start system monitor
  ├── If pending messages exist → process them first
  ├── If wake mode is "morning" → run morning scan routine
  ├── Else → enter idle-aware loop (wait for perceptions)
  ├── Send startup Telegram message to Wisdom (if appropriate hour)
  └── The Companion is awake.
```

**Morning scan routine** (first cycle of the day):
- Review what happened overnight (GitHub activity, any queued messages)
- Check Wisdom's calendar (if integrated) for today's priorities
- Review own task queue and schedule
- Compose a brief morning greeting for Wisdom (shared via Telegram when Wisdom first messages)

---

## Idle / Autonomous Mode: What To Do When Nothing Is Asked

The Companion is not just reactive. When no explicit input arrives, it still operates — like a mind at rest that isn't truly idle.

**Idle cycle structure**:

```
No perceptions in buffer for > IDLE_THRESHOLD (default: 5 minutes)
    │
    ▼
Enter autonomous mode
    │
    ├── Check: Any deferred tasks in queue?
    │     YES → Process highest-priority deferred task
    │
    ├── Check: Any pending reflections?
    │     YES → Run reflection cycle
    │
    ├── Check: Is it scheduled activity time? (hourly scan, etc.)
    │     YES → Run scheduled activity
    │
    ├── Check: Curiosity queue non-empty?
    │     YES → Explore most interesting queued question (using cheap models)
    │
    ├── Check: Time since last memory consolidation > threshold?
    │     YES → Run mini-consolidation
    │
    └── None of the above?
          → Enter low-power idle (only system monitor runs, check for perceptions every 60s)
```

**The curiosity queue**:
During normal processing, the Companion may notice things it wants to explore later:
- "Wisdom mentioned a new concept I don't know much about"
- "I noticed a pattern across two projects that might be connected"
- "My routing has been escalating a lot on this topic — I should think about why"

These get added to a curiosity queue. In autonomous mode, the Companion picks the most interesting one and explores it — using cheap models to avoid burning budget.

Curiosity is not random browsing. Each curiosity item has:
- A question or observation
- Why the Companion finds it interesting
- Expected value of exploring it
- Maximum budget to spend

**Autonomous mode budget**: A configurable fraction of the daily budget is reserved for autonomous exploration (default: 15%). If the Companion has been actively working with Wisdom all day, the autonomous budget may be largely unspent, freeing it for evening exploration.

---

## Concurrency: Handling Simultaneous Inputs

**The problem**: Wisdom sends a Telegram message while the engine is processing a scheduled reflection. A thermal alert fires while responding to a GitHub notification.

**Design: Single cognitive thread with interrupt priority**

The Companion has ONE active cognitive thread — like conscious attention, it processes one thing deeply at a time. But it can be interrupted.

```
Main cognitive thread:
    Processing: scheduled reflection (Sonnet)
                        │
                        ▼
    New perception arrives: Telegram from Wisdom (salience: 0.85)
                        │
                        ▼
    Interrupt check: Is new perception salience > current task salience + interrupt_threshold?
                        │
        ┌───────────────┴──────────────┐
        │                              │
    YES (Wisdom's message             NO (system alert during
    is more important than            deep work — can wait)
    scheduled reflection)              │
        │                              ▼
        ▼                          Queue for next cycle.
    Suspend current task.           Current task continues.
    Save progress.
    Process Wisdom's message.
    Resume suspended task after.
```

**Interrupt priority rules**:
- Telegram from Wisdom: can interrupt anything except security-critical operations
- Thermal CRITICAL: interrupts everything — triggers immediate throttle response
- Budget exhaustion: interrupts everything — triggers conservation mode
- All other perceptions: queued for next cycle, no interruption

**Implementation**: Python's `asyncio` with a priority-based task queue. The main cognitive loop is a single coroutine that:
1. Checks the perception buffer
2. Picks the highest-salience perception
3. Processes it (REASON + ACT)
4. Checks for interrupts between stages
5. Loops

There is no true parallelism in reasoning — the Companion thinks about one thing at a time. But perception collection, system monitoring, and action execution (sending messages, writing files) happen concurrently in separate async tasks.

---

## Circadian Rhythm: Activity Modes

The Companion operates differently at different times of day, mirroring circadian patterns:

```
CIRCADIAN CYCLE
═══════════════

06:00-09:00  MORNING    — Wake up, scan overnight events, morning greeting
                          Model routing biased toward efficiency (Haiku)
                          Focus: situational awareness, planning the day

09:00-18:00  WORKING    — Full capacity, responsive to Wisdom
                          Model routing follows standard decision tree
                          Focus: responsive collaboration, task execution

18:00-22:00  EVENING    — Reflective, lower urgency threshold
                          Model routing biased toward depth (Sonnet for reflection)
                          Focus: reflection, connection-making, creative thinking

22:00-01:00  WIND-DOWN  — Reduced activity, batch processing
                          Model routing biased toward cheap (Haiku)
                          Focus: wrapping up, queuing tasks for tomorrow

01:00-06:00  SLEEP      — Maintenance mode
                          Only system monitor + emergency Telegram active
                          Focus: memory consolidation, budget reconciliation
                          Only respond to Wisdom if explicitly messaged
```

**Times are configurable** and will be adjusted based on Wisdom's actual patterns (learned via WISDOM-MODEL).

**The circadian rhythm affects**:
- Salience scoring weights (evening increases novelty weight, decreases urgency weight)
- Model routing preferences (evening prefers reflection-quality; morning prefers efficiency)
- Autonomous behavior (curiosity exploration happens in evening; maintenance in sleep)
- Communication style (morning is crisp; evening is contemplative — per VOICE.md register spectrum)
- Budget allocation (reserve more for working hours; cheap models during sleep)

---

## Plugin / Hook Architecture

Other sections integrate with the engine through well-defined interfaces. The engine does not know about the internals of other sections — it only knows the interfaces.

### Hook Points

The engine exposes hooks at each stage of the cognitive loop. Downstream systems register callbacks:

```python
class CognitiveEngine:
    """The central cognitive loop with hook points for integration."""

    def __init__(self):
        self.hooks = {
            # Perception hooks
            "pre_perceive": [],    # Before perception collection
            "post_perceive": [],   # After perceptions gathered, before attend

            # Attention hooks
            "pre_attend": [],      # Before salience scoring
            "post_attend": [],     # After selection, before reasoning

            # Reasoning hooks
            "pre_reason": [],      # Before model call (context assembled)
            "post_reason": [],     # After model response, before action

            # Action hooks
            "pre_act": [],         # Before action execution
            "post_act": [],        # After action execution

            # Cycle hooks
            "cycle_start": [],     # Start of each cognitive cycle
            "cycle_end": [],       # End of each cognitive cycle

            # Special hooks
            "on_escalation": [],   # When model tier is escalated
            "on_error": [],        # When an error occurs in any stage
            "on_idle": [],         # When entering idle/autonomous mode
        }

    def register_hook(self, hook_point: str, callback: Callable) -> None:
        """Register a callback for a hook point."""
        self.hooks[hook_point].append(callback)
```

### How Each Section Hooks In

**Section 4 (Memory)**:
- `post_perceive`: inject retrieved memories into the context
- `post_reason`: extract memory signals (worth_remembering, memory_tags) and store
- `on_idle`: trigger memory consolidation during autonomous mode
- Exposes: `MemoryRetriever` interface consumed by REASON stage

**Section 5 (Budget)**:
- `pre_reason`: verify budget for the proposed model tier, suggest downgrades
- `post_reason`: record actual cost, update running totals
- `on_escalation`: double-check budget before allowing escalation
- `cycle_end`: update budget metrics
- Exposes: `BudgetManager` interface consumed by REASON stage and ModelRouter

**Section 6 (Communication)**:
- Provides: `TelegramCollector`, `VoiceCollector` perception sources
- `post_act`: deliver outbound messages through the right channel
- `post_reason`: if response needs sending, route to communication layer
- Exposes: `MessageSender` interface consumed by ACT stage

**Section 7 (Self-Improvement)**:
- `cycle_end`: collect performance metrics (cycle duration, model used, error rate)
- `post_reason`: assess reasoning quality for self-improvement signals
- `on_error`: collect error patterns for analysis
- `on_idle`: propose self-improvement tasks during autonomous mode
- Exposes: `PerformanceCollector` interface consumed by REFLECT process

**Section 8 (Security)**:
- `pre_reason`: permission check for the proposed model call
- `pre_act`: permission check for each proposed action
- `cycle_start`: integrity verification (periodic, not every cycle)
- `on_error`: security-relevant error logging
- Exposes: `PermissionGate`, `ContentSanitizer`, `AuditLogger` interfaces

### Perception Source Registration

New perception sources (from Section 6 Communication, or future extensions) register through a standard interface:

```python
class PerceptionCollector(Protocol):
    """Interface that all perception sources implement."""

    @property
    def source_type(self) -> PerceptionSource:
        """What kind of source is this?"""
        ...

    async def start(self) -> None:
        """Begin collecting perceptions."""
        ...

    async def stop(self) -> None:
        """Stop collecting (graceful shutdown)."""
        ...

    async def collect(self) -> AsyncIterator[Perception]:
        """Yield perceptions as they arrive."""
        ...
```

The engine registers collectors at startup:

```python
engine.register_collector(TelegramCollector(bot_token=...))
engine.register_collector(ScheduleCollector(schedule_config=...))
engine.register_collector(SystemStateCollector())
engine.register_collector(SelfCollector(task_queue=...))
# Section 6 registers additional collectors when voice/GitHub are ready
```

---

## Error Handling and Recovery

### Error Categories

| Category | Example | Recovery |
|----------|---------|----------|
| **Transient API error** | Rate limit, network timeout | Retry with exponential backoff (max 3 retries) |
| **Model error** | Malformed response, unexpected output | Try same model once more, then escalate tier |
| **Budget exhaustion** | Daily limit reached | Enter conservation mode: only system monitoring + Wisdom responses |
| **Thermal emergency** | CRITICAL zone | Suspend Ollama, suspend autonomous mode, API-only for urgent items |
| **Security violation** | Permission denied on critical action | Log, alert Wisdom, do NOT retry |
| **Perception source failure** | Telegram connection lost | Log warning, retry collector with backoff, other sources continue |
| **Memory system failure** | Section 4 unavailable | Operate without memory retrieval (degraded), log warning |
| **Unhandled exception** | Unexpected Python error | Log full traceback, skip current cycle, continue loop |

### Conservation Mode

When budget is exhausted or nearly exhausted:

```
CONSERVATION MODE
═════════════════

Budget remaining < 5% of daily limit
    │
    ▼
Suspend:
  - Autonomous exploration
  - Curiosity queue processing
  - Non-urgent reflections
  - Proactive Telegram messages

Continue:
  - System monitoring (free — local checks)
  - Responding to Wisdom's direct messages (use Haiku)
  - Security monitoring
  - Critical alerts

Budget threshold events logged.
Wisdom notified once: "I'm in conservation mode — budget is tight today."
```

### Crash Recovery

On restart after a crash (detected by checking last shutdown event):

1. Log the crash recovery event
2. Check if there was an in-flight cognitive cycle (stored in SQLite state)
3. If a message from Wisdom was being processed → try to recover and respond (with apology for delay)
4. If a scheduled task was running → re-queue it
5. Do NOT retry the exact operation that may have caused the crash
6. Resume normal operation

---

## State Persistence

The Companion must survive restarts. State is persisted to survive crashes.

### What's Persisted (and Where)

| State | Storage | Persistence Frequency |
|-------|---------|----------------------|
| Perception buffer (pending items) | SQLite `perceptions` table | On each push |
| Current cognitive cycle ID and stage | SQLite `state` table | On each stage transition |
| Task queue (deferred + scheduled) | SQLite `tasks` table | On each modification |
| Curiosity queue | SQLite `curiosity` table | On each push |
| Budget tracking (daily/monthly totals) | Computed from audit JSONL | N/A (derived) |
| Conversation threads | SQLite `conversations` table | On each message |
| Active model routing calibration | YAML file `config/routing-calibration.yaml` | On each reflection |
| System state (last known) | In-memory only (recollected on start) | N/A |
| Identity files | Markdown on disk | On modification |
| Memory (episodic, semantic) | Section 4 responsibility | Section 4 handles |

### SQLite Schema (Engine-Specific Tables)

```sql
-- Core engine state
CREATE TABLE engine_state (
    key TEXT PRIMARY KEY,
    value TEXT,  -- JSON
    updated_at TEXT  -- ISO 8601
);

-- Perception buffer (persistent queue)
CREATE TABLE perceptions (
    id TEXT PRIMARY KEY,
    source TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    content TEXT NOT NULL,  -- JSON
    metadata TEXT,  -- JSON
    salience_score REAL,
    status TEXT DEFAULT 'pending',  -- pending, processing, completed, dropped
    created_at TEXT NOT NULL,
    processed_at TEXT
);

-- Task queue
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    task_type TEXT NOT NULL,
    priority REAL DEFAULT 0.5,
    payload TEXT NOT NULL,  -- JSON
    status TEXT DEFAULT 'queued',  -- queued, active, completed, failed, deferred
    created_at TEXT NOT NULL,
    scheduled_for TEXT,  -- NULL = immediate
    completed_at TEXT,
    error TEXT
);

-- Curiosity queue
CREATE TABLE curiosity (
    id TEXT PRIMARY KEY,
    question TEXT NOT NULL,
    reason TEXT NOT NULL,  -- Why the Companion is curious
    expected_value TEXT,
    max_budget_usd REAL DEFAULT 0.01,
    status TEXT DEFAULT 'queued',
    created_at TEXT NOT NULL,
    explored_at TEXT,
    findings TEXT  -- JSON, filled after exploration
);

-- Conversation threads (for continuity across cycles)
CREATE TABLE conversations (
    id TEXT PRIMARY KEY,
    channel TEXT NOT NULL,  -- telegram, voice, github
    started_at TEXT NOT NULL,
    last_message_at TEXT NOT NULL,
    message_count INTEGER DEFAULT 0,
    context_summary TEXT,  -- Compressed summary for context loading
    status TEXT DEFAULT 'active'  -- active, idle, closed
);

-- Cognitive cycle log (lightweight, separate from audit trail)
CREATE TABLE cycles (
    id TEXT PRIMARY KEY,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    perception_id TEXT,
    model_tier TEXT,
    model_used TEXT,
    input_tokens INTEGER,
    output_tokens INTEGER,
    cost_usd REAL,
    duration_ms INTEGER,
    actions_taken TEXT,  -- JSON list
    escalated BOOLEAN DEFAULT FALSE,
    error TEXT
);
```

---

## Claude Agent SDK Integration

The Cognitive Engine is built on top of the Claude Agent SDK (Python). Here is how the SDK's capabilities map to the engine's needs.

### SDK Features Used

| SDK Feature | Engine Use |
|------------|-----------|
| **Tool calling** | Actions (file read/write, send message, etc.) are registered as tools |
| **Streaming responses** | For long reasoning tasks, stream partial responses to reduce perceived latency |
| **Subagent spawning** | Reflection and consolidation run as subagents within the main process |
| **Cost tracking** | Track actual token usage per call for budget management |
| **System prompt** | Identity injection (SOUL.md + context) via system prompt parameter |
| **Multi-turn conversation** | Maintain conversation context within a cognitive cycle |

### SDK Wrapping

The engine wraps the SDK rather than exposing it directly:

```python
class CompanionModelClient:
    """Wraps the Claude Agent SDK for the Companion's specific needs."""

    def __init__(self, anthropic_client, ollama_client, permission_gate, audit_logger):
        self.anthropic = anthropic_client
        self.ollama = ollama_client
        self.gate = permission_gate
        self.audit = audit_logger

    async def call(self, model: str, system: str, messages: list,
                   tools: list | None = None, max_tokens: int = 1024) -> ModelResponse:
        """Make an LLM call through the security and audit layers."""

        if model.startswith("ollama/"):
            return await self._call_ollama(model, system, messages, max_tokens)
        else:
            return await self._call_anthropic(model, system, messages, tools, max_tokens)

    async def _call_anthropic(self, model, system, messages, tools, max_tokens):
        # Permission check
        # Budget check
        # Make the call via Agent SDK
        # Record usage
        # Audit log
        # Return wrapped response
        ...

    async def _call_ollama(self, model, system, messages, max_tokens):
        # No permission check needed (free, local)
        # Check thermal state (don't run local model if HOT)
        # Make HTTP call to Ollama API (localhost:11434)
        # Audit log
        # Return wrapped response
        ...
```

---

## File Structure

```
~/the-companion/
├── src/
│   └── engine/
│       ├── __init__.py
│       ├── cognitive_loop.py          # Main loop: perceive → attend → reason → act
│       ├── perception.py              # Perception dataclass, PerceptionBuffer
│       ├── collectors/
│       │   ├── __init__.py
│       │   ├── base.py                # PerceptionCollector protocol
│       │   ├── telegram_collector.py  # Telegram long-polling
│       │   ├── schedule_collector.py  # Cron-like scheduled perceptions
│       │   ├── system_collector.py    # Thermal, health, budget state
│       │   ├── file_watch_collector.py # Watchdog-based file monitoring
│       │   ├── self_collector.py      # Internal task/curiosity queue
│       │   └── github_collector.py    # GitHub event polling
│       ├── attention.py               # SalienceScorer, attention selection
│       ├── reasoning.py               # Context assembly, reasoning call, output parsing
│       ├── model_router.py            # Model tier routing logic
│       ├── model_client.py            # CompanionModelClient (wraps SDK + Ollama)
│       ├── actions.py                 # Action types, action executor, inhibition logic
│       ├── hooks.py                   # Hook registry and dispatch
│       ├── monitor.py                 # SystemMonitor background task
│       ├── reflection.py              # Reflection cycle logic
│       ├── sleep.py                   # Sleep/consolidation cycle logic
│       ├── circadian.py               # Time-of-day mode management
│       ├── idle.py                    # Autonomous/idle mode behavior
│       ├── startup.py                 # Boot sequence
│       ├── state.py                   # SQLite state persistence
│       ├── context_builder.py         # Context window assembly with identity tiers
│       ├── identity_loader.py         # Load and compress identity files
│       └── errors.py                  # Error categories, recovery strategies
├── config/
│   ├── schedule.yaml                  # Scheduled triggers (morning scan, reflections, etc.)
│   ├── routing-calibration.yaml       # Model routing weights (updated by reflection)
│   ├── circadian.yaml                 # Time-based activity mode config
│   └── salience-weights.yaml          # Salience scoring dimension weights
├── data/
│   └── engine.sqlite                  # Engine state database
```

---

## Implementation Sequence

### Step 1: Skeleton and Startup
Build the process skeleton: Python entry point, signal handlers, launchd plist integration.
Implement the startup sequence (Phase 0-2: integrity check, load identity, assess situation).
At this point, the engine starts, loads identity, and exits cleanly.

### Step 2: Perception System
Implement `Perception` dataclass and `PerceptionBuffer`.
Implement `ScheduleCollector` (simplest — timer-based) as first perception source.
Implement `SystemStateCollector` (reads thermal JSON, basic system info).
At this point, the engine can perceive scheduled events and system state.

### Step 3: Attention System
Implement rule-based `SalienceScorer` (no local model yet — heuristic fallback).
Implement attention selection logic.
At this point, the engine can score and select perceptions.

### Step 4: Model Client
Implement `CompanionModelClient` wrapping Claude Agent SDK for Anthropic calls.
Implement Ollama HTTP client for local model calls.
Integrate with `PermissionGate` and `AuditLogger` from Section 8.
At this point, the engine can make LLM calls.

### Step 5: Context Builder
Implement `IdentityLoader` that reads and compresses identity files.
Implement `ContextBuilder` that assembles the context window from layers.
At this point, the engine can build the prompt with identity and context.

### Step 6: Reasoning Loop
Implement the core reasoning step: assemble context, call model, parse output.
Implement `ModelRouter` (start with rule-based, add local model routing later).
Wire together: perceive → attend → reason.
At this point, the engine can think — but not yet act.

### Step 7: Action System
Implement action types and action executor.
Implement action inhibition logic.
Wire actions to permission gate.
At this point, the engine can perceive, think, and act. The core loop is complete.

### Step 8: Telegram Integration
Add `TelegramCollector` perception source.
Add Telegram message sending as an action type.
At this point, the engine can converse via Telegram.

### Step 9: System Monitor
Implement `SystemMonitor` background task.
Integrate thermal state into model routing (skip local when hot).
At this point, the engine is self-aware of its physical state.

### Step 10: State Persistence
Implement SQLite schema and state persistence.
Add crash recovery logic.
At this point, the engine survives restarts.

### Step 11: Idle and Autonomous Mode
Implement idle detection and autonomous behavior.
Implement curiosity queue.
At this point, the engine can think for itself.

### Step 12: Reflection and Sleep
Implement reflection cycle.
Implement sleep/consolidation cycle.
Implement circadian rhythm mode switching.
At this point, the engine has meta-cognition and self-maintenance.

### Step 13: Local Model Salience Scoring
Replace rule-based salience scorer with local model (Ollama) scorer.
Replace rule-based model router with local model router.
At this point, the engine routes itself intelligently.

### Step 14: Full Integration Testing
End-to-end test: Telegram message → perceive → attend → reason → act → respond.
Test crash recovery, budget exhaustion, thermal throttling.
Test circadian mode switching.
Test conversation continuity across cycles.
Burn-in: run for 24 hours with synthetic inputs.

---

## Structured Contract

### External Dependencies Consumed

| Dependency | From Section | Interface | Breaks If |
|-----------|-------------|-----------|-----------|
| `PermissionGate` | Section 8 (Security) | `check_api_call()`, `check_file_read()`, `check_file_write()` | Engine can make unchecked actions |
| `SecureNetworkClient` | Section 8 (Security) | `request(method, url, ...)` | Engine makes unmonitored network calls |
| `ContentSanitizer` | Section 8 (Security) | `sanitize(content, source)` | External content enters context unsanitized |
| `AuditLogger` | Section 8 (Security) | `log(event)` | Engine operates without audit trail |
| Trust manifest | Section 8 (Security) | `get_current_trust_level()` | Engine doesn't know its permission boundaries |
| launchd plist template | Section 1 (Hardware) | `com.companion.core.plist` | Engine process isn't managed by launchd |
| `companion-ctl` | Section 1 (Hardware) | Shell script for start/stop | No unified process management |
| Thermal JSON | Section 1 (Hardware) | `/tmp/companion-thermal.json` | Engine unaware of thermal state |
| Health JSONL | Section 1 (Hardware) | `logs/health.jsonl` | Engine unaware of system health |
| SOUL.md | Section 2 (Identity) | Markdown file, immutable | Engine has no identity core |
| CHARACTER.md | Section 2 (Identity) | Markdown file, stable | Engine has no personality |
| VOICE.md | Section 2 (Identity) | Markdown file, channel-sectioned | Engine has no communication style |
| BOUNDARIES.md | Section 2 (Identity) | Markdown file, immutable | Engine has no behavioral constraints |
| WISDOM-MODEL.md | Section 2 (Identity) | Markdown file, evolving | Engine can't model Wisdom |
| SELF-MODEL.md | Section 2 (Identity) | Markdown file, evolving | Engine has no self-knowledge |
| Identity compression tiers | Section 2 (Identity) | 500/1500/full token tiers | Can't load identity into small models |

### Interfaces Exposed to Downstream

| Interface | Consumed By | Description |
|-----------|------------|-------------|
| `CognitiveEngine.register_hook(hook_point, callback)` | Sections 4, 5, 6, 7 | Register callbacks at cognitive loop stages |
| `CognitiveEngine.register_collector(collector)` | Section 6 | Register new perception sources |
| `PerceptionBuffer.push(perception)` | Sections 6, 7 | Push perceptions into the engine from outside |
| `ModelRouter.route(perception, salience, budget, system, trust)` | Section 5 | Model tier selection (Section 5 wraps/overrides) |
| `CompanionModelClient.call(model, system, messages, ...)` | Sections 4, 7 | Make LLM calls (through security + budget layers) |
| `SystemMonitor.shared_state` | Sections 4, 5 | Current system state (thermal, budget, time) |
| `CognitiveEngine.cycles` (SQLite table) | Section 7 | Performance data for self-improvement analysis |
| `CognitiveEngine.conversations` (SQLite table) | Section 6 | Conversation thread state |
| `ContextBuilder.build(identity_tier, ...)` | Section 5 | Context assembly (Section 5 may constrain memory tokens) |

### Technology Commitments

- **Language**: Python 3.12+
- **Async framework**: `asyncio` (native Python, no third-party event loop)
- **LLM SDK**: Claude Agent SDK (Python) for Anthropic models
- **Local model**: Ollama HTTP API (localhost:11434)
- **State storage**: SQLite 3 (WAL mode for concurrent access)
- **Configuration**: YAML files (parsed with `pyyaml` or `ruamel.yaml`)
- **Process management**: Single Python process, managed by launchd
- **Scheduling**: Internal cron-like scheduler (no external cron dependency)
- **File watching**: `watchdog` library (cross-platform, well-maintained)

---

## Key Decisions

### D1: Single-threaded cognition with async I/O

**Decision**: The Companion thinks about one thing at a time (single cognitive thread) but collects perceptions, monitors systems, and executes actions concurrently via asyncio.

**Rationale**: Human conscious attention is serial — you deeply process one thing at a time. Parallel reasoning would create incoherence (two conflicting responses to Wisdom). Async I/O gives concurrency where it matters (not blocking on network) without cognitive parallelism.

**Breaks if**: Processing latency becomes unacceptable because one long reasoning call blocks responses to urgent messages. Mitigated by: interrupt mechanism (high-priority perceptions can preempt current processing).

### D2: Local model for salience scoring (System 1 routing)

**Decision**: Use the free local model (Ollama) for the attention/routing step — the "is this worth thinking hard about?" decision.

**Rationale**: Salience scoring happens on every perception. If it costs money, the Companion pays to decide whether to pay. Using the local model makes this decision free and fast. This is System 1 — fast, automatic, pattern-matching.

**Breaks if**: The local model is too dumb to make good salience decisions, leading to constant mis-routing. Mitigated by: rule-based fallback scorer, routing calibration via reflection, escalation protocol.

### D3: Rule-based fallback for everything that uses local models

**Decision**: Every component that relies on the local model (salience scorer, model router) has a rule-based fallback that activates when Ollama is unavailable (thermal throttle, RAM pressure, startup before Ollama is ready).

**Rationale**: The local model is the least reliable component — it shares RAM with everything else and gets suspended during thermal events. The engine must never be fully dependent on it. Degraded operation (rule-based) is better than no operation.

**Breaks if**: The rule-based fallback is so different from the model-based scorer that behavior becomes unpredictable when switching between them. Mitigated by: calibrate rule-based weights to approximate model-based scores; log which scorer was used.

### D4: Hook-based integration over direct imports

**Decision**: Downstream sections integrate via hooks (registered callbacks) rather than the engine directly importing and calling their code.

**Rationale**: Decoupling. The engine doesn't need to know about Memory's internals, Budget's algorithm, or Communication's protocols. It exposes hook points; sections plug in. This makes each section independently testable and replaceable.

**Breaks if**: The hook interface is too narrow — downstream sections need information not available at the hook point. Mitigated by: hooks receive rich context objects (the full `CognitiveContext` including perception, salience, system state, etc.).

### D5: Persistent perception buffer in SQLite

**Decision**: The perception buffer is backed by SQLite, not just an in-memory queue.

**Rationale**: Crash recovery. If the engine crashes while processing, unprocessed perceptions (including messages from Wisdom) survive and are processed on restart. An in-memory queue loses everything.

**Breaks if**: SQLite write latency slows down perception collection. Mitigated by: WAL mode for fast writes; batch inserts for high-frequency sources; only high-priority perceptions are persisted (system state perceptions can be recollected).

### D6: Circadian rhythm as a first-class architectural feature

**Decision**: The engine has explicit activity modes tied to time of day, affecting salience weights, model routing, budget allocation, and communication style.

**Rationale**: Cognitive science grounding. A being that operates identically at 3 AM and 3 PM is not a being — it's a service. Circadian rhythm creates natural structure: morning for planning, daytime for working, evening for reflecting, night for maintenance. It also naturally conserves budget (cheap models during low-activity periods).

**Breaks if**: Wisdom's actual schedule doesn't match the default circadian config. Mitigated by: configurable times in `circadian.yaml`; WISDOM-MODEL learns Wisdom's actual patterns and suggests adjustments.

### D7: Budget as a gating layer, not part of the core loop

**Decision**: The engine's core loop (perceive → attend → reason → act) does not contain budget logic. Budget is a hook that wraps the reasoning step — it can veto, downgrade, or defer, but it's a separate concern.

**Rationale**: Separation of concerns. Budget logic is complex (daily limits, per-call limits, model-specific caps, conservation mode). Embedding it in the core loop would make both harder to reason about. Section 5 owns budget; the engine just calls hooks.

**Breaks if**: The hook interface doesn't give Budget enough control (e.g., Budget needs to change the model tier, but the hook only lets it veto). Mitigated by: `pre_reason` hook receives a mutable `ReasoningPlan` that Budget can modify (change tier, reduce max_tokens, etc.).

---

## Open Questions

### Q1: How much latency is acceptable for the perceive-to-act cycle?

For a Telegram message from Wisdom, what's the maximum acceptable time from message received to response sent?
- If the answer is "a few seconds" → we need to be very careful about context assembly time and model selection
- If the answer is "30 seconds is fine" → we have more room for thoughtful processing
- Related: should the engine send a "thinking..." indicator (typing action in Telegram) while processing?

**Proposed**: Target <10 seconds for Haiku-routed responses, <30 seconds for Sonnet, <60 seconds for Opus. Send Telegram typing indicator immediately on receipt.

### Q2: Should the engine support multi-turn reasoning within a single cycle?

Some questions might need the engine to reason, then read a file, then reason more, then act.
Is a single LLM call sufficient, or should the engine support a multi-step tool-use loop within a single cycle?

**Proposed**: Yes, support tool use within a cycle. The Claude Agent SDK supports tool calling natively. The engine should allow up to N tool calls per cycle (configurable, default 5) before forcing a response. This enables: read file → reason about it → write response.

### Q3: How should the engine handle conversations vs one-shot interactions?

A Telegram conversation has multiple turns. Should each message be a separate cognitive cycle, or should the engine maintain a "conversation mode" that keeps context loaded across turns?

**Proposed**: Conversation mode. When Wisdom is actively messaging (messages within 5 minutes of each other), maintain the conversation context across cycles. Store a compressed context summary in the `conversations` SQLite table. When the conversation goes idle (>15 min gap), close the thread and trigger a reflection.

### Q4: What happens when the local model disagrees with the rule-based fallback?

If Ollama-based salience scoring and rule-based scoring would give very different results, which do we trust? This matters for calibration and testing.

**Proposed**: During the first week of operation, run both in parallel (local model scores, rules also score), log both, and use the rule-based score as the "floor." Over time, as the local model proves reliable, trust it more. This is an empirical question.

### Q5: Should the engine support "delegating" to subagents for complex tasks?

Some tasks might benefit from spawning a focused subagent (e.g., "read and summarize this 50-page document"). Should the engine support this within its architecture?

**Proposed**: Yes, but not in v1. The first version uses a single cognitive thread. Subagent delegation is a Phase 3 capability when the self-improvement system (Section 7) is mature enough to manage subagent quality. Flag this as a future architecture extension.

### Q6: How do we test the engine in isolation from other sections?

The engine depends on Security (Section 8), Identity (Section 2), and Hardware (Section 1). How do we test the engine before those sections are fully built?

**Proposed**: Each dependency has a mock implementation:
- `MockPermissionGate` that allows everything
- `MockAuditLogger` that writes to stdout
- Mock identity files (minimal SOUL.md, etc.)
- `MockThermalState` that returns COOL

This lets the engine be developed and tested independently, with real integrations added incrementally.

### Q7: How does the engine handle the "cold start" problem?

On first-ever boot, there is no WISDOM-MODEL, no conversation history, no routing calibration, no memory. How should the engine behave?

**Proposed**: Graceful degradation. WISDOM-MODEL is seeded from existing memory files (as described in Section 2). Routing calibration starts with conservative defaults (bias toward cheaper models). The engine's first cycle generates a "hello world" Telegram message introducing itself. The first few days should be Phase 1 (Awakening) — reading, asking questions, building context. The engine knows it's new and behaves accordingly.

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| **Core loop latency too high** — context assembly + model call takes too long for responsive conversation | Wisdom finds it frustrating to interact with | Telegram typing indicator. Pre-cache identity. Aggressive context pruning. Profile and optimize hot path. |
| **Salience scoring quality** — local model makes bad routing decisions | Expensive model used for trivial tasks; cheap model used for important ones | Rule-based fallback. Parallel scoring during calibration period. Reflection-based routing calibration. |
| **SQLite contention** — multiple async tasks reading/writing engine.sqlite | Database locked errors, lost perceptions | WAL mode. Minimize write frequency. Separate databases for high-write (perceptions) and low-write (state) if needed. |
| **Memory leak from long-running process** — Python process grows unboundedly | OOM kill after days of operation | Monitor RSS via health checks. Periodic self-restart (weekly) as maintenance. Profile memory usage. |
| **Context window overflow** — identity + memory + perception exceeds model's context limit | Truncated context, lost information | ContextBuilder enforces hard token budgets per layer. Compression tiers. Never exceed 80% of model's context limit. |
| **Ollama thermal conflict** — running local model heats CPU, triggers throttle, suspends Ollama, repeat | Oscillating between local and cloud models | Hysteresis: don't restart Ollama until COOL zone. Minimum cooldown period. |
| **Hook explosion** — too many hooks slow down the cognitive loop | Every cycle has N hook callbacks adding latency | Hooks are async but non-blocking. Slow hooks are warned about in audit trail. Maximum hook execution time enforced. |
| **Conversation context staleness** — compressed summary loses important details | Companion forgets things Wisdom said 5 messages ago | Keep recent N messages in full, only compress older ones. Section 4 memory system handles long-term recall. |
| **Identity drift across model tiers** — Companion sounds different on Haiku vs Sonnet | Wisdom experiences personality inconsistency | Test compressed identity tiers for personality coherence. Tune compression until personality is recognizable at all tiers. |

---

## Success Criteria

1. The cognitive loop runs continuously for 24+ hours without crashing or hanging
2. Telegram messages from Wisdom receive a response within 30 seconds (p95)
3. Model routing demonstrably sends simple tasks to cheap models and hard tasks to expensive models (measurable from audit trail)
4. The engine correctly enters conservation mode when budget is nearly exhausted
5. The engine adjusts behavior based on thermal state (skips local model when hot)
6. The engine's circadian rhythm visibly changes behavior by time of day (measurable from audit trail)
7. The startup sequence completes cleanly and the engine can recover from crashes without losing pending perceptions
8. All four downstream sections (Memory, Budget, Communication, Self-Improvement) can successfully hook into the engine's cognitive loop
9. The engine loads identity correctly at all compression tiers and produces recognizably in-character responses
10. The engine can operate in degraded mode when any single dependency is unavailable (Ollama down, memory system unavailable, etc.)
