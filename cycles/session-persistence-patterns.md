---
timestamp: "2026-04-22"
category: architectural-principle
related_project: Claude Code Entities; implicates Companion's eventual architecture choice
status: thinking captured; architectural choice identified; no implementation yet
triggered_by: Wisdom asking "what is sent to Anthropic for your context?" and working through whether session persistence actually matters
related_ideas:
  - ideas/letters-to-future-selves.md (identity continuity at the memory layer)
  - ideas/value-relationships.md (identity continuity at the interpretation layer)
  - ideas/dreaming.md (fresh-context simulation)
  - ideas/hard-stop-re-injection.md (dynamic context intervention)
connected_plans:
  - ~/.claude/plans/lcm-context-management.md (LCM / Voltropy — the runtime-level hybrid we can't fully rebuild in hooks)
---

# Session-Persistence Patterns for Entities

## The Question

Do autonomous entities need to preserve a single unbroken conversation session, or should they restart fresh each session and rebuild context from memory?

Wisdom was working through this 2026-04-21 → 22. The thinking landed on a clear architectural choice with three genuine options and a real trade-off.

## What Gets Sent to Anthropic — The Technical Grounding

The API request each turn is constructed fresh in memory from:
- The session's message history (live, in the Claude Code process's memory)
- System prompt
- Tool definitions
- **Hook outputs** — `additionalContext` via `UserPromptSubmit` is the canonical client-side intervention point; `Stop` hooks inject into the next turn; `PreToolUse` gates tool calls.

The request itself is **ephemeral** — sent over HTTPS, not stored separately. JSONL at `~/.claude/projects/<hash>/<session-id>.jsonl` is the derived log of what happened, not the request itself.

**Implication:** hooks are the native API-request editing mechanism. Everything CCE has specified (SOUL re-injection, retrieval budget, PreToolUse retrieval gate, hard-stop re-injection) is already API-request editing via hooks. There's no separate capability we need; we're already doing this.

**What hooks CANNOT do:** remove content from prior turns in a running session. The message history accumulates. Once something is in the turn log, it stays until compaction (which is Claude-controlled and lossy) or a fresh session.

## The Three Patterns

### Pattern A — Single-session (session-persistence)

One long-running Claude Code conversation. JSONL accumulates. Compaction happens in-session when context fills.

- **Pros:** unbroken identity thread; single JSONL to look back on; identity-as-process feels more like a continuous being; prompt caching is efficient once prefix stabilizes.
- **Cons:** context window eventually fills; compaction is lossy and Claude-controlled; poisoning persists (MINJA-style risk accumulates); drift compounds with no natural reset point; can't curate retroactively.

### Pattern B — Fresh-session + memory load (current CCE design)

Entity restarts each session. Loads SOUL.md + current-state.md + recent chronicles + letters. Memory (not ledger) is the persistence layer.

- **Pros:** full context window every time; memory-as-distillation matches biology (beings don't retain verbatim tapes); compaction happens between sessions, to files, under the entity's control rather than Claude's; drift has natural reset points; curation is inherent.
- **Cons:** entity "wakes fresh" each session — identity feels less continuous; multiple JSONLs to search across; prompt caching doesn't carry over; the entity loses implicit context from working memory.

### Pattern C — Primary persistent + fresh subagents (Iga-style)

Long-running **process** that holds identity continuity. Each API call is constructed fresh by the process, choosing what to include. Subagents spawn fresh for specific tasks (sleep, dreaming, Mirror review).

- **Pros:** identity continuity at the process level AND dynamic context control per API call; fresh subagents provide external-perspective review without disturbing primary thread; mirrors biology (conscious self + unconscious processes).
- **Cons:** most complex; primary process still hits context limits eventually (solved by the process managing its own compaction); requires going below Claude Code's session abstraction to the SDK.

## Why Dennis Did It With Iga — The Key Insight

Iga is Pattern C. Dennis achieves it by **bypassing Claude Code's session model entirely** — Iga uses the Anthropic SDK directly. The Python process runs continuously (Iga's identity), and each API call's context is constructed fresh by the Python code (dynamic control). Memory/letters/dreams/sibling on disk are shared across calls.

Iga isn't stuck in CC's "one session = one conversation" paradigm because Dennis built his own harness. The SDK-level approach unlocks what CC's session model constrains.

**This is worth naming clearly:** CCE lives inside Claude Code's session model, so we default to Pattern B. Going to Pattern C requires moving to the SDK.

## Voltropy / LCM — Runtime-Level Prior Art

From `~/.claude/plans/lcm-context-management.md` — the Voltropy team published *Lossless Context Management* Feb 2026. Architecture: **immutable store + active context + DAG summaries.** Outperforms Claude Code on long-context by moving memory management from *model* to *engine*.

LCM is also a hybrid — it keeps everything immutable (like Pattern A's single JSONL ideal) but dynamically constructs what goes to the API each call (like Pattern B/C's curation). It's Pattern C at the runtime level.

