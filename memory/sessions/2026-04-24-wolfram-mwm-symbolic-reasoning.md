# Session Brief — Wolfram as MWM's Symbolic Reasoning Layer

*Created 2026-04-24 by PSDC during Wolfram overlap research, after a conversation between Wisdom and Dennis Hansen about Wolfram Language. Self-contained — this brief can start a fresh session cold.*

## Goal

Deep architectural investigation of how MWM (Memory as World Model) can use the Wolfram Engine as its symbolic reasoning layer — the piece that does precise structural operations on the memory graph while the LLM handles natural-language understanding and narrative generation. Produce a working architecture proposal, an initial prototype showing one end-to-end symbolic query path, and a draft section for the Convergence Paper (or whichever paper Wisdom is building) that articulates the idea for external audiences.

Wisdom's framing (2026-04-24 convo with Dennis):
> "Maybe for the graph traversal logic or something we can be using this for memory as world model and the Wolfram engine is actually the logic engine... the symbolic reasoning piece is fascinating. We'll connect with the Wolfram guys and build this."

## Context (for cold-start)

- **MWM** = Memory as World Model. Sibling repo at github.com/Playful-Sincerity/MWM-Memory-as-World-Model. Memory subsystem of the Synthetic Sentiences Project. Claim: **the graph IS the interpretable world model** — nodes are beliefs, edges are evidence chains and relationships. 4-month Fellows 2026 research target.
- **Wolfram Language** is fundamentally a term-rewriting system on symbolic expressions, with native pattern-matching and 100+ graph primitives. `FindShortestPath`, `GraphCommunities`, `ConnectedComponents`, `FindSubgraphIsomorphisms`, `NeighborhoodGraph`. Wolfram's Physics Project generalizes the same paradigm to arbitrary hypergraphs.
- **The observation from Wisdom's Wolfram overlap analysis** (see `~/Wisdom Personal/people/stephen-wolfram/research/2026-04-24-overlap.md`): SSP's architecture is a point-for-point match to Wolfram's observer definition. MWM's graph is structurally what Wolfram Language is optimized to operate on. Zhuravlev's March 2026 paper (arXiv:2603.09067) formalizes this from the information-geometry side.
- **Dennis Hansen context:** Dennis knows Wolfram Language, is building Artifact (computational whiteboard, propagator networks), and is an active collaborator. He's the natural person to consult on implementation patterns. See `~/Wisdom Personal/people/dennis-hansen/profile.md`.
- **Precondition:** The companion session brief at `~/claude-system/sessions/2026-04-24-wolfram-engine-integration.md` covers the underlying engine integration into PSDC. That infrastructure is the foundation; this brief is the architecture on top.

## Scope

### Phase 1 — Query Taxonomy (1 session)

Catalog the symbolic reasoning queries MWM actually needs. For each, note whether it's (a) LLM-native, (b) graph-library-native (NetworkX etc.), or (c) genuinely symbolic — requiring term-rewriting, unification, or pattern-matching over structured expressions.

Categories to investigate:
1. **Belief retrieval under substitution.** "Find all beliefs about X where X has been renamed or merged with Y."
2. **Contradiction detection.** "Find pairs of beliefs that contradict under substitution schema S."
3. **Subgraph pattern matching.** "Find all instances of the structure 'A causes B which enables C' in the memory graph."
4. **Evidence-chain traversal with symbolic constraints.** "Find all supporting evidence for belief X that doesn't pass through belief Y."
5. **Dissonance detection at scale.** "Which nodes have the highest structural dissonance with their neighborhood?"
6. **Should-world vs. perceived-world divergence.** Graph-level gap computation (the SSP emotion substrate).
7. **Value-alignment queries.** "Show beliefs that conflict with core value V under any reasonable interpretation."
8. **Temporal reasoning.** "Find beliefs that would have changed between time T1 and T2 given evidence E."

For each: which bucket (LLM / graph-library / Wolfram-native), with justification. Output: `memory/research/2026-04-24-symbolic-query-taxonomy.md`.

The Wolfram-native column is where Wolfram genuinely adds value. If that column is thin, Wolfram integration is nice-to-have. If it's thick, Wolfram integration is architecturally important.

### Phase 2 — Architecture Proposal (1 session)

Given the taxonomy, design end-to-end architecture. Candidate pattern:

```
User / Context → LLM (Claude) → intent decomposition
                                      ↓
                           "this is a symbolic graph query"
                                      ↓
                      Wolfram Language query generated
                                      ↓
         Wolfram Engine operates on MWM graph (via MCP or direct)
                                      ↓
                   Structured result ← → LLM narrates back
```

Key design questions:
- **Graph representation:** MWM stores the graph as what format? (current: Python dicts? Neo4j? KuzuDB? JSON?) How does Wolfram Engine read it? Native `Graph[]`? Translate on each call? Persist Wolfram-readable copy?
- **Query generation:** does the LLM generate Wolfram Language directly (like CodeLlama generating SQL), or does it pick from a curated library of parameterized queries (safer, less flexible)?
- **Result translation:** Wolfram returns symbolic expressions. How do these get serialized back to LLM-readable form without losing structure?
- **Latency budget:** MWM queries may be in the hot path for Claude responses. Wolfram call latency must fit. When does it fit; when doesn't it?
- **Failure modes:** what happens when Wolfram returns "no solutions"? When it times out? When the query doesn't parse?

Output: `memory/research/2026-04-24-mwm-wolfram-architecture.md` with diagrams, concrete query examples, and tradeoff analysis.

