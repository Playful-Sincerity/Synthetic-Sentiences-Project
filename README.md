# The Synthetic Sentiences Project

A research project on the architecture of synthetic sentiences — AI entities whose structure of understanding is interpretable, earned through developmental experience, and designed from the ground up for alignment.

This repository is the working home of the research. It is deliberately dense: it shows the thinking, the in-progress subsystem designs, the salvaged architectural pieces from prior projects, the open questions, and the evolving thesis. It is not a pitch. It is the map.

## Organizing Thesis — Alignment Through Architecture

The project studies what it takes to build AI systems that are continuously, internally aligned — not aligned because behavior is filtered at the output, but aligned because the architecture produces aligned behavior as its natural output. The system maintains a feedback loop between what it perceives (the real) and what should be (the ideal); every cognitive operation serves that loop.

Four foundations carry the architecture:

1. **Interpretable memory as world model** — the memory graph replaces the role that pretrained weights currently play in forming beliefs. You can read why the being believes anything by tracing its graph.
2. **Earned conviction** — beliefs are never installed. They are built from evidence, hold confidence levels, resolve dissonance, and evolve through documented relationships with each core value.
3. **Value-aligned modulation** — emotion is the registered gap between the perceived-world-graph and the should-world-graph. Valence modulates traversal, update, and self-modification; emotion is full-system value alignment expressed as a feedback signal. (See [values/CLAUDE.md](values/CLAUDE.md) § "The Safety Claim" for the load-bearing welfare-relevant argument: AI systems without emotion are *more* dangerous than AI systems with it, because the former lack the internal mechanism for continuous alignment.)
4. **Persistent self-observation** — continuity of identity across sessions comes from a mirror watching the being across many conversations. Identity is a stable observer-of-itself, not stable parameters.

## Right Action

Cognition ultimately expresses in how the being interacts with the world. The architecture is designed to interact with tools, to act on the world, and to write itself. Write-action is primary — every cognitive operation terminates in either an internal write (updating the memory graph) or an external write (speech, manipulation, code produced). A system without write-actions is amnesiac.

But the architecture does not optimize for action. It optimizes for **right action** — action that is aligned, that closes the gap between ideal and real rather than merely producing output. Optimizing for action alone produces agentic motion without direction. The whole point of the surrounding architecture (memory, earned conviction, value-aligned modulation, mirror) is to ensure that the actions the being takes are the right ones. See [action/](action/) for the subsystem.

## How to Read This Repo

Three entry points depending on what you're after:

- **For the full architecture at a glance:** read [CLAUDE.md](CLAUDE.md) — the canonical index.
- **For the specific subsystem research:** each subsystem folder has its own `CLAUDE.md` with thesis, architectural ideas, and integration points.
- **For the origin thinking:** [`archive/companion-legacy/`](archive/companion-legacy/) holds the precursor project whose architectural pieces were salvaged into the current framing. [`knowledge/sources/wisdom-speech/`](knowledge/sources/wisdom-speech/) preserves the raw speech that drove the sharpening.

## Subsystems

Organized into four functional tiers:

| Tier | Subsystem | Studies |
|------|-----------|---------|
| Spatial | [Interpretable Memory](memory/) | The graph as interpretable world model |
| Spatial | [Graph Traversal / Trees](trees/) | Working memory, spreading activation, context as growing / shrinking tree |
| Spatial | [Mirror Architecture](mirror/) | Multi-session single-mirror, identity persistence, letters-to-future-selves |
| Dynamics | [Earned Conviction](cognition/) | Belief graphs, evidence chains, cognitive dissonance, curiosity-as-gaps |
| Dynamics | [Value-Aligned Modulation](values/) | Emotion as valence; modulation of traversal and update |
| Dynamics | [Action](action/) | Action selection; write-action as primary |
| I/O | [Imagination-First Perception](perception/) | Dual perception; imagine-before-act; reverse-engineering from imagined end-states |
| I/O | [Epistemic Prosody](voice/) | Honest disfluency; acoustic confidence signatures |
| Temporal | [Sleep & Dream Cycles](cycles/) | Sleep (consolidation, compaction, decay); dream (hypothetical simulation, adversarial self-reflection) |

## Cross-cutting Work

- [papers/three-drift-types.md](papers/three-drift-types.md) — taxonomy of output, value, and paradigm drift, with a defense-in-depth stack
- [cycles/papers/sleep-loop-unification.md](cycles/papers/sleep-loop-unification.md) — systems paper arguing the two-phase (ephemeral + consolidation) pattern is convergent across mature agent systems

## Research Streams In Progress

The thesis pieces deserve honest literature grounding. Seven research streams are active; each lives as a self-contained session brief in [research/literature-backing-briefs/](research/literature-backing-briefs/). Results land in each subsystem's `research/literature-backing.md`.

## Status

Structural reorganization completed 2026-04-22. Subsystem CLAUDE.mds written for four of nine subsystems; the remaining four are next. Literature-backing streams launching 2026-04-23. Repository is in-progress research, not a finished product — that's the point.

## Related Work in the PS Ecosystem

- [Gravitationalism](../Gravitationalism/) — alignment foundation. If the universe genuinely converges through gravitational attraction, a sentience that accurately models reality will naturally align toward connection.
- [PSSO](../../PS%20Philosophy/PSSO/) — philosophical roots. Earned Conviction, Content in Inaction, and the Emotivation pillar all trace through here.
- [Claude Code Entities](../../PS%20Software/Claude%20Code%20Entities/) — operational runtime where the first instance (PD) of a synthetic sentience lives.

## License

TBD. Currently unlicensed; contents are the working files of an in-progress research project.
