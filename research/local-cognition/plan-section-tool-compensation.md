# Section 5: Tool Call Compensation

**Complexity:** M
**Risk:** Medium — depends on Sections 3+4 failure analysis
**Dependencies:** Sections 3 (structured output), 4 (traversal benchmark)
**Feeds into:** Sections 6 (cognitive loop), 9 (prototype)

---

## Core Principle

The model is not the reasoner. It is the reader/writer. Reasoning is offloaded to tools.

Any decision that is purely structural or geometric is deterministic. Any decision that requires reading content and applying semantic understanding is LLM. The tools provide structure; the model provides override capability.

---

## Part 1: Pre-Mapped Failure Modes

### FM-1: Contradiction Detection (High severity, ~30-40% error at 3.8B)
Small models confuse "different framing" with "contradiction," miss logical negation under embedding similarity. False-positive contradictions create spurious edges; false-negatives allow inconsistent subgraphs.

### FM-2: Relevance Scoring During Traversal (High severity, ~40%+ error by hop 3-4)
Poor semantic distance calibration. Recency bias, topic drift. Each hop looks locally plausible while the path as a whole diverges.

### FM-3: Confidence Calibration (Medium-High, ECE likely >0.20)
Models express high confidence in sparse graph regions, low confidence in dense ones. Can't distinguish "I know this" from "this text looks familiar."

### FM-4: Priority/Attention Allocation (Medium, ~25% misallocation)
Models can't estimate centrality or structural importance from content alone. Poor intra-tree budget distribution.

### FM-5: Merge vs. Create Node (Medium, ~35% error in ambiguous zone)
Over-merge (collapse distinct concepts) or under-merge (duplicate nodes). Paraphrase detection failures.

### FM-6: Structured Output Validity (High blocking risk, 5-15% without constrained decoding)
A single malformed GraphOp cascades in the cognitive loop.

### FM-7: Temporal/Causal Ordering (Medium-Low early, Medium-High for mature graph)
Can't reliably distinguish "A caused B" from "A and B co-occurred." ~45% error on non-obvious causal distinctions.

---

## Part 2: Seven Tools

### T1: Contradiction Detector (compensates FM-1)
Embedding cosine similarity + negation morpheme detection + polarity analysis (VADER). No LLM call.

```
contradiction_score = cosine_sim × negation_weight × (1 - temporal_distance_weight)
```

Model's reduced role: three-way classification (CONTRADICTS / SUPERSEDES / DISMISS) instead of free-form judgment.

**Cost:** <200MB RAM, ~100ms for 50 candidates.

### T2: Relevance Scorer (compensates FM-2)
Geometric computation: embedding proximity × edge weight × path novelty bonus.

```python
score = cosine_proximity(focus, candidate) × edge_weight × novelty_bonus
# novelty_bonus: 1.2 if unvisited, 0.8 if already traversed
```

Presents ranked menu to model. Model can override but default is tool-guided.

**Cost:** <5ms (pre-computed embeddings, NumPy), no RAM overhead.

### T3: Graph Centrality Advisor (compensates FM-4)
Weighted degree centrality + approximate betweenness (50-sample Monte Carlo) on k-hop subgraph.

High-centrality nodes get more traversal budget. Care level multiplier applied on top.

**Cost:** <30ms, trivial RAM.

### T4: Bayesian Confidence Calculator (compensates FM-3)
Structural computation from graph topology, not model self-assessment.

```python
comprehension = mean_edge_weight × (1 - weight_variance)
completeness = rendered_nodes / estimated_neighborhood_size
combined = comprehension × completeness × recency_factor
```

Model sees: "Structural confidence: 0.68. Options: (A) respond, (B) grow tree deeper, (C) spawn exploration." Model picks A/B/C.

**Cost:** <15ms, trivial RAM.

### T5: Semantic Merge Classifier (compensates FM-5)
Three zones based on cosine distance:
- `< 0.1` → auto-MERGE (no model call)
- `0.1 - 0.4` → MiniLM NLI classifier (entailment/contradiction/neutral maps to merge/contradict/create)
- `>= 0.4` → auto-CREATE (no model call)

**Cost:** ~30ms for NLI (only ~30-40% of cases), ~50MB RAM for quantized MiniLM.

