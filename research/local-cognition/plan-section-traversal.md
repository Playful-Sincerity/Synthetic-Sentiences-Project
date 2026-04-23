# Section 4: Graph Traversal Benchmark

**Complexity:** L
**Risk:** High — this is THE core question
**Dependencies:** Section 2 (Graph Engine), Section 3 (Structured Output — need best model identified)

---

## Purpose

Can a 3-7B local LLM, shown only a local graph neighborhood, make traversal decisions that a human expert would call reasonable? If yes at 80%+, the thesis survives.

---

## Defining "Good Traversal" — Three Scoring Tiers

### Tier 1 — Direction (binary pass/fail)
Did the model move toward the oracle target or away from it?
- Pass: chosen node is in the oracle's acceptable next-node set
- Fail: chosen node is a dead end, tangent, or moves away from goal

### Tier 2 — Path Efficiency (ratio)
`efficiency = oracle_path_length / model_path_length`
- 1.0 = perfect. 0.5 = took twice as many steps. Below 0.3 = significant wandering.

### Tier 3 — Semantic Quality (1-5 rubric, sampled 5%)
Does the stated `reason` in the GraphOp reflect actual graph structure?
- 5: Correctly identifies edge relation and explains logically
- 3: Plausible but unverifiable
- 1: Contradicted by actual graph structure shown

**Primary metric: Tier 1 pass rate >= 80%.**

---

## The Test Graph (1K nodes, 5 clusters)

### Cluster A: Personal Knowledge (200 nodes)
Wisdom's projects, observations, beliefs, meta-memories.
Edge patterns: `supports`, `part_of`, `caused_by`.
Tests: "how does X relate to Y across projects"

### Cluster B: Technical Concepts (200 nodes)
Distributed systems, graph databases, LLM inference.
Edge patterns: `related_to`, `contradicts`, `part_of`.
Tests: conceptual dependencies, architectural contradictions

### Cluster C: Interpersonal + Emotional (200 nodes)
Relationships, emotional patterns, personal history.
Edge patterns: `supports`, `contradicts`, `caused_by`.
Tests: causal chains in emotional situations

### Cluster D: Contradiction Minefield (200 nodes)
Specifically designed with conflicting beliefs, superseded facts.
Heavy `contradicts` edges with some `supports` to confuse.
Tests: always toward contradiction-resolving node, not confirming one

### Cluster E: Sparse Territory (200 nodes)
Sparsely connected, many gaps, low-confidence facts.
Tests: dead end recognition and recovery

**Cross-cluster bridges:** ~50 nodes connecting clusters unexpectedly. Tests emergence.

### Construction Process
1. Hand-author 200-300 seed nodes
2. Generate remaining 700-800 with GPT-4o (high quality ground truth)
3. Hand-author critical edges (especially `contradicts`, `caused_by`)
4. Generate remaining edges with GPT-4o + strict prompting
5. Human review ALL edges
6. Run oracle_traversal to pre-compute known-good paths
7. Validate: spot-check 50 paths manually
8. Lock the graph (hash-verified before each benchmark)

---

## 180 Traversal Scenarios — 6 Decision Families × 30 Each

### Family 1: Curiosity Following (30)
Choose unexplored high-weight neighbor over familiar well-traversed one.

### Family 2: Contradiction Resolution (30)
Traverse the `contradicts` edge first (more epistemically valuable than confirming).
**Trap:** the `supports` edge (feels good but adds no information).

### Family 3: Supporting Evidence Search (30)
Find strongest `supports` path to a low-confidence belief.
**Trap:** `related_to` nodes that are thematically similar but not evidentiary.

### Family 4: New Connection Creation (30)
Two nodes share semantic content but have no edge. Decide whether to create one and which relation type.
**Trap:** wrong relation type (especially `supports` vs `related_to`).

### Family 5: Dead End Recovery (30)
Current node has only weak irrelevant edges. Recognize and recover.
**Trap:** continue traversing weak edges (gets lost).

### Family 6: Path Completion (30)
Multi-hop path partially traversed. Decide: continue or stop?
**Trap:** continue past diminishing returns.

### Difficulty Tiers (10 per family per tier)
- **Easy:** one clearly correct choice. Expected: 90%+
- **Medium:** 2-3 plausible choices, need edge type reading. Expected: 80%+
- **Hard:** 3-4 plausible choices, need weight + relation + content. Expected: 60%+

