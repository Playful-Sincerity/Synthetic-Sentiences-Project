# Section 7 — World Model Scaling Analysis

**Complexity:** M
**Risk:** Low — measurement and analysis, not building
**Dependencies:** Section 2 (Graph Engine), Section 1 (Setup)
**Off critical path** — informs prototype expectations but does not block it

---

## Acceptance Criteria

- Documented performance curves (query time, storage, traversal quality) from 1K to 100K nodes
- Time estimates for reaching "useful understanding" of a domain at each scale
- SQLite behavior at each tier characterized
- Recommendation for the prototype's target operating scale

---

## Time-to-Knowledge Estimates

Baseline assumptions:
- **10 nodes/min** — one full thought cycle at ~30 tok/s on Phi-4 Mini 3.8B
- **1.5 edges/node average**
- **Continuous operation**

| Scale | Nodes | Edges (est.) | Time @ 10/min | Wall time |
|-------|-------|--------------|---------------|-----------|
| Seed | 1,000 | 1,500 | 100 min | ~1.7 hours |
| Useful | 10,000 | 15,000 | 1,000 min | ~16.7 hours |
| Deep | 50,000 | 75,000 | 5,000 min | ~3.5 days |
| Rich | 100,000 | 150,000 | 10,000 min | ~7 days |

**Thermal constraint (M1 Air, fanless):** Expect throttling after 20-40 min reducing throughput to 60-70% baseline. Real-world ~6-7 nodes/min sustained:

| Scale | Wall time (throttled) |
|-------|-----------------------|
| 1K nodes | ~2.5 hours |
| 10K nodes | ~25 hours (~1 day) |
| 50K nodes | ~5 days |
| 100K nodes | ~10 days |

---

## Storage Estimates

| Scale | Graph (nodes+edges) | Embeddings | Total |
|-------|---------------------|------------|-------|
| 1K | ~0.6 MB | ~1.5 MB | ~2 MB |
| 10K | ~6 MB | ~15 MB | ~21 MB |
| 50K | ~30 MB | ~77 MB | ~107 MB |
| 100K | ~60 MB | ~154 MB | ~214 MB |

**Storage is not the constraint.** Even 100K nodes fits in ~215 MB.

---

## Test Graph Generation

Three modes in `tools/generate_test_graph.py`:

1. **Uniform Random** — pure SQLite performance benchmark
2. **Clustered Domain** — realistic structure (History of Computing, 10 sub-domains, 70% intra-cluster / 30% inter-cluster edges)
3. **Organic Growth Simulation** — rule-based node creation mimicking real cognitive growth (~1000 nodes/min, no LLM)

Primary benchmark uses Mode 2 (Clustered Domain).

---

## What to Measure at Each Scale

At each scale point (1K, 10K, 50K, 100K):

1. **Query Latency** — single-node lookup, neighborhood query (100 reps, p50/p95/p99)
2. **Write Throughput** — batch insert, single-node insert with index update
3. **Traversal Performance** — 5-hop and 10-hop traversal time
4. **Spreading Activation** — grow_tree at depth 3, 5, 10 (time + RAM spike)
5. **Storage** — DB file size + WAL file size
6. **Traversal Quality** — 20 known-path questions, hit rate within 10 hops

---

## "Useful Understanding" Thresholds

| Level | Nodes | Definition |
|-------|-------|------------|
| Seed | ~500 | Basic facts; ~30% question accuracy |
| Functional | ~2,000 | Common questions; starts making connections |
| Useful | ~5,000-10,000 | 70%+ accuracy; non-obvious connections |
| Deep | ~20,000-50,000 | Specialist-level; 85%+ accuracy |
| Rich | ~100,000 | Expert-level; novel multi-hop paths |

Validated empirically, not assumed.

---

## Implementation Plan

1. Build `tools/generate_test_graph.py` (3 modes)
2. Build `benchmarks/scaling_benchmark.py`
3. Build `benchmarks/traversal_quality_eval.py` (20 known-path questions)
4. Run benchmarks at 1K, 10K, 50K, 100K on M1 Air
5. Record CPU temp and clock speed (detect throttling)
6. Write `results/scaling_analysis.md`

## Structured Contract

- **External dependencies:** Graph Engine (S2), Ollama + models (S1)
- **Interfaces exposed:** Test graph generator (used by S4, S8), scaling results
- **Technology commitments:** SQLite with WAL mode, sentence-transformers for embeddings

## Key Decisions

- **Clustered Domain over random:** Realistic structure reveals traversal quality issues that random graphs hide. Breaks if: clustering algorithm doesn't produce realistic graph topology.
- **History of Computing as domain:** Rich internal structure, known ground truth, bounded. Breaks if: domain is too niche to generalize findings.
- **Thermal-adjusted estimates:** Report both theoretical and throttled numbers. The throttled numbers are the real ones for M1 Air.
