# Stream 1 — Memory as World Model

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`) studies an architecture for AI entities whose structure of understanding is interpretable, earned, and organized around action. Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`memory/CLAUDE.md`](../../memory/CLAUDE.md) for this subsystem's current framing.

The memory subsystem is the project's load-bearing research claim. Its working-name acronym is **MWM — Memory (as) World Model** (locked tentatively pending collision re-check).

## Research goal

Survey the literature that supports, extends, or challenges the central architectural claim: **the interpretable memory graph replaces the role that pretrained weights currently play in forming beliefs.** In this framing the LLM becomes a traversal and reading engine; beliefs are explicit nodes with confidence, evidence, sources, and timestamps; the graph is the mind, the LLM is the voice, a separate reasoning tool handles logic.

Where is this idea already in the literature? Where has it been attempted and fallen short? Where is it genuinely novel?

## Claims to support / test / refine

- The graph IS the interpretable world model (not a retrieval database with interpretability layered on)
- LLM as traversal engine — language and reasoning are *outputs*, not stores
- Belief nodes with explicit evidence chains and confidence (navigable-by-design interpretability)
- Anti-hallucination is a consequence of architecture, not a fine-tuning target
- "Graph is the mind" generalizes across domains (not robotics-specific, not RAG-specific)

## Search priorities

- **Neurosymbolic memory.** Surveys from 2023–2026; specific systems (MemGPT, Letta, Mem0, MAGMA, MIRA-Feb-2026, Memoria).
- **Cognitive architectures.** ACT-R, Soar, CLARION — how do they separate knowledge from inference?
- **World models in agents.** Ha & Schmidhuber lineage; DeepMind's Dreamer V1/V2/V3; Meta FAIR IWM; "General agents contain world models" (arXiv:2506.01622).
- **Interpretability-by-design vs post-hoc.** Mech interp (Anthropic + Olah lineage) as the foil — forensic vs architectural interpretability.
- **Graph-based agent memory 2026 state.** Multiple 2026 surveys just surfaced ("State of AI Agent Memory 2026", "Memory in the Age of AI Agents: A Survey").

## Target output

Write synthesis + annotated bibliography to:

- `memory/research/literature-backing.md` (synthesis, ~2000 words)
- `memory/research/bibliography.md` (10–20 papers annotated)

## Independence

Independent of all other streams.
