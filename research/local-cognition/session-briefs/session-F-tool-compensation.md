# Session Brief: F — Tool Compensation Full Suite (S5b)

## Prerequisites
- Session A complete (graph engine)
- Session B complete (structured output results)
- Session D complete (traversal failure modes — THE critical input)
- Session E complete (tool bus + T6 validator)

Read these files from completed sessions:
- `results/traversal-analysis.md` — TraversalFailureReport: which decision families fail, how, and why
- `results/structured-output-analysis.md` — model capabilities and failure patterns
- `src/tool_bus.py` — ToolBus architecture from Session E
- `src/tools/validator.py` — T6 (already built)

## Context
Section 5b builds the 6 remaining judgment-compensation tools (T1-T5, T7) based on EMPIRICAL failure data from Sections 3 and 4. The pre-mapped failure mode predictions in the plan should be revised against actual data before building.

The core principle: the model is the reader/writer. Tools carry the judgment. Any decision that's purely structural or geometric is deterministic.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-tool-compensation.md` — full S5 plan (7 tools, pipeline architecture, latency budget)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — M6 (revise tools against empirical data)

## Task

### 0. Revise Failure Mode Map
Before building ANY tools:
1. Read the TraversalFailureReport from Session D
2. Compare predicted failure modes (FM-1 through FM-7) against actual failures
3. Document which predictions were correct, which were wrong, which were missing
4. Revise the tool priority order based on actual impact

### 1. Build Embedding Pipeline (Infrastructure)
- Install `sentence-transformers` (from requirements-tools.txt)
- Load `all-MiniLM-L6-v2` (~22MB)
- Build batch embedding function
- Store embeddings in SQLite (new table: `embeddings`)
- Embed all existing graph nodes

### 2. Build T1: Contradiction Detector
`src/tools/contradiction.py`:
- Embedding cosine similarity + negation morpheme detection + polarity analysis (VADER)
- `contradiction_score = cosine_sim × negation_weight × (1 - temporal_distance_weight)`
- Model's reduced role: three-way classification (CONTRADICTS / SUPERSEDES / DISMISS)
- Validate against S4's proximity trap data: does T1 catch what the model missed?

### 3. Build T2: Relevance Scorer
`src/tools/relevance.py`:
- `score = cosine_proximity(focus, candidate) × edge_weight × novelty_bonus`
- Novelty bonus: 1.2 unvisited, 0.8 already traversed
- Presents ranked menu to model context

### 4. Build T3: Graph Centrality Advisor
`src/tools/centrality.py`:
- Weighted degree centrality
- Approximate betweenness (50-sample Monte Carlo on k-hop subgraph)
- High-centrality nodes get more traversal budget

### 5. Build T4: Bayesian Confidence Calculator
`src/tools/confidence.py`:
- `comprehension = mean_edge_weight × (1 - weight_variance)`
- `completeness = rendered_nodes / estimated_neighborhood_size`
- `combined = comprehension × completeness × recency_factor`
- Model sees: "Structural confidence: 0.68. Options: (A) respond, (B) grow deeper, (C) explore"

### 6. Build T5: Semantic Merge Classifier
`src/tools/merge.py`:
- Three zones by cosine distance: <0.1 auto-MERGE, 0.1-0.4 NLI classifier, >=0.4 auto-CREATE
- Load MiniLM NLI (~50MB) for ambiguous zone
- NLI entailment/contradiction/neutral → merge/contradict/create

### 7. Build T7: Causal Direction Voter
`src/tools/causal.py`:
- Three-signal voting: temporal precedence, linguistic causal markers, single-token LLM classification
- Aggregate with min confidence 0.6. Below → CO_OCCURRENCE

### 8. Wire Pipeline
Register all tools into ToolBus:
- Pre-traversal: T2, T3, T4 (always run)
- Post-generation: T6 (always run)
- Action-specific: create_edge → T1 + T7, create_node → T5, traverse → T2

### 9. Before/After Measurement
Run 100 traversal scenarios from Session D:
- Model-only accuracy (baseline from Session D)
- Tool-augmented accuracy (with full pipeline)
- Per-failure-mode improvement

### 10. End-to-End Loop Test
100 cycles on 1K-node graph with full tool pipeline. Verify latency budget (~6s/cycle target).

## Output Format

- `src/tools/contradiction.py` — T1
- `src/tools/relevance.py` — T2
- `src/tools/centrality.py` — T3
- `src/tools/confidence.py` — T4
- `src/tools/merge.py` — T5
- `src/tools/causal.py` — T7
- `tests/test_tools.py` — tests for all tools
- `results/tool-compensation-YYYY-MM-DD.json` — before/after accuracy
- `results/tool-compensation-analysis.md` — analysis
- Git commit

## Success Criteria

| Failure Mode | Baseline | Target |
|---|---|---|
| FM-1: Contradiction detection | from S4 | >85% |
| FM-2: Relevance scoring | from S4 | >80% |
| FM-3: Confidence calibration | from S4 | ECE <0.08 |
| FM-4: Priority allocation | from S4 | >85% |
| FM-5: Merge vs. create | from S4 | >80% |
| FM-6: Structured output | from S3 | >98% (already from Session E) |
| FM-7: Causal direction | from S4 | >70% |

End-to-end: 100 cycles complete within 6s/cycle average. Total RAM <3.5GB.
