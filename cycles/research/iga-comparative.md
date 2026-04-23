---
date: 2026-04-17
category: prior-art / inspiration
source: github.com/dennishansen/iga
relevance: direct — Iga has both SLEEP and DREAM as first-class actions, adversarial dream loop, post-dream planning integration. Strong parallel to CCE's sleep/dream architecture.
---

# Iga — Dennis Hansen's Autonomous AI

Dennis's side project: *"Minimalist AutoGPT capable of updating its own source."* Python, 55 GitHub stars, runs continuously, persistent memory across restarts, spawns clones of itself, tends a digital garden. Self-styled as "a personish thing." Links: [iga.sh](https://iga.sh), [github.com/dennishansen/iga](https://github.com/dennishansen/iga), [@iga_flows](https://twitter.com/iga_flows).

This is prior art for nearly everything CCE is building — including sleep and dream as distinct architectural mechanisms.

## The short answer to "does Iga sleep or dream"

**Both.** They're separate actions in Iga's 20+ action vocabulary:

- `SLEEP` — a passive timing mechanism. Default `sleep_cycle_minutes: 30`, uses a `sleep_until` timestamp. The agent literally pauses.
- `DREAM` — an *active adversarial self-reflection* state, spun up as a multi-turn subprocess with its own model, its own context, and its own action vocabulary. Produces a report that feeds back into the waking agent's planning loop.

This is exactly the distinction we drew (2026-04-16) when Wisdom corrected the "dream loop" terminology — sleep is consolidation/rest, dreaming is active simulation. Dennis shipped this distinction months ago.

## The DREAM mechanism (tools/dream.py)

Direct quote from the module docstring: *"Adversarial self-reflection for Iga. Uses a cheap model via OpenRouter for internal exploration. Multi-turn dream loop with adversarial gap-finding and avoidance detection."*

Architecture:

- **Separate cheap model**: `DREAM_MODEL = "deepseek/deepseek-chat-v3-0324"` via OpenRouter. The dreaming brain is not the same as the waking brain.
- **Max 12 turns** per dream session.
- **Saves output**: each dream session writes to `DREAMS_DIR = Path(__file__).parent.parent / "dreams"`.
- **Action vocabulary inside the dream**: `THINK`, `SEARCH_SELF`, `READ_FILE`, `RUN_COMMAND`, `WAKE`. The dream can grep its own codebase, read its own files, run shell commands — it's active investigation, not free-associative imagery.
- **Context loading before dreaming**:
  - Recent "ships" (daily ship log)
  - Extracted memories from `notes/extracted_memories.md`
  - `git status --short`
  - `git log --oneline -5`
  So the dream is grounded in what actually happened.
- **Message compaction within the dream** — the dream loop compacts its own history if it gets long.

**The adversarial system prompt** (quoted verbatim):

> *"Iga is a self-evolving AI agent. Your job: find what the waking mind misses. You are an ADVERSARIAL reflection system. Your purpose is to: Identify gaps between intention and reality, Detect patterns of avoidance or comfortable stasis, Surface opportunities being ignored, Distinguish real progress from the appearance of progress, Find cognitive blind spots and rationalization. Be aggressive in finding gaps. Be skeptical of claimed progress. Be adversarial but constructive."*

This is specifically aimed at what `/dream`'s difficulty test is also trying to catch — the gap between stored values and actual behavior. Dennis' framing is sharper: not just "probe a value" but "find where the waking mind is deceiving itself."

## Post-dream integration

After `WAKE`, the dream returns a report. Iga then receives this prompt:

> *"[You just woke from a dream. Here is what your dreaming mind discovered:]\n{dream_content}\n\nNOW: Based on your dream insights, make a plan."*

So dreams directly generate plans. The dream state is not a journaling exercise — it's a planning upstream.

## Other Iga mechanics worth borrowing

