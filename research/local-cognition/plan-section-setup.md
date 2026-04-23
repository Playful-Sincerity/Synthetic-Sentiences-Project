# Section 1: Environment Setup

## Implementation Plan

1. **Install Ollama** — `brew install ollama` or download from ollama.com
2. **Download target models** — Pull the 3 candidates that fit 8GB:
   - `ollama pull phi4-mini` (3.8B Q5, ~2.5GB)
   - `ollama pull llama3.2:3b` (3B Q5, ~2.2GB)
   - `ollama pull qwen2.5:7b` (7B Q4, ~4.5GB — test if it fits alongside graph DB)
3. **Verify inference** — Run a quick structured output test with each model to confirm they work
4. **Set up Python environment** — `python3.11 -m venv .venv && source .venv/bin/activate`
5. **Install Python deps** — `pip install ollama numpy pytest`
6. **Create project scaffolding**:
   ```
   local-cognition/
     src/
       graph_engine.py          # Section 2
       benchmark_harness.py     # Section 3
       traversal_benchmark.py   # Section 4
       tools/                   # Section 5
       cognitive_loop.py        # Section 6
     scenarios/                 # Test scenarios (JSON)
     results/                   # Benchmark results
     tests/                     # pytest tests
     plan.md                    # Already exists
     plan-section-*.md          # Already exists
   ```
7. **Validate M1 compatibility** — Run `ollama` on M1 Air, verify models load and produce output. Record baseline tok/s for each model.

## Structured Contract

- **External dependencies assumed:** None — this is the foundation
- **Interfaces exposed:**
  - Ollama running as local service with 3 models available
  - Python 3.11+ venv with all deps installed
  - Project directory structure ready for all sections
- **Technology commitments:** Ollama (not llama.cpp directly, not MLX directly — Ollama wraps MLX on Apple Silicon)

## Test Strategy

- **Acceptance test:** `ollama run phi4-mini "Output a JSON object with keys: action, params, reason"` returns valid JSON
- **Acceptance test:** `python -c "import ollama; print(ollama.chat(model='phi4-mini', messages=[{'role':'user','content':'hello'}]))"` works
- **Acceptance test:** All 3 models load and respond within 30 seconds on M2 Air

## Key Decisions

- **Ollama over raw MLX/llama.cpp:** Simpler API, handles model management, uses MLX backend on Apple Silicon automatically. Breaks if: Ollama adds too much overhead or doesn't expose JSON mode properly.
- **Python 3.11+ over 3.9 system Python:** Need modern typing, better asyncio. Breaks if: some dep doesn't support 3.11.
- **No Docker/containers:** Bare metal for minimum overhead on 8GB. Breaks if: we need isolation later.

## Estimated Time

1-2 hours. Mostly download time for models.
