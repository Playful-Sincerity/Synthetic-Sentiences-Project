# Session Brief: C — Scaling Analysis + Graph Generator (S7)

## Prerequisites
- Session A must be complete
- Verify: GraphEngine works, venv active
- Can run in parallel with Sessions B and I

## Context
Two purposes: (1) measure how the graph engine performs at scale (1K to 100K nodes), and (2) build the canonical test graph generator that Session D (traversal benchmark) will use.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-scaling.md` — full S7 plan
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — m5: this session's graph generator becomes the canonical tool for S4
- `src/graph_engine.py` — the engine you're benchmarking

## Task

### 1. Build Graph Generator (PRIORITY — needed by Session D)
Create `scripts/generate_test_graph.py` with 3 modes:

**Mode 1: Uniform Random** — random nodes and edges, for pure SQLite benchmarking.

**Mode 2: Clustered Domain** — realistic structure:
- Domain: History of Computing (rich internal structure, known ground truth)
- 10 sub-domains (early machines, languages, networking, AI, databases, OSes, web, mobile, security, quantum)
- 70% intra-cluster edges, 30% inter-cluster edges
- Configurable size (1K, 5K, 10K, 50K, 100K)
- Node types distributed realistically (60% fact, 20% belief, 15% observation, 5% meta)
- Edge relations distributed realistically (40% related_to, 25% part_of, 15% supports, 10% caused_by, 10% contradicts)

**Mode 3: Organic Growth Simulation** — rule-based, mimics how the cognitive loop would grow a graph:
- Start with 10 seed nodes
- Each step: pick a node, generate 1-3 new nodes connected to it
- Preferential attachment (high-degree nodes attract more connections)
- ~1000 nodes/min (no LLM, pure algorithm)

### 2. Build Scaling Benchmark
Create `scripts/scaling_benchmark.py`:
- Generate graphs at 1K, 10K, 50K, 100K nodes (Mode 2)
- At each scale, measure:
  - Single-node lookup: 100 reps, p50/p95/p99
  - Neighborhood query (1-hop, 2-hop): 100 reps, p50/p95/p99
  - 5-hop traversal time
  - 10-hop traversal time
  - Spreading activation (depth 3, 5, 10): time + peak RAM
  - Batch insert (1000 nodes)
  - Single insert with index update
  - DB file size + WAL size

### 3. Build Traversal Quality Evaluator
Create `scripts/traversal_quality_eval.py`:
- 20 known-path questions for History of Computing domain
- For each: start node, target node, expected path
- Measure: can the graph engine find the path within 10 hops?
- Run at each scale point

### 4. Run Benchmarks on M1 Air
- Record CPU temp and clock speed throughout
- Use thermal-aware measurement: if throttling detected, note it in results
- Run on target hardware (M1 Air 8GB), not dev machine

### 5. Analysis
Write `results/scaling-analysis.md`:
- Performance curves (charts or tables) for all metrics at each scale
- Time-to-knowledge estimates (throttled and unthrottled)
- SQLite behavior at each tier (WAL size, query time curves)
- "Useful Understanding" threshold estimates validated against traversal quality
- Recommendation: target operating scale for prototype

## Output Format

- `scripts/generate_test_graph.py` — canonical graph generator (3 modes)
- `scripts/scaling_benchmark.py` — scaling measurement tool
- `scripts/traversal_quality_eval.py` — known-path evaluator
- `results/scaling-benchmark-YYYY-MM-DD.json` — raw benchmark data
- `results/scaling-analysis.md` — analysis with recommendations
- Git commit

## Success Criteria

1. Graph generator produces valid graphs at all scales (1K-100K) in all 3 modes
2. Performance data collected at all 4 scale points
3. Neighborhood queries <10ms at 10K nodes (plan requirement)
4. Clear recommendation for prototype operating scale
5. Traversal quality eval shows >70% hit rate at 10K nodes within 10 hops
6. Generator is documented and importable by Session D
