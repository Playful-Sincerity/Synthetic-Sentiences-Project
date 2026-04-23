# GRP — Generative Reconciliation Perception

The perception subsystem of The Synthetic Sentiences Project. A cognitive architecture for AI agents that see, imagine, and inhabit digital environments.

## Thesis

Classical perception is input-driven: observe, then interpret. GRP inverts this: **imagine expected state first, observe second, reconcile the two to produce interpretation.** Prediction error is the signal that updates the world model. This mirrors how biological perception actually works — the brain is predictive, not reactive.

The name GRP (Generative Reconciliation Perception) captures the actual mechanism: generate expectation → reconcile with observation → produce perception. This replaces the earlier codename "Phantom," which named a stealth property (not being seen) that was never the load-bearing contribution.

## Imagine-Before-Act — The Primary Use Case

The most valuable deployment of GRP's imagination engine is not next-state prediction (though that's the baseline capability). It's **imagining the final state — or a full video of the action sequence — and reverse-engineering the concrete actions needed to produce it.**

Two concrete applications:

- **Web design.** Screenshot the current page → imagine how it *should* look (or imagine a video of a user experiencing it perfectly) → generate the code that produces that imagined result. This is qualitatively different from "screenshot and describe." The imagination holds the target; reverse-engineering produces the diff.
- **Robotics.** Imagine the task being performed end-to-end → compute motor commands whose execution would reproduce the imagined video. Same mechanism, different output channel.

Quality scales with the quality of imagination, not with the density of step-by-step reasoning. Imagine well, reverse-engineer fast, produce high-quality output. See [../knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md](../knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md) for the source framing.

## Collaborative Generation — A Reframe of the Adversarial Paradigm

GANs (Generative Adversarial Networks) frame generator and discriminator as competitors. GRP's architecture is different: the imagined world and the observed world are **collaborators**, both working to converge. The being adjusts actions AND its own understanding so the observed matches the imagined — both sides of the architecture are trying to close the gap.

This is a gravitational-attraction framing of a classic adversarial pattern. It's consistent with the rest of the Synthetic Sentiences Project's alignment story (Gravitationalism: the universe converges through attraction, not opposition).

Working term: *Generative Collaborative Network*. The phrase is clean in the ML literature. The natural acronym GCN is taken (Graph Convolutional Network) — if this becomes a paper term, the shorthand needs to be different.

## The Loop

`IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN`

Nine components, genuinely novel in combination:

1. **Imagination engine** — generates expected state before acting (WebDreamer-style, LLM as world model)
2. **Dual perception** — visual (screenshot + Set-of-Mark) AND structural (DOM / a11y / macOS AX) simultaneously
3. **Reconciler** — merges both views; disagreements are treated as cognitive dissonance (no prior work does this)
4. **Affordances** — elements perceived as action potentials, not just structure (Gibson's ecological psychology)
5. **Prediction-error-gated learning** — world model updates only when surprised (reconsolidation from neuroscience)
6. **Causal edges** — clicking X caused Y → Pearl's Layer 2 interventional knowledge
7. **Tiered perception** — Kahneman dual-process applied to perception; imagination subsidizes cost
8. **Alignment critic** — Haiku checks every action against original intent (nobody else ships this)
9. **Temporal perception** — screen sampling over time, not just single frames (video model for animations, loading, transitions)

## Integration with Other Subsystems

- **Memory** (graph as world model) — predictions and observations write nodes here; causal edges become part of the being's world model
- **Values** (value-aligned modulation) — what to observe and what to imagine is weighted by current value-alignment state
- **Trees** (working memory) — the page or screen being perceived lives in the working tree; attention via spreading activation
- **Action** — perceptions feed action selection; actions change the observed world and produce new perceptions
- **Cycles** — dream cycles use GRP's imagination engine to simulate without observing (adversarial self-reflection)

## Key Files

- [SPEC.md](SPEC.md) — full architecture specification (source of truth)
- [README.md](README.md) — project overview and novel contributions
- [diagrams/](diagrams/) — architecture diagrams (D2 source + rendered SVG)
- [research/](research/) — academic papers and GitHub repos surveyed (~65 papers, ~80 repos)
- [_phantom-legacy-CLAUDE.md](_phantom-legacy-CLAUDE.md) — the original Phantom CLAUDE.md, preserved for lineage

## Status

Research complete (2026-03-31). SPEC.md is authoritative. Implementation not started. Renamed Phantom → GRP on 2026-04-22 as part of the Synthetic Sentiences Project unification.
