# Session Brief: A — Foundation (Setup + Graph Engine)

## Prerequisites
None — this is the first session. Can start immediately.

## Context
We're building a local-only cognitive agent that runs on an M1 MacBook Air 8GB with zero API costs. The thesis: "intelligence is architecture, not model size." A 3-7B local model + associative memory graph + tool calls = functional cognition.

This session builds the foundation: development environment and the graph storage layer that all other sessions depend on.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan.md` — master plan (cross-cutting concerns, data model, tech stack)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-setup.md` — S1 details
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-graph-engine.md` — S2 details
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — reconciliation (M1, M2, M5, m2 apply to this session)

## Task

### Part 1: Environment Setup (S1)

1. Install Ollama: `brew install ollama`
2. Start Ollama service and pull 3 primary models:
   - `ollama pull phi4-mini`
   - `ollama pull llama3.2:3b`
   - `ollama pull qwen2.5:7b`
3. Verify each model can produce structured JSON output
4. Set up Python environment:
   ```bash
   cd ~/Playful\ Sincerity/PS\ Software/The\ Companion/research/local-cognition/
   python3.11 -m venv .venv
   source .venv/bin/activate
   ```
5. Install core deps: `pip install ollama numpy pytest`
6. Create `requirements-core.txt` (ollama, numpy, pytest) and `requirements-tools.txt` (adds sentence-transformers, pydantic, vaderSentiment, faiss-cpu) — per reconciliation M1
7. Create project scaffolding:
   ```
   src/
     models.py              # Node, Edge, GraphOp dataclasses (reconciliation M5)
     graph_engine.py
     benchmark_harness.py
     traversal_benchmark.py
     tools/
     cognitive_loop.py
   scenarios/
   results/
   tests/
   scripts/                 # Utility scripts (reconciliation m2)
   ```
8. Record baseline tok/s for each model: run a standard 200-token generation, record timing

### Part 2: Graph Engine (S2)

1. Implement `src/models.py` — Node, Edge, GraphOp as Python dataclasses or Pydantic models
2. Implement `src/graph_engine.py` — GraphEngine class with full CRUD:
   - `create_node()`, `get_node()`, `update_node()`, `delete_node()`
   - `create_edge()`, `get_edge()`, `update_edge()`, `delete_edge()`
   - `get_neighborhood(node_id, hops=1)` — returns node + edges + neighbors within N hops
   - `search_nodes(query, type=None, tags=None)` — basic text search
   - `get_stats()` — node count, edge count, average degree
3. Implement `format_neighborhood()` — format neighborhood as text prompt
   - Must support configurable token budgets (350, 800, 1200, 2000) — per reconciliation C1
   - Default: current node summary, edges grouped by relation, neighbor summaries
4. Implement `seed_graph(domain, size)` — generate synthetic test graphs
   - Domains: "programming_concepts", "personal_knowledge", "general_knowledge"
   - Sizes: 100, 1K, 10K nodes
   - Realistic edge density: 3-5 edges/node average
5. Write tests in `tests/test_graph_engine.py`:
   - CRUD operations
   - Neighborhood queries at depth 1 and 2
   - Foreign key integrity
   - Search
   - Performance: 100 random neighborhood queries on 10K graph, all <10ms
   - format_neighborhood at multiple token budgets

### Part 3: Initialize Git

Initialize a git repo in the `local-cognition/` directory. First commit with all plan files + scaffolding + graph engine code.

## Output Format

- All code in `src/` and `tests/` directories
- `requirements-core.txt` and `requirements-tools.txt` at project root
- `results/baseline-tok-s.json` — model speed benchmarks
- All tests passing
- Git repo initialized with first commit

## Success Criteria

1. `ollama run phi4-mini "Output JSON: {action, params, reason}"` returns valid JSON
2. `python -c "import ollama; ..."` works from the venv
3. All 3 models load and respond within 30 seconds
4. GraphEngine CRUD tests pass
5. 10K-node graph neighborhood queries all <10ms
6. `format_neighborhood()` produces readable output under configurable token budgets
7. Git repo initialized, first commit made
