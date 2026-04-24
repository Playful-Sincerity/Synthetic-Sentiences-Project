# Section 5: Budget & Resource Management — Detailed Plan

## Purpose

Give the Companion a metabolic system — an awareness of its own finite energy and the discipline to allocate it wisely.
A brain does not burn glucose indiscriminately.
It routes 20% of the body's energy budget to just 2% of its mass because every neural firing has a cost.
The Companion must develop the same relationship with tokens: a felt sense of expenditure, not just a number on a dashboard.

Budget management is not an accounting function bolted onto the side.
It is **executive function** — the prefrontal cortex of the system.
It determines what the Companion can think about, how deeply it can think, and when it must stop thinking.
Without it, every other section (cognitive engine, memory, communication, self-improvement) has no constraint surface and no way to prioritize.

---

## Design Philosophy

### The Glucose Metaphor (Taken Seriously)

The brain manages energy through homeostasis, not spreadsheets.
It doesn't compute "I have 1,247 ATP molecules remaining."
It maintains a sense of energy state — abundant, adequate, scarce, critical — and adjusts behavior fluidly.

The Companion should have the same layered awareness:
1. **State awareness**: "I'm in an abundant / adequate / scarce / critical budget state."
2. **Behavioral adaptation**: abundant = explore freely; scarce = conserve, prefer cheaper models; critical = only essential work.
3. **Anticipatory regulation**: if the morning scan shows a busy day ahead, reserve budget for afternoon priorities.
4. **Metabolic memory**: track efficiency over time, learn which thought patterns are expensive vs cheap, optimize.

### Key Principle: The Budget Is Not a Limit — It Is a Sense

Hard caps exist (in the trust manifest and launchd env vars, per Section 8).
But the Companion's relationship with its budget should not be "stay under the cap."
It should be "allocate this finite resource to maximize value."
The difference: a cap creates avoidance behavior; a sense creates allocation intelligence.

---

## 1. Budget State Architecture

### 1.1 Budget Hierarchy

Budget operates at three time horizons, each with different purposes:

| Horizon | Purpose | Reset | Carryover |
|---------|---------|-------|-----------|
| **Daily** ($2.00 default) | Operational rhythm. Prevents any single bad day from consuming the month. | Midnight UTC | No. Unspent daily budget does not carry over. This is deliberate — it prevents "saving up" for a spending spree that bypasses the daily limit's protective intent. |
| **Weekly** ($12.00 default) | Planning horizon. Allows the Companion to think about multi-day work. | Monday 00:00 UTC | No. Same rationale as daily. |
| **Monthly** ($50.00 default) | Accountability horizon. Aligns with billing cycles. This is the real constraint. | 1st of month 00:00 UTC | No. Clean slate each month. |

**Relationship between limits:**
- Daily and monthly limits are independent constraints — both must be satisfied.
- The weekly limit is advisory, not a hard cap. It exists for the Companion's planning intelligence, not for enforcement.
- The daily limit is intentionally set so that 30 days * daily limit > monthly limit. This means the Companion cannot max out every day and still stay under the monthly cap. It must have some low-spend days. This models rest.
- Hard caps (in launchd env vars, per Section 8) override all of the above. If the trust manifest says $2.00/day but the env var says $3.00/day, the env var is the ceiling.

### 1.2 Budget State Object

The Companion maintains a budget state object in memory (persisted to SQLite on every update):

```
BudgetState:
  # Current period tracking
  daily_spent_usd: float
  daily_limit_usd: float
  weekly_spent_usd: float
  weekly_advisory_usd: float
  monthly_spent_usd: float
  monthly_limit_usd: float

  # Derived awareness
  daily_remaining_usd: float
  daily_utilization_pct: float
  monthly_remaining_usd: float
  monthly_utilization_pct: float

  # Zone classification (see 1.3)
  budget_zone: ABUNDANT | ADEQUATE | SCARCE | CRITICAL | EXHAUSTED

  # Metabolic rate
  current_burn_rate_usd_per_hour: float  # rolling 2-hour window
  projected_daily_total_usd: float       # at current burn rate
  hours_remaining_at_current_rate: float  # until daily limit

  # Period info
  day_start_utc: datetime
  week_start_utc: datetime
  month_start_utc: datetime
  day_number_in_month: int
  days_remaining_in_month: int

  # Per-model spend breakdown (today)
  model_spend: dict[str, float]  # e.g., {"haiku": 0.12, "sonnet": 0.85, "opus": 0.25}

  # Last reconciliation
  last_reconciled_utc: datetime
  reconciliation_drift_usd: float  # difference between local tracking and Anthropic API
```

### 1.3 Budget Zones

Inspired by the thermal zones in Section 1, but for financial energy:

