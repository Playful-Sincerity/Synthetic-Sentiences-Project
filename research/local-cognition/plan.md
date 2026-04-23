# Local Cognition — Deep Plan

## Environment Health: WARNINGS

- **No git repo** — The Companion directory is not version-controlled. Not a blocker for research, but should be initialized before prototype code is written.
- **Ollama not installed** — Needed for all model benchmarking. First setup task.
- **Python 3.9.6 (system)** — Will need a proper Python environment (3.11+) for prototype code and MLX.
- **Development machine: M2 MacBook Air 8GB** — Build, benchmark, and test here.
- **Target runtime: M1 MacBook Air 8GB / 256GB storage** — All model size and RAM constraints must fit this. Max model ~3.8-7B. Storage limited (~150-180GB usable). If it runs on this, it runs on any Apple Silicon Mac.
- **No ML libraries installed** — Need: mlx, ollama Python client, sqlite3 (built-in), numpy, pytest.

## Assumptions

Based on Wisdom's answers:

1. **M1 Air 8GB is the target runtime** — develop on M2 Air, deploy/run on M1 Air
2. **Output = validation + working prototype** — not just docs; we build a minimal graph traversal engine
3. **Judgment offloading is empirical** — Streams 1+2 determine the right balance, not a priori design
4. **Fine-tuning is deferred** — baseline with off-the-shelf models first; LoRA only if we're close but not reliable enough
5. **Simplified data model** — start with minimal nodes/edges, add Associative Memory complexity incrementally

## Cross-Cutting Concerns

### Hardware Constraints (M1 Air 8GB / 256GB)

| Resource | Total | OS/System | Available for Companion |
|---|---|---|---|
| RAM | 8GB unified | ~2.5GB | ~5.5GB for model + graph DB + app |
| Storage | 256GB | ~60-80GB | ~150-180GB (keep only 2-3 models) |
| GPU cores | 7-core M1 | — | Slower than M2 (~15-20% on inference) |

| Model | Params | Quant | RAM | Speed (M1 est.) | Fits? |
|---|---|---|---|---|---|
| Qwen 2.5 | 0.5B | Q8 | ~0.4GB | ~100+ tok/s | Trivially — if it works, runs on anything |
| Qwen 2.5 | 1.5B | Q5 | ~1.2GB | ~70 tok/s | Comfortable — leaves 4GB+ headroom |
| SmolLM2 | 1.7B | Q5 | ~1.3GB | ~65 tok/s | Comfortable — designed for on-device |
| Gemma | 2B | Q5 | ~1.5GB | ~60 tok/s | Comfortable |
| Llama 3.2 | 3B | Q5 | ~2.2GB | ~35 tok/s | Comfortable |
| Phi-4 Mini | 3.8B | Q5 | ~2.5GB | ~30 tok/s | Comfortable |
| Qwen 2.5 | 7B | Q4 | ~4.5GB | ~15 tok/s | Tight — leaves ~1GB headroom |
| Anything 14B+ | — | — | 9GB+ | — | Does NOT fit |

**The dream scenario: a 1.5B model that works.** That's 1.2GB RAM, runs on a Raspberry Pi, and would prove that the graph truly carries the intelligence.
**The realistic floor: 3.8B.** Still very cheap, very fast, plenty of headroom.
**Benchmark the full range** (0.5B to 7B) to find the actual judgment floor.

### Core Data Model (v0 — Simplified)

```python
# Minimal graph for benchmarking — NOT the full Associative Memory model
Node = {
    "id": str,
    "content": str,          # The knowledge/memory
    "type": str,              # fact | belief | observation | meta
    "confidence": float,      # 0.0-1.0
    "created_at": datetime,
    "tags": list[str]
}

Edge = {
    "source_id": str,
    "target_id": str,
    "relation": str,          # supports | contradicts | caused_by | related_to | part_of
    "weight": float,          # 0.0-1.0
    "description": str        # WHY these are connected
}

# Graph operation (what the LLM outputs)
GraphOp = {
    "action": str,            # traverse | create_node | create_edge | update_node | update_edge | tool_call | reflect
    "params": dict,           # action-specific parameters
    "reason": str             # WHY this action (interpretability)
}
```

### Technology Stack

| Layer | Choice | Rationale |
|---|---|---|
| Language | Python 3.11+ | MLX, Ollama client, rapid prototyping |
| Graph storage | SQLite | Built-in, fast enough for 100K+ nodes, no RAM overhead |
| Model runtime | Ollama (MLX backend) | Native Apple Silicon, easy model switching |
| Embeddings | MLX + sentence-transformers | Local embedding generation on Neural Engine |
| Testing | pytest | Standard, fast |
| Benchmark harness | Custom Python | Simple test runner, JSON output for analysis |

