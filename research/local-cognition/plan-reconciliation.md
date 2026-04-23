# Plan Reconciliation — Step 3

Cross-reference of all 8 section plans for dependency satisfaction, technology conflicts, interface mismatches, and fragility violations.

---

## Critical Conflicts (must resolve before execution)

### C1: Neighborhood Token Budget Mismatch

**Sections involved:** S2, S3, S4, S6

| Section | Neighborhood budget | Context |
|---------|-------------------|---------|
| S2 (Graph Engine) | <2,000 tokens | `format_neighborhood()` design target |
| S3 (Structured Output) | 400–1,200 tokens | Benchmark scenario neighborhoods |
| S4 (Traversal Benchmark) | ~800 tokens (implied) | Based on S3's prompt templates |
| S6 (Cognitive Loop) | **~350 tokens** | Production loop: 80 + 150 + 90 + 30 |

S6's production neighborhood is **2-3x smaller** than what S3/S4 benchmark against. If the model's traversal quality was validated on 800-token neighborhoods, it may degrade at 350 tokens.

**Resolution options:**
1. **Expand S6's neighborhood budget** to ~600-800 tokens and increase `num_ctx` from 1024 to 1536. Adds ~15-20% latency. Cycle time stays within 6s budget.
2. **Add a benchmark condition in S3** that tests at 350-token neighborhoods. Then we know the quality delta empirically.
3. **Both** — benchmark at multiple neighborhood sizes, then pick the sweet spot for S6.

**Recommended:** Option 3. Add a "production-size context" condition to S3/S4 so the quality impact is measured, not assumed.

---

### C2: S4's Long Benchmark Has No Thermal Management

**Sections involved:** S4, S6

S4 plans a 4-6 hour benchmark run on M1 Air. S6 documents that the M1 Air (fanless) throttles after 10-20 minutes of sustained inference, stabilizing at ~50-60% peak.

**Problem:** S4's benchmark will hit thermal throttling ~15 minutes in. The last 5+ hours run at degraded speed. Worse: if throttling changes model quality (not just speed), mid-run and late-run results are measured under different conditions than early-run results.

**Resolution:**
1. Add thermal monitoring to S4's benchmark harness (log tok/s every 60s, flag throttle events).
2. Use S6's duty cycling approach: 20 min active / 10 min rest between benchmark batches.
3. Report results with thermal state annotations so early vs. late performance can be compared.
4. Or: run on M2 Air (dev machine, also fanless but slightly more thermal headroom) and validate a subset on M1 Air.

**Recommended:** Add thermal monitoring + duty cycling to S4. This is easy and prevents unreliable results.

---

## Medium Conflicts (should resolve before execution)

### M1: S1 Dependency List Incomplete

S1 installs: `ollama numpy pytest`

Additional dependencies needed by later sections:

| Package | Needed by | Purpose |
|---------|-----------|---------|
| `sentence-transformers` | S5, S7, S8 | all-MiniLM-L6-v2 embeddings |
| `pydantic` | S5 (T6) | GraphOp schema validation |
| `faiss-cpu` | S8 | RAG baseline vector search |
| `vaderSentiment` | S5 (T1) | Polarity analysis for contradiction detection |
| `torch` (CPU) | transitive via sentence-transformers | ML backend |

**Resolution:** Update S1's pip install to include all deps, or split into "core" (S1-S4) and "extended" (S5-S8) requirements files. The extended deps add ~2GB disk and ~200MB RAM at runtime. This matters on 256GB/8GB target.

**Recommended:** Two requirements files: `requirements-core.txt` (ollama, numpy, pytest) for S1-S4, and `requirements-tools.txt` (adds sentence-transformers, pydantic, vaderSentiment, faiss-cpu) installed before S5.

---

### M2: S1 Model List Incomplete

S1 pulls 3 models: phi4-mini, llama3.2:3b, qwen2.5:7b.

S3 wants to benchmark 7+ models including Qwen 2.5 0.5B, 1.5B, SmolLM2 1.7B, and Gemma 2B. The master plan says "benchmark the full range 0.5B to 7B."

**Resolution:** S1 should pull all candidate models, or S3 should pull its own models as part of benchmark setup. Since model downloads are just `ollama pull` commands, this is low-risk — just needs documentation.

**Recommended:** S1 pulls the 3 primary candidates. S3's harness pulls additional models on-demand before benchmarking. Document which models are cached at each phase.