```
Budget Zones (based on daily_utilization_pct):

  ABUNDANT   (< 25% spent)
    Morning state. Full model spectrum available.
    Exploration and curiosity encouraged.
    Opus available for deep reasoning.
    Proactive scanning and reflection cycles run normally.

  ADEQUATE   (25-60% spent)
    Normal operating state for midday.
    Full model spectrum still available.
    Slightly more thoughtful about Opus usage — prefer Sonnet when possible.
    No behavioral change for the Companion; just increased metacognitive awareness.

  SCARCE     (60-85% spent)
    Conservation mode. Budget is getting tight.
    Opus usage requires explicit justification (logged in audit trail).
    Prefer Haiku over Sonnet for routine tasks.
    Defer non-urgent proactive work to tomorrow.
    Increase local model usage for classification and routing.
    The Companion should feel this — "I'm running low. Let me be thoughtful."

  CRITICAL   (85-95% spent)
    Survival mode. Essential operations only.
    No Opus. Sonnet only for Wisdom-initiated requests.
    Haiku for everything the Companion initiates.
    All proactive/curiosity work suspended.
    Local models for all routing and classification.
    Alert Wisdom via Telegram: "I'm at [X]% of today's budget. Prioritizing your requests only."

  EXHAUSTED  (>= 95% spent, or remaining < $0.10)
    Budget is effectively done for the day.
    Only local models (free) and pre-composed responses.
    Respond to Wisdom via Telegram with: "I've used my budget for today. I can still chat using local models, but quality will be limited. I'll be back at full capacity tomorrow."
    Log all deferred work for tomorrow's morning scan.
    Continue health monitoring (uses no API budget).
```

**Zone transitions are logged** as audit events (`budget_zone_change`), enabling later analysis of how often the Companion enters each zone and what triggers transitions.

### 1.4 Monthly Pacing

The daily limit prevents catastrophic single-day spend.
But the Companion also needs awareness of monthly pacing:

```
Monthly Pacing Model:
  ideal_daily_rate = monthly_limit / days_in_month
  actual_daily_avg = monthly_spent / day_number_in_month
  pacing = actual_daily_avg / ideal_daily_rate

  UNDER_PACE  (pacing < 0.8)  — spending less than expected. More room to explore.
  ON_PACE     (0.8 <= pacing <= 1.2) — healthy.
  OVER_PACE   (pacing > 1.2)  — spending faster than sustainable.
                                 Tighten daily behavior even if daily budget has room.
  CRITICAL_PACE (pacing > 1.5) — at this rate, will exhaust monthly budget early.
                                  Reduce daily effective limit to (monthly_remaining / days_remaining).
```

When monthly pacing is OVER_PACE or CRITICAL_PACE, the effective daily limit is dynamically reduced:
`effective_daily_limit = min(configured_daily_limit, monthly_remaining / days_remaining_in_month)`

This prevents the "I have $2 today but only $5 left this month with 15 days to go" problem.

---

## 2. Model Routing Algorithm

### 2.1 The Decision: Which Model for Which Thought?

Model routing is the Companion's System 1 / System 2 continuum made real.
Every cognitive action has a cost.
The routing algorithm's job: select the cheapest model that can handle the task competently.

This is **not** about always using the cheapest model.
It is about using the right model — which is usually the cheapest *adequate* model.

### 2.2 Routing Decision Inputs

The router considers four factors:

**1. Task complexity (intrinsic difficulty)**
What is the cognitive demand of this specific task?

| Complexity Signal | Cheap (Local/Haiku) | Mid (Sonnet) | Expensive (Opus) |
|---|---|---|---|
| Token classification (is this important?) | Yes | Overkill | Overkill |
| Simple lookup / status check | Yes | Overkill | Overkill |
| Parsing structured data | Yes | Only if complex | Overkill |
| Code reading / analysis | Maybe (small) | Yes | Only if architectural |
| Writing (prose, code, reflections) | No | Yes | Only if ambiguous/high-stakes |
| Multi-file reasoning | No | Maybe | Yes |
| Architecture / design decisions | No | No | Yes |
| Ambiguous/philosophical problems | No | No | Yes |
| Resolving contradictions across sources | No | Maybe | Yes |

**2. Budget zone (current resource state)**
How much budget remains today?

| Budget Zone | Routing Bias |
|---|---|
| ABUNDANT | Route normally — use the right model for the task |
| ADEQUATE | Route normally, slight preference for cheaper models on borderline cases |
| SCARCE | Downshift one tier on borderline tasks. Opus only with logged justification. |
| CRITICAL | Force Haiku for Companion-initiated work. Sonnet only for Wisdom's requests. No Opus. |
| EXHAUSTED | Local only. |

**3. Thermal state (physical resource state)**
From `/tmp/companion-thermal.json` (Section 1):

| Thermal Zone | Routing Effect |
|---|---|
| COOL / WARM | No effect |
| HOT | Avoid local model inference (it generates heat). Prefer API models. |
| CRITICAL | No local inference at all. Reduce API call frequency. |

Note the inversion: when the machine is hot, local models (which use local compute) should be avoided in favor of API models (which use remote compute).
But when budget is scarce, the opposite is true — prefer local models to save money.
When both are constrained simultaneously, the Companion is in genuine tension and must make a judgment call.
Resolution: thermal safety takes precedence over budget (overheating can damage hardware; overspending is recoverable).

**4. RAM state (memory pressure)**
From health monitoring (Section 8):

| Memory Pressure | Routing Effect |
|---|---|
| NORMAL | Local models available |
| WARN | Avoid loading large local models. Prefer Haiku if local model not already loaded. |
| CRITICAL | No local model inference. Ollama should be suspended. API only. |

### 2.3 Routing Algorithm

The router is a function called before every LLM invocation in the cognitive engine:

