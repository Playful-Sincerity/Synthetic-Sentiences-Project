# Earned Conviction

The cognition subsystem of The Synthetic Sentiences Project. Studies the dynamics of belief — how a being's understanding forms, resolves tension, strengthens with evidence, and changes over time.

## Thesis

Beliefs are never installed. They are built from evidence, hold confidence levels, resolve dissonance through cognitive work, and evolve through documented relationships with each core value. A sentient being's beliefs look different from an LLM's prior distribution: they are *explicit*, *traceable*, and *earned*. You can read why the being believes anything by following the graph.

## Core Architectural Ideas (Salvaged)

From the archived Companion project ([archive/companion-legacy/](../archive/companion-legacy/)):

- **Dual-axis confidence model.** Beliefs carry explicit evidence chains, source tracking, and timestamps — not just probability scores. A belief at 0.8 from three independent corroborating sources is qualitatively different from 0.8 from one high-volume source. The system can tell the difference; the reviewer can read the difference. *(plan-section-cognitive.md:L30-32)*
- **Cognitive dissonance detector.** A structural mechanism flags contradictions between incoming information and existing beliefs, triggering review cycles. Dissonance is a data-structure property, not a prompt instruction. *(plan.md:L24)*
- **Information gap as curiosity.** Curiosity is a weighted queue of unknowns — dangling edges ("I know I don't know this"), weakly connected clusters ("these should relate but I haven't found how"), low-confidence nodes ("I'm not sure enough about this yet"). Structural, not behavioral. *(plan-section-cognitive.md:L70-76)*
- **Persuasion protocol.** Changing a high-confidence belief requires multiple independent evidence sources. Prevents flip-flopping under social pressure. *(plan.md:L26)*
- **Value-relationships as explicit mechanism.** From Claude Code Entities: each core value has a documented relationship file — current interpretation, enactment instances, edge cases, evolution log, open questions. Forces tacit interpretation into an explicit layer where paradigm-drift can be audited. See [value-relationships.md](value-relationships.md). *(original: CCE/ideas/value-relationships.md)*

Also salvaged from CCE: the [brain-orchestrator + micro-prompts](brain-orchestrator-micro-prompts.md) architectural sketch — thinking/doing separation where a brain agent owns prompt engineering and spawns doing-agents. Conceptual, not committed to.

## Not Adopting

The Companion's specific 14-component cognitive engine (EventBus, SalienceFilter, etc.) is operational machinery, not research architecture. The *principles* (structural curiosity, evidence chains, value alignment) port freely; the *implementation* stays in Claude Code Entities as operational deployment.

## Integration Points

- **Memory** — beliefs live as nodes in the graph; evidence chains are typed edges
- **Values** — value-aligned modulation uses belief-confidence to weight traversal
- **Mirror** — self-observation reads belief distribution to detect drift
- **Cycles** — dream cycles simulate hypotheticals against current beliefs; sleep cycles consolidate evidence

## Status

Research / concept. No implementation yet. See three-drift-types paper ([../papers/three-drift-types.md](../papers/three-drift-types.md)) for the companion defense-in-depth framing.
