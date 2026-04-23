# Session Brief: G — Continuous Cognition Loop (S6)

## Prerequisites
- Session A complete (graph engine)
- Session B complete (best model, best prompt condition)
- Session D complete (traversal quality validated)
- Session F complete (full tool suite wired into ToolBus)

Read these files from completed sessions:
- `results/structured-output-analysis.md` — best model name, best temperature, JSON mode recommendation
- `results/traversal-analysis.md` — best prompt variant, context size findings
- `src/tool_bus.py` + `src/tools/` — full tool pipeline
- `src/graph_engine.py` — CRUD + neighborhoods

## Context
This section integrates everything into a continuous cognitive loop that runs for 8 hours on a fanless M1 Air. The loop is >99% inference time — all performance leverage is in thermal management and prompt design.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-cognitive-loop.md` — full S6 plan (6 stages, thermal management, duty cycling)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — M3 (configurable model), M4 (expand to 2048 context)

## Task

### 1. Build Loop Components

Create these files:

**`src/pulse.py`** — EmotionalState with 4 dimensions:
- `alignment_confidence`: rises with consistent traversal, drops with failures
- `curiosity_pull`: rises with low-confidence nodes, falls during creation
- `energy`: thermal ceiling × (1 - active_fatigue)
- `coherence`: proportion of consecutive focus nodes that are adjacent

Fast path (every cycle, <5ms): read state. Slow path (every 30 cycles): full recomputation.

**`src/attention.py`** — AttentionQueue with deterministic salience scoring:
```
attention_score(node) =
    edge_weight × 0.35 + (1-confidence) × 0.25 + novelty × 0.20
    + curiosity × is_gap × 0.15 + coherence_repair × is_flagged × 0.05
```
Pulse modulation: energy < 0.3 → 1-hop only. alignment < 0.4 → force meta node. coherence < 0.4 → force contradiction.

**`src/neighborhood.py`** — Graph neighborhood assembly + prompt construction:
- Configurable token budget (use findings from Session B on production-size context)
- Apply reconciliation M4: target ~600-800 tokens for neighborhood, total prompt ~1500 tokens
- `num_ctx: 2048` (not 1024)

**`src/chronicle.py`** — CycleRecord logging, append to JSONL, query last N.

**`src/thermal.py`** — ThermalState monitoring:
- Measure tok/s as thermal proxy (no direct temp reading needed)
- States: COOL (<baseline×0.85), WARM, HOT (>40% degradation), THROTTLED
- Duty cycle: 20 min active / 10 min rest (tunable)

**`src/consolidation.py`** — Rest-period graph maintenance:
- Prune orphan nodes
- Recompute centrality
- Reset attention queue
- Optional 1 LLM mini-reflection call

**`src/cognitive_loop.py`** — CognitiveLoop class:
- `__init__(model_name, graph_engine, tool_bus, config)` — configurable model per reconciliation M3
- `do_cycle()` — PULSE → ATTEND → PERCEIVE → TRAVERSE → ACT → REFLECT
- `do_rest(duration_minutes)` — consolidation period
- `run(duration_hours)` — main entry point with duty cycling

### 2. Graph Growth Controls
- Create when: focus node references something not in graph AND proposed content < 0.7 similarity to existing
- Traverse only when: focus node recent, energy low, or graph already grew this session
- Update-over-create: 0.85 cosine threshold

### 3. Smoke Tests
- Single cycle (mocked model): <1s
- Pulse update: <100ms
- Attention scoring: <50ms
- Thermal throttle trigger: <1s
- 30 live cycles: ~15-20 min, verify loop stability

### 4. 8-Hour Validation on M1 Air
**Run on target hardware (M1 MacBook Air 8GB).** Elevated on stand for airflow.

Start from a seed graph (~100-200 nodes). Log every 10 minutes:
- tok/s
- RSS memory
- Node count, edge count
- Thermal state
- Cycle count

Output: `results/8h-validation-YYYY-MM-DD.json`

### 5. Analysis
Write `results/cognitive-loop-analysis.md`:
- Duty cycle effectiveness (did the 20/10 pattern prevent sustained throttling?)
- Graph growth rate (nodes/hour, edges/hour)
- Memory stability (RSS drift over 8h)
- Emotional state trajectories
- Cycle time distribution (histogram)
- Recommendations for Session H (prototype)

## Output Format

- `src/pulse.py`, `src/attention.py`, `src/neighborhood.py`, `src/chronicle.py`, `src/thermal.py`, `src/consolidation.py`, `src/cognitive_loop.py`
- `tests/test_cognitive_loop.py` — smoke tests
- `results/8h-validation-YYYY-MM-DD.json` — raw validation data
- `results/cognitive-loop-analysis.md` — analysis
- Git commit

## Success Criteria

1. Loop runs 8 hours without crash (400+ cycle records)
2. tok/s never drops below 50% of initial for >2 consecutive 10-min samples
3. Graph has ≥50 new nodes AND ≥25 new edges after 8h
4. RSS after 8h within 200MB of RSS after first 30 min (no memory leak)
5. All smoke tests pass