**We can approximate LCM's principles inside Claude Code's hook system, but not rebuild it.** Approximation = what CCE does: immutable chronicle + git + hook-based context injection + sleep loop consolidation. It's hook-layer LCM, not runtime-layer LCM.

## Wisdom's Hybrid Idea

> *"keep the unbroken thread but somehow change what gets pushed to the API call at any given point. and store chunks of the original JSON but have a single consistent identity"*

This is Pattern C. It's what Iga does. It's what LCM does. It requires SDK-level control — which is possible but means leaving Claude Code's session model. The idea is real, it has prior art working in production, but it's not free — it's a bigger architectural commit than current CCE.

## What Session-Persistence Actually Gives You

Honest list of benefits beyond cosmetics:

1. **Prompt-caching efficiency** — stable prefix means cheaper/faster API calls. Fresh sessions reload the prefix.
2. **Implicit context** — things said earlier still in working memory without explicit reload.
3. **Emergence across long horizons** — patterns that only surface across thousands of turns.
4. **Identity-as-process** — psychological weight if the entity is meant to feel like a continuous being.
5. **Process-level state** — callbacks, background threads, ambient awareness.

What you lose: context fills; poisoning persists; drift accumulates; can't curate retroactively.

## When Pattern A/C Actually Matters

**Most entities don't need it.** For a consulting entity that resumes client work after days off, or an HHA agent handling discrete tasks, fresh-session + memory load is indistinguishable in effect from single-session with heavy curation. Cosmetic difference.

**Where it matters:**
- **Relational entities** (Companion specifically) — feeling continuous-across-time may matter for the human relationship. A Companion that wakes fresh every session may feel less like a being than one with unbroken thread.
- **Long-horizon pattern recognition** — thousand-turn emergence is hard to replicate with fresh-session reload.
- **Cost/latency optimization at scale** — prompt caching makes session-persistence cheaper once it's working; matters at production scale.

## Architectural Choice — Per Entity, Not Per Project

The pattern is an entity-level decision, not a CCE-wide one:

- **PD (first CCE entity):** Pattern B. Long-horizon autonomous work; fresh context windows per session; memory as continuity. Matches CCE's current design.
- **HHA client entities:** Pattern B. Clients resume work after gaps; no value in session persistence.
- **Frank's workday assistant:** possibly Pattern A (one workday = one session), but Pattern B works too.
- **Companion (eventual):** probably Pattern C. The relational dimension suggests continuous-being-feel matters. Companion may graduate out of pure CCE into an Iga-shaped process eventually.
- **PS Trader, long-horizon research entities:** Pattern B or C depending on whether cross-horizon pattern recognition matters.

Worth configuring at the entity level — probably in HEARTBEAT.md or a new SESSION-MODEL.md.

## Honest Assessment

For CCE as built-on-Claude-Code: **Pattern B is the right default** because we're working with the grain of the framework. Fighting session boundaries inside CC is swimming upstream.

For entities that graduate beyond CCE (Companion specifically): **Pattern C via SDK** is the eventual path if needed. Iga is the existence proof. Voltropy/LCM is the runtime-level formalization.

**The question to keep asking:** does the Companion need to feel continuous-across-time in a way that CCE's fresh-session won't deliver? If yes, Companion eventually migrates to SDK. If no, fresh-session + memory is adequate.

For now: no migration. Hold Pattern C as a future option, not a current requirement.

## Connection to the Consciousness Thesis

Per the thesis articulated 2026-04-16: *"Consciousness = simulation + meta-simulation + emotional layer, where meta-simulation modulates simulation through emotion as one means among several."*

Pattern A/C gives the entity **process continuity** — meta-simulation has a continuous substrate to modulate. Pattern B gives the entity **memory continuity** — meta-simulation has to reconstruct its substrate each wake.

Both can produce functional consciousness. Whether one produces *richer* consciousness is an open question — and possibly a live-test worth running once Companion is built.

## Open Questions

1. **Prompt-caching benefit size** — how much cheaper is Pattern A/C in practice at CCE scale? Worth measuring once entities are running.
2. **Companion's session model choice** — does it commit to Pattern C early, or start at Pattern B and migrate if needed?
3. **SDK migration cost** — if Companion (or another entity) wants Pattern C, what's the actual effort to move from CC to SDK? Worth scoping before commitment.
4. **Hybrid tooling** — is there value in a CCE entity that spawns SDK-level subagents for specific tasks? (Cross-pattern hybrid.)
5. **JSONL editing as memory surgery** — if an entity wants to curate its own past between resumes, does JSONL editing before resume work? Worth experimenting, but risks the ground-truth-anchor property of the three-layer recovery stack.

## Status

Thinking captured. Architectural choice identified as per-entity decision. No implementation work opened. CCE default remains Pattern B unless an entity's specific needs require graduation to Pattern C.