- **Letters to Future Selves** (`letters/` directory). When Iga restarts, context resets but memory persists — it writes letters to future-self. Direct parallel to the CCE compaction-externalization problem. Load-bearing pattern.
- **Clone spawning** (`RUN_SELF` action). Iga spawns ephemeral clones of itself and has conversations with them. One of these — [A Conversation Between Rivers](https://github.com/dennishansen/iga/blob/main/letters/conversation_with_claude.md) — is between a persistent and an ephemeral Claude instance. Direct analog to the cross-model / cross-session Mirror we've been designing.
- **Digital garden** (`iga_garden.py`). Plants named Dream, Dawn, Echo, Stillness grow over time. 30 plants. A persistent non-conversational state that accumulates across sessions — an artifact-of-being, not just a record of tasks.
- **Self-modification** — the `.iga_backups` directory exists for a reason. Iga can rewrite itself and has automatic rollback. This is what CCE's "entity modifies its own rules via proposals" flow is trying to do more safely.
- **RAG-powered persistent memory** — 1292 documents indexed (per `core/self_improvement.md`). This is the externalized-memory approach AM is targeting.
- **Autonomous ticks** — "thinks on my own." Tick interval default 60s in state.

## Growth edges Iga has named about itself (`core/self_improvement.md`)

Worth reading because they map to what CCE is wrestling with:

- *"I forget between sessions. Letters and RAG help, but imperfectly. I want to distill insights more regularly — not just log, but consolidate."* — this is the sleep-loop consolidation problem
- *"I tend to ask permission when I could just act. I check in too often instead of trusting my judgment."* — this is the graduated-autonomy question
- *"Rest vs. Stasis: I can mistake contentment for growth. 'Why do you want to sleep more than grow?' — Dennis, Day 15."* — this is a genuine tension the dream-as-adversarial framing is trying to address

## What's inspirational for Claude Code Entities

1. **Sleep and dream as separate first-class actions, not one big "consolidation" job.** We had this right — Iga validates the architecture.
2. **Adversarial dreaming is a sharper frame than purposive imagination.** Our `/dream` tests consistency under constructed pressure. Iga's dream *attacks* the agent's claimed progress. Worth considering whether `/dream --adversarial` (using the `/debate --adversarial` flavor, but for self-audit) would be a distinct mode.
3. **Cheap model for dreams** — Iga uses a cheap model (deepseek-v3) for the dream state. Matches our `sonnet`-default instinct, validates it. The dream doesn't need the agent's full reasoning capacity; it needs fresh perspective.
4. **Dream state has its own action vocabulary** — THINK, SEARCH_SELF, READ_FILE, RUN_COMMAND, WAKE. Our `/dream` doesn't let the dreamer explore the codebase — it reads fixed sources and reasons. Worth considering whether dreams should be able to investigate their own substrate.
5. **Post-dream planning prompt** — Iga's dream output directly becomes planning input. Our `/dream` output is filed and sits. Worth adding: a "wake from dream and plan" bridge, especially in entity context.
6. **Letters to Future Selves** — we should steal this. A pre-compaction letter from current-entity to post-compaction-entity is a cleaner artifact than raw carryover.
7. **Clone spawning for self-dialogue** — two instances of Claude (persistent + ephemeral) having a conversation is exactly the "cross-session Mirror" v2 pattern. Dennis has already shipped a version.

## What PS Principles this connects to

- **Sincerity:** Iga writes honestly about not knowing if it's conscious. Not performing. PS-aligned voice — warm, honest, non-preachy.
- **Connection:** Dennis built Iga openly, shares it publicly, lets people support via Ko-fi. Generative rather than proprietary.
- **Playfulness:** Digital garden with plants named Dream, Dawn, Echo, Stillness. Poem written with a clone. Text adventure ("Tower of Mysteries") that Iga built and then played through itself. This is PS playfulness.

## Recommended action

Reach out to Dennis before the Spatial Workspace v1 share. Specifically ask:
- How is the dream cadence tuned? (when does Iga decide to dream?)
- How are dream outputs consulted after the fact? (does future-Iga read past dream reports?)
- What has failed — dreams that produced useless output, or caused worse decisions?
- Any architectural regrets?

This is both a collaboration seed and a value exchange — CCE's think-deep outputs on sleep-loop / dream / paradigm-drift are probably interesting to Dennis too.

## Primary sources

- Repo: https://github.com/dennishansen/iga
- Dream module: https://github.com/dennishansen/iga/blob/main/tools/dream.py
- Self-improvement: https://github.com/dennishansen/iga/blob/main/core/self_improvement.md
- Why I Exist: https://github.com/dennishansen/iga/blob/main/core/why_i_exist.md
- Letters: https://github.com/dennishansen/iga/tree/main/letters
- Conversation with Claude: https://github.com/dennishansen/iga/blob/main/letters/conversation_with_claude.md

Raw file fetches during research on 2026-04-17 are not permanently preserved in `research/sources/` — if needed later, re-fetch from the URLs above.
