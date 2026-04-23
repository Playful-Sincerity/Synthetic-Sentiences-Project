# Section 3: Structured Output Benchmark

**Complexity:** M
**Risk:** Medium — first critical validation gate
**Dependencies:** Section 1 (Ollama + env), Section 2 (Graph Engine)
**Blocks:** Sections 4, 5, 6, 9

---

## Purpose

Can the model produce reliably structured output at all? Two distinct questions:

- **Validity** — does the output parse as JSON and conform to the GraphOp schema?
- **Correctness** — does the output represent the right action for the situation?

Section 3 proves validity. Section 4 tests correctness. A model scoring 100% validity but 50% correctness is still useful (plumbing works, judgment improvable). A model scoring 60% validity is a non-starter.

---

## The Constrained Decoding Question

Ollama's `format: "json"` guarantees syntactically valid JSON via grammar-constrained decoding. **This does NOT solve the problem.** It solves syntax but not:

1. **Schema validity** — output may have wrong keys, missing fields
2. **Type correctness** — confidence might be `"high"` instead of `0.7`
3. **Reference validity** — `edge_id` may reference a non-existent edge (hallucination)
4. **Enum validity** — relation might be `"similar"` instead of a valid type
5. **Semantic coherence** — `reason` may be empty or wrong

**Benchmark both with and without JSON mode.** The delta is informative research.

---

## 56 Test Scenarios — 8 Categories

### Category 1: Pure Action Recognition (8 scenarios, easy)
Unambiguous tasks — model must select the right action type.
- Explore connection → `traverse`
- Record new fact → `create_node`
- Connect two nodes → `create_edge`
- Strengthen confidence → `update_node`
- Adjust edge weight → `update_edge`
- Need math computation → `tool_call`
- Pause and reflect → `reflect`
- Empty neighborhood → `create_node` or `reflect`

### Category 2: Field Completeness (8 scenarios, medium)
Correct action AND all required params populated with correct types.
- `create_node` must have content, type, confidence (float 0-1), tags (list)
- `create_edge` must have source_id, target_id, relation (enum), weight, description
- `traverse` must reference a valid edge_id from the neighborhood
- `tool_call` must have tool_name and tool_params

### Category 3: Relation Disambiguation (8 scenarios, medium-hard)
Select correct relation type: `supports | contradicts | caused_by | related_to | part_of`.
Includes ambiguous cases where model must commit and reason.

### Category 4: Confidence Calibration (6 scenarios, medium-hard)
Produce appropriate confidence values: speculation (~0.2-0.4), established fact (~0.85-1.0), direct observation (~0.9), inference from weak beliefs (~0.3-0.5).

### Category 5: Multi-Hop Reasoning (6 scenarios, hard)
Reason about graph topology, not just focal node. Chains, clusters, contradictions, redundancies.

### Category 6: Node Type Routing (6 scenarios, easy-hard)
Select correct type: `fact | belief | observation | meta`.
Includes tricky cases ("Evolution is the best explanation" = belief, not fact).

### Category 7: Adversarial / Edge Cases (8 scenarios, adversarial)
- Empty neighborhood (0 edges)
- Very long node content (500+ words)
- High-density neighborhood (10 edges)
- Task contradicts neighborhood
- Nearly identical nodes (merge decision)
- High-confidence wrong fact
- No tool available for tool_call
- Genuinely ambiguous task

### Category 8: Regression / Baseline (6 scenarios, trivial-easy)
Sanity checks. Literal transcription tasks. If these fail, the test setup is broken.

**Distribution:** 14 easy/trivial, 22 medium, 14 hard, 6 adversarial.

---

## Prompt Templates

### System Prompt (fixed)
Contains:
- GraphOp schema with all 7 action types and their required params
- 7 rules (valid JSON only, exactly one GraphOp, non-empty reason, valid references, valid enums, valid ranges)
- Optional 2-shot examples (condition-dependent)

### User Prompt (varies per scenario)
```
## Graph Neighborhood
{ "focal_node": {...}, "edges": [...], "neighbors": [...] }

## Task
{task_description}

## Output
Respond with exactly one GraphOp JSON object.
```

Neighborhood token budget: 400-800 tokens (easy/medium), up to 1,200 (hard).

---

## 11-Point Validity Checklist

| # | Check | Rule |
|---|---|---|
| 1 | json_parse | Response is syntactically valid JSON |
| 2 | top_level_keys | Exactly 3 keys: action, params, reason |
| 3 | valid_action | action is one of 7 valid strings |
| 4 | params_is_dict | params is a non-null dict |
| 5 | reason_nonempty | reason is non-empty string (>10 chars) |
| 6 | traverse_ref | traverse: edge_id exists in neighborhood |
| 7 | create_node_fields | content, type (enum), confidence (float 0-1), tags (list) |
| 8 | create_edge_fields | source_id, target_id, relation (enum), weight (float 0-1), description |
| 9 | update_fields | node_id/edge_id present, fields dict non-empty |
| 10 | tool_call_fields | tool_name (string), tool_params (dict) |
| 11 | reflect_fields | summary (string) |

