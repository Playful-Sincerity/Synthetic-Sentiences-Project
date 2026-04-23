# Session Brief: E — Tool Validator (S5a: T6 Only)

## Prerequisites
- Session A complete (graph engine, models.py)
- Session B complete (structured output failure modes)
- Can run in parallel with Session D

Read these files from completed sessions:
- `results/structured-output-analysis.md` — failure mode breakdown (which validity checks fail most)
- `src/models.py` — GraphOp schema

## Context
S5 (Tool Compensation) was split during reconciliation into S5a (this session — validator only, needs S3 data) and S5b (Session F — full tool suite, needs S4 data). This session builds the GraphOp validation and repair layer that prevents malformed operations from crashing the cognitive loop.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-tool-compensation.md` — S5 plan, focus on T6 (GraphOp Validator + Retry Handler)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — M6 (S5 split)

## Task

### 1. Build Tool Bus Scaffolding
Create `src/tool_bus.py`:
- `ToolBus` class with pre/post/action-specific hook points
- `Tool` base interface: `name`, `run(context) -> ToolResult`
- Hook registration: `register_pre_traversal(tool)`, `register_post_generation(tool)`, `register_action_handler(action, tool)`
- All tools individually disableable (for debugging, thermal management)

### 2. Build T6: GraphOp Validator + Retry Handler
Create `src/tools/validator.py`:

Three-layer defense:
1. **Grammar-constrained decoding** — Ollama `format: "json"` (handled at inference level)
2. **Pydantic schema validation** — validate GraphOp against schema:
   - All 11 validity checks from S3
   - Reference checking (node/edge IDs exist in current graph)
   - Enum validation (action types, relation types, node types)
   - Range validation (confidence 0-1, weight 0-1)
3. **Repair heuristics** — when validation fails:
   - Fill missing fields with sensible defaults
   - Substitute nearest valid reference for invalid node/edge IDs
   - Reclassify unknown action types to nearest valid
   - Truncate out-of-range values to valid ranges

Max 2 retries on validation failure. After 2 failures, emit `no_op` (keeps loop alive).

### 3. Calibrate Against S3 Failure Data
- Load S3's failure mode breakdown
- For each common failure pattern, verify T6 catches and repairs it
- Run T6 against S3's raw model outputs (the ones that failed) to measure repair rate
- Target: T6 repairs 80%+ of structural failures without re-inference

### 4. Tests
Create `tests/test_validator.py`:
- Valid GraphOps pass through unchanged
- Each failure type (parse error, missing field, invalid action, wrong type, out of range, invalid reference, invalid enum) is caught
- Repair heuristics produce valid output for common failures
- Retry handler fires on validation failure
- `no_op` emitted after max retries
- Tool bus hooks fire in correct order

## Output Format

- `src/tool_bus.py` — ToolBus class with hook architecture
- `src/tools/__init__.py`
- `src/tools/validator.py` — T6 implementation
- `tests/test_validator.py` — comprehensive tests
- `results/validator-calibration.md` — repair rate against S3 failure data
- Git commit

## Success Criteria

1. T6 catches all 11 validity check failures
2. Repair heuristics fix 80%+ of S3's structural failures without re-inference
3. After T6, structural validity rate is >98% (from whatever baseline S3 found)
4. ToolBus hook architecture works and is extensible for Session F's tools
5. All tests pass