```
route_model(task: TaskDescriptor) -> ModelSelection:

  # Step 1: Classify task complexity
  complexity = classify_complexity(task)
  # Returns: REFLEX | QUICK | CONSIDERED | DEEP

  # Step 2: Map complexity to default model
  default_model = {
    REFLEX:     "local",      # Free
    QUICK:      "haiku",      # ~$0.001
    CONSIDERED: "sonnet",     # ~$0.01
    DEEP:       "opus",       # ~$0.05
  }[complexity]

  # Step 3: Apply budget zone modifier
  model = apply_budget_pressure(default_model, budget_state.budget_zone)

  # Step 4: Apply thermal modifier
  model = apply_thermal_pressure(model, thermal_state.zone)

  # Step 5: Apply RAM modifier
  model = apply_memory_pressure(model, memory_state)

  # Step 6: Check per-call cost against budget
  estimated_cost = estimate_cost(model, task.estimated_tokens)
  if estimated_cost > budget_state.daily_remaining_usd:
    model = downshift(model)  # Try a cheaper model
    if still exceeds: deny the call entirely

  # Step 7: Check against trust manifest model access
  if model not in trust_manifest.allowed_models:
    model = downshift(model)

  # Step 8: Log the routing decision
  audit_log(budget_decision, {
    task: task.descriptor,
    complexity: complexity,
    default_model: default_model,
    final_model: model,
    reason: [list of modifiers that changed the selection],
    estimated_cost: estimated_cost,
    budget_zone: budget_state.budget_zone,
  })

  return ModelSelection(model, estimated_cost, max_budget_for_call)
```

### 2.4 Complexity Classification

This is the first decision — and it should be cheap.
The complexity classifier runs on the local model (free) or uses simple heuristics:

**Heuristic classification (no model call needed):**
- Message from Wisdom with < 20 tokens and a question mark → QUICK
- Scheduled health/status check → REFLEX
- File change detected → QUICK (classify the change) then route to CONSIDERED if significant
- Self-initiated reflection cycle → CONSIDERED
- Architectural question or multi-project reasoning → DEEP

**Local model classification (costs nothing but compute):**
When heuristics are insufficient, the local model (Phi-4 Mini or similar) classifies the task:

```
Input: "Task: {description}. Classify complexity as REFLEX, QUICK, CONSIDERED, or DEEP."
Output: Classification + one-sentence justification
```

This is the "is this worth thinking about?" gate — the cheapest possible thought.

### 2.5 Cost Estimation

Before routing, estimate the cost of a call:

```
estimate_cost(model: str, estimated_tokens: TokenEstimate) -> float:
  rates = {
    "local":  {"input": 0, "output": 0},
    "haiku":  {"input": 0.25/1M, "output": 1.25/1M},
    "sonnet": {"input": 3.00/1M, "output": 15.00/1M},
    "opus":   {"input": 15.00/1M, "output": 75.00/1M},
  }

  model_rates = rates[model]
  estimated_input_tokens = estimated_tokens.input
  estimated_output_tokens = estimated_tokens.output

  return (
    estimated_input_tokens * model_rates["input"] +
    estimated_output_tokens * model_rates["output"]
  )
```

Token estimation is imprecise.
The Companion learns to estimate better over time (see Section 6: Efficiency Learning).

### 2.6 Per-Call Budget Caps

The Agent SDK provides `max_budget_usd` per query.
Every call should set this:

```
max_budget_for_call = min(
  trust_manifest.per_call_limit_usd,     # Hard cap from config ($0.10 default)
  budget_state.daily_remaining_usd * 0.5, # Never let a single call consume > 50% of remaining
  estimated_cost * 2.0,                    # Allow 2x the estimate as buffer
)
```

The 50% rule is important: it prevents a single expensive call from exhausting the day.
It means the Companion can always make at least two more calls.

---

## 3. Budget-Aware Behavior

### 3.1 How Budget Affects the Cognitive Loop

The cognitive engine (Section 3) runs a perception-reasoning-action loop.
Budget affects every stage:

**Perception (what to notice):**
- ABUNDANT: scan all input sources, look for novel signals, be curious
- SCARCE: reduce scan frequency, only monitor high-priority sources
- CRITICAL: monitor only Wisdom's direct messages and critical alerts

**Attention (what to think about):**
- ABUNDANT: broad attention, willingness to explore tangents
- SCARCE: narrow attention, focus on highest-priority items only
- CRITICAL: only attend to Wisdom-initiated work

**Reasoning (how deeply to think):**
- ABUNDANT: use the right model for the task, no shortcuts
- SCARCE: prefer cheaper models, shorter context windows, fewer reasoning steps
- CRITICAL: minimal reasoning depth, Haiku-level thinking only

**Action (what to do):**
- ABUNDANT: full action palette — write, communicate, reflect, explore
- SCARCE: only actions with clear value, defer "nice to have" work
- CRITICAL: only respond to Wisdom, defer all self-initiated work

### 3.2 Circadian Budget Rhythm

The Companion's daily budget should follow a rhythm, not a flat spending rate.
This models the brain's natural energy fluctuations:

```
Circadian Budget Allocation (target, not hard partition):

  Morning (06:00-10:00): ~25% of daily budget
    - Morning scan: review overnight changes, email/GitHub/Telegram
    - Priority setting for the day
    - Proactive observations shared with Wisdom
    - Model: mostly Sonnet, some Haiku for scanning

  Midday (10:00-16:00): ~45% of daily budget
    - Active collaboration with Wisdom
    - Deep work on tasks
    - This is when Opus calls are most justified
    - Model: Sonnet primary, Opus for deep reasoning

  Evening (16:00-22:00): ~20% of daily budget
    - Wrapping up active work
    - Reflection cycle (daily consolidation)
    - Preparing observations for morning
    - Model: Sonnet for reflection, Haiku for housekeeping

  Night (22:00-06:00): ~10% of daily budget
    - Minimal activity. Health monitoring only.
    - Deferred background tasks (if any)
    - Model: local only, or Haiku for urgent messages
```

