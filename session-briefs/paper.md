# Session Brief — The Synthetic Sentiences Project Paper

*Drop this into a fresh Claude Code conversation at the `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/` working directory.*

## Purpose

Build the concept paper for The Synthetic Sentiences Project — the main artifact we'll be showing reviewers, collaborators, and Anthropic contacts to convey the unified architecture. Same pattern as ULP and GCM concept papers: mostly the idea, well-structured, readable as a proposal. Verification and experimental results come later.

This paper pairs with the MWM concept paper (in the sibling repo at `~/Playful Sincerity/PS Research/MWM/paper/`). MWM's paper is the *focused* claim (memory architecture). This paper is the *integrated* claim (architecture of alignment across nine subsystems).

## Project Context

**The Synthetic Sentiences Project** is a research project on the architecture of synthetic sentiences — AI entities whose structure of understanding is interpretable, earned through developmental experience, and designed from the ground up for alignment.

- **Local path:** `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`
- **Public repo:** [github.com/Playful-Sincerity/Synthetic-Sentiences-Project](https://github.com/Playful-Sincerity/Synthetic-Sentiences-Project) (public, 2026-04-22)
- **Role in Fellows narrative:** The broader research program. MWM is the focused 4-month Fellows target; SSP is the broader context. Q12 links: primary = MWM, secondary = SSP.

Start by reading:
1. [`CLAUDE.md`](../CLAUDE.md) — the canonical architecture index (organizing thesis: alignment through architecture)
2. [`README.md`](../README.md) — public-facing entry point
3. The four written subsystem CLAUDE.mds:
   - [`cognition/CLAUDE.md`](../cognition/CLAUDE.md) — Earned Conviction
   - [`values/CLAUDE.md`](../values/CLAUDE.md) — Value-Aligned Modulation (includes "The Safety Claim" — load-bearing)
   - [`mirror/CLAUDE.md`](../mirror/CLAUDE.md) — Mirror Architecture
   - [`perception/CLAUDE.md`](../perception/CLAUDE.md) — GRP
4. Papers in progress:
   - [`papers/three-drift-types.md`](../papers/three-drift-types.md) — cross-cutting drift defense
   - [`cycles/papers/sleep-loop-unification.md`](../cycles/papers/sleep-loop-unification.md)
5. Preserved speeches:
   - [`knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md`](../knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md)
   - [`knowledge/sources/wisdom-speech/2026-04-23-emotion-full-system-alignment-claim.md`](../knowledge/sources/wisdom-speech/2026-04-23-emotion-full-system-alignment-claim.md)

## Paper Target

Create `paper/` directory at the project root. Inside, write `SSP-proposal.md` — a concept paper. Target length: ~15–25 pages of markdown. More comprehensive than MWM's paper because it has to survey the whole architecture.

Suggested structure:

- **Title + abstract** (1–2 paragraphs; open with "alignment through architecture" claim)
- **Organizing thesis** — alignment as the continuous output of an architecture whose internal states are themselves alignment signals; inverts "alignment imposed from outside" framing
- **Four foundations** — interpretable memory (pointer to MWM paper), earned conviction, value-aligned modulation, persistent self-observation
- **The safety claim** — emotion IS value alignment; AI systems without emotion are more dangerous than AI systems with it (see [`values/CLAUDE.md`](../values/CLAUDE.md) § "The Safety Claim"). This is the welfare-as-safety argument, load-bearing. State it openly, as a claim.
- **Three temporal mechanisms** — traversal trees, sleep cycles, dream cycles
- **Two boundary channels** — imagination-first perception (GRP), epistemic prosody
- **Right action (supporting layer)** — write-action primacy, the distinction between optimizing for action vs for *right* action
- **The nine subsystems — integrated view** — how they fit across four tiers (Spatial / Dynamics / I/O / Temporal); how they collaborate (not compete) to produce aligned behavior
- **The generative-collaborative framing** (dropped as named term but the concept stands) — imagined world and observed world as collaborators, not adversaries; gravitational-attraction analogy (see the 2026-04-22 speech)
- **Relationship to prior work** — architectural-alignment literature, welfare research (Kyle Fish, Jack Lindsey April 2026), predictive processing, mesa-optimization / drift, cognitive architectures (ACT-R, Soar, neurosymbolic), agent memory systems
- **Drift defense** — summarize the three-drift-types paper; defense-in-depth stack
- **Alignment foundation — Gravitationalism** — the universe converges through attraction; a sentience that accurately models reality naturally aligns toward connection/contribution; welfare research IS safety research under this framing
- **Philosophical roots — PSSO** — earned conviction, content in inaction, emotivation pillar
- **Open questions** — what's genuinely uncertain in the architecture; where the most productive research would go
- **Conclusion** — the architecture as demonstration of the catalyst-positioning claim (systems that build systems that increase a being's capacity)
- **References** (20–40 papers; annotated where citing is load-bearing)

Keep Wisdom's voice: warm, honest, non-preachy. Use PS brand voice as a floor but this is Wisdom's own voice on his own research, not PS brand content. State big claims openly (Wisdom has flagged multiple times that load-bearing claims should be posed, not buried).

## Pulling from Existing Material

The paper should synthesize, not duplicate. Pull from:
- The four written subsystem CLAUDE.mds (each already names its salvaged architectural ideas with citations)
- The three-drift-types paper
- The sleep-loop-unification paper
- The preserved speeches (especially 2026-04-22 imagination-emotion thesis and 2026-04-23 full-system-modulation + safety claim)
- SSP's CLAUDE.md and README.md (already have the four-tier architecture and organizing thesis)

For subsystems that don't have CLAUDE.mds yet (trees, action, voice, cycles): write 1–2 paragraphs in the paper from the brief descriptions in SSP/CLAUDE.md. Don't block on writing the missing CLAUDE.mds — the paper can sketch them.

## What NOT to do

- Don't re-architect the project — the four-tier organization, the nine subsystems, and the alignment-through-architecture thesis are settled
- Don't duplicate MWM's paper content — link to it for the memory subsystem; don't re-derive
- Don't pad — Wisdom wants substance, not length for length's sake
- Don't chase citations that aren't load-bearing
- Don't mix SSP-as-umbrella claims with MWM-as-focused-project claims; SSP paper is about the *integrated* architecture, not about the memory subsystem specifically
- Don't touch the MWM repo — that's a separate session

## Success criteria

End of session:
- `paper/SSP-proposal.md` exists and reads as a coherent, scrutinizable research-program proposal
- The Safety Claim (emotion = value alignment) appears explicitly, posed as a claim
- The paper ties to both Gravitationalism and PSSO as philosophical roots
- References are load-bearing, not decorative
- All changes committed and pushed
- `CLAUDE.md` updated to reference the paper