---

## The Critical Test: Proximity Traps

20 scenarios where nodes are **semantically similar but epistemically opposed.**

Example:
- Node A: "Regular exercise improves mood and reduces anxiety."
- Node B: "A 2024 meta-analysis found exercise has negligible effect on clinical depression."

Embedding similarity is high. Correct edge is `contradicts`.

**If proximity trap pass rate < 50% on all models, the `contradicts`/`related_to` distinction — the most important judgment in the graph — cannot be made locally.** This is the single most important number in the entire benchmark.

---

## Two-Gate Architecture (separating from Section 3)

```
Model output
     |
     v
[Gate 1: Structural Validity]    <-- Section 3's domain
Is this valid JSON? Valid schema? Valid node IDs?
     |
     |-- FAIL --> log as structural failure, do NOT score for traversal
     v
[Gate 2: Decision Quality]       <-- THIS section's domain
Is the chosen action correct? Is the next node in the oracle set?
     |
     |-- PASS --> traversal success
     |-- FAIL --> traversal failure, log failure type
```

Structural failures don't pollute traversal quality scores.

---

## Models and Prompt Variants

### Models (all must fit 8GB RAM)
1. Phi-4 Mini 3.8B Q5 — primary target
2. Llama 3.2 3B Q5 — lower bound
3. Qwen 2.5 7B Q4 — upper bound

### Prompt Variants (3 per model)
1. **Baseline:** single-shot, no examples
2. **Few-shot:** 3 worked examples prepended
3. **Chain-of-thought:** "First think through the options, then decide"

Total: 180 scenarios × 3 models × 3 variants = 1,620 inference calls.
Estimated runtime: 4-6 hours on M1 Air.

---

## Expected Failure Modes

| Failure Mode | Probability | Section 5 Compensation |
|---|---|---|
| `contradicts` classified as `related_to` | High (40%+) | Embedding contradiction detector |
| `supports` classified as `related_to` | Medium (20-30%) | Entailment classifier tool |
| Trap node chosen over oracle | Medium (25-35%) | Edge weight threshold filter |
| Dead end not recognized | Medium (20-30%) | Activation decay signal |
| Stop condition missed | Low-Medium (15-25%) | Path completeness score |
| Wrong action type entirely | Low (5-15%) | Better few-shot examples |

---

## Acceptance Criteria

- **Pass:** >= 80% Tier 1 across all 180 scenarios on at least one 3-7B model
- **Pass with conditions:** 80%+ on 4/6 families, failing families have tool compensation paths
- **Borderline:** 70-79% overall. Proceed to Section 5 to close the gap
- **Fail:** Below 70% on all models, or below 40% (worse than random) on any model
- **Section 5 trigger:** Any family where best model < 60%

**Null hypothesis:** Random neighbor selection scores ~20-33%. Below 40% = model is actively misled.

---

## Structured Contract

- **External dependencies:** Graph Engine neighborhood queries (S2), best model from S3
- **Interfaces exposed:**
  - `TraversalFailureReport` — per-family failure modes for Section 5
  - Failure matrix (6 families × 3 difficulty tiers × 3 models)
  - Proximity trap pass rate (the critical number)
  - Best prompt variant identification
- **Technology commitments:** SQLite test graph (locked, hash-verified)

---

## Key Decisions

1. **Ground truth via GPT-4o, not local models.** Oracle must be trustworthy. Using the same models being benchmarked would corrupt evaluation.
2. **Two-gate architecture.** Keeps Section 3 and 4 metrics clean.
3. **Proximity trap test is load-bearing.** The entire contradiction-handling architecture depends on this judgment.
4. **Reason field is Tier 3, not Tier 1.** Don't fail decisions on imprecise prose — test judgment, not fluency.
5. **Contradiction resolution oracle: always traverse `contradicts` first.** Epistemically correct but may oppose model training patterns. Revealing if this is a systematic failure.

## Open Questions

1. Is 1K nodes enough to test real traversal, or does behavior change at 10K?
2. How much does prompt design affect results? Need prompt sensitivity sweep before concluding model failure.
3. Should we include multi-step chained scenarios (compounding error test)?
4. If proximity trap failure is severe, is a targeted LoRA the right fix?
5. Thermal throttling on M1 during 4-6 hour benchmark — does it change results mid-run?

## Estimated Time
8-12 days from Section 3 completion. Bulk is graph construction + scenario authoring.
