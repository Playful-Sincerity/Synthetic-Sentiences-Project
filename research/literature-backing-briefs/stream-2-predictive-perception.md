# Stream 2 — Predictive Perception / Imagine-Before-Act

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`). Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`perception/CLAUDE.md`](../../perception/CLAUDE.md) for this subsystem (GRP — Generative Reconciliation Perception).

## Research goal

Survey the prior work supporting the central claim: **perception is primarily generative, not receptive.** The being imagines the expected state first, observes second, reconciles the two. Prediction error is the learning signal. Extended further: the most valuable use of the imagination engine is imagining the *final state* (or a full video of the action sequence) and reverse-engineering the concrete actions needed to produce it.

Where does this architecture already exist? Which pieces are novel in combination?

## Claims to support / test / refine

- Predictive/generative perception as default, observation-driven as exception (inverts classical framing)
- Imagine-the-final-state + reverse-engineer-actions as a distinct use of imagination from step-by-step next-state prediction
- Reconciliation of imagined vs observed as a cognitive dissonance event (novel in web/desktop agents)
- Dual perception (visual + structural) with prediction-error-gated learning
- Generator and reality as collaborators rather than adversaries (the Generative Collaborative framing — concept, not necessarily the acronym)

## Search priorities

- **Predictive coding / active inference.** Friston, Rao & Ballard, Clark; recent computational implementations.
- **World models in agents.** Dreamer V1/V2/V3 (Hafner et al), WebDreamer, mental simulation literature.
- **Visual foresight in robotics.** Finn et al; video prediction for action planning; diffusion-policy models.
- **Mental imagery and planning.** Kosslyn lineage; mental-simulation-for-decision-making.
- **Inverse dynamics / goal-conditioned imitation.** How do systems go from "imagined end state" back to actions?
- **Prediction-error-gated learning.** Reconsolidation neuroscience; surprise-driven memory updates.

## Target output

Write synthesis + annotated bibliography to:

- `perception/research/literature-backing.md` (synthesis, ~2000 words)
- `perception/research/bibliography.md` (10–20 papers annotated)

Special attention to: the imagine-final-state + reverse-engineer mechanism. Is there direct prior work on it? If not, it's likely a distinctive contribution worth flagging in the Fellows drafts.

## Independence

Independent of other streams. Some overlap with Stream 5 (sleep/dream) on simulation, but different focus.
