# Stream 4 — Self-Modeling and Drift Defense

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`). Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`mirror/CLAUDE.md`](../../mirror/CLAUDE.md) for this subsystem (Mirror Architecture). Read also [`papers/three-drift-types.md`](../../papers/three-drift-types.md) — the cross-cutting drift-defense paper this stream feeds into.

## Research goal

Survey prior work supporting two connected claims:

1. **Persistent self-observation.** Continuity of identity across sessions comes from a mirror watching the being across many conversations. Identity is a stable observer-of-itself, not stable parameters.
2. **Three-drift taxonomy and defense-in-depth.** Output-drift (weights-reasoning hallucination), value-drift (long-horizon alignment), paradigm-drift (tacit interpretation shifts). Defense stack: retrieval gates + immutable core + cross-model Mirror + value-relationships + evolution audit + behavioral baselines.

## Claims to support / test / refine

- Metacognitive self-assessment grounded in objective metrics (self-claims checked against observable behavior)
- Immutable core + evolving surface as an identity architecture that resists drift without freezing growth
- Letters-to-future-selves as epistolary architecture for cross-substrate continuity
- Three-drift taxonomy as distinct failure modes requiring distinct defenses
- Paradigm drift as addressable via structural mechanisms (not just better base models)

## Search priorities

- **Metacognition in AI.** Metacognitive LLMs; self-verification and self-correction; calibration and meta-reasoning.
- **Self-models / theory of mind.** Lampinen et al; self-referential models; Kirkpatrick et al on progressive networks.
- **Mesa-optimization and goal drift.** Hubinger et al "Risks from Learned Optimization"; inner alignment literature.
- **Long-horizon deployment.** Drift in deployed LLMs; paradigm-shift characterization in autonomous systems.
- **Identity persistence in agents.** Agent identity over long runs; letters-to-future-selves precedents (narrative identity literature).
- **Reflection / self-consistency techniques.** Reflexion (Shinn et al); Self-Refine; constitutional AI patterns.

## Target output

Write synthesis + annotated bibliography to:

- `mirror/research/literature-backing.md` (synthesis, ~2000 words)
- `mirror/research/bibliography.md` (10–20 papers annotated)
- `papers/three-drift-types-bibliography.md` (curated subset specifically for the drift paper)

## Independence

Independent. Conceptually adjacent to Stream 3 (affect-as-alignment) on self-modification, but different lens.