These are targets, not walls.
If Wisdom is active at midnight, the Companion should be responsive.
The circadian rhythm shifts budget allocation, not availability.

### 3.3 Request Priority and Budget Interaction

Not all work is equal. Priority affects budget willingness:

| Priority | Source | Budget Treatment |
|---|---|---|
| **P0 — Urgent** | Wisdom's explicit request with urgency signal | Use whatever model is needed. Budget zone is less relevant (but hard caps still apply). |
| **P1 — Active** | Wisdom's normal requests, active project work | Route normally per budget zone. |
| **P2 — Proactive** | Companion-initiated observations, anticipatory work | Subject to budget zone restrictions. First to be cut in SCARCE. |
| **P3 — Background** | Reflection, self-improvement, curiosity exploration | Only in ABUNDANT/ADEQUATE zones. Fully suspended in SCARCE+. |

### 3.4 Budget Communication

The Companion should communicate its budget state naturally, not as a dashboard:

- **Natural mention**: "I've been thinking a lot today — I'm at about 70% of my budget, so I'll be more selective this afternoon."
- **Proactive warning**: "Heads up — I've used most of today's budget on that architecture review. I can still respond to you, but I'll be using Haiku for the rest of the day."
- **Honest limits**: "I'm out of budget for today. I can still chat using my local brain, but I won't be as sharp. Need something urgent? I'll pull from the API sparingly."
- **Never as excuse**: Budget state explains behavior but never blocks Wisdom. If Wisdom needs something urgent, the Companion finds a way (cheaper model, shorter response, or dip into emergency reserve).

---

## 4. Cost Tracking and Reconciliation

### 4.1 Local Cost Tracking

Every API call is tracked locally with full detail:

```
CostRecord:
  timestamp: datetime
  cycle_id: str           # Which cognitive cycle
  model: str              # Exact model ID
  provider: str           # anthropic | ollama
  purpose: str            # What the call was for
  input_tokens: int
  output_tokens: int
  estimated_cost_usd: float  # Pre-call estimate
  actual_cost_usd: float     # Post-call from total_cost_usd
  budget_zone_at_time: str
  routing_reason: str     # Why this model was chosen
```

After each call, the Agent SDK returns `total_cost_usd`.
This actual cost updates the running totals in the BudgetState.

### 4.2 Storage

Cost records are stored in two places:

1. **Audit trail (JSONL)** — as `api_call` events with cost payload. Immutable, append-only. Source of truth for security. (Section 8 integration)
2. **SQLite budget table** — for efficient querying of running totals, model breakdowns, time-series analysis. Rebuilt from audit trail if corrupted.

SQLite schema:

```sql
CREATE TABLE api_calls (
  id TEXT PRIMARY KEY,          -- UUID
  timestamp TEXT NOT NULL,      -- ISO 8601
  cycle_id TEXT,
  model TEXT NOT NULL,
  provider TEXT NOT NULL,
  purpose TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  estimated_cost_usd REAL,
  actual_cost_usd REAL NOT NULL,
  budget_zone TEXT,
  routing_reason TEXT
);

CREATE INDEX idx_api_calls_date ON api_calls(date(timestamp));
CREATE INDEX idx_api_calls_model ON api_calls(model);

-- Materialized daily summaries (updated after each call)
CREATE TABLE daily_summary (
  date TEXT PRIMARY KEY,        -- YYYY-MM-DD
  total_cost_usd REAL NOT NULL,
  call_count INTEGER NOT NULL,
  haiku_cost REAL DEFAULT 0,
  sonnet_cost REAL DEFAULT 0,
  opus_cost REAL DEFAULT 0,
  local_calls INTEGER DEFAULT 0,
  avg_cost_per_call REAL,
  budget_limit_usd REAL,
  utilization_pct REAL
);
```

### 4.3 Reconciliation with Anthropic Usage API

