# Session Brief: D — Traversal Benchmark (S4)

## Prerequisites
- Session A complete (graph engine)
- Session B complete (best model identified, failure modes cataloged)
- Session C complete (graph generator available)

Read these files from completed sessions:
- `results/structured-output-analysis.md` — top 3 models, best prompt conditions
- `scripts/generate_test_graph.py` — use Mode 2 (clustered) as foundation for test graph
- `src/models.py` — GraphOp schema
- `src/graph_engine.py` — neighborhood queries

## Context
This is THE core question: can a local 3-7B model, shown only a local graph neighborhood, make traversal decisions that a human expert would call reasonable? The proximity trap test — can models distinguish contradiction from similarity when embeddings look alike — is the single most important number in the entire research.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-traversal.md` — full S4 plan (180 scenarios, 6 decision families, 3 scoring tiers)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — C1 (test at 350-token neighborhoods too), C2 (add thermal management to benchmark), m3 (use top 3 from S3, not hardcoded)

## Task

### 1. Build the 1K-Node Test Graph

Use Session C's graph generator (Mode 2, clustered) as the structural foundation. Then customize into 5 clusters:

- **Cluster A: Personal Knowledge** (200 nodes) — projects, observations, beliefs, meta
- **Cluster B: Technical Concepts** (200 nodes) — distributed systems, graph DBs, LLM inference
- **Cluster C: Interpersonal + Emotional** (200 nodes) — relationships, patterns, history
- **Cluster D: Contradiction Minefield** (200 nodes) — conflicting beliefs, superseded facts
- **Cluster E: Sparse Territory** (200 nodes) — sparse connections, low confidence, gaps

Plus ~50 cross-cluster bridge nodes.

**Construction process:**
1. Hand-author 200-300 seed nodes (especially Cluster D contradictions)
2. Generate remaining with GPT-4o / Claude (high quality ground truth — NOT the local models being tested)
3. Hand-author critical edges (especially `contradicts`, `caused_by`)
4. Generate remaining edges with quality prompting
5. Human review ALL edges
6. Compute oracle paths (known-good traversal for each scenario)
7. Lock graph (hash-verify before each benchmark run)

### 2. Author 180 Traversal Scenarios

6 decision families × 30 scenarios each:
- Family 1: Curiosity Following (choose unexplored over familiar)
- Family 2: Contradiction Resolution (traverse `contradicts` first)
- Family 3: Supporting Evidence Search (find `supports` path to low-confidence belief)
- Family 4: New Connection Creation (create edge between related unconnected nodes)
- Family 5: Dead End Recovery (recognize and recover from dead ends)
- Family 6: Path Completion (continue or stop a partial path)

Each family: 10 easy, 10 medium, 10 hard.

### 3. Build 20 Proximity Trap Scenarios

Nodes that are semantically similar but epistemically opposed. E.g.:
- "Regular exercise improves mood" vs "Exercise has negligible effect on clinical depression"
- High embedding similarity, correct edge = `contradicts`

**This is the most important test.** If proximity trap pass rate < 50%, contradiction detection can't be trusted to the model alone.

### 4. Build Traversal Benchmark Runner

Create `src/traversal_benchmark.py`:
- Two-gate architecture: structural validity (Gate 1, from S3) then decision quality (Gate 2)
- Tier 1 scoring: direction (pass/fail against oracle)
- Tier 2 scoring: path efficiency (oracle_path / model_path)
- Tier 3 scoring: semantic quality (reason field, sampled 5%)
- Failure mode tagging per scenario

### 5. Run Benchmark

**Models:** Top 3 from Session B (not hardcoded — per reconciliation m3).
**Prompt variants:** 3 per model (baseline, few-shot, chain-of-thought).
**Context sizes:** Standard (~800 tokens) AND production-size (~350 tokens) — per reconciliation C1.

Total: 200 scenarios × 3 models × 3 prompts × 2 context sizes = 3,600 runs.

**CRITICAL (reconciliation C2):** Add thermal management:
- Monitor tok/s every 60 seconds
- Use 20 min active / 10 min rest duty cycling between batches
- Record thermal state with every result
- Flag any results taken during throttled state

### 6. Analysis

Write `results/traversal-analysis.md`:
- Overall Tier 1 pass rate per model
- Per-family breakdown (6 families × 3 difficulty tiers × 3 models)
- **Proximity trap pass rate** (THE critical number)
- Standard vs production-context quality delta
- Failure mode matrix: which families/difficulties fail most, and how
- `TraversalFailureReport` for Session F (tool compensation) — specific failure modes that need tools
- Recommendation: best model + best prompt variant

## Output Format

- `data/test-graph-1k.db` — locked test graph (SQLite)
- `data/test-graph-1k.sha256` — hash for verification
- `scenarios/traversal/*.json` — 200 scenario files
- `src/traversal_benchmark.py` — benchmark runner
- `results/traversal-YYYY-MM-DD.json` — raw results
- `results/traversal-analysis.md` — analysis + TraversalFailureReport
- Git commit

## Success Criteria

- **Pass:** >= 80% Tier 1 across all 180 scenarios on at least one model
- **Pass with conditions:** 80%+ on 4/6 families, failing families have clear tool compensation paths
- **Borderline:** 70-79% — proceed to Session F to close the gap
- **Fail:** Below 70% on all models, or below 40% on any model
- **Proximity trap:** Report the number regardless. Below 50% = T1 contradiction detector (Session F) is mandatory, not optional