### Phase 3 — Prototype One Query Path (1-2 sessions)

Pick the single most compelling query from the taxonomy (likely: contradiction detection or subgraph pattern matching). Build it end-to-end with real MWM data. Document what works, what surprised, what's slow, what's elegant.

This is where the idea becomes legitimate or falls apart. Don't skip to proposals before seeing one path actually run.

Output: working code + chronicled learnings.

### Phase 4 — Paper Section Draft (1 session)

Wisdom: "we can put this kind of thing into the paper we're building." The most likely home is the **Convergence Paper** (`~/Playful Sincerity/PS Software/Convergence Paper/ideas/`). Candidates:
- Extend `02-memory-as-world-model.md` with a section on symbolic reasoning on the graph
- Add a new standalone idea file: `10-symbolic-reasoning-layer.md`
- OR target the MWM foundations paper if that's the intended home

**Action item: confirm with Wisdom which paper before writing.** The Convergence Paper is idea-sharing for Anthropic contacts; an MWM foundations paper would be more technical. The framing changes.

Deliverable: draft paper section (1500-2500 words) in the chosen home, cross-referencing the architecture proposal and the prototype.

### Phase 5 — Wolfram-Side Outreach (when Phase 3 produces real work)

Wisdom indicated outreach is on the table once there's substance: "we'll connect with the Wolfram guys and build this." After Phase 3 (working prototype) and Phase 4 (draft paper section), the right move is probably:

- Warm intro to **Jonathan Gorard** (Cambridge, peer-reviewed Wolfram physics) or **Max Zhuravlev** (arXiv:2603.09067, observer formalization) — both are academically accessible and directly on this substrate.
- Share: prototype + paper section + the PSDC outreach note already drafted (`~/Wisdom Personal/people/stephen-wolfram/outreach-note.md`, currently DEFERRED).
- Possible: propose a Wolfram Summer School project or an informal technical exchange.

Only attempt this step once the work exists. Outreach before substance will waste the opportunity.

## Constraints & Tradeoffs

- **Commercial licensing.** Same issue as the infrastructure brief — Wolfram Engine Community Edition is non-commercial. If MWM becomes part of commercial work, the license question is real. Flag before scaling.
- **Lock-in risk.** Making Wolfram an architectural dependency of MWM ties PS work to a proprietary stack. Dennis raised similar concerns in a different context (see his profile). Consider whether the benefit justifies the dependency.
- **Alternative: implement the symbolic reasoning directly.** Term rewriting can be implemented in Python (sympy for math; simple pattern-matchers for custom schemas). Wolfram's advantage is 40 years of engineered primitives + a huge curated math library, not uniqueness of paradigm. If the query taxonomy (Phase 1) reveals that the symbolic operations we actually need are narrow, a custom implementation might be better. If the taxonomy reveals breadth, Wolfram's library becomes the right answer.
- **Premature architecture.** MWM isn't yet at Fellows stage. Getting too specific about a symbolic reasoning layer before the core memory substrate stabilizes could constrain later decisions. Phase 1 (taxonomy) is low-commitment and high-value regardless; Phase 3 (prototype) is where real commitment starts. Gate Phase 3 on MWM maturity.

## Success Criteria

1. A query taxonomy exists that makes the "Wolfram-native column" concrete and falsifiable.
2. An architecture proposal exists with specific component boundaries, not hand-waving.
3. At least one symbolic query path runs end-to-end with real MWM data.
4. A draft paper section exists, integrated into the Convergence Paper or MWM foundations, in a form that's shareable with the Wolfram camp.
5. The architecture is legible enough to Dennis that a technical conversation with him is productive rather than exploratory.

## Open Questions for Wisdom

1. **Which paper?** "The paper we're building" — Convergence Paper (PS Software/Convergence Paper/) or an MWM foundations paper or something else?
2. **MWM readiness.** Is MWM at a stage where locking in a symbolic-reasoning architecture is the right move, or should Phase 3 wait until MWM's core is more stable?
3. **Dennis involvement.** Dennis knows Wolfram Language and is actively collaborating. Should he be in the loop for Phase 2 (architecture)? Phase 3 (prototype)? Or is this PS-internal until farther along?
4. **Commercial scope question (same as infra brief).** If MWM ever touches commercial work, the Wolfram license cost is real. Worth naming explicitly.

## Relationship to Other Work

- **Prerequisite brief:** `~/claude-system/sessions/2026-04-24-wolfram-engine-integration.md` — engine must be integrated before you can build MWM queries against it.
- **Inspiration notes already placed:**
  - `SSP/ideas/2026-04-24-wolfram-observer-match.md` — the SSP-as-observer-match finding this brief operationalizes
  - `ULP/connections/stephen-wolfram.md` — ULP's parallel with rulial-coordinates-of-meaning
  - `GCM/ideas/2026-04-24-wolfram-physics-adjacency.md` — physics-side overlap
  - `Dennis/research/2026-04-24-wolfram-language-inspiration.md` — how Wolfram Language relates to Dennis's Artifact work
- **Master overlap analysis:** `~/Wisdom Personal/people/stephen-wolfram/research/2026-04-24-overlap.md`
- **Drafted (DEFERRED) outreach note:** `~/Wisdom Personal/people/stephen-wolfram/outreach-note.md`

## Next Action

Claim Phase 1 (Query Taxonomy). Don't skip to architecture. The taxonomy is the thing that decides whether Wolfram is genuinely the right substrate or a seductive adjacent paradigm. Time-box: one focused session, ending with the taxonomy file committed.