---

### M3: S6 Hardcodes phi4-mini

S6's TRAVERSE stage says `model="phi4-mini"`. But the whole point of S3/S4 is to find the BEST model empirically.

**Resolution:** S6 should reference "best model from S3/S4" as a configurable parameter, not a hardcoded string. The cognitive loop's `CognitiveLoop.__init__()` should accept `model_name` as a constructor argument.

---

### M4: S6 Context Window Is Very Tight

S6 specifies `num_ctx: 1024` with a prompt of ~850 tokens. That's 83% utilization leaving ~174 tokens of margin.

**Risks:**
- Tool assessments from T2/T3/T4 (S5) add context that S6 doesn't budget for. S5's "What the Model Actually Sees" example shows ~200 extra tokens for tool assessments.
- Any prompt expansion (richer neighborhoods, more emotional state) breaks the budget.
- No room for few-shot examples if S3 determines they're needed.

**Resolution:** Budget `num_ctx: 2048` and design the prompt to use 1200-1500 tokens, leaving 500-800 tokens margin. The RAM impact is negligible (context is KV cache, not model weights). The latency impact of a larger context window on a 3.8B model is minimal (~10-15% at 2048 vs 1024).

---

### M5: GraphOp Schema Has No Home File

The GraphOp data class is defined in the master plan's cross-cutting section. S2 doesn't include it in its interfaces (S2 exposes GraphEngine for CRUD, not the operation schema). S3 references it. S5 validates it (T6). S6 generates it.

**Resolution:** Create a `src/models.py` containing Node, Edge, and GraphOp dataclasses. S2's GraphEngine imports from models.py. S3/S5/S6 all import from the same source.

---

### M6: S5 Pre-Commits to Tool Designs Before Empirical Data

S5 designs 7 specific tools with concrete implementations based on PREDICTED failure modes. The predictions are well-reasoned but may not match reality. If S3/S4 surface unexpected failure patterns, S5's tools may need redesign.

**Resolution:** Acknowledge this explicitly in S5. Split S5 into:
- **S5a (post S3):** Revise predicted failure modes with actual S3 data. Confirm or modify T6 (validator).
- **S5b (post S4):** Revise remaining tools with actual traversal failure data. Build tools against empirical failure modes, not predictions.

This is already implied by S5's dependency on S3/S4, but making the revision step explicit prevents treating the pre-mapped designs as final.

---

## Minor Conflicts (note and proceed)

### m1: S6 Tool Name Mismatch with S5

S6's structured contract says it requires `similarity_score + check_contradiction tools`. S5 names these T2 (Relevance Scorer) and T1 (Contradiction Detector). The Tool interface in S5 doesn't expose `similarity_score` or `check_contradiction` as method names.

**Resolution:** Align naming. Either S6 uses S5's tool names (T1, T2, etc.) or S5 exposes descriptive method names. Recommend the latter: `tool_bus.score_relevance()`, `tool_bus.check_contradiction()`.

---

### m2: S7 Uses `tools/` Directory Not in S1 Scaffolding

S7 references `tools/generate_test_graph.py`. S1's scaffolding has `src/`, `scenarios/`, `results/`, `tests/` but no `tools/`.

**Resolution:** Add `tools/` to S1's scaffolding. Or rename to `scripts/` per folder-structure conventions.

---

### m3: S4 Hardcodes 3 Models

S4 lists Phi-4 Mini, Llama 3.2 3B, Qwen 2.5 7B as its test models. If S3 identifies a different winner (e.g., SmolLM2 1.7B performs surprisingly well), S4 would miss testing it.

**Resolution:** S4 should test "top 3 models from S3" rather than pre-specified names.

---

### m4: Different Test Domains Across Sections

| Section | Domain |
|---------|--------|
| S4 | Personal/technical/emotional/contradiction clusters |
| S7 | History of Computing |
| S8 | Programming Languages (50 Wikipedia articles) |

These are all different. Findings in one domain may not transfer to another.

**Resolution:** Acceptable — different sections test different properties. But S7 and S8 should note that their domain-specific findings need validation on the personal-knowledge domain that the actual Companion will use.

---

### m5: S4 and S7 Both Build Test Graphs Independently

S4 builds a 1K-node test graph (5 clusters, hand-authored seeds + GPT-4o generation). S7 builds test graphs from 1K to 100K (3 modes: uniform, clustered, organic). S2 also has a `seed_graph()` function.

