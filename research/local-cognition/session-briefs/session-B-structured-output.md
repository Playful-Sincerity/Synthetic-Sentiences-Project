# Session Brief: B — Structured Output Benchmark (S3)

## Prerequisites
- Session A must be complete
- Verify: Ollama running, 3+ models available, GraphEngine works, venv active

Read these files from Session A output:
- `results/baseline-tok-s.json` — model speeds
- `src/models.py` — GraphOp schema (the contract you're benchmarking against)
- `src/graph_engine.py` — `format_neighborhood()` (produces the context the model reads)

## Context
This is the first critical validation gate. Can local 3-7B models reliably output valid JSON graph operations? If no model achieves 95%+ validity, the thesis is in trouble.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-structured-output.md` — full S3 plan (56 scenarios, 11-point validity checklist, 4 test conditions)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — C1 applies: add a "production-size context" condition (350-token neighborhoods)

## Task

### 1. Author 56 Test Scenarios
Create `scenarios/` directory with JSON files for all 56 scenarios across 8 categories:
- Category 1: Pure Action Recognition (8 easy)
- Category 2: Field Completeness (8 medium)
- Category 3: Relation Disambiguation (8 medium-hard)
- Category 4: Confidence Calibration (6 medium-hard)
- Category 5: Multi-Hop Reasoning (6 hard)
- Category 6: Node Type Routing (6 easy-hard)
- Category 7: Adversarial / Edge Cases (8 adversarial)
- Category 8: Regression / Baseline (6 trivial-easy)

Each scenario file must include: task description, graph neighborhood (at specified token budget), expected action type, expected key params, difficulty tier.

### 2. Build Benchmark Harness
Create `src/benchmark_harness.py`:
- Load scenarios from `scenarios/`
- Run each scenario against each model × each condition
- Apply the 11-point validity checklist
- Score correctness (0-3 informational)
- Tag failure modes
- Output results to `results/`

### 3. Pull Additional Models
Pull smaller models for the full sweep:
- `ollama pull qwen2.5:0.5b`
- `ollama pull qwen2.5:1.5b`
- `ollama pull smollm2:1.7b` (verify exact tag)
- `ollama pull gemma2:2b` (verify exact tag)

### 4. Run the Benchmark
4 conditions per model (baseline, json_mode, few_shot, json+few_shot).
56 scenarios × 4 conditions × 7+ models = 1,500+ runs.

**CRITICAL (reconciliation C1):** Add a 5th condition for the top 2 models: run all 56 scenarios with 350-token neighborhoods (production-size context). This measures quality degradation at the context size S6 will actually use.

Temperature: 0.0 for all runs.

### 5. Determinism Check
Run 5 trivial scenarios 5× each at T=0.0 to verify MLX determinism.

### 6. Quantization Sweep (best model only)
For the best-performing model, sweep Q8 → Q5 → Q4 → Q3 → Q2.

### 7. Analysis
Write `results/structured-output-analysis.md`:
- Ranked model list by validity rate (all conditions)
- Best prompt condition per model
- Failure mode breakdown (which checks fail most?)
- Production-context (350-token) results vs standard
- Quantization sensitivity curve
- Clear recommendation: which model(s) and condition(s) for subsequent sections

## Output Format

- `scenarios/*.json` — all 56 scenarios
- `src/benchmark_harness.py` — reusable harness
- `results/structured-output-YYYY-MM-DD.json` — raw results
- `results/structured-output-analysis.md` — analysis with recommendations
- Git commit with all results

## Success Criteria

- **Pass:** validity_rate >= 0.95 in best condition AND >= 0.90 in baseline, for at least one model
- **Soft pass:** >= 0.95 in best condition, < 0.90 in baseline
- **Fail:** < 0.80 in best condition for all models → thesis in serious trouble

Deliver the ranked model list and failure mode breakdown regardless of pass/fail — Section 4 and 5 need these.