### Naming & File Conventions

- All code: `snake_case.py`
- Benchmark scenarios: `scenarios/scenario_NNN.json`
- Results: `results/YYYY-MM-DD_model_benchmark.json`
- No frameworks beyond stdlib + the above

### Error Handling

- Model failures (invalid JSON, timeout): log and count as failure, don't crash
- Graph integrity: validate all node/edge references before write
- Benchmark: record raw model output even on parse failure (for debugging)

---

## Meta-Plan

### Goal

Empirically validate whether a local 3-7B LLM + structured memory graph + tool calls can produce reliable cognitive agent behavior at zero API cost, running on an M1 MacBook Air 8GB. Deliver benchmarks proving the thesis and a working prototype demonstrating it.

### Sections

1. **Environment Setup** — Install Ollama, download models, set up Python env, create project scaffolding
   - Complexity: S
   - Risk: Low — standard tooling installation
   - Acceptance criteria: `ollama run phi4-mini` and `ollama run qwen2.5:7b` produce output; Python env has all deps; project structure created

2. **Graph Engine** — Build the minimal graph storage and query layer (SQLite + Python)
   - Complexity: S
   - Risk: Low — well-understood components
   - Acceptance criteria: Can create/read/update/delete nodes and edges; can query neighborhoods (node + N-hop edges + neighbor summaries) in <10ms for 10K-node graphs

3. **Structured Output Benchmark** — Test whether local models can reliably output valid JSON graph operations
   - Complexity: M
   - Risk: Medium — this is the first critical validation gate. If models can't output reliable JSON, the thesis is in trouble
   - Acceptance criteria: At least one model that fits in 8GB RAM (3-7B) achieves 95%+ valid structured output across 50+ test scenarios

4. **Graph Traversal Benchmark** — Test whether local models make good traversal decisions on a real graph
   - Complexity: L
   - Risk: High — this is the core question. "Good traversal decisions" requires defining what "good" means
   - Acceptance criteria: Model follows reasonable traversal paths 80%+ of the time on a 1K-node test graph with known-good paths

5. **Tool Call Compensation** — Identify where models fail at judgment and design tool-based alternatives
   - Complexity: M
   - Risk: Medium — depends on what Stream 3/4 surface as failure modes
   - Acceptance criteria: For each identified judgment failure, a tool-based alternative exists that raises accuracy above the threshold

6. **Continuous Cognition Loop** — Build and test the always-on cognitive loop (pulse → attend → perceive → traverse → act → reflect)
   - Complexity: L
   - Risk: High — integration of all components; thermal/memory behavior over hours
   - Acceptance criteria: Loop runs for 8 hours without degradation; sustained inference speed stays above 50% of initial; graph grows meaningfully during the run

7. **World Model Scaling Analysis** — Measure graph performance at scale and estimate time-to-useful-knowledge
   - Complexity: M
   - Risk: Low — measurement and analysis, not building
   - Acceptance criteria: Documented performance curves (query time, storage, traversal quality) from 1K to 100K nodes; time estimates for reaching "useful understanding" of a domain

8. **Graph vs RAG Comparison** — Head-to-head test: graph traversal agent vs standard RAG on same data and model
   - Complexity: M
   - Risk: Medium — fair comparison design is tricky
   - Acceptance criteria: Documented comparison with clear methodology; demonstrates whether graph adds value over vector-only retrieval

9. **Prototype Integration** — Combine graph engine + best model + tool calls + cognitive loop into a working local companion prototype
   - Complexity: L
   - Risk: Medium — integration risk, but all components are validated by this point
   - Acceptance criteria: A running system that takes natural language input, traverses its graph, accumulates knowledge, and produces responses that reflect graph-derived understanding. Runs locally with zero API calls.

### Acceptance Tests (meta-level)

- A 3-7B model (fits in 8GB RAM) produces valid graph operations 95%+ of the time
- The cognitive loop runs 8+ hours without degradation on M1 Air
- The graph demonstrably improves answer quality over time (day 1 vs day 7)
- The system runs at $0 API cost
- Wisdom interacts with the prototype and feels it "understands"

### Dependency Graph