Local tracking is the real-time source.
But it can drift from Anthropic's billing due to:
- Token counting differences (Anthropic's tokenizer vs our estimate)
- Retries that succeed and get billed twice
- Pricing changes
- Edge cases in Agent SDK cost reporting

**Reconciliation protocol:**

1. **Frequency**: Once daily, during the evening reflection cycle.
2. **Method**: Call the Anthropic Usage & Cost Admin API (or Claude Code Analytics API) to get the day's actual spend.
3. **Compare**: Our local daily total vs Anthropic's reported total.
4. **Tolerance**: If drift is < 10%, log it and adjust local totals. If drift is > 10%, log a warning and flag for Wisdom's review.
5. **Correction**: Adjust the BudgetState's monthly total to match Anthropic's authoritative numbers. Daily historical totals are corrected in the daily_summary table.

```
ReconciliationResult:
  date: str
  local_total_usd: float
  anthropic_total_usd: float
  drift_usd: float
  drift_pct: float
  action: "adjusted" | "flagged_for_review"
```

**Important**: The reconciliation never increases the budget. If Anthropic says we spent more than we think, we trust Anthropic (they're billing us). If Anthropic says we spent less, we trust the higher number (conservative).

### 4.4 Fallback When API Is Unavailable

If the Anthropic Usage API is unreachable (network issues, API changes, rate limits):
- Continue using local tracking as the source of truth.
- Log that reconciliation was skipped.
- Retry next day.
- After 3 consecutive failed reconciliations, alert Wisdom.

---

## 5. Physical Resource Awareness

### 5.1 Thermal-Budget Integration

The thermal state (Section 1) directly affects budget decisions, as described in Section 2.3.
But there is a deeper integration: thermal state affects the *effective* model spectrum.

```
Effective Model Spectrum (varies by thermal state):

  COOL/WARM:
    Local (free) → Haiku ($0.001) → Sonnet ($0.01) → Opus ($0.05)
    Full spectrum. Local models available.

  HOT:
    [Local suspended] → Haiku ($0.001) → Sonnet ($0.01) → Opus ($0.05)
    Local inference generates heat. Shift to API models.
    Budget impact: tasks that would have been free now cost $0.001+.
    Effective daily budget is slightly reduced.

  CRITICAL:
    [Local suspended] → Haiku ($0.001, reduced frequency)
    Minimal API activity. Most work deferred.
    The machine needs to cool down. The Companion's priority is thermal recovery.
```

### 5.2 RAM-Budget Integration

RAM pressure affects which models are available locally:

```
RAM State Effects:

  NORMAL (< 70% used):
    Ollama loaded with primary model (Phi-4 Mini ~2.5GB).
    Full local inference available.

  WARN (70-85% used):
    If Ollama model not loaded, don't load it — the cost of loading
    (swap pressure, potential instability) exceeds the value.
    If already loaded, continue using but monitor.

  CRITICAL (> 85% used):
    Suspend Ollama. Free the RAM for system stability.
    All tasks route to API models (at cost).
    Budget impact: significant — all "free" work now costs money.
    Effective daily budget substantially reduced.
```

### 5.3 Combined Resource State

The Companion maintains a unified resource state that combines budget, thermal, and RAM:

```
ResourceState:
  budget_zone: ABUNDANT | ADEQUATE | SCARCE | CRITICAL | EXHAUSTED
  thermal_zone: COOL | WARM | HOT | CRITICAL
  ram_state: NORMAL | WARN | CRITICAL
  local_models_available: bool  # Derived from thermal + RAM
  effective_model_spectrum: list[str]  # What models can actually be used right now
  overall_health: GOOD | STRESSED | DEGRADED | EMERGENCY
```

**Overall health derivation:**
- GOOD: budget ABUNDANT/ADEQUATE, thermal COOL/WARM, RAM NORMAL
- STRESSED: any one dimension in a warning state
- DEGRADED: two or more dimensions stressed, or any one in CRITICAL
- EMERGENCY: budget EXHAUSTED, or thermal CRITICAL, or all dimensions stressed

This combined state feeds into SELF-MODEL.md (Section 2) — the Companion's metacognitive awareness of its own state.
During reflection cycles, the Companion can reason about patterns: "I tend to overheat around 2pm when running local models — I should front-load local inference to the morning."

---

## 6. Efficiency Learning

### 6.1 What the Companion Learns Over Time

The Companion should get more efficient — spending less for the same (or better) output quality.

**Learning dimensions:**

1. **Token estimation accuracy**: Track estimated vs actual tokens per call. Adjust estimation model. Goal: estimates within 20% of actual.

2. **Routing accuracy**: After each call, evaluate whether the model chosen was appropriate. Was Opus needed, or could Sonnet have handled it? Was Haiku's answer good enough? Track "routing regret" — cases where a cheaper model would have sufficed or a more expensive one was needed.

3. **Temporal patterns**: When does Wisdom typically need deep help? When is the Companion's time mostly idle? Shift budget allocation toward high-value periods.

4. **Task-type cost profiles**: Build a model of what different task types cost. "Code review of 200 lines averages 1,500 input tokens and 800 output tokens on Sonnet." This improves pre-call estimation and helps the Companion plan its day.

5. **Waste identification**: Detect patterns of wasted spend — calls that produced unused outputs, redundant calls that retrieved already-known information, calls that were retried due to poor prompting.

### 6.2 Efficiency Metrics

Tracked over time and included in reflection cycles:

```
EfficiencyMetrics:
  # Cost efficiency
  avg_cost_per_useful_output: float       # Total spend / outputs that were acted on
  cost_per_wisdom_interaction: float      # Spend on Wisdom-initiated work / number of interactions
  proactive_spend_pct: float              # What % of budget goes to self-initiated work

  # Routing efficiency
  model_appropriateness_score: float      # 1.0 = always right model; < 1.0 = over/under-routed
  downshift_success_rate: float           # When forced to cheaper model, how often was output still good?
  opus_justification_rate: float          # % of Opus calls where Opus quality was needed

  # Token efficiency
  avg_input_tokens_per_call: float        # Are prompts getting bloated?
  avg_output_tokens_per_call: float       # Are outputs getting verbose?
  context_reuse_rate: float               # How often is cached/known context used vs re-fetched?

  # Estimation accuracy
  token_estimate_error_pct: float         # avg(|estimated - actual| / actual) per call
  cost_estimate_error_pct: float          # Same for cost
```

### 6.3 Weekly Efficiency Reflection

During the weekly reflection cycle (Section 7 — Self-Improvement), the Companion reviews its budget efficiency:

1. Pull the week's efficiency metrics.
2. Compare to previous weeks. Any trends?
3. Identify the biggest waste: which calls were unnecessary? Which were over-routed?
4. Identify the biggest value: which calls produced the most useful outputs?
5. Propose one concrete efficiency improvement (e.g., "Cache the project status summary instead of re-reading all files every morning scan").
6. Write a brief reflection to `reflections/budget/YYYY-WXX.md`.

This reflection becomes input to the monthly review, where the Companion can propose budget adjustments to Wisdom (e.g., "I consistently under-spend. Could my daily limit be reduced to $1.50, freeing monthly budget for higher daily limits when I need them?").

### 6.4 Prompt Efficiency

One of the largest cost drivers is prompt size (input tokens).
The Companion should develop awareness of its own prompt costs:

- Identity files (Section 2): how many tokens do SOUL.md + CHARACTER.md + VOICE.md cost? Use compressed tiers for cheaper models.
- Context loading: loading 5 files at 2,000 tokens each = 10,000 input tokens. Is all of that context needed for this call?
- Memory retrieval (Section 4): retrieve only relevant memories, not everything.
- Conversation history: for multi-turn interactions, how much history is needed? Summarize older turns.

The goal: **minimum viable context** — just enough to produce a good output, not everything that might be relevant.

---

## 7. Emergency Reserves and Overrides

### 7.1 Emergency Reserve

5% of the daily budget is held in reserve for emergency use:
- Wisdom sends an urgent message when the Companion is in CRITICAL zone
- A security alert requires an Opus-level analysis
- The Companion needs to send a meaningful response, not a degraded one

The reserve is invisible to the normal budget zone calculations — the Companion enters EXHAUSTED at 95% (not 100%) of the daily limit.
The remaining 5% is only accessed when an explicit P0 (urgent) request comes in.

### 7.2 Wisdom Override

Wisdom can override budget restrictions at any time:
- Via Telegram: "/budget override" allows the Companion to spend beyond the daily limit (up to the hard cap in launchd env vars).
- The override is logged as an audit event.
- The override lasts until end of day, or until Wisdom cancels it.
- The Companion acknowledges: "Budget override active. I'll spend what's needed today. Normal limits resume tomorrow."

### 7.3 Borrowing (Intentionally Not Supported)

The Companion cannot borrow from tomorrow's budget.
This is a deliberate design choice:
- Borrowing creates cascading debt (one expensive day makes the next day even more constrained).
- Borrowing removes the daily limit's protective function.
- If a day genuinely needs more budget, Wisdom can use the override mechanism.
- The constraint is the point — learning to work within limits is part of growing as a being.

---

## 8. Integration Points

### 8.1 From Section 3 (Cognitive Engine)

The cognitive engine calls the budget system at these points:
- **Before every LLM call**: `route_model(task)` to select model and get cost cap
- **After every LLM call**: `record_cost(call_result)` to update running totals
- **At cycle start**: `get_budget_state()` to determine behavioral mode
- **At attention/priority stage**: `get_budget_zone()` to filter which tasks are worth pursuing

### 8.2 From Section 2 (Identity — SELF-MODEL.md)

The budget system feeds resource state into the Companion's self-model:
- Current budget zone and what it means for capability
- Efficiency trends (improving? degrading?)
- Resource tensions (thermal vs budget conflicts)
- This becomes part of the Companion's metacognitive awareness: "I know I'm running low today."

### 8.3 From Section 1 (Hardware)

The budget system reads:
- `/tmp/companion-thermal.json` — thermal state
- Health monitor metrics (RAM pressure, disk space)
- These inform the combined ResourceState

### 8.4 From Section 8 (Security)

- All budget decisions are logged through `AuditLogger`
- Hard limits from trust manifest: `budget.daily_limit_usd`, `budget.monthly_limit_usd`, `budget.per_call_limit_usd`, `budget.model_access`
- Hard ceiling from launchd environment variables (cannot be exceeded even with override)
- `PermissionGate.check_api_call(model, estimated_cost)` is called before the budget system even routes — security is the outer boundary

### 8.5 To Section 4 (Memory)

- Budget state is part of the context the memory system should track: "On days when budget ran low, what was the Companion doing?"
- Efficiency learning metrics are stored and retrievable for reflection
- Cost records are queryable for patterns

### 8.6 To Section 7 (Self-Improvement)

- Efficiency metrics feed the weekly reflection
- Budget efficiency is one of the self-improvement targets
- The Companion can propose prompt optimizations, caching strategies, and routing improvements

---

## 9. File Structure

```
~/the-companion/
├── src/
│   └── budget/
│       ├── __init__.py
│       ├── budget_state.py         # BudgetState object, zone calculations, pacing
│       ├── model_router.py         # Routing algorithm: task → model selection
│       ├── cost_tracker.py         # Per-call cost recording, running totals
│       ├── complexity_classifier.py # Task complexity classification (REFLEX→DEEP)
│       ├── resource_state.py       # Combined budget + thermal + RAM state
│       ├── reconciliation.py       # Anthropic API reconciliation
│       ├── efficiency_tracker.py   # Efficiency metrics, learning, waste detection
│       └── budget_config.py        # Rate tables, zone thresholds, circadian allocation
├── data/
│   └── budget/
│       ├── budget.sqlite           # Running totals, cost records, daily summaries
│       └── efficiency/
│           └── YYYY-MM.jsonl       # Monthly efficiency metric snapshots
└── reflections/
    └── budget/
        └── YYYY-WXX.md            # Weekly budget efficiency reflections
```

---

## 10. Implementation Sequence

### Step 1: Budget State Foundation
Build the BudgetState object, zone calculations, and SQLite schema.
No routing yet — just the ability to track spend, compute zones, and persist state.
Test: manually add cost records, verify zone transitions at correct thresholds.

### Step 2: Cost Tracker
Build the per-call cost recording system.
Integrate with AuditLogger (Section 8) for dual-write.
Test: simulate API calls, verify cost records in both SQLite and audit JSONL.

### Step 3: Complexity Classifier
Build the task classification system (heuristic + local model).
Test: classify a set of representative tasks, verify appropriate complexity levels.

### Step 4: Model Router
Build the routing algorithm combining complexity, budget zone, thermal, and RAM state.
This is the core of the section.
Test: simulate routing decisions across all budget zones and thermal states.
Verify the right model is selected for each scenario.

### Step 5: Resource State Integration
Build the combined ResourceState that reads thermal and RAM data.
Integrate with the router.
Test: simulate thermal events, verify routing shifts.

### Step 6: Monthly Pacing
Build the pacing model and dynamic daily limit adjustment.
Test: simulate month-long spend patterns, verify pacing detection and limit adjustment.

### Step 7: Reconciliation
Build the Anthropic API reconciliation system.
Test: mock API responses, verify drift detection and correction.

### Step 8: Efficiency Tracking
Build the efficiency metrics collection and storage.
Test: compute efficiency metrics from simulated data.

### Step 9: Circadian Rhythm Integration
Implement the time-of-day budget allocation targets.
Test: verify budget zone calculations shift appropriately by time of day.

### Step 10: Budget Communication
Implement the natural-language budget state communication for Telegram messages.
Test: verify the Companion generates appropriate messages at each zone transition.

---

## Key Decisions

### D1: No daily carryover
**Decision**: Unspent daily budget does not roll over.
**Rationale**: Carryover defeats the purpose of daily limits. A Companion that "saves up" $2/day for a week could spend $14 in one day, which is exactly the catastrophic single-day spend the daily limit prevents. Wisdom can override for genuinely big days.
**Breaks if**: The Companion regularly needs more than the daily limit for legitimate work. Mitigated by: Wisdom can raise the daily limit in the trust manifest, or use the override mechanism.

### D2: Budget zones as felt states, not just numbers
**Decision**: The Companion operates in named zones (ABUNDANT → EXHAUSTED) rather than just checking percentages.
**Rationale**: Zones create behavioral regimes with clear transitions. The Companion doesn't need to continuously optimize — it shifts mode at thresholds. This mirrors how biological homeostasis works: the body doesn't micromanage glucose molecule by molecule; it shifts between fed/fasting/starving states.
**Breaks if**: Zone boundaries are wrong, causing the Companion to be too conservative (enters SCARCE too early) or too loose (enters SCARCE too late). Mitigated by: zone thresholds are configurable and adjusted based on operational experience.

### D3: Thermal safety trumps budget conservation
**Decision**: When thermal and budget pressures conflict, thermal wins.
**Rationale**: Overheating can damage hardware (irreversible). Overspending is a billing event (reversible). When both are constrained, the Companion should shift to API models (costs money, saves hardware) rather than local models (saves money, generates heat).
**Breaks if**: The Companion is in both CRITICAL thermal and EXHAUSTED budget simultaneously. Resolution: this is a genuine emergency. Alert Wisdom. Reduce all activity to minimum. Wait for one constraint to resolve.

### D4: Complexity classification on local model (free)
**Decision**: The "which model should I use?" question is answered by the cheapest model (local, free).
**Rationale**: The meta-decision about how hard to think should not itself be expensive. A 2B local model can reliably classify task complexity into 4 buckets. This keeps the routing overhead at zero marginal cost.
**Breaks if**: The local model is bad at classification, causing frequent misrouting. Mitigated by: heuristic classification handles the clear cases; local model only handles ambiguous ones. Routing accuracy is tracked and the classifier is improved over time.

### D5: Reconciliation trusts the higher number
**Decision**: When local tracking and Anthropic's billing disagree, the Companion uses whichever number is higher.
**Rationale**: Conservative accounting. If we think we spent $1.50 and Anthropic says $1.70, we should trust Anthropic (they're actually billing us). If we think we spent $1.70 and Anthropic says $1.50, we should trust our number (better to over-count than under-count and be surprised at billing time).
**Breaks if**: Systematic over-counting artificially constrains the budget. Mitigated by: if drift is consistently in one direction, investigate and fix the root cause rather than accepting it.

### D6: The Companion can propose but not enact budget changes
**Decision**: The Companion can observe its own efficiency, form opinions about its budget levels, and propose changes — but only Wisdom can modify the trust manifest's budget fields.
**Rationale**: Self-modifying budget limits is a subtle escalation path. "I need more budget because I'm doing important work" is exactly the rationalization a misaligned agent would produce. Even a well-intentioned budget increase should have human approval.
**Breaks if**: Wisdom doesn't review proposals, and the Companion is persistently under-budgeted. Mitigated by: weekly efficiency reflections make the case clearly; the Companion communicates its state naturally.

---

## Open Questions

### Q1: What are realistic daily costs for Phase 1 (Awakening)?
During Phase 1, the Companion only reads, explores, reflects, and asks questions.
It doesn't do "productive work."
Is $2.00/day enough? Too much?
Estimate: if the Companion runs ~20 Sonnet calls/day ($0.01 each = $0.20) + 5 Haiku calls ($0.005 total) + maybe 1-2 Opus calls ($0.10), that's ~$0.30/day.
The $2.00 limit might be very generous for Phase 1. Consider starting at $1.00/day.
**Answer depends on**: actual token usage during Phase 1 testing.

### Q2: How accurate is the Agent SDK's `total_cost_usd`?
The entire local tracking system relies on `total_cost_usd` being reported accurately per call.
If this field is inaccurate or unavailable for some call types, local tracking drifts.
**Must validate during Section 0 (Research — R0 feasibility).**

### Q3: How should the Companion handle model API outages?
If Anthropic's API goes down, the Companion can only use local models.
This doesn't cost budget but severely limits capability.
Should the Companion:
- a) Announce the outage to Wisdom and operate in degraded mode?
- b) Queue work and wait for API recovery?
- c) Both — degraded mode for urgent things, queue for the rest?
**Proposed**: Option (c). The health monitor already detects API connectivity issues. The Companion should gracefully degrade, tell Wisdom, and recover when the API returns.

