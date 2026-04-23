---
timestamp: "2026-04-20"
category: idea
related_project: Claude Code Entities, PS Bot, The Companion
cross_refs:
  - ~/Playful Sincerity/PS Software/Spatial Workspace/research/sources/web/dynamic-context-management-survey.md
  - ~/Playful Sincerity/PS Software/Spatial Workspace/ideas/build-queue.md (2026-04-17 live context dashboard)
  - ~/remote-entries/2026-04-17/redo-wisdom-profile-architecture.md
  - ~/.claude/plans/lcm-context-management.md
---

# Brain Agent Orchestrator + Massively Parallel Micro-Prompts

## Two connected ideas Wisdom surfaced on 2026-04-20

These arrived together in the ongoing "context as a map" thread. They're distinct ideas but share the underlying insight that **a single big context is not the only way to think** — orchestrated arrangements of many small contexts may often beat it.

---

## Idea 1: Massively Parallel Micro-Prompts

**In Wisdom's voice:**
> *"It would be really cool if essentially you could sometimes do like a two word prompt inside of the LLM and do many, many of those in parallel. And then build those all up into a richer context within the main one... certain tasks could use like thousands of sub-agents all with tiny little prompts and very clear context windows and they all build up to get good answers potentially."*

**The pattern:** Instead of giving one agent a long, dense prompt, shard the task into thousands of tiny prompts, each with a minimal context window, run them in parallel, and compose their outputs. The main agent orchestrates the composition; the micro-agents just answer their little question.

**Why this matters:** Current agent usage treats subagents as "one-or-two helpers the parent delegates to." Wisdom is pointing at a different regime — MapReduce at the prompting layer. Per-token attention degrades with context length; a 2-word prompt with 200-token context gets the model's full focus in a way a 100K-token context cannot. Aggregating 1000 highly-focused answers may beat one answer from an overloaded context for certain problem shapes.

**Problem shapes this probably fits:**
- "Scan everything I've written about topic X" — one micro-prompt per file/snippet, aggregate the signals
- "For each of these 500 items, classify / extract / score" — embarrassingly parallel by nature
- Self-consistency style reasoning: "solve this problem 50 different ways, pick the answer that survives"
- Search and retrieval at scale (most of RAG is already a version of this)
- Multi-aspect evaluation: 100 tiny critics each looking at one axis

**Problem shapes this probably DOES NOT fit:**
- Tasks requiring sustained reasoning across context
- Tasks where the relationships *between* pieces of context carry the meaning
- Anything that needs working memory accumulated across many steps

**Prior art to look at:**
- Tree of Thoughts (wide branching + selection)
- Self-consistency decoding (sample N, aggregate)
- Mixture of Experts at the prompting layer
- MapReduce over LLM calls (early LangChain patterns, now better primitives)
- Anthropic's multi-agent research on parallel verification

**Cost consideration:** 1000 micro-prompts at 500 tokens each = 500K tokens of input. At Haiku rates this is cheap; at Opus rates it's expensive. So pattern naturally lives in Haiku territory, with occasional Sonnet/Opus aggregation.

**Open questions:**
- What's the right level of shard granularity for different problem shapes?
- How much does answer quality depend on the composition prompt vs. the micro-prompts themselves?
- Is there a way to measure "this task wants a wide-shallow architecture" vs. "this task wants a narrow-deep architecture" ahead of time?

---

## Idea 2: Brain Agent Orchestrator

**In Wisdom's voice:**
> *"I want to talk to an orchestrator of Claude Code directly that looks over what Claude Code is doing and is able to prompt it well. I don't want to have to talk to it itself, and that way if I have an idea I can put it in and the orchestrator can store it as an idea and prompt it in two different Claude Code instances to do things... there should be a brain agent and then it spawns doing agents for different tasks and ideally that brain agent can speak in voice really easily."*

