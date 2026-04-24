# Interpretable Memory (Memory as World Model — sibling repo)

The memory subsystem of The Synthetic Sentiences Project. The full project lives in its own repo as the 4-month Anthropic Fellows 2026 research target:

**Project home:** [github.com/Playful-Sincerity/MWM](https://github.com/Playful-Sincerity/MWM)
**Local path:** `~/Playful Sincerity/PS Research/MWM/` (sibling to this folder)

## Why a sibling repo, not a subfolder here

MWM is the focused 4-month research target for the Anthropic Fellows 2026 application. Keeping it as its own repo gives it a dense, standalone home — matching how the application frames it (Q16: the focused scope; the broader program = this SSP repo). The two scales — focused project + integrated program — are each coherent on their own.

## Thesis

The memory structure IS the interpretable world model, replacing the role that pretrained weights currently play in forming beliefs. The LLM becomes a traversal and reading engine; the graph is the mind. You can read why the agent believes anything by tracing a path in the graph, not by training a probe against the weights.

Full thesis + Three Planes (Matrix / Trees / Mirror) architecture lives in [MWM's CLAUDE.md](https://github.com/Playful-Sincerity/MWM/blob/main/CLAUDE.md) and [MWM's vision.md](https://github.com/Playful-Sincerity/MWM/blob/main/vision.md).

## How MWM fits into SSP

MWM is the substrate that the other SSP subsystems build on, modulate, or consume:

- **Earned Conviction** ([cognition/](../cognition/)) — beliefs are explicit nodes in MWM's graph with evidence chains and confidence levels
- **Value-Aligned Modulation** ([values/](../values/)) — emotion is the registered gap between the perceived-world subgraph and the should-world subgraph within MWM
- **Mirror Architecture** ([mirror/](../mirror/)) — the should-world layer of MWM (self-model, values)
- **Trees** ([trees/](../trees/)) — working memory extracted from the MWM graph via spreading activation
- **Imagination-First Perception** ([perception/](../perception/)) — GRP's imagination engine populates predicted subgraphs in MWM, reconciles against observed ones
- **Action** ([action/](../action/)) — write-actions into MWM are the primary form of action; external actions are secondary
- **Sleep & Dream Cycles** ([cycles/](../cycles/)) — consolidation and simulation both operate on the MWM graph
- **Epistemic Prosody** ([voice/](../voice/)) — confidence in speech maps to confidence-levels of the nodes being rendered

MWM is the substrate; SSP is the program that shows how that substrate supports a full sentience.

## Key Files (in MWM repo)

- [MWM/vision.md](https://github.com/Playful-Sincerity/MWM/blob/main/vision.md) — thesis
- [MWM/design/](https://github.com/Playful-Sincerity/MWM/tree/main/design) — architecture, data model, traversal, value-system, etc.
- [MWM/research/](https://github.com/Playful-Sincerity/MWM/tree/main/research) — audits, multi-round research streams, local-cognition feasibility

## Status

Research / design phase. No implementation yet. Target: working implementation + paper as the 4-month Fellows research project.

## Literature-Backing Stream

Stream 1 in SSP's `research/literature-backing-briefs/` targets this subsystem. When that stream completes, its output lands in `MWM/research/literature-backing.md`, not in this folder.
