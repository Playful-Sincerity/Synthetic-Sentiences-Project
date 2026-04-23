# Reorganization Plan — The Synthetic Sentiences Project

*Living document. Update as phases complete.*

**Started:** 2026-04-22
**Status:** Phase 0 complete. Phase 1+ pending Wisdom's approval on open questions below.

---

## Critical Open Questions (Resolve Before Phase 5)

### 1. Fellows Path — A or B?

- **Path A:** This umbrella IS the Q16 submission. Fellows drafts reference "The Synthetic Sentiences Project" with memory/interpretability as Year 1 technical focus.
- **Path B:** Memory/AM gets its own scientific rename for Fellows; SS is the broader research program above it.

Leaning A given the "keep everything together" signal, but requires rewriting q15/q16/q17 drafts. **CANNOT move AM until resolved.** Four days to April 26 deadline.

### 2. Scientific register of subsystem names

The names in the root CLAUDE.md are descriptive (Interpretable Memory, Earned Conviction, etc.). If you want plainer still, flag now — renaming folders + display names at this stage is cheap.

### 3. Voice subsystem scope

Extract from where? PS Bot early work + Companion's `plan-section-communication.md` + `~/claude-system/voice/`? Probably all three. Confirm.

---

## Phase Sequence

### Phase 0 — Skeleton · COMPLETE (2026-04-22)