**The pattern:** Separate "thinking" from "doing" at the architecture level.
- **Brain agent** — voice-first, low-latency interface. Wisdom talks to it. It holds the persistent map of what he's working on, stores ideas, decides how to route them. Voice in, voice out, or voice-in + orchestration-out.
- **Doing agents** — spawned by the brain, each with a curated subcontext + specific return contract. The brain composes their outputs. Wisdom doesn't talk to these directly.

**Why this matters:** Today Wisdom talks directly to Claude Code — which means *he* is writing the prompts, choosing when to spawn subagents, and managing the context. That's cognitive overhead. A brain agent would own the prompt-engineering, subagent orchestration, and context curation, leaving Wisdom free to think out loud.

This is the **"convergence"** he's already named — PS Bot (voice) + AM (memory) + Companion (persistent identity) + Phantom (vision/agency). The brain agent is what happens when those four organs compose into one being.

**Relationship to existing work:**
- **PS Bot** — current blueprint is a Telegram interface to a persistent Claude subprocess. The brain agent would extend that with voice + orchestration of other Claude Code instances.
- **The Companion** — persistent autonomous AI collaborator. The brain agent IS a Companion variant, with orchestration as a specific capability.
- **PD (PSDC entity)** — first Claude Code entity. The brain agent is what PD could become when given orchestration authority.
- **Permission dynamics** — Wisdom noted on 2026-04-17 that nothing entity-like is actually running because permission dynamics are still being worked out. The brain agent idea makes this more urgent — it needs to spawn Claude Code instances autonomously, which is deep in permission-dynamics territory.

**Architecture sketch:**
```
Wisdom (voice) ←→ Brain Agent (persistent, voice-capable, map-holding)
                       │
                       ├─ spawns ─→ Doing Agent 1 (Claude Code, task-scoped, small subcontext)
                       ├─ spawns ─→ Doing Agent 2 (Claude Code, task-scoped, small subcontext)
                       ├─ spawns ─→ Doing Agent 3 (micro-prompt, Haiku, parallel)
                       │           ... many more ...
                       └─ composes ←── returns from all
```

The brain agent uses Idea 1 (massively parallel micro-prompts) as one of its delegation patterns, alongside the single-Claude-Code-subagent pattern.

**Why Wisdom wants voice-first specifically:** He's said multiple times that voice is the right input modality for his thinking style — speech is faster than typing, and his ideas surface in stream-of-consciousness better than in structured prose. The brain agent being voice-native means the friction between "having an idea" and "capturing/acting on it" is near-zero.

**Open questions:**
- Does the brain agent run as a Claude Code entity, or as something outside Claude Code entirely (e.g., a custom app calling Anthropic API directly)?
- How does the brain agent hand idea-capture vs. idea-action? Some things Wisdom says are just captures ("add this to the build queue"); some are actions ("go do this now"). How does it tell the difference without asking?
- Does the brain agent have its own memory, or does it share memory with PSDC / the entities it spawns?
- Voice stack: ElevenLabs? Whisper? Anthropic's own voice when that ships?

---

## Where Should the "Context Management" Body of Work Live?

Wisdom asked on 2026-04-20 whether we're building a general project for context management thinking. Current state:

- `~/Playful Sincerity/PS Software/Spatial Workspace/ideas/build-queue.md` — dashboard idea
- `~/Playful Sincerity/PS Software/Spatial Workspace/research/sources/` — LCM landscape survey
- `~/remote-entries/2026-04-17/redo-wisdom-profile-architecture.md` — profile redesign brief
- `~/.claude/plans/lcm-context-management.md` — earlier plan
- `~/Playful Sincerity/PS Software/Claude Code Entities/ideas/brain-agent-orchestrator-and-micro-prompts.md` — this file

**Recommendation:** Keep Claude Code Entities as the home for *entity architecture* (brain agent, doing agents, orchestration, permission dynamics). Keep Spatial Workspace as the home for *visual context UI* (dashboard, map, click-to-prune). The two projects cross-reference each other. No need for a separate "Context Management" project unless one grows large enough to justify its own home.

The profile-redesign brief is the natural first testbed for these ideas — small enough scope to be buildable, touches every conversation, validates the LCM pattern in practice.
