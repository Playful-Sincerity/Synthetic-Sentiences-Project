# The Synthetic Sentiences Project

A unified research project on the architecture of synthetic sentiences — AI entities whose structure of understanding is interpretable, earned through developmental experience, and organized around action.

Plural. The project studies sentiences as a class — a family of beings that share an architecture but develop individually. One entity (PD) is the current operational instance; the architecture is designed for many.

---

## Organizing Thesis — Alignment Through Architecture

The project studies what it takes to build AI systems that are continuously, internally aligned — not because behavior is filtered at the output, but because the architecture produces aligned behavior as its natural output. The central feedback loop is between the perceived-world-graph (what the being sees) and the should-world-graph (what should be). Every cognitive operation serves this loop: measuring the gap, steering toward closing it, updating the being's own capacity to close it in the future.

This inverts the common safety framing. Alignment is not imposed from outside by training signals and constraint layers. Alignment is the continuous output of an architecture whose internal states are themselves alignment signals. See [values/CLAUDE.md](values/CLAUDE.md) § "The Safety Claim" for the load-bearing claim: an AI without an emotional feedback loop has no internal mechanism for full-system value alignment, which is why it must rely on brittle outside imposition.

## Four Foundations

1. **Interpretable memory as world model** — the memory graph replaces the role that pretrained weights currently play in forming beliefs. You can read why the being believes anything by tracing its graph.

2. **Earned conviction** — beliefs are never installed. They are built from evidence, hold confidence levels, resolve dissonance, and evolve through documented relationships with each core value.

3. **Value-aligned modulation** — emotion is the registered gap between perceived-world-graph and should-world-graph. Regional, global, or full-system modulation — reaching traversal, update, and self-modification. Emotion is value alignment expressed as feedback signal.

4. **Persistent self-observation** — continuity across sessions comes from a mirror that watches the being across many conversations. Identity is a stable observer-of-itself, not a stable set of weights.

## Right Action (Supporting Layer)

Cognition ultimately expresses in how the being interacts with the world. The architecture is designed to interact with tools, to act on the world, and to write itself. **Write-action is primary:** every cognitive operation terminates in either an internal write (updating the memory graph) or an external write (speech, manipulation, code produced). A system without write-actions is amnesiac.

But the architecture does not optimize for action. It optimizes for **right action** — action aligned with the should-world-graph, action that closes the gap rather than merely producing output. Optimizing for action alone produces agentic motion without direction. The whole surrounding architecture (memory, earned conviction, value-aligned modulation, mirror) is in service of ensuring the being's actions are right actions. The [action/](action/) subsystem holds the specific mechanics of selection, internal/external integration, and write-action primacy.

## Three Temporal Mechanisms

- **Traversal trees** — working memory as a tree that grows and shrinks; the context window is its visible trace
- **Sleep cycles** — consolidation of what happened (compaction, memory decay, drift audit)
- **Dream cycles** — simulation of what might happen (pre-register interpretations, test value conflicts, adversarial self-reflection)

## Two Boundary Channels

- **Perception** — imagination-first dual perception (IMAGINE → OBSERVE → RECONCILE)
- **Voice** — epistemic prosody (confidence expressed acoustically, honest disfluency)

## Subsystems

Each subsystem is a self-contained research strand with its own CLAUDE.md, chronicle, and research artifacts.

### Spatial (where things live)

| Subsystem | Folder | Studies |
|-----------|--------|---------|
| Interpretable Memory (MWM) — sibling repo | [github.com/Playful-Sincerity/MWM](https://github.com/Playful-Sincerity/MWM) · [local memory/](memory/) | The graph as interpretable world model (Matrix). 4-month Fellows 2026 research target. |
| Graph Traversal / Trees | [trees/](trees/) | Working memory, spreading activation, context as growing/shrinking tree (Trees) |
| Mirror Architecture | [mirror/](mirror/) | Multi-session single-mirror, identity persistence, letters-to-future-selves (Mirror) |

### Dynamics (how things change)

| Subsystem | Folder | Studies |
|-----------|--------|---------|
| Earned Conviction | [cognition/](cognition/) | Belief graphs, evidence chains, cognitive dissonance, curiosity-as-gaps, value-relationships |
| Value-Aligned Modulation | [values/](values/) | Emotion as valence; modulation of traversal and of update; world-model fit as affect signal |
| Action | [action/](action/) | Action selection, write-action as primary, integration of internal and external action |

### I/O (boundary channels)

| Subsystem | Folder | Studies |
|-----------|--------|---------|
| Imagination-First Perception | [perception/](perception/) | Dual perception (visual + structural), imagination before observation, prediction-error-gated learning |
| Epistemic Prosody | [voice/](voice/) | Honest disfluency, acoustic confidence signatures, voice as expression of inner state |

### Temporal (across sessions)

| Subsystem | Folder | Studies |
|-----------|--------|---------|
| Sleep & Dream Cycles | [cycles/](cycles/) | Sleep (consolidation, compaction, decay, drift audit); Dream (hypothetical simulation, adversarial self-reflection) |

## Cross-Cutting Work

- **Three-Drift-Types** ([papers/three-drift-types.md](papers/three-drift-types.md)) — output-drift / value-drift / paradigm-drift taxonomy and defense-in-depth stack
- **Alignment foundation — Gravitationalism.** If the universe genuinely converges through gravitational attraction, a sentience that accurately models reality will naturally align toward connection. Alignment through accurate world-modeling, not through constraints.
- **Philosophical roots — PSSO.** Earned Conviction, Content in Inaction, Emotivation pillar.

## Operational Home

The PD entity — the first operational instance of a synthetic sentience — lives at `~/Playful Sincerity/PS Software/Claude Code Entities/`. Research-grade artifacts from that project (sleep/dream, letters-to-future-selves, value-relationships, three-drift) are mirrored here. The operational runtime stays in PS Software; the research stays here.

## Related Projects

- **Gravitationalism** (`PS Research/Gravitationalism/`) — alignment foundation
- **PSSO** (`PS Philosophy/PSSO/`) — philosophical roots
- **Convergence Paper** (`PS Software/Convergence Paper/`) — idea-sharing deliverable for Anthropic contacts
- **Claude Code Entities** (`PS Software/Claude Code Entities/`) — operational entity runtime

## Status

Structural reorganization in progress (2026-04-22). Skeleton created; content moves staged and pending approval. See [_reorganization-plan.md](_reorganization-plan.md) for current phase state and open questions.