**Resolution:** S7's graph generator should be the canonical test graph tool, built in S2 or shared. S4 can use S7's clustered-domain mode with custom cluster definitions. Prevents duplicate work and ensures consistent graph topology.

---

## Fragility Cross-Reference

Checking each section's "breaks if" conditions against other sections' decisions:

| "Breaks if" | Source | Status |
|---|---|---|
| Ollama adds overhead or no JSON mode | S1 | **Safe** — S3 tests JSON mode directly |
| Need concurrent writes | S2 | **Safe** — S6 is single-process |
| Models need raw JSON, not prose context | S2 | **Safe** — S3 benchmarks formatted text |
| Schema evolves significantly | S2 | **Safe** — simplified model is by design |
| JSON mode causes semantic degradation | S3 | **Monitored** — S3 benchmarks with/without |
| 1K nodes not enough for real traversal | S4 | **Addressed** by S7 (scaling analysis) |
| Thermal throttling changes mid-run results | S4 | **UNADDRESSED** → **C2** |
| Embeddings go stale | S5 | **Unaddressed** — no section handles re-embedding on node update. Low priority for prototype. |
| Tools degrade at cold start | S5 | **Partially addressed** — S6's warm-up phase (cycles 1-5: prefer familiar territory) mitigates but doesn't fully solve. |
| Clustering algorithm unrealistic | S7 | **Acceptable risk** — organic growth mode provides alternative |
| FAISS not installed | S8 | **Addressed** by **M1** resolution |

---

## Resolution Summary

| ID | Conflict | Action | Owner |
|---|---|---|---|
| **C1** | Neighborhood token mismatch | Add production-size (350-token) condition to S3/S4; expand S6 to ~600-800 | S3, S4, S6 |
| **C2** | S4 no thermal management | Add thermal monitoring + duty cycling to S4 benchmark | S4 |
| **M1** | Missing dependencies | Two requirements files (core + tools) | S1 |
| **M2** | Missing models | S3 pulls additional models on-demand | S1, S3 |
| **M3** | Hardcoded model name | Make S6 model configurable | S6 |
| **M4** | Tight context window | Expand to num_ctx: 2048 | S6 |
| **M5** | GraphOp has no home | Create src/models.py | S2 |
| **M6** | Pre-committed tool designs | Split S5 into S5a (post-S3) and S5b (post-S4) | S5 |
| **m1** | Tool name mismatch | Align S5/S6 naming | S5, S6 |
| **m2** | Missing tools/ directory | Add to S1 scaffolding | S1 |
| **m3** | Hardcoded model list | S4 uses S3 winners | S4 |
| **m4** | Different test domains | Note in findings, acceptable | S4, S7, S8 |
| **m5** | Duplicate graph generators | S7 is canonical, S4 uses it | S2, S4, S7 |

---

## Updated Dependency Graph (post-reconciliation)

```
S1 (Setup) ──────────────────────────────────────→ ALL
    │
    ▼
S2 (Graph Engine + models.py) ───────────────────→ S3, S4, S7, S8, S9
    │
    ├──→ S7 (Scaling) ──────────────────────────→ S4 (provides graph generator)
    │                                               S9
    ├──→ S8 (Graph vs RAG) ────────────────────→ S9
    │
    ▼
S3 (Structured Output) ─── [C1: add 350-tok condition] ──→ S4, S5a, S6, S9
    │
    ▼
S4 (Traversal) ─── [C2: add thermal mgmt] ────→ S5b, S6, S9
    │
    ▼
S5a (Tool Compensation - validator) ───→ S5b
S5b (Tool Compensation - full suite) ──→ S6, S9
    │
    ▼
S6 (Cognitive Loop) ─── [M3: configurable model] [M4: 2048 ctx] ──→ S9
    │
    ▼
S9 (Prototype Integration) ◄── ALL
```

**Key change:** S5 now has two sub-phases (S5a after S3, S5b after S4). S7's graph generator is shared upstream to S4.

---

## Revised Critical Path

```
S1 → S2 → S3 (with 350-tok condition) → S4 (with thermal mgmt) → S5b → S6 → S9
                                           ↑
                              S7 graph generator feeds into S4
```

S5a runs in parallel with S4 (only needs S3 results). S7 and S8 remain off critical path but S7's graph generator is needed by S4.

**New dependency:** S7's graph generator should be built early (part of S2 or immediately after S2) so S4 can use it.