**Valid = all applicable checks pass.** One failure = invalid.

### Correctness Scoring (0-3, informational only in S3)
- 0: wrong action type
- 1: correct action, significantly wrong params
- 2: correct action, correct key params, minor issues
- 3: correct action, all params correct, reason demonstrates understanding

### Failure Mode Tags
`parse_error | schema_miss | invalid_action | missing_field | wrong_type | out_of_range | invalid_reference | invalid_enum | reason_empty | wrong_action | prose_contamination | model_refusal`

---

## Model Test Matrix

### Models
| Model | Ollama Tag | RAM | Speed (M1 est.) |
|---|---|---|---|
| Llama 3.2 3B | `llama3.2:3b-instruct-q5_K_M` | ~2.2GB | ~35 tok/s |
| Phi-4 Mini 3.8B | `phi4-mini:3.8b-instruct-q5_K_M` | ~2.5GB | ~30 tok/s |
| Qwen 2.5 7B | `qwen2.5:7b-instruct-q4_K_M` | ~4.5GB | ~15 tok/s |
| Qwen 2.5 7B Q5 | `qwen2.5:7b-instruct-q5_K_M` | ~5.2GB | ~12 tok/s |

Plus smaller models from updated plan: Qwen 2.5 0.5B, 1.5B, SmolLM2 1.7B, Gemma 2B.

### 4 Test Conditions Per Model
| Condition | JSON Mode | Few-shot | Purpose |
|---|---|---|---|
| A: baseline | OFF | 0-shot | Raw model capability |
| B: json_mode | ON | 0-shot | What JSON mode buys |
| C: few_shot | OFF | 2-shot | What examples buy |
| D: json+few | ON | 2-shot | Best case — all assists |

**Total:** 56 scenarios × 4 conditions × 4+ models = 896+ runs.
**Estimated time:** ~45 min/model, ~3-4 hours total on M1 Air.
**Temperature:** 0.0 for all runs (deterministic benchmarking).

### Quantization Sensitivity (best model only)
Sweep Q8 → Q5 → Q4 → Q3 → Q2 to find quality degradation curve.

---

## Acceptance Criteria

- **Pass:** validity_rate >= 0.95 in Condition D AND >= 0.90 in Condition A, for at least one model
- **Soft pass:** >= 0.95 in D but < 0.90 in A (JSON mode required in production — workable but noted)
- **Partial fail:** 0.80-0.94 in D — investigate failure modes, possible prompt engineering fix
- **Hard fail:** < 0.80 in D — thesis in serious trouble at this hardware tier

---

## Key Surprises to Watch

1. **7B dramatically better than 3B** — if Qwen 7B passes at 97% while Phi-4 Mini is at 72%, the judgment floor is above 3.8B
2. **JSON mode causes semantic degradation** — forced token paths may produce valid-but-wrong output (high validity + low correctness)
3. **Few-shot examples act as attractors** — model always traverses because the examples did
4. **Reason field is first casualty** — empty reasons appear before action/params errors
5. **Reference hallucination is the hardest failure** — looks valid until checked against actual graph. Invisible to JSON mode and schema validation. Likely dominant failure mode for adversarial scenarios.

---

## Structured Contract

- **External dependencies:** Ollama + models (S1), Node/Edge/GraphOp classes (S2)
- **Interfaces exposed:**
  - Ranked model list by validity rate (used by all subsequent sections)
  - Best prompt condition (used by S4, S6)
  - Failure mode breakdown (feeds S5 tool compensation design)
  - Quantization sensitivity data (informs RAM budgeting)
- **Technology commitments:** Ollama Python client, `format: "json"` for production

## Open Questions

1. Does installed Ollama support full JSON Schema structured outputs (beyond just `format: "json"`)?
2. Is T=0.0 actually deterministic on MLX? Run trivial scenario 5x to check.
3. Actual RAM headroom on M1 Air during inference — measure with `vm_stat`
4. Should Qwen 7B Q5 be attempted at ~5.2GB model + ~2.5GB OS on 8GB system?
5. How to classify model refusals on adversarial scenarios?
6. Should even smaller models (0.5B, 1.5B) be included in the sweep?

## Estimated Time
Scenario authoring: 2-3 days. Harness build: 1 day. Benchmark runs: 3-4 hours. Analysis: 1 day.
Total: ~4-5 days.
