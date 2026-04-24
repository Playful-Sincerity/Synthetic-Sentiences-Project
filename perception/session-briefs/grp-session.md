# Session Brief — GRP Dedicated Session

*Drop this into a fresh Claude Code conversation at the `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/perception/` working directory. This is the GRP session — a conversation specifically dedicated to advancing the Generative Reconciliation Perception subsystem and closing out the Phantom → GRP transition across the repo.*

## Purpose

A dedicated working session for **GRP (Generative Reconciliation Perception)** — the imagination-first perceptual architecture, formerly named "Phantom." The session has two main thrusts:

1. **Close out the Phantom → GRP transition** across the SSP/perception/ subtree — sweep all internal references, update the SPEC and diagrams, ensure a reviewer reading any file lands on the current naming and framing.
2. **Develop GRP forward** — sharpen the architecture, deepen the SPEC where current thinking has moved past it, build/update diagrams, work through open questions.

GRP is the perception subsystem of [The Synthetic Sentiences Project](https://github.com/Playful-Sincerity/Synthetic-Sentiences-Project). It lives within the SSP repo (not its own standalone repo, unlike MWM). The 4-month Anthropic Fellows 2026 target is MWM specifically; GRP is a secondary research interest in the Fellows narrative but a load-bearing subsystem in the broader SSP architecture.

## Project Context

**GRP — Generative Reconciliation Perception** is a cognitive architecture for AI agents that see, imagine, and inhabit digital environments. The thesis: classical perception is observe-then-interpret; GRP inverts this — imagine expected state first, observe second, reconcile the two. Prediction error is the learning signal. Quality scales with the quality of imagination, not the density of step-by-step reasoning.

The most valuable use case (sharpened 2026-04-22): imagine the *final state* (or a video of the action sequence) and reverse-engineer the concrete actions needed to produce it. Applied to web design, robotics, code-from-vision-to-implementation.

- **Local path:** `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/perception/`
- **Repo home:** [github.com/Playful-Sincerity/Synthetic-Sentiences-Project/tree/main/perception](https://github.com/Playful-Sincerity/Synthetic-Sentiences-Project/tree/main/perception) (lives in SSP, not standalone)
- **Sister project:** [Memory as World Model](https://github.com/Playful-Sincerity/Memory-as-World-Model) — MWM is the world-model substrate that GRP's predictions and observations write into

Start by reading:
1. `CLAUDE.md` — current GRP-framed project doc (already rewritten 2026-04-22)
2. `SPEC.md` — full architecture specification; written when project was Phantom — needs GRP rename sweep + sharpening
3. `README.md` — likely still Phantom-framed; needs rewrite
4. `_phantom-legacy-CLAUDE.md` — preserved historical version of the original CLAUDE.md (do not modify; reference for what changed)
5. `diagrams/phantom-architecture.d2` and `diagrams/phantom-architecture.svg` — likely needs rename + content update
6. `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/CLAUDE.md` § perception subsystem entry — for context on how GRP fits SSP
7. `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md` — Wisdom's most recent GRP framing (imagine-final-state, reverse-engineer, the GAN→Generative-Collaborative reframe)

## Priorities

### Priority 1 — Phantom → GRP rename sweep

The folder was renamed in spirit, the CLAUDE.md was rewritten with GRP framing, but most internal files still say "Phantom." Sweep with judgment:

- `cd ~/Playful Sincerity/PS Research/Synthetic Sentiences Project/perception && grep -rln "Phantom" . --include="*.md"` — survey hits
- Update running-text references to GRP / Generative Reconciliation Perception
- Leave historical references intact where they're actually historical:
  - `_phantom-legacy-CLAUDE.md` — original, preserved verbatim
  - `chronicle/` entries that document the rename itself
  - `archive/` — historical
  - `ideas/build-queue.md` — the entry "2026-04-21 — Rename: Phantom → something about imagination" stays as captured history
- Updates that should happen:
  - `SPEC.md` — load-bearing technical doc, every "Phantom" → "GRP" or "the agent" depending on context
  - `README.md` — if it still says Phantom, full rewrite to GRP framing (mirror the SSP/perception/CLAUDE.md style)
  - `diagrams/phantom-architecture.d2` / `.svg` — rename file to `grp-architecture.d2` / `.svg`, update title and any internal "Phantom" labels
  - Any `research/*.md` files describing current architecture (not historical retrospectives)

Commit: "sweep: Phantom → GRP internal references across perception/"

### Priority 2 — Update / sharpen SPEC.md

`SPEC.md` is the source of truth for the architecture. Likely needs:

- GRP naming throughout (running text)
- The 2026-04-22 sharpening of the imagine-before-act mechanism: imagine the final state (or a full video) and reverse-engineer; web design + robotics examples (see `knowledge/sources/wisdom-speech/2026-04-22-grp-imagination-gcn-emotion.md`)
- The Generative Collaborative Network reframe (concept, not the GCN acronym which is taken by Graph Convolutional Network) — generator and observer as collaborators converging, not adversaries
- Cross-links updated to reflect the SSP subsystem structure: GRP integrates with MWM (writes predicted/observed subgraphs into the graph), Values (modulates what to attend to), Trees (where the page being perceived lives), Action (perceptions feed action selection), Cycles (dream cycles use GRP's imagination engine)

If SPEC.md has grown unwieldy, consider splitting into focused documents (`SPEC-architecture.md`, `SPEC-cognitive-loop.md`, etc.) — judgment call.

### Priority 3 — Rewrite README.md (public-facing)

The README is what someone clicking through to `perception/` sees. Should:
- Open with GRP, not Phantom
- State the thesis (imagine-before-act; quality scales with imagination quality)
- Show the cognitive loop (IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN)
- Name the 2 most distinctive contributions (dual perception with reconciliation; imagine-final-state-then-reverse-engineer) with prior work context
- Link to SPEC.md for full architecture
- Link to SSP root + sibling MWM repo

Mirror the style of `~/Playful Sincerity/PS Research/MWM/README.md` and SSP's root README.

### Priority 4 — Diagrams

The architecture diagram exists at `diagrams/phantom-architecture.d2` (D2 source) and `.svg` (rendered). Update:

- Rename files: `phantom-architecture.d2` → `grp-architecture.d2` (and the .svg)
- Update internal title labels from "Phantom" to "GRP" or "Generative Reconciliation Perception"
- Sanity-check architecture against current SPEC — ensure imagine-before-act loop is the spine, dual perception is shown, the reconciler is centered
- Re-render: `d2 grp-architecture.d2 grp-architecture.svg`

Consider adding new diagrams:
- The imagine-final-state → reverse-engineer-actions flow (the high-value use case)
- The Generative Collaborative framing (imagined world + observed world converging)

### Priority 5 — Open questions and forward-looking research

The `research/open-questions.md` is the active scratchpad for unresolved design challenges. Edit pass:

- Add questions surfaced by the 2026-04-22 sharpening: how to scale imagination (compute), how to evaluate imagined-vs-observed when both are uncertain, how to integrate with MWM's graph for write-back
- Resolve / mark settled questions where current thinking has answered them
- Surface 1–3 questions worth a focused research stream later

### Priority 6 — Contribute to SSP paper's perception section

The SSP paper (see `~/Playful Sincerity/PS Research/Synthetic Sentiences Project/session-briefs/paper.md`) needs a perception subsystem section. While this brief doesn't *write* that section, it should ensure GRP's architecture is documented at sufficient depth (SPEC + README + diagrams) that the paper's perception section can be written from current docs without re-deriving thinking.

If the paper-author-session asks for a 3–5 paragraph GRP summary, having that drafted as `perception/paper-section.md` would shorten their work.

## Working Conventions

- **Chronicle every meaningful action.** `chronicle/YYYY-MM-DD.md` with What/Why/Means.
- **Each priority gets its own commit** to the SSP repo.
- **Push frequently** to `origin main` of the SSP repo so Wisdom can review mid-stream.

## What NOT to do

- Don't re-architect — the IMAGINE → OBSERVE → RECONCILE loop and the 9-component novel architecture are settled
- Don't touch MWM repo files — separate project, separate brief
- Don't touch other SSP subsystems' folders (cognition/, values/, mirror/, etc.) — separate scopes
- Don't try to make GRP a standalone repo — it stays in SSP/perception/. If that decision changes, it'll be made deliberately, not as a side effect of this session
- Don't lose the load-bearing pieces of the architecture: dual perception, the reconciler, imagine-before-act, the Generative Collaborative reframe (concept), prediction-error-gated learning

## Success Criteria

End of session, ideally most of:

- All `perception/*.md` files have running-text references updated from Phantom → GRP (historical references preserved)
- `SPEC.md` reflects current thinking, including the 2026-04-22 imagine-final-state sharpening
- `README.md` rewritten as a GRP-framed public-facing entry point
- Diagrams renamed and updated; new diagram(s) drafted if useful
- `research/open-questions.md` reflects current open problems
- All changes committed and pushed to SSP main
- A short `perception/paper-section.md` drafted for the SSP paper to consume (3–5 paragraphs on GRP)
