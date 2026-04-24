# Decision — Repository Organization for MWM

**Date:** 2026-04-23
**Status:** Proposed, pending Wisdom confirmation
**Decision (proposed):** Two repos. MWM (Memory as World Model) gets its own GitHub repo (rename of the existing Associative Memory project). The Synthetic Sentiences Project stays as the broader research-program umbrella.

---

## The Question

Should Memory-as-World-Model (MWM) be:

**A.** A subsystem folder inside the Synthetic Sentiences Project repo (absorbed into `SSP/memory/`), or
**B.** Its own GitHub repository, with SSP as the sibling umbrella?

Wisdom flagged this today as a decision worth making deliberately rather than defaulting.

## Context — What the Fellows Application Is Claiming

- **MWM is the 4-month Fellows research target.** Q16 essay names it specifically as the bounded scope, with planned metrics (belief-traceability vs flat-memory baseline like AriGraph; designed-emotion variant against Jack Lindsey's April 2026 results).
- **SSP is the broader research program.** Positioning frames the four foundations (interpretable memory, earned conviction, value-aligned modulation, persistent self-observation) as the convergence; the 4-month Fellows work is focused on MWM within that program.
- **Q12 "other links" is currently `[github link TBD]`** — the decision on what repo(s) to link is explicitly open.
- **The resume (Figma: figma.com/design/a4ONhCMAo5fg5clPu2a0sE) badges MWM as "PROPOSED FELLOWS RESEARCH TARGET."** Distinct from the surrounding SSP block.
- **Catalyst positioning frame (2026-04-23)** emphasizes Wisdom's capacity is *building integrated systems that increase a being's capacity*. The architecture IS the demonstration. Two repos at different scales can *demonstrate* this — scope-clarity at the focused level, integration at the program level.

## What Currently Exists in the AM Project

`PS Research/Associative Memory/` already has the density for an MWM-named standalone repo:

- `vision.md` — the current thesis (graph IS the interpretable world model)
- Design docs: architecture, data-model, traversal, pruning, consolidation, value-system, world-integration
- Research audits (50+ systems surveyed, Round 4 multi-agent research)
- `research/round4-agents/` with 12 stream reports
- The rename-session-seed + positioning work already staged

It is not thin. It's ready to be its own repo.

## Option A — Unified Repo (absorb MWM into SSP/memory/)

Move AM contents into `SSP/memory/`. Single GitHub repo. SSP's README points at the memory subsystem directly.

**Pros:**
- Reviewer lands in one place and sees integration immediately
- Clean "architecture is the thesis" story
- No cross-repo navigation

**Cons:**
- MWM's depth is diluted inside a larger integrated repo
- A Fellows reviewer looking specifically at the 4-month target has to navigate
- Loses the framing "here is the focused scope; here is the broader program"
- The architectural integration story is already *shown* by SSP — MWM doesn't need to sit inside SSP to prove the integration

## Option B — Two Repos (recommended)

MWM becomes its own GitHub repo (rename of AM). SSP stays at its current location with `memory/` as a thin pointer folder that links out to the sibling MWM repo and describes how memory fits into the larger architecture.

**Pros:**
- MWM gets a dense, focused home that matches its Fellows status
- SSP shows integration; MWM shows depth; both land strong on their own
- Application narrative maps cleanly: Q16 (focused project) → MWM repo; broader program → SSP repo
- MWM can evolve at its own cadence without SSP-level churn
- Demonstrates the catalyst-positioning frame at two scales (integrated program + focused project)

**Cons:**
- Two repos to maintain
- Cross-linking has to be explicit (README in each repo points to the other)
- One more place to keep coherent

## What About GRP?

By the same logic: GRP is a secondary research interest, not the Fellows 4-month target. GRP does not need its own repo. It stays as `SSP/perception/`. If GRP later gets a standalone publication push or an implementation phase, revisit.

## Recommendation

**Option B.** The application's scope claim is "four months focused on MWM within the broader Synthetic Sentiences Project." The repo structure should match the scope claim.

Specifically for the Fellows reviewer landing via Q12: primary link = MWM repo (the focused 4-month target they're evaluating); secondary link = SSP repo (the broader program the target sits within). Two clicks, two coherent surfaces, no dilution.

The agent survey's counter-argument (integration is the thesis → one repo) is addressed: integration is shown *by SSP* — the nine subsystem docs, the four-tier organization, the convergence thesis. Splitting MWM out doesn't break that; it reinforces that MWM is a distinct, fully-scoped research target within the program.

## Concrete Steps If Approved

1. Rename `PS Research/Associative Memory/` → `PS Research/MWM/`
2. Initialize MWM as its own git repo (`git init` + initial commit)
3. Write a public-facing `README.md` for MWM (distinct from existing CLAUDE.md; mirrors style of SSP README)
4. Create `github.com/Playful-Sincerity/Memory-as-World-Model` as public; push
5. Update `SSP/memory/CLAUDE.md` to:
   - Describe how memory fits into SSP (graph is world model; LLM is traversal engine)
   - Link out to `github.com/Playful-Sincerity/Memory-as-World-Model` for the focused project
6. Update SSP root `README.md` and `CLAUDE.md` to reference MWM as the memory project (sibling repo)
7. Update Fellows Q12 links:
   - Primary: MWM repo URL
   - Secondary: SSP repo URL
8. Update memory files: `project_associative_memory_architecture.md` → `project_mwm.md`; MEMORY.md index entry
9. Update `~/Playful Sincerity/ECOSYSTEM.md`, `~/Playful Sincerity/CLAUDE.md`, `~/Wisdom Personal/Anthropic Fellows Application/linked-assets/`

## What Doesn't Change

- SSP architecture; the 9-subsystem model stays intact (memory is still one of the nine; it just points to a sibling repo)
- 4 written subsystem CLAUDE.mds (perception, cognition, values, mirror) — unchanged
- Literature-backing briefs and streams — Stream 1 still targets the memory subsystem; its output lands in MWM's repo, referenced from SSP
- Value-Aligned Modulation safety claim; GRP's thesis framing; Mirror Architecture; all unchanged
- Catalyst positioning frame — reinforced by showing two scales of coherent work

## Open Considerations

- **MWM repo's own internal structure.** Keep AM's current internal layout (vision/design/research/journal) or reorganize to match SSP conventions (subsystem tiers don't apply, but the naming style should be consistent). Lean toward light cleanup, not restructure — AM's structure works.
- **License.** Both repos currently unlicensed. Decide before public push. Default: keep unlicensed (all rights reserved) until a deliberate open-licensing decision.
- **Does this affect the literature-backing streams?** No — stream 1 still runs against the memory subsystem; its outputs land in the MWM repo.