- Create `PS Research/Synthetic Sentiences/` directory
- Create subsystem folders: memory, trees, cognition, perception, voice, values, mirror, cycles, action
- Create root CLAUDE.md (the project's index)
- Create Universal Scaffold: papers/, research/, chronicle/, ideas/, play/, archive/
- Create `_extracted-from/` for provenance tracking

**Risk:** None. Fully reversible.

### Phase 1 — Pull CCE research artifacts (COPY, not move)

Extract research-grade work from `PS Software/Claude Code Entities/` without disturbing the operational home. Record lineage in each copy's frontmatter.

| Source | Destination |
|--------|-------------|
| `papers/sleep-loop-unification.md` | `cycles/papers/sleep-loop-unification.md` |
| `ideas/dreaming.md` | `cycles/dreaming.md` |
| `ideas/dream-skill-conversation-starter.md` | `cycles/dream-skill-concept.md` |
| `research/2026-04-17-iga-dennis-hansen.md` | `cycles/research/iga-comparative.md` |
| `ideas/value-relationships.md` | `cognition/value-relationships.md` |
| `papers/three-drift-types.md` | `papers/three-drift-types.md` |
| `ideas/letters-to-future-selves.md` | `mirror/letters-to-future-selves.md` |
| `ideas/session-persistence-patterns.md` | `cycles/session-persistence-patterns.md` |
| `ideas/memory-decay-and-pinning.md` | `cycles/memory-decay-and-pinning.md` |
| `ideas/brain-agent-orchestrator-and-micro-prompts.md` | `cognition/brain-orchestrator-micro-prompts.md` |

**Risk:** Low. Copies leave originals intact.

### Phase 2 — Move Phantom → perception/

- `mv` contents of `PS Software/Phantom/` into `perception/`
- Keep internal structure (SPEC.md, README.md, research/, diagrams/, tests/)
- Leave tombstone at old location pointing here
- Update memory file `project_phantom.md` and MEMORY.md index

**Risk:** Medium. References to `PS Software/Phantom/` exist throughout ecosystem. Grep sweep required.

### Phase 3 — Move/split The Companion → cognition/ + mirror/ + others

The Companion has distributed content. Proposed split:

| Companion File | Destination |
|----------------|-------------|
| `plan.md`, `plan-section-cognitive.md`, `plan-section-practical-consciousness.md` | `cognition/planning/` |
| `plan-section-identity.md`, `plan-section-self-improvement.md` | `mirror/planning/` |
| `plan-section-memory.md` | `memory/companion-memory-plan.md` (after Phase 5) |
| `plan-section-communication.md` | `voice/companion-communication-plan.md` |
| `plan-section-security.md`, `plan-section-hardware.md`, `plan-section-budget.md` | `archive/companion-operational-planning/` (superseded by CCE) |
| `convergence.md` | `archive/convergence-v1.md` (content absorbed into root CLAUDE.md; keep as historical) |
| `research/local-cognition/` | `research/local-cognition/` (shared; stays at SS root) |
| `plan-reconciliation.md` | `archive/` |

Leave tombstone at `PS Software/The Companion/README.md`.

**Risk:** Medium-high. Many files; the split requires per-file judgment.

### Phase 4 — Voice extraction → voice/

- Review `PS Software/PS Bot/` for salvageable architectural pieces (most absorbed into CCE per 2026-04-05 pivot)
- Reference (don't move) epistemic-prosody content from `~/claude-system/voice/` — that directory is operational
- Write `voice/CLAUDE.md` integrating the pieces

**Risk:** Low.

### Phase 5 — Move Associative Memory → memory/

**BLOCKED ON: Fellows Path decision (Question 1).**

If Path A:
- `mv` contents of `PS Research/Associative Memory/` into `memory/`
- Update Fellows symlink at `~/Wisdom Personal/Anthropic Fellows Application/linked-assets/`
- Update Fellows drafts (q15/q16/q17/cv): replace `[NAME]` with "The Synthetic Sentiences Project"; frame memory/interpretability as Year 1 focus
- Update memory file `project_associative_memory_architecture.md` → `project_synthetic_sentiences_memory.md`
- Grep sweep for "Associative Memory" references across ecosystem

If Path B:
- Rename AM per scientific-register decision (from [rename-session-seed.md](../Associative%20Memory/rename-session-seed.md) or fresh)
- Don't move into SS; SS references it as sibling subsystem

**Risk:** HIGH. Four days to Fellows deadline. Every reference matters.

### Phase 6 — Global reference sweep

Update references in:
- `~/.claude/CLAUDE.md`
- `~/Playful Sincerity/CLAUDE.md` (branch structure table)
- `~/Playful Sincerity/ECOSYSTEM.md`
- `~/Playful Sincerity/PS Research/CLAUDE.md` (if exists)
- Memory index `~/.claude/projects/-Users-wisdomhappy/memory/MEMORY.md`
- Individual memory files referencing moved paths
- Claude Code Entities references to Companion/AM/Phantom

**Risk:** Medium. Grep + careful edits.

### Phase 7 — Archive what's superseded

- `PS Software/PS Bot/` → `PS Software/archive/PS Bot/` (already effectively archived per 2026-04-05)
- Companion operational-only planning → handled in Phase 3
- Superseded Companion plan drafts → handled in Phase 3

**Risk:** Low.

### Phase 8 — Verify

- `find` + `grep` sweep for dangling references
- Every subsystem has a CLAUDE.md
- Every old location has a tombstone README
- Fellows drafts read consistently
- Memory files reflect new names
- Walk through the structure mentally as if starting a fresh conversation — does it make sense?

---

## What Does NOT Move

- **Claude Code Entities** stays in `PS Software/` as the operational entity runtime. Research artifacts are copied into SS; PD's home stays operational.
- **Convergence Paper** stays in `PS Software/` as a deliverable for Anthropic contacts.
- **Gravitationalism** stays in `PS Research/` as its own project (alignment foundation, referenced here).
- **Spatial Workspace, RenMap, HHA, Hearth, CoVibe, etc.** unrelated, untouched.

## Rollback

Each phase is reversible up to Phase 4. Phase 5 (AM + Fellows) is the highest-commitment step; verify thoroughly before executing. Old directories are preserved as tombstones with clear redirects.

---

## Phase Log

- **2026-04-22** — Phase 0 complete. Skeleton + CLAUDE.md + this plan written.
- **2026-04-22** — Folder renamed `Synthetic Sentiences` → `Synthetic Sentiences Project` (another session brought folder name into alignment with canonical name in CLAUDE.md).
- **2026-04-22** — Wisdom decisions: Path B for Fellows (AM keeps own scientific name, sibling to SS); lock **GRP** for Phantom rename; **MWM** proposed for AM, tentative pending final confirmation.
- **2026-04-22** — Phase 1 complete. 10 CCE research artifacts copied into subsystems (cycles, cognition, mirror, papers). Originals remain in CCE.
- **2026-04-22** — Phase 2 complete. Phantom → `perception/`. Old Phantom CLAUDE.md preserved as `_phantom-legacy-CLAUDE.md`. New `perception/CLAUDE.md` written introducing GRP. Tombstone README at `PS Software/Phantom/`.
- **2026-04-22** — Phase 3 started. Companion archived to `archive/companion-legacy/`. `research/local-cognition/` preserved at project root (shared with memory subsystem). Subsystem CLAUDE.mds written for `cognition/` (Earned Conviction), `values/` (Value-Aligned Modulation), `mirror/` (Mirror Architecture) — each incorporates salvaged architectural ideas with file:line citations to the archived Companion docs.
- **Next** — Write remaining subsystem CLAUDE.mds: `trees/`, `action/`, `voice/`, `cycles/`. Then Phase 5 (AM → MWM) once name confirmed. Then Phase 6 (global reference sweep across ECOSYSTEM.md, memory files, etc.) and Phase 7 (PS Bot archive).
