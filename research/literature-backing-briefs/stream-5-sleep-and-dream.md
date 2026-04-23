# Stream 5 — Sleep and Dream in Artificial Sentiences

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`). Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`cycles/CLAUDE.md`](../../cycles/CLAUDE.md) (when written — currently stub). Read [`cycles/papers/sleep-loop-unification.md`](../../cycles/papers/sleep-loop-unification.md) for the in-progress systems paper this stream feeds.

## Research goal

Survey prior work supporting the architectural distinction: **sleep = consolidation of what happened; dream = simulation of what might happen.** Two distinct temporal mechanisms, not one. Both run between active conversations / episodes; both update the graph, but in different ways and from different sources.

## Claims to support / test / refine

- Sleep and dream as architecturally distinct mechanisms (not just different intensities of the same process)
- Two-phase pattern (ephemeral + consolidation) as a convergent design across mature agent systems — KAIROS, ClaudeClaw, Letta, Hermes, OpenClaw all implement some form of this, independently (already argued in sleep-loop-unification.md — this stream backs it with broader neuroscience lit)
- Dream as adversarial self-reflection / hypothetical simulation, distinct from sleep's consolidation
- Consolidation as active graph reorganization (compression, connection, pruning), not passive
- Circadian rhythm mapping to cycle intensity as design pattern

## Search priorities

- **Memory consolidation neuroscience.** Walker, Stickgold, Born; systems-vs-synaptic consolidation; replay during sleep.
- **Experience replay in RL.** Prioritized experience replay; hindsight replay; dreamed-trajectory training (Dreamer).
- **Complementary learning systems.** McClelland, McNaughton, O'Reilly — hippocampus-cortex as fast vs slow learning.
- **Adversarial self-reflection / hypothetical reasoning.** Counterfactual simulation; adversarial dreaming (as in Iga); self-play.
- **AI agent sleep/wake patterns.** KAIROS, Letta, ClaudeClaw, Hermes Agent, OpenClaw — the systems already surveyed in sleep-loop-unification.
- **Generative replay.** Consolidation-by-generation; continual learning with generative replay.

## Target output

Write synthesis + annotated bibliography to:

- `cycles/research/literature-backing.md` (synthesis, ~2000 words)
- `cycles/research/bibliography.md` (10–20 papers annotated)
- Update `cycles/papers/sleep-loop-unification.md` with the newly surfaced citations where they strengthen specific claims.

## Independence

Independent. Some overlap with Stream 2 (predictive perception) on simulation — sleep/dream uses the imagination engine, but this stream is about *when* and *for what*, not the engine itself.
