# Section 8 — Graph vs RAG Comparison

**Complexity:** M
**Risk:** Medium — fair comparison design is genuinely hard
**Dependencies:** Section 2 (Graph Engine)
**Off critical path** — validates the approach before Section 9

---

## Acceptance Criteria

- Documented comparison with clear methodology (reproducible)
- Demonstrates whether graph adds value over vector-only retrieval
- Honest treatment of failure cases
- Recommendation: which approach (or blend) for the prototype

---

## The Core Question

Does building an associative memory graph and traversing it produce better answers than simply embedding source material and doing vector similarity search?

---

## Fairness Principles

**Fixed across both agents:**
- Same local model (Phi-4 Mini 3.8B Q5)
- Same source material (50 Wikipedia articles on programming languages)
- Same question set (20 questions, pre-registered)
- Same scoring rubric
- Same hardware (M1 Air 8GB)
- Same token budget (~2K tokens of retrieved context)

**The only difference:** retrieval mechanism (graph traversal vs top-K similarity)

---

## Question Set: 20 Questions, 4 Categories

### Category A: Factual Recall (5)
Answers verbatim in source. *Hypothesis: RAG wins or ties.*
- "What year was Python first released?"
- "Who created Haskell?"
- "What does LISP stand for?"
- "In what decade did C become dominant?"
- "Which language introduced garbage collection?"

### Category B: Single-hop Inference (5)
One inferential step. *Hypothesis: comparable.*
- "Why did Smalltalk's message-passing model influence modern languages?"
- "What made ML's type system novel for its time?"
- "How did UNIX's C dependency shape language adoption?"
- "What problem was Prolog designed to solve?"
- "Why did Lisp remain influential despite limited commercial adoption?"

### Category C: Multi-hop Connection (5)
Connecting facts across multiple sources. *Hypothesis: Graph wins.*
- "Trace the lineage from LISP to Python."
- "How did ideas from Smalltalk reach Java?"
- "What features of ML influenced both Haskell and OCaml?"
- "How did Backus's 1977 Turing Award lecture echo in modern languages?"
- "What connects Erlang's concurrency model to Go's goroutines?"

### Category D: Temporal / Confidence (5)
Reasoning about time and reliability. *Hypothesis: Graph wins.*
- "Is Python's popularity likely to continue, and why?"
- "Which language paradigm has had the most lasting influence?"
- "Was Smalltalk's commercial failure inevitable given its design?"
- "How reliable is the claim that C++ was designed by Stroustrup alone?"
- "Has the importance of static typing changed over time?"

---

## Scoring Rubric

Each answer scored blind by Wisdom:

| Dimension | Scale | Meaning |
|---|---|---|
| Correctness | 0-3 | 0=wrong, 1=partial, 2=mostly correct, 3=fully correct |
| Connection quality | 0-2 | 0=none, 1=one useful connection, 2=multiple illuminating connections |
| Confidence calibration | 0-1 | 0=miscalibrated, 1=appropriately hedged |

**Max per question:** 6. **Max total:** 120.

Graph Agent additionally scored on **path auditability** (0-1): can you trace which nodes/edges produced this answer?

---

## Agent Implementations

### Graph Agent
1. Find entry node (embed question → nearest node by vector similarity)
2. Grow tree from entry (spreading activation, depth=5)
3. Assemble context from rendered nodes (within 2K token budget)
4. LLM answers given context + traversal path
5. Return answer + full path for audit

### RAG Agent
1. Embed question
2. Top-5 similarity search over FAISS index (~400 tokens each = ~2K total)
3. Assemble context from top-5 chunks
4. Same LLM answers given context
5. Return answer + retrieved chunks

---

## Evaluation Protocol

1. Ingest source material into both agents (timed)
2. Run both agents on all 20 questions, record answers + latency
3. Anonymize answers (random "Agent A" / "Agent B" labels)
4. Wisdom judges all 40 answers blind
5. Reveal labels, compile scores by agent and category
6. Run path audit on Graph Agent answers
7. Document honest failure cases

---

## Additional Metrics

| Metric | Record for both |
|---|---|
| Ingestion time | Graph build time vs chunking+embedding time |
| Per-question latency | Traversal time vs similarity search time |
| RAM peak during query | — |
| Update cost (new info) | Add nodes/edges vs re-embed chunks |

---

## Expected Findings

- **Graph wins:** Categories C (multi-hop) and D (temporal)
- **RAG wins or ties:** Category A (factual recall)
- **Comparable:** Category B (single-hop)
- **Graph wins:** Interpretability (path audit)

If this pattern holds → **hybrid architecture for the prototype**: RAG for grounding, graph for connections and temporal reasoning.

---

## Honest Failure Cases to Document

1. **Verbatim lookup:** If RAG wins on factual recall, say so
2. **Ingestion quality:** Graph is only as good as the ingestion LLM's node creation
3. **Coverage:** RAG sees all source text; graph may drop facts during ingestion
4. **Speed:** Graph ingestion takes much longer than RAG chunking

---

## Deliverables

1. `benchmarks/comparison_ingest_graph.py`
2. `benchmarks/comparison_ingest_rag.py`
3. `benchmarks/comparison_run.py`
4. `benchmarks/comparison_score.py`
5. `results/comparison_YYYYMMDD.json`
6. `results/comparison_analysis.md`

## Structured Contract

- **External dependencies:** Graph Engine (S2), Ollama (S1), FAISS or numpy for RAG
- **Interfaces exposed:** Comparison results, recommendation for prototype architecture
- **Technology commitments:** FAISS (in-memory, minimal RAM), sentence-transformers/all-MiniLM-L6-v2

## Key Decisions

- **Programming languages as domain:** Rich connections, clear ground truth, bounded, available source material. Breaks if: domain too specialized to generalize.
- **Blind scoring:** Essential for validity. Breaks if: Wisdom can tell which agent is which from answer style (mitigate: use identical system prompts).
- **Same token budget (2K):** Forces fair context comparison. Breaks if: graph needs more context to show its advantage (but that would be a real finding too).