### T6: GraphOp Validator + Retry Handler (compensates FM-6)
Three-layer defense:
1. Grammar-constrained decoding (Ollama JSON mode)
2. Pydantic schema validation with reference checking
3. Repair heuristics (fill missing fields, substitute nearest valid reference, reclassify unknown action)

Max 2 retries. After failures, emit `no_op` to keep loop alive.

**Cost:** <5ms validation, ~500ms per retry (rare).

### T7: Causal Direction Voter (compensates FM-7)
Three-signal voting:
1. Temporal precedence (which node came first?)
2. Linguistic causal markers ("caused," "led to," "triggered")
3. Single-token LLM classification ("A" or "B") — ~50ms vs ~500ms for full generation

Aggregate with min confidence 0.6. Below threshold → label as CO_OCCURRENCE.

**Cost:** <60ms total per edge.

---

## Part 3: Pipeline Architecture

```
Input: Rendered Tree (2-4K tokens)
          │
          ▼
    ┌─ PRE-TRAVERSAL TOOLS (always run) ─────────────┐
    │  T2: Score traversal candidates                  │
    │  T3: Compute centrality                          │
    │  T4: Compute structural confidence               │
    │  → Augment model's context with assessments      │
    └──────────────────────────────────────────────────┘
          │
          ▼
    Model generates GraphOp (JSON)
          │
          ▼
    ┌─ POST-GENERATION (always run) ──────────────────┐
    │  T6: Validate and repair GraphOp                 │
    └──────────────────────────────────────────────────┘
          │
          ▼
    ┌─ ACTION-SPECIFIC TOOLS ─────────────────────────┐
    │  create_node → T5: merge vs create               │
    │  create_edge → T1: contradiction check           │
    │                T7: causal direction vote          │
    │  traverse    → T2: validate against ranking      │
    └──────────────────────────────────────────────────┘
          │
          ▼
    Execute GraphOp → Update tree → Loop
```

### What the Model Actually Sees

```
## Current Graph Neighborhood
[Rendered tree nodes and edges — 1500 tokens]

## Tool Assessments (pre-computed)
Traversal candidates (ranked by relevance):
  1. node_abc (score: 0.87) — "Project Phoenix timeline"
  2. node_def (score: 0.71) — "Resource constraints Q1"
  3. node_xyz (score: 0.45) — "Team velocity observations"

Structural confidence: comprehension=0.71, completeness=0.52
  → Moderate confidence. Consider growing tree before responding.

## Your Task
Generate a GraphOp. Choose action, params, and reason.
```

### Deterministic vs. LLM Decision Matrix

| Decision | Who | Why |
|---|---|---|
| Which nodes to render (spreading activation) | Algorithm | Purely structural |
| Edge weight updates (Hebbian) | Deterministic | Mechanical reconsolidation |
| Decay computation | Deterministic | Mathematical formula |
| Merge for distance < 0.1 or >= 0.4 | Deterministic | Clear-cut zones |
| Traversal candidate ranking | Algorithm (T2+T3) | Geometric, faster, more consistent |
| Contradiction scoring | Algorithm (T1) | Algebraically detectable |
| Confidence computation | Algorithm (T4) | Structural property of tree |
| **Which GraphOp to emit** | **LLM** | Requires content understanding |
| **Node content generation** | **LLM** | Language task |
| **Edge descriptions** | **LLM** | Language task |
| **Reason field** | **LLM** | Interpretability |

---

## Part 4: Latency Budget

Target: ~10 cycles/min (6 seconds per cycle) on M1 Air 8GB.

| Component | Latency | Notes |
|---|---|---|
| Tree rendering (SQLite) | <10ms | |
| T2 relevance scorer | <5ms | Pre-computed embeddings |
| T3 centrality advisor | <30ms | Local subgraph |
| T4 confidence calculator | <15ms | |
| Context assembly | <5ms | |
| **Model inference (3.8B, ~300 tok)** | **1000-2000ms** | **Main bottleneck** |
| T6 validation | <1ms | |
| T1 contradiction (when triggered) | <100ms | ~20% of ops |
| T5 merge classifier (when triggered) | <30ms | ~30% of ops |
| T7 causal voter (when triggered) | <60ms | ~20% of ops |
| Graph write | <5ms | |
| **Total typical cycle** | **~1200-2300ms** | Within 6s budget |

