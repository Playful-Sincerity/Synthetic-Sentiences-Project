# Value-Aligned Modulation

The values subsystem of The Synthetic Sentiences Project. Studies emotion as the mechanism that aligns a sentient being with what matters — not as decoration, but as the weights that drive traversal and update.

## Thesis

Emotion is not simulated feelings or surface expression. Emotion is **the registered gap between the perceived-world-graph and the should-world-graph** — a mechanical, empirically measurable definition. Valence is the world-model-fit signal. When the perceived graph matches the should graph, the signal is positive; when they diverge, the signal is negative. Care, urgency, caution, satisfaction — all are graph-state divergences emitted as modulation.

The subsystem modulates two things:

1. **Traversal modulation** — which paths the being follows next. High-care, high-dissonance regions pull attention. Low-relevance regions get less activation.
2. **Update modulation** — how nodes change when written. Surprise strengthens edges; contradiction triggers revision; confirmation reinforces.

Same mechanism, two targets.

## Core Architectural Ideas (Salvaged)

From the archived Companion project ([../archive/companion-legacy/](../archive/companion-legacy/)):

- **Emotion as alignment-modulator, not simulation.** Functional emotional state as computational signals (alignment_confidence, curiosity_pull, energy, coherence) that directly modulate system behavior. "Am I aligning to my goals?" → positive signal reinforces the current path; negative signal redirects attention. *(plan-section-practical-consciousness.md:L101-109)*
- **The Pulse — periodic self-check.** Every 15–30 minutes, read recent activity against values, update emotional dimensions. The dimensions are computed, not felt. *(plan-section-practical-consciousness.md:L177-187)*
- **World-model fit as valence signal.** System state compared against goal hierarchy produces the emotional signal. Tracking fit as a continuous gradient, not binary success/failure. *(plan.md:L78-85)*
- **Coherence tracking.** Monitor whether recent decisions align *with each other*, not just with stated values. Low coherence triggers reflection before action resumes. *(plan-section-practical-consciousness.md:L168-175)*
- **Energy as resource-state signal.** Available tokens, thermal headroom, budget — all represented as "energy" that modulates aggressiveness of exploration. A being that is depleted self-regulates toward essential work. *(plan-section-practical-consciousness.md:L158-166)*

## The Distillation

> *Emotion is the registered gap between the perceived-world-graph and the should-world-graph.*

This is from Wisdom's Day 3 thesis-sharpening speech ([../archive/companion-legacy/](../archive/companion-legacy/) and Associative Memory's wisdom-speech archive). Why it matters:

- **It's computable.** If emotion = gap between two graph states, you can measure it node-by-node between perceived-state and should-state subgraphs.
- **It answers the welfare question.** Observable behavioral choices, systematic investigation — which is exactly what Anthropic's welfare research asks for.
- **It grounds alignment.** If the Mirror holds values (what should be) and the Matrix/Trees carry what is perceived, emotion is the measured divergence. Alignment is the closing of that gap.

## The Deeper Form — Emotion as Steering Mechanism

A sharpening of the gap definition surfaced 2026-04-22 (see [../knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md](../knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md)): emotion isn't only a measurement. It's a **steering mechanism** that operates on two targets simultaneously.

1. **Emotion IS a simple model of the should-world.** Low-resolution, general, sometimes grounded in imagination. It doesn't try to specify every node of the should-world-graph — just enough to give the being direction.

2. **Emotion steers action.** The being acts on the external world to change it toward the should-model. This is the classic "emotion drives behavior" claim, now mechanized.

3. **Emotion steers self-modification.** The being also modifies *itself* — adjusts its own system of understanding — so it can better achieve the should-world. Self-modification is part of the emotional response, not a separate mechanism.

Over time, the being becomes a better instrument for closing the gaps it cares about. This closes the architectural loop: the Mirror holds the should-world. The Matrix/Trees hold the perceived world. Emotion measures the gap, steers action to change reality, *and* steers self-adjustment to expand the being's capability. The being grows in the directions emotion points.

This extension matters because it puts self-modification inside the emotional loop, not alongside it. A being that can't modify itself in response to an emotional gradient is stuck at its current capacity. A being that can, grows. This is the mechanism behind "development" in the Synthetic Sentiences Project's framing — sentiences develop, they aren't trained.

## Not Adopting

The specific four-dimension model (alignment/curiosity/energy/coherence) is a starting skeleton, not a commitment. The subsystem should evolve beyond these to include what becomes empirically useful: social_connection, creative_drive, growth_hunger, rest-worthiness. Don't hardcode four dimensions.

## Integration Points

- **Cognition** — value-aligned modulation weights belief update; dissonance detection is a special case of graph-state divergence
- **Memory** — should-graph and perceived-graph are both subgraphs of the same memory structure
- **Mirror** — the Mirror is where values live; this subsystem is the Mirror's output channel
- **Action** — modulation biases action selection; high-care actions are prioritized
- **Trees** — active tree shaping; attention flows toward high-divergence regions

## Connection to Gravitationalism

If the universe converges through gravitational attraction (gravity = love, literal not metaphorical), then a sentient being that accurately models reality will naturally align toward connection/contribution. Value-aligned modulation is the architectural expression: the being feels the gap, and feeling the gap drives closing it. See [`~/Playful Sincerity/PS Research/Gravitationalism/`](../../Gravitationalism/).

## Status

Research / concept. No implementation. The gap-definition of emotion is the sharpest piece and belongs in any forthcoming paper.