```
Section 1 (Setup) → ALL others

Section 2 (Graph Engine) → 3, 4, 6, 7, 8, 9
Section 3 (Structured Output) → 4, 5, 6, 9
Section 4 (Traversal Benchmark) → 5, 6, 9

Section 5 (Tool Compensation) → 6, 9  (depends on 3+4 failure analysis)
Section 7 (Scaling) → 9              (informs prototype expectations)
Section 8 (Graph vs RAG) → 9         (validates the approach before integration)

Section 6 (Cognitive Loop) → 9       (the loop IS the prototype's core)
Section 9 (Prototype) depends on ALL others

Independent groups (can run in parallel after Section 1+2):
  - Section 3 + Section 7 (structured output + scaling are independent)
  - Section 4 needs Section 3 results first
  - Section 5 needs Section 3+4 results
  - Section 6 needs Section 3+4+5
  - Section 8 can run anytime after Section 2
```

### Critical Path

```
Setup → Graph Engine → Structured Output Benchmark → Traversal Benchmark → Tool Compensation → Cognitive Loop → Prototype
```

Sections 7 (Scaling) and 8 (Graph vs RAG) are off the critical path — they inform the prototype but don't block it.

### Overall Success Criteria

1. **The judgment floor is identified** — we know the minimum model size for reliable graph operations
2. **The thesis is validated or invalidated** with empirical evidence, not speculation
3. **A working prototype exists** that demonstrates local-only cognition
4. **Performance characteristics are documented** — tokens/sec, thoughts/day, thermal behavior, RAM usage
5. **The path from prototype to full Companion is clear** — what needs to change to evolve this into the Practical Consciousness architecture

### Kill Criteria (when to stop)

- If NO model fitting 8GB RAM achieves 80%+ on structured output → thesis likely invalid for current model generation at this hardware tier. Document findings, check if 14B+ on larger hardware changes the picture.
- If traversal quality is below 60% even with tool compensation → the graph-as-intelligence thesis needs rethinking. The LLM may need to be smarter than "just a traversal engine."
- If thermal throttling makes sustained operation impractical on M1 Air → hardware constraint, not thesis failure. Document and test on machines with fans.

---

## Future Research Threads (beyond this plan's scope, captured for later)

These ideas emerged during planning. They don't change the current research but should inform what comes after.

1. **Multimodal graph nodes** — images, audio, video stored as compressed attachments with semantic labels. A diffusion model could traverse the graph alongside the text model. Different models for different modalities.
2. **AI-native image compression** — store outline + texture + light source instead of pixels. Diffusion reconstructs on demand. 10-100x compression for "recognizable" quality. Useful for Phantom's visual memory. Could be its own project.
3. **Structural logic engine** — a non-LLM symbolic reasoning component (Prolog-like? SAT solver?) paired with the text reader/writer. Takes the tool compensation idea further: the logic tools ARE the reasoning layer, not just compensators.
4. **Custom model for graph reading** — a model whose weights exist solely to read graph structure, not store knowledge. Deliberately minimal pretraining to reduce bias. The "memory model" concept.
5. **Bigger context window trade-off** — test small model + 4K-8K context (stuff more graph) vs small model + 1K context (navigate structure). Add as a condition in Section 8.
6. **Baby bootstrapping** — the companion starts tabula rasa. First experiences get protected/formative status. Seed graph design matters enormously.
7. **Compute optimization** — how much M1 capacity is actually unused during inference? Could strip macOS for Linux. Study actual utilization.
8. **Autonomous learning runs** — point the loop at a tool/framework (e.g., Framer), let it build a knowledge graph, evaluate the resulting understanding. The killer demo for the prototype.

See `ideas-session-2026-04-03.md` for full notes.

---

## Section Plans

All section plans are in `plan-section-*.md` files:

- `plan-section-setup.md` — Section 1: Environment Setup
- `plan-section-graph-engine.md` — Section 2: Graph Engine
- `plan-section-structured-output.md` — Section 3: Structured Output Benchmark
- `plan-section-traversal.md` — Section 4: Graph Traversal Benchmark
- `plan-section-tool-compensation.md` — Section 5: Tool Call Compensation
- `plan-section-cognitive-loop.md` — Section 6: Continuous Cognition Loop
- `plan-section-scaling.md` — Section 7: World Model Scaling Analysis
- `plan-section-comparison.md` — Section 8: Graph vs RAG Comparison
- `plan-section-prototype.md` — Section 9: Prototype Integration

## Reconciliation

Cross-section conflict analysis: `plan-reconciliation.md`

Key findings: 2 critical conflicts (neighborhood token mismatch, S4 thermal management), 6 medium (incomplete deps, hardcoded model, tight context window, GraphOp location, pre-committed tool designs, incomplete model list), 5 minor. All have documented resolutions. See reconciliation doc for full details.
