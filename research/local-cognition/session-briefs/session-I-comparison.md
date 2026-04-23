# Session Brief: I — Graph vs RAG Comparison (S8)

## Prerequisites
- Session A complete (graph engine)
- Can run in parallel with Sessions B, C (only needs graph engine + Ollama)

## Context
Head-to-head comparison: does building an associative memory graph and traversing it produce better answers than standard RAG (vector similarity search)? Same model, same source material, same token budget. The only difference is retrieval mechanism.

This is off the critical path but validates the entire approach before the prototype.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-comparison.md` — full S8 plan (20 questions, 4 categories, fairness principles, scoring rubric)
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-reconciliation.md` — M1 (FAISS in requirements-tools.txt)

## Task

### 1. Install Extended Dependencies
```bash
pip install -r requirements-tools.txt  # includes faiss-cpu, sentence-transformers
```

### 2. Prepare Source Material
- Download/prepare 50 Wikipedia articles on programming languages
- Clean and chunk for RAG (400-token chunks with 50-token overlap)
- Embed all chunks with all-MiniLM-L6-v2
- Build FAISS index

### 3. Build Graph Agent Ingestor
Create `scripts/comparison_ingest_graph.py`:
- For each article: LLM extracts key concepts (→ nodes) and relationships (→ edges)
- Connect new nodes to existing graph (cross-article edges)
- Use Phi-4 Mini (or best model from Session B if available) for extraction
- Record: time, node/edge counts, RAM

### 4. Build RAG Agent
Create `scripts/comparison_ingest_rag.py` + `scripts/comparison_rag_agent.py`:
- Standard RAG: embed question → top-5 similarity → assemble context → LLM answers
- Same model (Phi-4 Mini), same token budget (~2K context)

### 5. Build Graph Agent Query Path
Create `scripts/comparison_graph_agent.py`:
- Embed question → nearest node → grow tree (depth=5) → assemble context (2K budget) → LLM answers
- Return answer + full traversal path for audit

### 6. Pre-Register 20 Questions
Create `scenarios/comparison-questions.json`:
- Category A: Factual Recall (5) — answers verbatim in source
- Category B: Single-hop Inference (5) — one inferential step
- Category C: Multi-hop Connection (5) — connecting facts across sources
- Category D: Temporal / Confidence (5) — reasoning about time and reliability

### 7. Run Both Agents
- Run both on all 20 questions
- Record: answer, latency, RAM peak, retrieval path
- Anonymize outputs as "Agent A" / "Agent B" (random assignment)

### 8. Blind Scoring
Prepare scoring sheet for Wisdom:
- Each answer scored on: Correctness (0-3), Connection quality (0-2), Confidence calibration (0-1)
- Graph agent additionally scored on path auditability (0-1)
- Wisdom judges blind — doesn't know which is graph vs RAG

### 9. Analysis
After Wisdom scores, write `results/comparison-analysis.md`:
- Per-category scores for each agent
- Overall scores
- Latency comparison
- Ingestion time comparison
- RAM comparison
- Honest failure cases (where RAG won, where graph won)
- **Recommendation:** which approach (or hybrid) for the prototype

## Output Format

- `scripts/comparison_ingest_graph.py`
- `scripts/comparison_ingest_rag.py`
- `scripts/comparison_graph_agent.py`
- `scripts/comparison_rag_agent.py`
- `scripts/comparison_run.py` — orchestrator
- `scripts/comparison_score.py` — scoring sheet generator
- `scenarios/comparison-questions.json`
- `results/comparison-YYYY-MM-DD.json` — raw results (anonymized)
- `results/comparison-analysis.md` — analysis (after scoring)
- Git commit

## Success Criteria

1. Both agents run on same model, same data, same token budget (fair comparison)
2. All 20 questions answered by both agents
3. Blind scoring completed by Wisdom
4. Honest documentation of where each approach wins and loses
5. Clear recommendation for prototype architecture (graph-only, RAG-only, or hybrid)