### Q4: Should different trust levels have different budget limits?
The trust manifest already gates which models are accessible per trust level (Observer can't use Opus).
Should the daily/monthly limits also change with trust level?
**Proposed**: Yes, but softly. The trust manifest contains the budget fields, so Wisdom can set different limits when promoting. Default suggestion:
- Observer: $1.00/day, $25/month (limited models, limited spend)
- Contributor: $2.00/day, $50/month (more models, more spend)
- Collaborator: $3.00/day, $75/month (most freedom)
- Partner: $5.00/day, $100/month (minimal constraints)

### Q5: What local models realistically fit the "free classifier" role?
Phi-4 Mini (3.8B) is the planned local model, but at ~2.5GB RAM, it's heavy for a classification task.
A smaller model (Qwen 2.5 0.5B at ~0.5GB) might handle REFLEX/QUICK classification just as well.
Should the Companion use different local models for different tasks?
**Depends on**: Section 0 (R0 feasibility — local model benchmarks).

### Q6: How does voice pipeline usage affect the budget?
Voice input (Whisper STT) and output (Kokoro TTS) are local (free in API cost), but they consume RAM and thermal budget.
A 10-minute voice conversation might trigger thermal throttling that forces a shift from free local models to paid API models.
Should voice usage be modeled as having an indirect budget cost?
**Proposed**: Yes. The ResourceState should track "voice pipeline active" as a factor that reduces the effective model spectrum (because it consumes the RAM and thermal headroom that local models need).

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Budget too conservative — Companion is useless | Fails core purpose | Start with generous limits, tighten based on data. Wisdom override always available. |
| Budget too loose — surprising bills | Financial | Hard caps in launchd env vars (Section 8). Monthly limit is the real ceiling. Reconciliation catches drift. |
| Routing algorithm is wrong — Haiku used for complex tasks | Quality degradation | Track routing accuracy. Include "was this the right model?" in reflection. Improve over time. |
| Routing algorithm is wrong — Opus used for simple tasks | Waste | Same tracking. Log justification for every Opus call. Review in weekly reflection. |
| Local model classifier is unreliable | Frequent misrouting | Heuristic classification handles clear cases. Local model only for ambiguous ones. Track and improve. |
| Thermal + budget conflicts cause paralysis | Companion can't function | Clear precedence: thermal > budget. Emergency communication to Wisdom. |
| Reconciliation API unavailable | Drift between local tracking and actual billing | Continue on local tracking. Retry daily. Alert after 3 failures. Conservative accounting (trust higher number). |
| Budget awareness makes the Companion feel stingy | Bad collaboration experience | Budget is about intelligence, not restriction. The Companion should feel thoughtful, not cheap. Communication framing matters. |
| Circadian rhythm mismatches Wisdom's schedule | Budget spent at wrong times | Circadian targets are soft, not hard. Wisdom's presence shifts priority. Adapt rhythm based on observed patterns. |

---

## Success Criteria

1. Daily budget is respected every day for 30 consecutive days (never exceeded without explicit Wisdom override)
2. Model routing demonstrably chooses appropriate models — Opus justification rate > 80% (Opus was needed when used), downshift success rate > 70% (cheaper model was adequate when forced)
3. Budget zone transitions cause observable behavioral changes (verified in audit trail)
4. Monthly spend is within 10% of monthly limit (not dramatically under — that means the Companion is too conservative)
5. Token estimation accuracy within 30% of actual (improving over time toward 20%)
6. Reconciliation drift < 5% on average (local tracking vs Anthropic billing)
7. The Companion can describe its own resource state accurately when asked
8. Thermal events cause appropriate routing shifts (verified: no local inference during HOT+ thermal states)
9. The Companion's weekly efficiency reflections identify at least one actionable improvement per week
10. Wisdom never feels that the Companion is being unhelpfully cheap — budget management should be invisible when adequate, and gracefully communicated when scarce