### RAM Profile

| Component | RAM |
|---|---|
| Phi-4 Mini 3.8B Q5 | ~2.5GB |
| SQLite graph DB (10K nodes) | ~150MB |
| all-MiniLM-L6-v2 embedder | ~22MB |
| MiniLM NLI classifier | ~50MB |
| Python runtime + libs | ~300MB |
| Working set | ~200MB |
| **Total** | **~3.2GB** |

Leaves ~2.3GB headroom on 8GB M1 Air. With 7B model: ~5.2GB total, ~2.8GB headroom.

---

## Part 5: Implementation Sequence

### Phase A: Infrastructure
- A1: Embedding pipeline (all-MiniLM-L6-v2, batch embedding, SQLite storage)
- A2: Tool bus scaffolding (pre/post/action-specific hooks, `Tool` interface)
- A3: T6 GraphOp validator (Pydantic schema, repair heuristics, retry handler)

### Phase B: Core Judgment Tools
- B1: T2 Relevance scorer
- B2: T4 Confidence calculator
- B3: T3 Centrality advisor

### Phase C: Content-Sensitive Tools
- C1: T1 Contradiction detector
- C2: T5 Merge classifier (MiniLM NLI)
- C3: T7 Causal direction voter

### Phase D: Measurement
- D1: Before/after accuracy tests (100 scenarios, model-only vs tool-augmented)
- D2: End-to-end loop test (100 cycles on 1K-node graph)

---

## Acceptance Criteria

| Failure Mode | Baseline (model-only) | Target (tool-augmented) |
|---|---|---|
| FM-1: Contradiction detection | ~60-70% | >85% |
| FM-2: Relevance scoring | ~60-75% at hop 3+ | >80% |
| FM-3: Confidence calibration | ECE ~0.20 | ECE <0.08 |
| FM-4: Priority allocation | ~75% | >85% |
| FM-5: Merge vs. create | ~65% ambiguous zone | >80% |
| FM-6: Structured output | TBD by S3 | >98% |
| FM-7: Causal direction | ~55% | >70% |

---

## Structured Contract

- **External dependencies:** Graph Engine (S2), best model + failure modes (S3, S4)
- **Interfaces exposed:**
  - `ToolBus` class with pre/post/action hooks
  - 7 tools conforming to `Tool` interface
  - `ConfidenceState`, `ScoredCandidate`, `ContradictionCandidate` data classes
  - Before/after accuracy measurements
- **Technology commitments:** all-MiniLM-L6-v2 (22MB), MiniLM NLI (50MB), VADER, NumPy

## Key Decisions

1. **Tools augment context, don't replace generation.** Model always generates final GraphOp. Tools simplify decisions from judgment to confirmation.
2. **Pre-computed embeddings stored in SQLite.** No on-the-fly embedding during traversal. T2 and T5 are near-zero latency.
3. **Single-token LLM calls for classification.** T7 uses "A or B?" at ~50ms. Apply this pattern wherever model role is classification, not generation.
4. **All tools independently disableable.** Required for thermal management, debugging, and graceful degradation.
5. **Small specialized models for language classification.** MiniLM NLI for merge decisions saves ~10x latency vs. main model.

## Key Insights

1. **Traversal relevance is geometric, not linguistic.** Embedding distance from focus is faster and more consistent than asking the model to rank.
2. **Confidence calibration is mostly structural.** Comprehension and completeness are computable from graph topology. T4 is effectively free.
3. **NLI's three-way classification maps exactly to merge/contradict/create.** Not approximate — exactly what NLI was designed for.
4. **Tool bus automatically generates training data.** Every (tool_recommendation, model_decision, outcome) triple is a potential LoRA fine-tuning example.

## Open Questions

1. Should embeddings be re-computed as node associations evolve?
2. How do tools behave at cold start (empty graph)? Model may need to carry more weight initially.
3. At what model size do tools become unnecessary? Should tool aggressiveness scale with model capability?
4. Can accumulated tool_recommendation data train a LoRA that collapses tools back into the model?
5. Pre-computed vs on-demand centrality? (30ms on-demand seems fine; pre-computed goes stale on every write)
