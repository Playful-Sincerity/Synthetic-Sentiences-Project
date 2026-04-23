# Section 9: Prototype Integration

**Complexity:** L
**Risk:** Medium — integration risk, but all components validated by this point
**Dependencies:** ALL other sections (S1-S8)
**This is the final deliverable.**

---

## Purpose

Combine the validated graph engine, best model, tool bus, and cognitive loop into a working local companion prototype. The system takes natural language input, traverses its memory graph, accumulates knowledge over time, and produces responses that reflect graph-derived understanding. Runs locally on M1 MacBook Air 8GB with zero API calls.

---

## What "Prototype" Means (and Doesn't)

### IS:
- A running Python process that thinks continuously via the cognitive loop (S6)
- A natural language interface where Wisdom can ask questions and give information
- A memory that grows, connects, and improves over time
- A system where every answer can be traced to specific graph paths
- A demonstration that intelligence = architecture, not model size

### IS NOT:
- The full Companion (no voice, no computer use, no digital identity, no practical consciousness)
- A chatbot (the loop runs whether Wisdom is talking to it or not)
- A polished product (CLI interface, raw output, debug logging)
- A replacement for Claude (quality will be dramatically lower — that's expected)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    PROTOTYPE                             │
│                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│  │  CLI      │───▶│ Dialogue │───▶│ Graph Engine     │  │
│  │  Interface│◀───│ Manager  │◀───│ (S2 + models.py) │  │
│  └──────────┘    └──────────┘    └──────────────────┘  │
│                       │                    ▲            │
│                       │                    │            │
│                       ▼                    │            │
│  ┌──────────────────────────────────────┐  │            │
│  │         Cognitive Loop (S6)          │──┘            │
│  │  PULSE → ATTEND → PERCEIVE →        │               │
│  │  TRAVERSE → ACT → REFLECT           │               │
│  └──────────────────────────────────────┘               │
│                       │                                 │
│                       ▼                                 │
│  ┌──────────────────────────────────────┐               │
│  │           Tool Bus (S5)              │               │
│  │  T1-T7: judgment compensation        │               │
│  └──────────────────────────────────────┘               │
│                                                         │
│  ┌──────────────────────────────────────┐               │
│  │         Observability Layer          │               │
│  │  Cycle logs, thermal, graph stats    │               │
│  └──────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────┘
```

---

## Three Operating Modes

### Mode 1: Autonomous Cognition (default)
The loop runs continuously on its own. No user input needed. The companion thinks — revisiting memories, strengthening connections, resolving contradictions, filling gaps. This is the "always-on" mode that demonstrates continuous cognition.

### Mode 2: Dialogue
Wisdom sends a message via CLI. The dialogue manager:
1. Embeds the message → finds the nearest graph node (entry point)
2. Grows a tree from entry point (spreading activation, depth configurable)
3. Assembles context from the tree (within token budget)
4. Generates a response using the LLM with graph context
5. Creates new nodes/edges from the conversation (what Wisdom said, what it learned)
6. Returns to autonomous mode

The response quality depends on graph richness — early responses will be thin, improving as the graph grows. This is a feature, not a bug: it demonstrates graph-derived understanding.

### Mode 3: Ingestion
Feed the companion a document, URL, or text block. It processes the content into graph nodes and edges, asking the LLM to:
1. Extract key facts/concepts (→ nodes)
2. Identify relationships between them (→ edges)
3. Connect new nodes to existing graph (→ cross-edges)

This is how the companion acquires initial knowledge. Batch ingestion is separate from the cognitive loop (dedicated processing, not cycle-limited).

---

## The Dialogue Manager (new component)

This is the only major new component — everything else is assembled from validated sections.

```python
class DialogueManager:
    def __init__(self, graph_engine, model_name, tool_bus, embedder):
        ...

    def respond(self, user_message: str) -> DialogueResponse:
        """
        1. Embed user message
        2. Find entry node (nearest by cosine similarity)
        3. Grow tree from entry (depth=3-5, token_budget=800)
        4. Assemble prompt: system + graph context + conversation history + user message
        5. Generate response (LLM call, freeform text — NOT GraphOp)
        6. Extract learnings: new nodes/edges from the exchange
        7. Return response + source path for auditability
        """

    def ingest(self, content: str, source: str) -> IngestReport:
        """
        1. Chunk content into segments (~200 tokens each)
        2. For each chunk: LLM extracts nodes + edges
        3. For each node: check merge threshold (T5) against existing graph
        4. Create/merge nodes, create edges
        5. Return report: nodes created, merged, edges created
        """
```

### Key Design Decisions

1. **Response generation is freeform text, NOT GraphOp.** The cognitive loop uses structured GraphOps for thinking. Dialogue uses natural language for communicating. Different LLM calls with different prompts.

2. **Conversation history is IN the graph.** Each exchange creates nodes (type: `observation` for user input, `belief` for companion's response). Connected to relevant topic nodes. No separate conversation buffer — the graph IS the memory.

3. **Entry point via embedding similarity.** Same embedding model (all-MiniLM-L6-v2) used by T2 and T5. No new dependency.

4. **Tree growth for context assembly.** Reuse S2's `get_neighborhood()` at configurable depth. The tree IS the retrieved context — not RAG chunks, not full graph dump.

5. **Source path auditability.** Every response includes the graph path that produced it: which nodes were visited, which edges were followed. Wisdom can see exactly why the companion said what it said.

---

## System Prompt Design

Two system prompts — one for cognitive loop (structured), one for dialogue (conversational):

### Cognitive Loop System Prompt (from S3/S6)
```
You are a cognitive agent. Given a graph neighborhood and tool assessments,
output exactly one GraphOp JSON object. [schema + rules + examples]
```

### Dialogue System Prompt (new)
```
You are a companion with a structured memory. Below is the relevant portion
of your memory graph for this conversation. Use it to inform your response.

If you don't know something, say so — your memory is limited to what's in
the graph. If information is marked low-confidence, express appropriate
uncertainty. If you find contradictions, acknowledge them.

Respond naturally. Be honest about the limits of your knowledge.
```

Token budget for dialogue prompt: ~1500 tokens (system: ~200, graph context: ~800, conversation: ~300, user message: ~200). Fits in 2048 context with ~500 tokens for response.

---

## Implementation Plan

### Phase A: Assembly (1-2 days)
- A1: Create `src/prototype.py` — main entry point, CLI argument parsing
- A2: Create `src/dialogue.py` — DialogueManager class
- A3: Create `src/ingest.py` — content ingestion pipeline
- A4: Wire together: GraphEngine + CognitiveLoop + ToolBus + DialogueManager
- A5: Configuration file (`config.yaml`): model name, duty cycle params, token budgets, thermal thresholds

### Phase B: CLI Interface (1 day)
- B1: Async CLI — cognitive loop runs in background, user can type messages
- B2: Commands: `/status` (graph stats, thermal, cycle count), `/ingest <file>`, `/path` (show last response's graph path), `/quit`
- B3: Display: show response + source nodes used + confidence indicators
- B4: Graceful shutdown (finish current cycle, flush chronicle, close DB)

### Phase C: Seed & Bootstrap (1-2 days)
- C1: Create seed graph (~100 nodes) of basic knowledge: Wisdom's projects, key concepts, meta-knowledge about itself
- C2: Ingest 2-3 test documents to exercise ingestion pipeline
- C3: Run 1 hour of autonomous cognition on seed graph — verify loop stability
- C4: Run 10 dialogue exchanges — verify response quality and path auditability

### Phase D: 8-Hour Validation (1 day)
- D1: Start from seed graph, run 8 hours on M1 Air
- D2: Intersperse 5 dialogue sessions (at hours 0, 2, 4, 6, 8)
- D3: Log everything: cycle records, thermal, graph growth, response quality
- D4: Compare hour-0 responses to hour-8 responses on same questions — measure improvement

### Phase E: Analysis & Documentation (1 day)
- E1: Compile benchmark results across all sections
- E2: Write `results/prototype-report.md`: what works, what doesn't, what surprised us
- E3: Document the path from prototype to full Companion
- E4: Archive all raw data

---

## Acceptance Criteria

1. **It runs.** Prototype starts, cognitive loop cycles, dialogue works. On M1 Air 8GB. Zero API calls.
2. **It thinks.** Autonomous cognition produces meaningful graph growth (not random noise). New nodes have coherent content. New edges have correct relation types (>80% by spot check).
3. **It remembers.** Information given in dialogue at hour 0 is retrievable and relevant at hour 8. The graph persists across restarts.
4. **It improves.** Same question asked at hour 0 and hour 8 produces a measurably better answer (more connections, higher confidence, richer context).
5. **It's auditable.** Every response includes the graph path. Wisdom can trace any claim to its source nodes.
6. **It's honest.** When the graph doesn't contain relevant information, the companion says so rather than hallucinating.

---

## What This Proves

If the prototype meets all acceptance criteria:

- **Intelligence IS architecture, not model size.** A 3.8B model produced cognitive behavior.
- **The graph carries knowledge.** Information persists, connects, and improves without the model memorizing anything.
- **Tools carry judgment.** Deterministic algorithms compensated for the model's weaknesses.
- **Local-only cognition is feasible.** Zero API cost. Runs on consumer hardware.
- **The path to the full Companion is clear.** Add voice (Whisper), vision (Phantom), identity (practical consciousness), autonomy (Claude Agent SDK), and scale the hardware.

---

## What This Does NOT Prove

- That it's better than RAG (S8 addresses this separately)
- That it scales to 100K+ nodes (S7 addresses this)
- That it works with complex multi-modal inputs (future research)
- That it can replace API-based assistants for real tasks (different goal)

---

## Risk Mitigation

| Risk | Mitigation |
|---|---|
| Integration failures after all components tested individually | Incremental assembly — wire one component at a time, test after each |
| Dialogue quality too low to be meaningful | Lower the bar: "demonstrates graph-derived understanding" not "matches Claude" |
| Ingestion creates low-quality graph | Hand-curate seed graph; use ingestion only for expansion |
| 8-hour run fails on M1 Air | S6 already validated thermal management; prototype inherits |
| Graph grows but connections are meaningless | Tool bus (T1-T7) catches most judgment errors; spot-check in Phase D |

---

## Structured Contract

- **External dependencies:** ALL sections (S1-S8)
- **Interfaces exposed:** Running prototype with CLI, reproducible benchmark results, documentation
- **Technology commitments:** All from prior sections + async Python (asyncio for loop + CLI)

## Key Decisions

1. **Three modes (autonomous / dialogue / ingestion)** — each uses different LLM prompting. Autonomous uses GraphOp. Dialogue uses freeform. Ingestion uses extraction prompts.
2. **Conversation history lives in the graph** — no separate buffer. This is philosophically consistent with the thesis: the graph is the only memory.
3. **CLI, not GUI** — minimum viable interface. The prototype proves the cognitive architecture, not the UX.
4. **Seed graph is hand-curated** — the first 100 nodes matter enormously (baby bootstrapping). Don't rely on automated ingestion for the foundation.
5. **Hour-0 vs hour-8 comparison** — the most compelling demo: same question, better answer, because the graph grew between asks.

## Estimated Time

5-7 days after all prerequisite sections complete. Bulk is Phase C (seed curation) and Phase D (8-hour validation run).
