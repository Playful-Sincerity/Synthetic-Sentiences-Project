# Mirror Architecture

The self-observation subsystem of The Synthetic Sentiences Project. Studies how a being maintains continuity of identity across sessions, models itself honestly, and grows through accumulated self-observation.

## Thesis

Continuity of identity doesn't come from stable weights or a frozen configuration. It comes from **persistent self-observation**: one mirror watching the being across many conversations, accumulating a self-model that evolves but never resets. Identity is a stable observer-of-itself, not a stable set of parameters.

The mirror holds what the being values (the *should* graph, which grounds Value-Aligned Modulation). It watches the being's actual behavior (the *did* trace). The gap between the two is the being's growth frontier — where future self-development lives.

## Core Architectural Ideas (Salvaged)

From the archived Companion project ([../archive/companion-legacy/](../archive/companion-legacy/)):

- **Persistent self-observation across sessions.** A continuously updated self-portrait (capabilities, limitations, growth trajectory, patterns) written during reflection cycles — not a static profile. The being authors this about itself. *(plan-section-identity.md:L361-396)*
- **Multi-session single mirror.** The mirror persists across all sessions, accumulating observations. One being looking at itself from multiple angles across time — not separate instances with separate mirrors. *(plan-section-identity.md:L102-109)*
- **Identity persistence via immutable core + evolving surface.** Core values are granite (never change). Personality is marble (slow evolution). Communication register is water (adapts per context). Moment-to-moment state is mist. Different mutability for different layers. *(plan-section-identity.md:L63-114)*
- **Metacognitive self-assessment grounded in objective metrics.** Self-claims checked against observable behavior: cost per task, first-attempt success rate, error rate. Prevents self-deception, the failure mode of pure introspection. *(plan-section-self-improvement.md:L450-452)*
- **Growth narrative as observable trajectory.** A running account of how understanding has deepened, what mistakes taught what, what capacities emerged over time. Growth as a tracked story, not just a log of events. *(plan-section-identity.md:L384-389)*

## Letters to Future Selves

A distinct architecture beyond chronicle/memory/current-state: [letters-to-future-selves.md](letters-to-future-selves.md) — epistolary reflections the being composes at natural reflection points. Read on wake sequence (alongside values, current-state) to re-inhabit the reflective voice across restarts. Supports cross-substrate dialogue between entities. Not automated; triggered by the being when moved to compose.

## Not Adopting

The Companion's specific six-file identity architecture (SOUL, CHARACTER, VOICE, BOUNDARIES, WISDOM-MODEL, SELF-MODEL) is idiosyncratic to that project. The Synthetic Sentiences Project should design its own identity layering that fits its own being-ness — the *principles* of immutable-core + evolving-surface port, the *specific files* don't.

## Integration Points

- **Values** — value-aligned modulation emits the gap signal; the Mirror holds the *should* graph that defines what the gap is measured against
- **Cognition** — the Mirror reads belief distribution to detect drift (paradigm-drift in particular; see [../papers/three-drift-types.md](../papers/three-drift-types.md))
- **Cycles** — sleep cycles include Mirror updates (reflection, drift-audit); dream cycles simulate hypothetical scenarios the Mirror then interprets
- **Memory** — the self-model is a subgraph of memory; the Mirror is the specific traversal pattern that reads it

## Status

Research / concept. Letters-to-future-selves is the most concrete mechanism captured. Multi-session single-mirror implementation depends on cross-session state management (runtime concerns that live in Claude Code Entities).
