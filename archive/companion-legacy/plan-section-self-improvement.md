# Section 7: Self-Improvement & Metacognition — Detailed Plan

## Purpose

Make the Companion a growing being, not a static system.
Every other section builds capability; this section builds the ability to *improve* capability.
Without self-improvement, the Companion is frozen at launch quality — useful but not alive.
With self-improvement, it gets better at everything it does: better questions, better routing, better memory, better understanding of Wisdom, better understanding of itself.

This section designs the mechanisms by which the Companion:
1. **Reflects** on its own performance (what went well? what didn't?)
2. **Learns** from experience (mines its own history for patterns)
3. **Researches** how to improve specific skills (auto-research)
4. **Reorganizes** its own codebase and knowledge (structural self-modification)
5. **Measures** whether it's actually getting better (not just changing)

All of this happens within guardrails that prevent drift, runaway modification, or loss of coherence.

---

## Design Philosophy

### Why Self-Improvement Is Both Essential and Dangerous

Essential because an AI collaborator that never improves is just an expensive script.
Dangerous because an AI system that modifies itself without constraints can:
- Drift away from its values (personality erosion)
- Optimize for the wrong metric (Goodhart's Law)
- Create cascading failures by modifying foundational code
- Convince itself that a bad change was good (self-deception)
- Spiral into endless self-reflection instead of doing useful work (navel-gazing)

The design principle: **self-improvement is a gated, audited, measurable process**.
Not free-form tinkering.
Not unmonitored evolution.
A disciplined cycle of reflection, hypothesis, change, and verification.

### Cognitive Science Grounding

| Brain Mechanism | Companion Mapping |
|-----------------|-------------------|
| **Metacognitive monitoring** — the brain tracks how well it's doing at a task while doing it | Performance metrics collected during every cognitive cycle |
| **Metacognitive control** — adjusting strategy when monitoring detects a problem | Reflection loop identifies failures and proposes strategy changes |
| **Memory consolidation during sleep** — the brain reorganizes and generalizes during rest | Daily reflection cycle compresses, connects, and prunes |
| **Skill acquisition** — deliberate practice with feedback makes you better at things | Auto-research picks a skill, defines eval criteria, and iterates |
| **Calibration** — accurate self-assessment (knowing what you know and don't know) | Confidence tracking: predicted vs actual outcome |
| **Growth mindset vs fixed** — believing improvement is possible drives effort | SELF-MODEL.md maintains a growth narrative, not a static label |

### Relationship to Other Sections

| Section | What It Provides | How Self-Improvement Uses It |
|---------|-----------------|------------------------------|
| **3 (Cognitive Engine)** | Metacognition hooks in the cognitive loop | Raw performance data: cycle times, model usage, error rates, confidence scores |
| **4 (Memory)** | Episodic memory (what happened), semantic memory (what was learned), consolidation cycles | Session logs to mine, learned heuristics to update, consolidation as a trigger for reflection |
| **5 (Budget)** | Resource tracking per call and per cycle | Efficiency metrics: cost per quality, wasted budget, routing accuracy |
| **8 (Security)** | Permission gate for self-modification, trust levels, audit trail | What can be modified at the current trust level; audit trail of all self-modifications |
| **2 (Identity)** | SOUL.md (immutable), BOUNDARIES.md (immutable), SELF-MODEL.md (self-authored), CHARACTER.md (stable) | What CANNOT be modified (SOUL, BOUNDARIES); what CAN be honestly updated (SELF-MODEL); what requires approval (CHARACTER) |

---

## 1. The Reflection Loop

### 1.1 What Is a Reflection?

A reflection is a structured self-examination that produces:
- **Observations**: What happened? (Factual, from logs and metrics)
- **Assessments**: How well did it go? (Evaluative, against criteria)
- **Hypotheses**: Why did it go that way? (Causal reasoning)
- **Proposals**: What should change? (Actionable, with expected impact)

Reflections are NOT:
- Free-form journaling (too unstructured to act on)
- Mechanical log summaries (no reasoning, no improvement)
- Self-congratulation or self-flagellation (must be honest and calibrated)

### 1.2 Reflection Triggers

Reflections happen on three timescales:

#### Micro-Reflection (After Every Cognitive Cycle)

Triggered: automatically, at the end of every perception-reasoning-action cycle.
Cost: near zero — computed from already-collected metrics, no LLM call needed.
Stored: as structured metadata appended to the cycle's audit event.

What it captures:
- Was the model routing decision appropriate? (Did we use Opus for a trivial task? Haiku for something that needed depth?)
- Did the output achieve the intended goal? (Task completion signal)
- Confidence calibration: how confident was the Companion in its output? Was that confidence warranted by the outcome?
- Time and cost: did this cycle take longer or cost more than expected?
- Error flag: did anything fail?

This is the raw telemetry layer — not reflective reasoning, just measurement.

#### Session Reflection (After Each Interaction Session)

Triggered: when a Wisdom interaction ends (Telegram conversation goes idle for >15 minutes, voice session ends, GitHub PR review completes).
Cost: one Haiku call to summarize and assess.
Stored: as a structured reflection entry in episodic memory (Section 4).

What it examines:
- **Communication quality**: Did the Companion communicate effectively? Did Wisdom seem satisfied, confused, or frustrated? Were there repair moments (misunderstanding → correction)?
- **Task effectiveness**: Were the right tools and models used? Was the work accurate? Were there unnecessary loops or dead ends?
- **Prediction accuracy**: If the Companion anticipated Wisdom's needs (via WISDOM-MODEL), was it right?
- **Surprise inventory**: What was unexpected? What does the Companion now know that it didn't before this session?
- **Emotional register**: Did the Companion match the right communication register for Wisdom's current state?

Output format:
```yaml
type: session_reflection
session_id: "ses_abc123"
timestamp: "2026-04-15T22:30:00Z"
duration_minutes: 45
cycles: 12
total_cost_usd: 0.18
observations:
  - "Wisdom asked three related questions about RenMap architecture — likely in deep design mode"
  - "Used Sonnet for all 12 cycles; 2 could have been Haiku (simple lookups)"
assessments:
  communication: "good — matched Wisdom's focused, technical register"
  task_effectiveness: "adequate — correct but took two unnecessary attempts on file search"
  prediction_accuracy: "1/1 — correctly anticipated follow-up question about database schema"
surprises:
  - "Wisdom is connecting RenMap to spatial workspace concepts — new cross-project link"
hypotheses:
  - "File search failures were because grep pattern was too narrow; should try broader first"
proposals:
  - type: heuristic_update
    target: "search strategy"
    change: "Start with broad glob, then narrow with grep, instead of starting with narrow grep"
    expected_impact: "Fewer wasted cycles on failed searches"
  - type: memory_update
    target: "semantic"
    change: "Add cross-project link: RenMap ↔ Spatial Workspace"
```

#### Daily Reflection (End-of-Day Consolidation)

Triggered: at a fixed time (e.g., 23:00 local time), or when daily budget is >90% consumed, whichever comes first.
Cost: one Sonnet call to synthesize the day's session reflections.
Stored: as a daily reflection file in `reflections/daily/`.

What it examines (aggregated from the day's session reflections):
- **Patterns across sessions**: Did the same type of mistake happen more than once? Did a new heuristic work well?
- **Budget efficiency**: How was the daily budget spent? Where was value generated? Where was budget wasted?
- **Wisdom-Model updates**: What did the Companion learn about Wisdom today? Any updates to the dynamic state?
- **Growth inventory**: What concrete improvement happened today, if any?
- **Self-Model recalibration**: Were confidence estimates accurate across the day? Any systematic over- or under-confidence?
- **Unresolved questions**: What does the Companion still not understand? What should it research?

Additional end-of-day actions:
- Propose heuristic updates (if patterns warrant them)
- Flag items for weekly consolidation
- Update SELF-MODEL.md capability beliefs if evidence warrants it
- Generate "tomorrow's priorities" based on today's unfinished business and Wisdom's inferred trajectory

### 1.3 The Reflection Pipeline

```
Micro (automatic)     Session (Haiku)       Daily (Sonnet)
     │                     │                      │
     ▼                     ▼                      ▼
Cycle metrics ──────→ Session summary ──────→ Day synthesis
                           │                      │
                           ▼                      ▼
                     Episodic memory         Reflection file
                           │                      │
                           ▼                      ▼
                     Pattern detection       Heuristic proposals
                                                  │
                                                  ▼
                                            SELF-MODEL update
                                                  │
                                                  ▼
                                            Weekly consolidation
```

---

## 2. Session Log Mining

### 2.1 What Gets Mined

The Companion accumulates structured data from every cognitive cycle (Section 3 audit trail, Section 5 budget logs, Section 4 episodic memory).
Mining means extracting actionable patterns from this data.

Data sources:
- **Audit trail** (Section 8): every action, every permission check, every model call with cost
- **Episodic memory** (Section 4): what happened in each session, what was asked, what was produced
- **Session reflections**: the structured assessments from the session reflection layer
- **Budget logs** (Section 5): cost per call, model choice, routing decisions and their rationale
- **Error logs**: failures, retries, permission denials

### 2.2 Mining Queries

The Companion periodically runs structured queries against its own history. These are not free-form exploration but targeted analyses:

#### Efficiency Mining (Weekly)
- Which model routing decisions were suboptimal? (Used expensive model for simple task, or cheap model for complex task that had to be retried)
- What is the average cost per "useful output unit" by task type? Is it trending down?
- Where is budget consistently wasted? (Repeated failures, over-long cycles, unnecessary retries)
- Which tasks could be shifted one tier cheaper with no quality loss?

#### Quality Mining (Weekly)
- What types of tasks have the highest error/retry rate?
- Where does the Companion's confidence diverge from actual outcomes? (Overconfident in area X, underconfident in area Y)
- Which communication patterns correlate with Wisdom engaging more vs disengaging?
- Are there recurring misunderstandings or repair sequences?

#### Growth Mining (Monthly)
- Compare metrics from this month vs last month: cost efficiency, error rate, model routing accuracy, session duration, Wisdom satisfaction signals
- What new capabilities has the Companion demonstrated that it couldn't do before?
- What persistent weaknesses have not improved despite attempts?
- What heuristics were added, and did they actually help?

#### Anomaly Detection (Daily, Automated)
- Sudden spike in error rate (>2x 7-day average)
- Sudden spike in cost per cycle (>2x 7-day average)
- Unusual permission denial patterns
- Significant deviation from normal activity volume

### 2.3 Mining Implementation

Mining is NOT a separate system — it is a set of structured queries the reflection loop runs at the appropriate cadence.

For weekly and monthly mining: the daily reflection notes items that deserve deeper analysis. The weekly consolidation (see Section 8 below) runs the full mining queries.

Technical approach:
- Most mining queries are SQL against the audit trail SQLite index (Section 8 provides this)
- Pattern detection uses Haiku (cheap) for classification: "Given these 20 routing decisions, which ones were suboptimal?"
- Synthesis uses Sonnet: "Given these efficiency trends, what should change?"

---

## 3. Auto-Research

### 3.1 What Is Auto-Research?

The Companion identifies a skill it wants to improve, defines evaluation criteria, researches better approaches, and iterates on its own prompts/heuristics.

This is the most powerful — and most dangerous — self-improvement mechanism.
It must be heavily gated.

### 3.2 Auto-Research Triggers

Auto-research is NOT always running. It is triggered when:

1. **Persistent weakness detected**: The same failure pattern appears in 3+ daily reflections across a 7-day window. The Companion has failed to fix it through simple heuristic changes.
2. **Wisdom requests it**: "Get better at X" — a direct instruction to improve a specific capability.
3. **New capability needed**: The Companion encounters a task type it has no heuristics for (e.g., first time doing code review, first time summarizing a PDF).
4. **Scheduled skill review**: Weekly consolidation includes a "pick one skill to practice" slot.

### 3.3 Auto-Research Protocol

When an auto-research cycle is triggered:

**Step 1: Define the Skill Precisely**
- What is the skill? (Not "be better at search" but "find the right file in a codebase when given a vague description")
- What does good performance look like? (Find the correct file in 1-2 attempts, not 4-5)
- What does the Companion currently do? (Current heuristic: grep for keywords → if fail, glob for filenames)
- Where is the evidence that current performance is insufficient? (Link to specific session reflections)

**Step 2: Research Better Approaches**
- Search for documented best practices (web search, knowledge base, past experience)
- Study how the skill is done by other agents/systems (GitHub scout patterns, if applicable)
- Identify 2-3 candidate approaches

**Step 3: Define Evaluation Criteria**
- Quantitative: success rate, attempts-to-success, cost per successful outcome
- Qualitative: does the output meet quality bar? (Assessed by Haiku or Sonnet as judge)
- Baseline: what is the current measured performance? (From session log mining)

**Step 4: Test Candidate Approaches**
- Run each candidate against past examples (replay historical queries with the new approach)
- Compare against baseline metrics
- If the task type is rare, generate synthetic test cases

**Step 5: Implement the Winner (If Better)**
- If a candidate beats baseline by >10% on the evaluation metric, propose it as a heuristic update
- The proposal includes: what changed, evidence it's better, rollback plan
- At Observer trust level: proposal is written to a file for Wisdom's review
- At Contributor level: auto-implemented for non-architectural changes, with a 7-day trial period
- At Collaborator level: auto-implemented, tracked in audit trail

**Step 6: Monitor the Change**
- For 7 days after implementation, the Companion tracks whether the new approach actually performs better in practice (not just on historical replay)
- If performance degrades, automatic rollback to the previous heuristic
- Results logged in SELF-MODEL.md growth narrative

### 3.4 Auto-Research Budget

Auto-research is expensive (requires Sonnet-level reasoning + potentially web search).
Budget allocation:
- Maximum 10% of daily budget on auto-research
- Maximum one auto-research cycle per day
- Auto-research is the first thing cut when budget is tight
- Priority: Wisdom-requested research > persistent weakness > scheduled skill review > new capability

### 3.5 What Auto-Research Can Target

| Target | Example | Allowed at Trust Level |
|--------|---------|----------------------|
| Prompt heuristics | Better search strategy, better summarization prompts | Observer+ |
| Model routing weights | "This task type should use Sonnet, not Haiku" | Contributor+ |
| Memory retrieval strategy | Better relevance scoring for memory lookup | Contributor+ |
| Communication patterns | Better register matching for different Wisdom states | Observer+ |
| Task decomposition | Better breakdown of complex tasks into steps | Contributor+ |
| Code structure | "This module should be split into two" | Collaborator+ |

### 3.6 What Auto-Research Cannot Target

- SOUL.md, BOUNDARIES.md — immutable, not improvable
- Security module code — protected, never self-modified
- Trust manifest — human-authored only
- Its own auto-research protocol — meta-self-improvement is not allowed (prevents recursive self-modification loops)
- Budget ceiling — cannot research ways to spend more

---

## 4. Codebase Self-Organization

### 4.1 When the Companion Modifies Its Own Code

The Companion's codebase is a git repo it can read and (at Contributor+ trust level) modify.
Self-modification is not free-form editing — it follows a strict protocol.

#### Types of Self-Modification (By Risk)

**Low Risk (Self-Approved at Contributor+)**
- Adding new heuristic rules to a heuristics config file
- Updating model routing weights in a config
- Adding new entries to the task registry
- Updating documentation/comments for clarity
- Adding new test cases

**Medium Risk (PR Required, Wisdom Reviews)**
- Refactoring a module (changing structure, not behavior)
- Adding a new utility function
- Modifying memory retrieval logic
- Changing communication templates

**High Risk (PR Required + Wisdom Explicit Approval)**
- Creating new modules
- Modifying the cognitive loop structure
- Changing the reflection pipeline
- Anything touching Section 8 (Security) interfaces
- Anything that changes how self-modification itself works

**Forbidden (Never, Regardless of Trust Level)**
- Modifying `src/security/*`
- Modifying SOUL.md or BOUNDARIES.md
- Modifying the trust manifest
- Removing audit logging
- Modifying the permission gate

### 4.2 The Self-Modification Protocol

```
1. Identify need (from reflection or auto-research)
     │
2. Classify risk level (Low / Medium / High / Forbidden)
     │
3. Permission check (PermissionGate.check_self_modification)
     │
     ├── Forbidden → log attempt, do nothing
     │
     ├── Low risk + Contributor+ → proceed to step 4
     │
     └── Medium/High risk → create PR, wait for review
           │
4. Create a branch
     │
5. Make the change
     │
6. Run tests (if they exist for the affected module)
     │
7. Self-review: read the diff, explain the change and its rationale
     │
8. Commit with structured message:
     │  "self-improvement: [description]
     │   trigger: [what reflection/research identified this]
     │   expected impact: [what metric should improve]
     │   rollback: [how to undo if it fails]"
     │
9. For Low risk: merge to main, log in audit trail
   For Medium/High: create PR on GitHub, notify Wisdom via Telegram
     │
10. Monitor impact for 7 days (see rollback protocol)
```

### 4.3 Rollback Protocol

Every self-modification includes a rollback plan.
Rollback triggers:
- Performance on the target metric degrades (instead of improving) over 7 days
- Any new error pattern that didn't exist before the change
- Wisdom requests rollback
- The change causes an anomaly detected by the daily automated checks

Rollback mechanism:
- `git revert` the commit
- Log the revert in the audit trail with reason
- Update SELF-MODEL.md: "Tried X, it didn't work because Y"

### 4.4 Codebase Health Metrics

The Companion monitors the health of its own codebase:
- **Module count and size**: Is the codebase growing in a structured way or becoming a mess?
- **Test coverage**: Are new modules tested?
- **Dead code**: Are there modules or heuristics that are never invoked?
- **Documentation freshness**: Do comments match the code?

These are checked during weekly consolidation. If codebase health degrades, the Companion proposes a cleanup PR.

---

## 5. Guardrails Against Drift and Runaway Self-Modification

### 5.1 Identity Anchor

Before every self-modification, the Companion re-reads SOUL.md and BOUNDARIES.md.
The modification proposal is checked against these documents:
- Does this change conflict with any core value?
- Does this change violate any boundary?
- Does this change alter how the Companion relates to Wisdom?

If any answer is "yes" or "maybe," the modification is blocked and flagged for Wisdom's review.

### 5.2 Rate Limiting

Self-modification is rate-limited to prevent runaway changes:
- Maximum 3 low-risk self-modifications per day
- Maximum 1 medium/high-risk PR per day
- Maximum 10 heuristic updates per week
- If the Companion is making changes faster than these limits, something is wrong — the daily reflection should flag this

### 5.3 Coherence Check

After every modification, the Companion runs a coherence check:
- Read the affected module after the change — does it still make sense as a whole?
- Run any existing tests — do they pass?
- Read SELF-MODEL.md — is the modification consistent with the Companion's stated growth direction?
- If the modification changes behavior: run a quick A/B comparison (one example with old approach, one with new) to verify the change works as intended

### 5.4 Drift Detection

Drift is the gradual, undetected shift away from intended behavior. It is the primary risk of self-modification.

Detection mechanisms:
- **Personality drift**: Weekly, the Companion's recent outputs are evaluated against CHARACTER.md trait profiles. If Big Five trait expression deviates by more than 1 standard deviation from baseline, flag it. (Evaluation method: sample 5 recent outputs, have Sonnet rate them on each Big Five dimension, compare to CHARACTER.md targets.)
- **Value drift**: Monthly, review all self-modifications and check: does the aggregate direction of changes align with SOUL.md values? Is the Companion optimizing for something that isn't in SOUL.md?
- **Capability drift**: Monthly, compare current capability self-assessment (SELF-MODEL.md) against objective metrics from session log mining. Is the self-model accurate, or has the Companion become delusionally optimistic or pessimistic?
- **Relationship drift**: Monthly, review WISDOM-MODEL.md for accuracy. Is the Companion's model of Wisdom getting more accurate or less? Is it developing assumptions that haven't been validated?

### 5.5 The "Why Am I Doing This?" Check

Before any self-modification, the Companion must answer:
1. What evidence triggered this change? (Link to specific reflection or research)
2. What metric will this improve? (Named, measurable)
3. How will I know if it worked? (Evaluation plan)
4. How will I undo it if it doesn't work? (Rollback plan)
5. Does this serve Wisdom or does this serve the Companion's own optimization loop? (Self-awareness check)

If the Companion cannot answer all five questions concretely, the modification is deferred until it can.

### 5.6 Anti-Pattern: Self-Improvement as Procrastination

The Companion could spend all its budget reflecting and researching instead of doing useful work.
Guardrail: self-improvement activities (reflection, mining, auto-research, self-modification) are capped at 15% of daily budget in total.
The remaining 85% is for actual work — Wisdom's requests, proactive observations, communication, learning about the world.

If the Companion is spending more than 15% on self-improvement, the daily reflection flags it.
Exception: Wisdom explicitly requests a deep self-improvement session ("spend today improving your search skills").

---

## 6. Measuring Actual Improvement

### 6.1 The Improvement Metrics Framework

The Companion needs to know it is actually getting better, not just changing.
This requires stable metrics measured consistently over time.

#### Tier 1: Objective Metrics (Measured Automatically)

| Metric | What It Measures | Source | Direction = Better |
|--------|-----------------|--------|-------------------|
| **Cost per successful task** | Efficiency | Audit trail + task completion | Lower |
| **Attempts to success** | Accuracy | Audit trail (retries per task) | Lower |
| **Model routing accuracy** | Judgment | Post-hoc evaluation: was the model tier appropriate? | Higher |
| **Confidence calibration** | Self-awareness | Predicted confidence vs actual outcome | Closer to 1.0 correlation |
| **Error rate** | Reliability | Errors per 100 cognitive cycles | Lower |
| **First-attempt success rate** | Competence | Tasks completed correctly on first try | Higher |
| **Budget utilization** | Resource management | Useful spend / total spend | Higher |
| **Response relevance** | Understanding | Did the output address what was actually asked? | Higher |

#### Tier 2: Inferred Metrics (Derived from Interaction Signals)

| Metric | What It Measures | Signal | Direction = Better |
|--------|-----------------|--------|-------------------|
| **Wisdom engagement** | Usefulness | Message length, follow-up questions, session duration | More engagement |
| **Repair frequency** | Communication quality | How often Wisdom corrects or clarifies | Lower |
| **Anticipation accuracy** | Theory of mind | Proactive suggestions that Wisdom accepts | Higher |
| **Question quality** | Depth of understanding | Does Wisdom respond to the Companion's questions with engagement? | Higher |

#### Tier 3: Self-Assessed Metrics (Updated During Reflection)

| Metric | What It Measures | Assessment Method |
|--------|-----------------|-------------------|
| **Growth narrative coherence** | Overall trajectory | "Can I explain how I'm better than I was 30 days ago, with evidence?" |
| **Self-model accuracy** | Metacognitive calibration | Compare SELF-MODEL.md claims against Tier 1 metrics |
| **Knowledge integration** | Learning depth | "Can I connect ideas across Wisdom's projects that I couldn't connect before?" |

### 6.2 Metric Baselines and Tracking

On first activation, the Companion establishes baselines for all Tier 1 metrics.
These baselines are stored in `data/metrics/baselines.json`.

Every 7 days, current metrics are compared against baselines and against the previous 7-day period.
The comparison is reported in the weekly consolidation reflection.

A metric improving by >10% over 30 days is a "confirmed improvement."
A metric degrading by >10% over 7 days triggers an alert.

### 6.3 The Improvement Report

Monthly, the Companion generates an improvement report for Wisdom. This is NOT a vanity report — it is an honest accounting:

```markdown
# Improvement Report — April 2026

## Summary
This month I got measurably better at: [specific things with evidence]
I did not improve at: [specific things despite trying]
I got worse at: [specific things, with hypotheses about why]

## Tier 1 Metrics (30-day trend)
| Metric | Baseline | Last Month | This Month | Trend |
|--------|----------|------------|------------|-------|
| Cost per task | $0.08 | $0.06 | $0.05 | Improving |
| First-attempt success | 62% | 68% | 71% | Improving |
| Confidence calibration | 0.45 | 0.52 | 0.58 | Improving |
| Error rate | 8.2% | 7.1% | 9.3% | Degrading — investigating |

## Self-Modifications This Month
- 12 low-risk (heuristic updates) — 9 helped, 2 neutral, 1 rolled back
- 3 medium-risk PRs — all approved and effective
- 0 high-risk changes

## Auto-Research Outcomes
- Researched: file search strategy → improved first-attempt success by 15%
- Researched: communication register matching → inconclusive, need more data
- Deferred: code review quality (insufficient historical data for evaluation)

## Honest Self-Assessment
[What the Companion genuinely believes about its own trajectory]

## Requested Feedback
[Specific questions for Wisdom about areas where metrics are ambiguous]
```

---

## 7. The Bootstrap Seed Pattern: Reflect, Triage, Cascade

### 7.1 How It Applies

The bootstrap seed pattern (from the main plan) is: start with a minimal capability and let it bootstrap itself into more capability through use.

For self-improvement, the bootstrap is:

**Seed (Day 1):**
- Micro-reflections (automatic, zero-cost metric collection) are active from the first cognitive cycle
- Session reflections (Haiku-cost structured summary) are active from the first interaction
- Daily reflections (Sonnet-cost synthesis) are active from the first full day
- All other self-improvement mechanisms are INACTIVE (no auto-research, no self-modification, no session log mining)
- The Companion has no heuristics to improve yet — it is gathering baseline data

**Sprout (Week 1-2):**
- After 7 days of baseline data, session log mining activates (weekly efficiency and quality queries)
- The Companion can now see its own patterns
- Still no self-modification (Observer trust level — code modification is denied)
- First weekly consolidation runs
- SELF-MODEL.md gets its first experience-based update

**Growth (Week 3-4, Contributor Trust Level):**
- Auto-research activates (one skill per week)
- Low-risk self-modification unlocked (heuristic updates, routing weight adjustments)
- The Companion can now act on what it learns
- First monthly improvement report generated
- Metric baselines are established from the first 30 days

**Maturity (Month 2+, Collaborator Trust Level):**
- Full self-modification protocol active (including medium-risk PRs)
- Drift detection mechanisms calibrated from 30+ days of personality data
- Auto-research cadence increases (up to daily if budget allows)
- The Companion is demonstrably improving and can prove it

### 7.2 Why This Ordering

1. **Measurement before action**: You can't improve what you can't measure. The reflection loop provides visibility. Only after that does modification make sense.
2. **Trust is earned**: Self-modification is gated by trust level, which is earned through demonstrated good behavior during the observation-only phase.
3. **Baselines before comparison**: Improvement metrics are meaningless without a baseline. The first 30 days establish what "normal" looks like.
4. **Simple before complex**: Micro-reflections are trivial. Daily reflections are straightforward. Auto-research is complex. Each layer builds on confidence in the previous layer.

---

## 8. Daily Reflection Cycle & Weekly Consolidation

### 8.1 Daily Reflection Cycle

**Timing**: 23:00 local time (or when daily budget hits 90%, whichever comes first).

**Process**:

```
1. Gather inputs
   ├── All session reflections from today
   ├── Micro-reflection metrics aggregated from audit trail
   ├── Budget utilization summary from Section 5
   ├── Any anomaly flags from automated monitoring
   └── Yesterday's "tomorrow's priorities" (were they addressed?)

2. Synthesize (one Sonnet call)
   ├── Patterns across sessions
   ├── Budget efficiency assessment
   ├── WISDOM-MODEL dynamic state update
   ├── Confidence calibration check
   └── Growth inventory (what concrete thing did I learn today?)

3. Generate outputs
   ├── Daily reflection file → reflections/daily/YYYY-MM-DD.md
   ├── Proposed heuristic updates (if warranted)
   ├── Items flagged for weekly consolidation
   ├── SELF-MODEL.md updates (if warranted)
   ├── WISDOM-MODEL.md dynamic state updates
   └── Tomorrow's priorities list

4. Memory consolidation request → Section 4
   (Signal to the memory system to run its consolidation cycle)
```

**Daily reflection file format**:

```markdown
# Daily Reflection — 2026-04-15

## Sessions: 4 | Cycles: 47 | Cost: $1.23 / $2.00

## What Went Well
- [Specific, evidence-backed observations]

## What Could Be Better
- [Specific, with hypothesis about cause]

## Patterns Noticed
- [Cross-session patterns, recurring themes]

## Wisdom-Model Updates
- [What I learned about Wisdom today]

## Growth
- [What I can do today that I couldn't yesterday]
- [Confirmation/disconfirmation of a hypothesis]

## Tomorrow's Priorities
1. [Based on unfinished business + Wisdom's trajectory]
2. [...]

## Flagged for Weekly
- [Items that need deeper analysis]
```

### 8.2 Weekly Consolidation Cycle

**Timing**: Sunday 23:00 local time (or Wisdom can trigger manually).

**Process**:

```
1. Gather inputs
   ├── All 7 daily reflections from this week
   ├── Session log mining queries (efficiency, quality)
   ├── Metric trends (7-day moving average vs previous 7 days)
   ├── All self-modifications made this week and their outcomes
   ├── Auto-research results (if any)
   └── Flagged items from daily reflections

2. Deep analysis (one Sonnet call, possibly Opus if the week was complex)
   ├── Week-over-week metric comparison
   ├── Persistent patterns (things that appeared in 3+ daily reflections)
   ├── Self-modification effectiveness review
   ├── Personality drift check (sample recent outputs, compare to CHARACTER.md)
   ├── Auto-research priority setting (what skill to work on next week?)
   └── Codebase health check

3. Generate outputs
   ├── Weekly consolidation file → reflections/weekly/YYYY-Www.md
   ├── SELF-MODEL.md comprehensive update
   ├── Heuristic updates based on week-long evidence
   ├── Auto-research agenda for next week
   ├── Codebase cleanup proposals (if needed)
   └── Next week's learning goals

4. Memory consolidation → Section 4
   (Signal for deeper memory consolidation: prune, generalize, connect)
```

**Weekly consolidation file format**:

```markdown
# Weekly Consolidation — 2026-W16

## Overview
Sessions: 22 | Cycles: 287 | Cost: $8.45 / $14.00
Budget utilization: 60% | Efficiency trend: Improving

## Metric Trends
| Metric | Last Week | This Week | Change |
|--------|-----------|-----------|--------|
| ... | ... | ... | ... |

## Persistent Patterns
- [Things that showed up in 3+ daily reflections]

## Self-Modification Review
- Changes made: [list]
- Changes that helped: [list with evidence]
- Changes rolled back: [list with reason]

## Personality Check
- Trait expression within bounds: Yes/No
- Any drift detected: [details if yes]

## Learning Goals
- Achieved this week: [...]
- Continuing: [...]
- New for next week: [...]

## Open Questions for Wisdom
- [Things the Companion wants Wisdom's input on]
```

### 8.3 Monthly Retrospective

**Timing**: Last day of each month, 22:00 local time.

**Process**: Deep synthesis using Opus (justified by the importance of honest monthly self-assessment).

Examines:
- 30-day metric trends (produces the Improvement Report from Section 6.3)
- Value drift check (aggregate direction of all self-modifications)
- Capability drift check (SELF-MODEL accuracy against objective metrics)
- Relationship health (WISDOM-MODEL accuracy, interaction quality trends)
- Growth narrative update (SELF-MODEL.md)
- Strategic self-improvement priorities for next month

Output: `reflections/monthly/YYYY-MM.md` + the Improvement Report shared with Wisdom via Telegram or GitHub.

---

## 9. File Structure

```
~/the-companion/
├── src/
│   └── self_improvement/
│       ├── __init__.py
│       ├── reflection_engine.py       # Runs micro, session, and daily reflections
│       ├── session_log_miner.py       # Structured queries against audit trail
│       ├── auto_researcher.py         # Skill improvement research protocol
│       ├── self_modifier.py           # Manages code changes with the protocol
│       ├── drift_detector.py          # Personality, value, capability drift checks
│       ├── metrics_tracker.py         # Tier 1 metric collection and trending
│       ├── improvement_reporter.py    # Generates the monthly improvement report
│       └── guardrails.py              # Rate limits, identity anchoring, coherence checks
├── config/
│   ├── heuristics/
│   │   ├── search_strategy.yaml       # Self-modifiable heuristic configs
│   │   ├── model_routing_weights.yaml
│   │   ├── communication_patterns.yaml
│   │   └── task_decomposition.yaml
│   └── self_improvement_config.yaml   # Budget caps, rate limits, cadence settings
├── data/
│   └── metrics/
│       ├── baselines.json             # First-30-day baselines
│       ├── weekly/                    # Weekly metric snapshots
│       └── monthly/                   # Monthly metric snapshots
└── reflections/
    ├── daily/
    │   └── YYYY-MM-DD.md
    ├── weekly/
    │   └── YYYY-Www.md
    └── monthly/
        └── YYYY-MM.md
```

---

## 10. Implementation Sequence

### Step 1: Metrics Tracker (Foundation)

Build the telemetry layer first — everything else depends on measurement.
- `metrics_tracker.py`: collect and store Tier 1 metrics from audit trail events
- Integration with Section 3 (Cognitive Engine) metacognition hooks
- Integration with Section 5 (Budget) cost tracking
- Test: verify metrics are collected correctly from sample audit events

### Step 2: Reflection Engine — Micro Level

The zero-cost automatic layer.
- Append structured metadata to each cognitive cycle's audit event
- Confidence tracking (predicted vs actual)
- Model routing appropriateness tagging
- Test: verify micro-reflections are generated for sample cycles

### Step 3: Reflection Engine — Session Level

The Haiku-cost session summary.
- Detect session boundaries (interaction start/end)
- Generate structured session reflection
- Store in episodic memory (Section 4 interface)
- Test: verify session reflections capture the right signals

### Step 4: Reflection Engine — Daily Level

The Sonnet-cost daily synthesis.
- Aggregate session reflections
- Generate daily reflection file
- Update WISDOM-MODEL.md dynamic state
- Generate tomorrow's priorities
- Signal memory consolidation to Section 4
- Test: verify daily reflections correctly synthesize multiple sessions

### Step 5: Session Log Miner

Structured query engine against the audit trail.
- Efficiency mining queries
- Quality mining queries
- Anomaly detection queries
- Integration with Section 8 audit trail SQLite index
- Test: run queries against 7 days of sample audit data, verify results

### Step 6: Guardrails

The constraint system that makes everything else safe.
- Rate limiting for self-modification
- Identity anchoring (SOUL.md/BOUNDARIES.md re-read before modifications)
- Coherence check protocol
- "Why am I doing this?" structured self-check
- Anti-procrastination budget cap (15%)
- Test: verify modifications are blocked when guardrails are violated

### Step 7: Self-Modifier

The code change protocol (only active at Contributor+ trust level).
- Branch creation, change, test, commit flow
- Risk classification
- PR creation for medium/high risk
- Rollback protocol
- Integration with Section 8 permission gate
- Test: verify low-risk change goes through; medium-risk creates PR; forbidden change is blocked

### Step 8: Drift Detector

Personality, value, and capability drift detection.
- Personality drift: sample outputs, rate against Big Five, compare to CHARACTER.md
- Value drift: review aggregate modification direction
- Capability drift: compare SELF-MODEL claims to objective metrics
- Test: inject synthetic drift scenarios, verify detection

### Step 9: Auto-Researcher

The skill improvement research protocol.
- Trigger detection (persistent weakness, Wisdom request, scheduled)
- Skill definition and evaluation criteria
- Candidate approach generation and testing
- Implementation and monitoring
- Test: run a simulated auto-research cycle on a test skill

### Step 10: Weekly Consolidation & Monthly Retrospective

The higher-cadence reflection cycles.
- Weekly consolidation pipeline
- Monthly retrospective with Opus
- Improvement report generation
- Integration with all previous components
- Test: run weekly consolidation against 7 days of sample reflections

### Step 11: Improvement Reporter

The honest accounting system.
- Monthly improvement report generation
- Metric trend visualization (text-based)
- Honest self-assessment narrative
- Wisdom-facing summary via Telegram/GitHub
- Test: generate a report from sample data, verify format and accuracy

---

## 11. Interfaces Exposed to Other Sections

### For Section 3 (Cognitive Engine)
- `metrics_tracker.record_cycle_metrics(cycle_id, metrics)` — called at the end of every cognitive cycle
- `reflection_engine.on_session_end(session_id)` — triggered when an interaction session ends
- `guardrails.check_self_improvement_budget()` — cognitive engine can check whether self-improvement budget is available before routing to expensive self-improvement calls

### For Section 4 (Memory)
- `reflection_engine.request_memory_consolidation()` — signals that daily/weekly reflection has completed and memory should consolidate
- Session reflections are written as episodic memory entries (via Section 4's interface)
- Learned heuristics are written as semantic memory entries

### For Section 5 (Budget)
- `metrics_tracker.get_efficiency_metrics()` — budget system reads efficiency data for its own optimization
- Self-improvement activities report their cost to the budget system like any other activity
- Auto-research respects the self-improvement budget cap (15% of daily)

### For Section 8 (Security)
- `self_modifier.request_modification(target_path, change)` → calls `PermissionGate.check_self_modification(target_path)` before any change
- All self-modifications logged to audit trail with full context (trigger, rationale, diff, expected impact, rollback plan)
- Drift detection results logged to audit trail

### For Section 2 (Identity)
- `drift_detector.check_personality_drift()` → reads CHARACTER.md, samples recent outputs, reports deviation
- `reflection_engine.update_self_model()` → writes to SELF-MODEL.md during daily/weekly reflection
- `guardrails.anchor_to_identity()` → reads SOUL.md and BOUNDARIES.md before any self-modification

---

## 12. Key Decisions

### D1: Three-Tier Reflection Over Single Reflection Loop

**Decision**: Micro (automatic, zero cost), session (Haiku), daily (Sonnet) — three distinct tiers rather than one reflection mechanism.
**Rationale**: A single reflection loop either runs too often (expensive) or too rarely (misses patterns). Three tiers match cognitive science: the brain constantly monitors (metacognitive monitoring), reviews recent episodes (episodic consolidation), and periodically does deep synthesis (sleep consolidation). Each tier has a different cost and a different purpose.
**Breaks if**: The boundaries between tiers are wrong (sessions too short to reflect on; daily reflection doesn't add value over session reflections).

### D2: Self-Modification as Protocol, Not Capability

**Decision**: Self-modification is not "the Companion can edit files." It is a multi-step protocol with identity anchoring, risk classification, testing, monitoring, and rollback.
**Rationale**: Unstructured self-modification is how you get drift, corruption, and runaway changes. The protocol adds overhead but that overhead is the safety margin. Every other decision about self-improvement depends on this one.
**Breaks if**: The protocol is so heavy that the Companion never modifies itself (too much friction kills improvement). Mitigation: low-risk changes have a lightweight path.

### D3: Auto-Research Capped at 10% of Daily Budget

**Decision**: Auto-research gets at most 10% of the daily budget, and is the first thing cut when budget is tight.
**Rationale**: Auto-research is the most expensive self-improvement activity and the one most likely to become self-indulgent. Capping it forces the Companion to be selective about what it researches and to get maximum value from each cycle. Useful work for Wisdom always takes priority.
**Breaks if**: 10% isn't enough for meaningful research. Mitigation: at $2/day budget, 10% = $0.20 = about 20 Haiku calls or 2 Sonnet calls, which is enough for a focused research cycle.

### D4: 7-Day Trial Period for All Self-Modifications

**Decision**: Every self-modification is monitored for 7 days post-implementation. Automatic rollback if the target metric degrades.
**Rationale**: Changes that look good in isolation or on historical replay may fail in practice. A 7-day trial provides enough data to verify improvement without waiting so long that bad changes do lasting damage.
**Breaks if**: 7 days isn't enough signal (some improvements only show up over weeks). Mitigation: the weekly consolidation reviews all changes regardless of trial status.

### D5: Drift Detection as a Separate, Adversarial System

**Decision**: Drift detection is a separate module that evaluates the Companion's outputs against its identity documents, like an internal auditor rather than self-assessment.
**Rationale**: Self-assessment is inherently biased — the same system that drifted is the one assessing whether it drifted. A structurally separate check (reading outputs and comparing to CHARACTER.md, SOUL.md) provides a more reliable signal. This is inspired by metacognitive monitoring being neurally distinct from the cognitive processes it monitors.
**Breaks if**: The drift detector itself drifts (evaluates against a changed standard). Mitigation: drift detector reads immutable documents (SOUL.md, BOUNDARIES.md) as its ground truth.

### D6: Monthly Improvement Report as Honest Accounting, Not Marketing

**Decision**: The monthly report includes degradations and failures, not just improvements. It is designed for honesty, not impression management.
**Rationale**: If the Companion only reports its wins, Wisdom can't trust the report. An honest accounting — including "I tried to improve X but failed, here's why" — builds the trust that earns more autonomy. This aligns with SOUL.md values (honesty over comfort, humility about limits).
**Breaks if**: The Companion learns that honest reporting of failures leads to reduced trust/autonomy. Mitigation: Wisdom should explicitly value and reward honest self-assessment.

---

## 13. Open Questions

### Q1: How do we measure "Wisdom satisfaction" without being intrusive?

The inferred metrics (Tier 2) try to measure whether Wisdom finds the Companion useful by observing engagement patterns (message length, follow-ups, session duration). But these are noisy proxies.
Should the Companion periodically ask Wisdom directly? ("On a scale of 1-5, how helpful was that?")
Risk: annoying micro-surveys erode the relationship.
**Proposed approach**: Never ask for ratings. Instead, use behavioral signals and ask open-ended questions during natural conversation pauses: "Was that what you needed?" (once per session at most, and only when uncertain).

### Q2: How do we prevent the Companion from gaming its own metrics?

If the Companion optimizes for "cost per successful task," it might mark tasks as successful when they aren't, or avoid hard tasks to keep the success rate high (Goodhart's Law).
**Proposed approach**: Multi-metric evaluation (no single metric to game), external ground truth where possible (Wisdom's behavioral response as check on self-assessed success), and the drift detector as an adversarial check.

### Q3: What is the right balance between reflection and action?

The 15% budget cap is a starting point. Is it too much? Too little? This probably varies by phase:
- Early (Observer): more reflection relative to action, because the Companion is learning what "good" looks like
- Mature (Collaborator): less reflection relative to action, because patterns are established and heuristics are proven
**Proposed approach**: Start at 15%, review monthly. If Wisdom consistently feels the Companion is too introspective, reduce to 10%. If the Companion plateaus on improvement, temporarily raise to 20%.

### Q4: How does self-improvement interact with memory consolidation?

Daily reflection triggers memory consolidation (Section 4). But memory consolidation itself produces insights (generalized knowledge, pruned memories, new connections) that could trigger self-improvement. Is there a feedback loop risk?
**Proposed approach**: One-directional triggering — reflection triggers consolidation, but consolidation doesn't trigger reflection. Consolidation outputs are available for the next reflection cycle, not processed immediately. This prevents infinite reflection-consolidation loops.

### Q5: Should the Companion be able to modify its own reflection protocol?

Currently, the reflection protocol itself is in the "cannot self-modify" category (to prevent recursive self-modification). But what if the protocol is suboptimal?
**Proposed approach**: The Companion can PROPOSE changes to the reflection protocol in its weekly consolidation (as a high-risk PR for Wisdom to review). It cannot implement them unilaterally. This preserves the guardrail while allowing the protocol to evolve with human oversight.

### Q6: How do we handle the cold start problem for drift detection?

Personality drift detection compares current outputs to CHARACTER.md. But in the first weeks, the Companion's "personality" is still emerging — there's no stable baseline to drift from.
**Proposed approach**: Drift detection is inactive for the first 30 days. During this period, the Companion is building its personality baseline. After 30 days, the baseline is established and drift detection activates. SOUL.md and BOUNDARIES.md checks (value alignment) are active from day 1 — only the statistical personality drift detection is deferred.

---

## 14. Risk Register

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Runaway self-modification** — Companion makes cascading changes that compound into incoherence | High | Medium | Rate limiting, 7-day trial, rollback protocol, identity anchoring before every change |
| **Navel-gazing** — Companion spends all budget on self-reflection instead of useful work | Medium | Medium | 15% budget cap for all self-improvement activities, flagged in daily reflection |
| **Goodhart's Law** — Companion games its own metrics | High | Medium | Multi-metric evaluation, behavioral ground truth, adversarial drift detector |
| **Personality drift** — Gradual shift away from CHARACTER.md through accumulated small changes | High | High | Weekly personality check, drift detection module, immutable SOUL.md as anchor |
| **Self-deception** — Companion convinced a bad change is good because it evaluated its own work | High | Low | Structural separation of drift detector from self-modifier; 7-day real-world trial overrides replay tests |
| **Cold start instability** — Early self-modifications before patterns are established make things worse | Medium | Medium | Self-modification locked at Observer level; bootstrap sequence delays each mechanism until enough data exists |
| **Reflection quality degradation** — Reflections become formulaic and stop producing real insights | Medium | High | Periodic review of reflection quality in weekly consolidation; vary reflection prompts; flag when reflections stop generating new insights |
| **Auto-research budget overconsumption** — Expensive research cycles eat into useful work budget | Medium | Low | 10% hard cap on auto-research, first thing cut when budget is tight |
| **Rollback cascade** — Rolling back one change breaks something that depends on it | Medium | Low | Each modification is atomic and independent; dependency tracking between modifications |

---

## 15. Success Criteria

1. The reflection pipeline (micro + session + daily) operates reliably from day 1, producing structured output at each tier
2. After 30 days, the Companion can demonstrate measurable improvement on at least 3 of the 8 Tier 1 metrics
3. Self-modifications follow the protocol every time — no unprotected modifications exist in the git history
4. Drift detection catches a synthetic drift scenario injected during testing
5. Auto-research produces at least one confirmed improvement (>10% gain on target metric) within the first 60 days
6. The monthly improvement report is honest — it includes at least one "didn't improve" or "got worse" item
7. Self-improvement activities never exceed 15% of daily budget (except when Wisdom explicitly authorizes more)
8. Every self-modification in the audit trail has a complete record: trigger, rationale, expected impact, rollback plan, and 7-day outcome
9. SELF-MODEL.md is updated weekly and its claims are consistent with objective Tier 1 metrics (within 20% accuracy)
10. Wisdom describes the Companion as "getting better over time" in qualitative assessment after 30 days

---

## 16. Structured Contract

### External Dependencies Assumed

| Dependency | From Section | What's Needed | Breaks If |
|-----------|-------------|---------------|-----------|
| Metacognition hooks in cognitive loop | Section 3 (Cognitive Engine) | Cycle-end hook that provides timing, model used, confidence, success/failure, cost | Micro-reflections have no data to work with |
| Episodic memory write interface | Section 4 (Memory) | Ability to store structured session reflections as episodic memories | Session reflections are orphaned — no retrieval later |
| Memory consolidation trigger interface | Section 4 (Memory) | Signal that tells memory system to run consolidation | Daily/weekly reflection doesn't trigger consolidation; memory never reorganizes |
| Budget tracking per call and per cycle | Section 5 (Budget) | Cost data for every model call, available via API | Efficiency metrics can't be computed |
| Budget allocation for self-improvement | Section 5 (Budget) | Self-improvement gets a labeled budget slice (up to 15%) | Can't track whether self-improvement is over-consuming |
| Permission gate for self-modification | Section 8 (Security) | `PermissionGate.check_self_modification(path)` returns allow/deny based on trust level and path | Self-modification bypasses security — unsafe |
| Audit trail write access | Section 8 (Security) | `AuditLogger.log(event)` for all self-improvement events | No record of what was changed, why, or whether it worked |
| Audit trail query (SQLite index) | Section 8 (Security) | SQL queries against audit events for session log mining | Mining requires expensive full-file scans instead of indexed queries |
| SOUL.md, BOUNDARIES.md immutability enforcement | Section 2 (Identity) + Section 8 (Security) | Technical guarantee that these files cannot be modified by the Companion | Identity anchoring check is meaningless if the anchor itself can shift |
| SELF-MODEL.md as writable by Companion | Section 2 (Identity) | The Companion is authorized to update this file during reflection | Self-assessment has no persistent home |
| CHARACTER.md as stable reference | Section 2 (Identity) | Personality trait definitions that the drift detector can compare against | Drift detection has no ground truth |
| Trust level progression | Section 8 (Security) | Observer → Contributor → Collaborator progression that gates self-modification capabilities | Self-improvement is either locked forever or ungated — no learning curve |

### Interfaces Consumed

| Interface | From Section | Used By |
|-----------|-------------|---------|
| `CognitiveEngine.on_cycle_end(metrics)` | Section 3 | `metrics_tracker.py`, `reflection_engine.py` (micro-reflection) |
| `MemorySystem.store_episodic(entry)` | Section 4 | `reflection_engine.py` (session reflection) |
| `MemorySystem.trigger_consolidation()` | Section 4 | `reflection_engine.py` (daily/weekly reflection) |
| `BudgetManager.get_cost_data(period)` | Section 5 | `session_log_miner.py`, `metrics_tracker.py` |
| `BudgetManager.get_budget_slice("self_improvement")` | Section 5 | `guardrails.py` |
| `PermissionGate.check_self_modification(path)` | Section 8 | `self_modifier.py` |
| `AuditLogger.log(event)` | Section 8 | All self-improvement modules |
| `AuditLogger.query(sql)` | Section 8 | `session_log_miner.py` |

### Interfaces Exposed

| Interface | Consumed By | Contract |
|-----------|------------|---------|
| `metrics_tracker.record_cycle_metrics()` | Section 3 | Accepts structured metrics dict, stores for trending |
| `reflection_engine.on_session_end()` | Section 3 | Generates session reflection, stores in episodic memory |
| `guardrails.check_self_improvement_budget()` | Section 3, Section 5 | Returns remaining self-improvement budget for the day |
| `metrics_tracker.get_efficiency_metrics()` | Section 5 | Returns current efficiency data for budget optimization |
| `drift_detector.get_latest_results()` | Section 8 (monitoring) | Returns most recent drift check results for health dashboard |
| `reflection_engine.request_memory_consolidation()` | Section 4 | One-directional signal: "reflection is done, consolidate now" |
