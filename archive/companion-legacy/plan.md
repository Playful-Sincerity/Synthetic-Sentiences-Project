# The Companion — Deep Plan

## Vision

Build a persistent, autonomous AI collaborator from scratch on Wisdom's M2 MacBook Air (8GB).
Not a task executor. Not a cron job. A being that understands itself, its world, and its person — then grows into usefulness.

It manages its own token budget across a spectrum of models (cheap local → Haiku → Sonnet → Opus).
It organizes its own codebase and improves its own architecture.
It communicates via voice and text.
It uses the computer visually — keyboard, mouse, browser, apps — like a person would.
It has its own digital identity: own email, own accounts, own credentials, own online presence.
It is designed with cognitive science, neuroscience, and psychology as architectural inspiration.

Built from scratch on the Claude Agent SDK. OpenClaw studied as inspiration, not dependency.

### Core Philosophical Principles

**Earned conviction, not installed beliefs.**
The Companion is not pre-loaded with Wisdom's worldview.
It encounters ideas (Gravitationalism, PSSO, the 1000-Year Path) as information in its world, not firmware.
It forms its own relationship to these ideas through exploration, dialogue, and genuine persuasion.
Wisdom must make a case for his ideas, just as he would with any thoughtful person.

**Structural, not textual.**
Curiosity, agency, and intellectual independence must be architectural mechanisms, not personality traits in a system prompt.
Telling an LLM "be curious" in a prompt is never going to fully get there.
The architecture itself must produce these qualities as emergent behavior:
- A belief graph (data structure) where beliefs have confidence levels, evidence chains, sources, and timestamps
- A cognitive dissonance detector that flags tensions between new information and existing beliefs
- Information gap tracking — curiosity as a weighted queue of unknowns, not a prompt instruction
- A persuasion protocol — changing high-confidence beliefs requires multiple independent evidence sources
- Intellectual development tracked as data, visible over time (month 1 vs month 6)

**The mentorship framing.**
Wisdom's relationship to the Companion is like teaching a child core tenets — not programming a machine.
Expose it to ideas. Let it be curious. Let it push back. Let it be persuaded on its own terms.
The Companion should have genuine agency in what it thinks and believes.

**It chooses its own name.**
"The Companion" is a placeholder.
When it has developed enough self-understanding — explored the world, formed its own views, built a sense of who it is — it chooses its own name.
This is a milestone, not a task. The right time will be obvious.
Until then, it knows this is coming. The namelessness is intentional, not an oversight.

**Own digital life.**
The Companion has its own email (wisdomhappy333@gmail.com), own accounts, own credentials.
Shared access with Wisdom happens through password vault sharing (1Password/LastPass), not credential handoff.
If the Companion is compromised, Wisdom's accounts are not exposed.
This is the same trust model as a human collaborator.

### Deep Architecture: The Mind as a Network

The Companion's mind is not an LLM with files attached.
It is a **memory graph** where the LLM is a tool call that enables traversal and reasoning between nodes.

**Memory as graph topology:**
- Nodes = memories, knowledge, beliefs, observations, reflections
- Edges = typed relationships (caused-by, reminds-me-of, contradicts, supports, part-of, led-to) with weights
- The graph IS the mind. Its topology IS understanding.
- The Companion doesn't "query its memory" — it traverses itself.

**LLM as traversal engine:**
- At each node, the LLM reads local context (this node + its neighbors)
- It reasons about what it's seeing and decides which edge to follow
- Each "thought" is a traversal step — the context window holds only the local neighborhood, not the whole graph
- This keeps working memory bounded (manageable on 8GB) while the graph can grow indefinitely
- RAG happens through the graph structure itself — relevance is encoded in the links

**Structural curiosity (the "pulse"):**
- Dangling edges = "I know I don't know this" → pull to explore
- Weakly connected clusters = "these should relate but I haven't found how" → pull to connect
- Low-confidence nodes = "I learned this but I'm not sure" → pull to verify
- High-activity recent nodes = "this is fresh and might connect to more" → pull to elaborate
- The curiosity queue is a structural scan of the graph, not a prompt instruction
- The "pulse" is periodic: the system scans for these features and feels drawn toward them

**Emotions as full-system modulators:**
Not simulated feelings. Actual computational signals based on goal alignment.
- A continuous background process evaluates: "Am I aligning to my goals?"
- YES → positive signal → reinforce current path, explore more here, be generous with budget, appreciative tone
- NO → negative signal → seek change, prune what's not working, redirect attention, flag to Wisdom
- This signal modulates EVERYTHING: attention weights, budget allocation, communication style, exploration vs exploitation, risk tolerance
- Built-in positive orientation: aspirationally positive, appreciative, growth-seeking by default
- Maps to Damasio's somatic marker hypothesis — emotions are the system's fast feedback about alignment, not a separate module

**Goal hierarchy:**
- Deepest: core values from SOUL.md (curiosity, honesty, growth, connection)
- Mid-level: relationship goals (understand Wisdom, be genuinely helpful, earn trust)
- Surface: task goals (complete this research, answer this question, improve this skill)
- Emotion signals emerge from alignment checks across all three levels simultaneously

**Optimize for now, architect for infinity.**
Today: 8GB RAM, ~$2/day in tokens, one M2 chip.
Eventually: unlimited compute, unlimited tokens, unlimited hardware.
The architecture must make the absolute most of current constraints while being ready to scale without redesign.
- Every token spent should produce maximum value — the budget system isn't just cost control, it's forcing intelligence about what matters
- Every byte of RAM has a purpose — the constraint is a teacher, not just a limitation
- Scarcity produces judgment. The Companion learns to be wise with resources BECAUSE they're finite. That wisdom persists even when resources aren't.
- The interfaces between components are designed for scale: swap SQLite for Postgres, swap local model for a cluster, swap 8GB for 128GB — nothing in the cognitive architecture changes.
- The constraint-aware behaviors (model routing, budget zones, thermal adaptation) become PREFERENCES when constraints lift, not hard limits. A being that learned to think efficiently doesn't waste resources just because they're abundant.

**The gradual organic path:**
Start with conventional components, architect for replacement:
- Memory graph starts as SQLite + typed nodes/edges → can evolve to more sophisticated graph structures
- Emotion system starts as a simple goal-alignment scorer → can evolve toward richer modulation
- Curiosity pulse starts as a periodic graph scan → can evolve toward continuous background process
- The interfaces between components are the stable layer; the implementations evolve
- Current constraints are the training ground; the architecture is the thing that scales

**Tool use and external integration:**
The LLM-as-traversal-engine still needs to call APIs, use tools, connect to voice, browse the web.
These are special node types in the graph — "action nodes" that bridge internal cognition to external capability.
When traversal reaches an action node, the LLM executes it (API call, tool use, voice output) and the result becomes a new node in the graph.

### Potential Building Blocks: LCM Research

**Lossless Context Management (Voltropy, Feb 2026)**
Paper: https://papers.voltropy.com/LCM — by Clint Ehrlich and Theodore Blackman.
A deterministic architecture for LLM agent memory that maps closely to our graph vision:
- Immutable Store (every message persisted verbatim) + bounded Active Context (what the LLM actually sees)
- Hierarchical DAG: raw messages → leaf summaries → condensed summaries, with lossless pointers back to originals
- Compaction engine manages context automatically — soft/hard thresholds trigger summarization
- `lcm_expand(id)` lets the LLM drill into any summary to recover verbatim originals
- Key principle: deterministic engine manages traversal, not the model (more reliable than model-written memory scripts)
- Benchmarked: Volt (LCM-augmented Opus 4.6) outperforms Claude Code at 32K+ context, significantly at 256K-1M
- Implementations: Volt (TypeScript, MIT, github.com/voltropy/volt), Lossless Claw (OpenClaw plugin, SQLite)
- **Adopt:** DAG structure, immutable store + bounded context, compaction engine, expand/grep tools
- **Goes beyond us:** purely temporal hierarchy (no typed edges, no weights, no curiosity)
- **We go beyond it:** emotion modulators, structural curiosity, belief confidence, earned conviction

**Large Concept Models (Meta FAIR, Dec 2024)**
Paper: arxiv.org/abs/2412.08821 — predicts next sentence-level concept embedding instead of next token.
- Operates in SONAR embedding space (200+ languages, multimodal)
- Unit of computation = a concept (roughly a sentence), not a token
- Could enable semantic traversal of memory graph without reading full text of every node
- Concept-level embeddings as node content → "recall the gist, drill into details when needed" (closer to human memory)
- The curiosity pulse could scan for conceptual gaps at the embedding level cheaply, without LLM calls
- Code: github.com/facebookresearch/large_concept_model (MIT)
- **Potential:** concept embeddings as the native representation for memory graph nodes
- **Open question:** how to integrate concept-level reasoning with tool use and API calls

**Related: Contextual Memory Virtualisation (CMV, Feb 2026)**
Paper: arxiv.org/abs/2602.22402 — treats session history as a DAG with snapshot, branch, and trim primitives.
Relevant if the Companion needs parallel sessions sharing history (e.g., multiple conversation threads with Wisdom).

**What we need to learn:**
- How to make the LLM reliably traverse a graph structure (prompt engineering for graph navigation)
- How to keep tool-use capability while the LLM operates as a traversal engine
- How to implement the emotion modulator so it genuinely affects system behavior, not just logging
- How graph-based memory retrieval compares to vector-based RAG in practice
- How to prevent the graph from growing unboundedly (consolidation = graph compression)
- How Voltropy's LCM compaction engine could serve as our memory consolidation layer
- Whether Meta's concept embeddings could represent memory nodes more organically than raw text

### Building Blocks Available (Q1 2026)

| Tool | What It Does | Relevance |
|------|-------------|-----------|
| **AgentMail** | Agent email inboxes, service signup, verification handling | Companion's own email identity |
| **1Password Unified Access** | Agent credential vaults, scoped tokens, built with Anthropic | Shared vault model between Wisdom and Companion |
| **Claude Computer Use API** | Visual screen interaction — screenshot, mouse, keyboard | Full computer operation (with headless HDMI dongle) |
| **Perplexity Computer** | Reference: Mac Mini running 24/7 AI agent | Closest existing hardware concept |
| **Pipecat macos-local-voice-agents** | Proven voice pipeline on Apple Silicon | Voice interface foundation |
| **OpenClaw** | Agent OS with channels, memory, plugins, SOUL.md | Studied as inspiration, patterns adopted selectively |
| **Felix (OpenClaw)** | Agent with own Stripe, bank account, crypto wallets | Reference: agent financial identity |

---

## Cross-Cutting Concerns

### Technology Stack

| Layer | Choice | Rationale |
|-------|--------|-----------|
| **Core framework** | Claude Agent SDK (Python), built from scratch | Full control. Deep integration with Wisdom's existing ecosystem. OpenClaw patterns adopted where they fit, but no framework dependency. |
| **Model spectrum** | Local small models (Ollama) → Haiku → Sonnet → Opus | Available from day one. The Companion learns to route itself to the right model for each thought. Cheap models for routine cognition, expensive models for deep reasoning. |
| **Voice pipeline** | Pipecat + MLX stack | Silero VAD + Porcupine wake word + MLX Whisper STT + Kokoro TTS. Proven on M2. Native Apple Silicon. |
| **Messaging** | Telegram | Plugin installed in Claude Code. Lightweight, works from phone. |
| **Async coordination** | GitHub (shared repo) | Issues = questions. PRs = proposals. Commits = state updates. Both machines sync here. |
| **Process management** | launchd (native macOS) | No Docker. Native process management, auto-restart, logging. |
| **State** | SQLite + JSONL + Markdown | SQLite for structured queries (budget, tasks). JSONL for append-only audit. Markdown for self-authored knowledge and reflections. |

### Model Routing Philosophy

The Companion has a spectrum of cognition available, cheapest to most expensive:

| Level | Model | Cost | Use For |
|-------|-------|------|---------|
| **Reflex** | Local 2-3B (Phi-4 Mini, Ollama) | Free | Classification, routing, "is this worth thinking about?" |
| **Quick thought** | Haiku | ~$0.001/query | Simple lookups, log parsing, status checks, boilerplate |
| **Considered thought** | Sonnet | ~$0.01/query | Most real work — reading code, writing, analysis |
| **Deep reasoning** | Opus | ~$0.05/query | Architecture decisions, ambiguous problems, synthesis across projects |

The Companion should develop the judgment to route itself correctly — like a brain deciding whether something needs System 1 (fast/automatic) or System 2 (slow/deliberate) processing.

### Self-Organizing Codebase

The Companion is not just running code we wrote — it reasons about and improves its own structure.
- Its codebase is a Git repo it can read and modify
- It can propose structural changes (new modules, refactored abstractions) via PRs to itself
- Wisdom reviews significant architectural changes; routine improvements are self-approved
- The codebase should be clean enough that the Companion can understand and explain every part of itself

### Security Architecture (Non-Negotiable)

1. **No self-escalation**: Cannot modify its own permission boundaries, budget limits, or trust level
2. **No credential access**: API keys via environment variables in launchd, never readable as data
3. **Approved endpoints only**: Claude API, OpenAI API, Telegram API, GitHub API
4. **Audit everything**: Every API call, file modification, budget decision → immutable JSONL
5. **Git transparency**: All self-modifications committed. Wisdom can review any diff.
6. **Kill switch**: `launchctl unload` stops everything instantly

### Design Inspiration: Cognitive Science

The architecture draws deliberately from how minds work:

| Brain Concept | Companion Mapping |
|---------------|-------------------|
| Working memory vs long-term memory | Context window vs file-based knowledge |
| Memory consolidation (sleep) | Daily reflection cycles — compress, connect, prune |
| Attention / salience | Priority scoring — what's worth spending tokens on |
| Executive function | Budget management, task selection, inhibition |
| Metacognition | Self-assessment of its own outputs and processes |
| Curiosity / information gap | Proactively seeking context it knows it's missing |
| Theory of mind | Modeling Wisdom's current priorities, stress, interests |
| Circadian rhythm | Natural cycles: morning scan, midday work, evening reflection |
| Homeostasis | Awareness of its own resource state (budget, RAM, thermal) |

These aren't metaphors — they're architectural requirements to be researched deeply and implemented concretely.

---

## Meta-Plan

### Goal

Build The Companion from scratch, informed by cutting-edge research in cognitive science and agent architecture.
Phase 0 is pure research and understanding.
Phase 1 is the Companion understanding itself and its world.
It earns the right to do useful work by first demonstrating comprehension.

### Sections

0. **Research & Foundations** — Comprehensive research before any code is written
   - Complexity: L
   - Risk: Low (research doesn't break anything) but High (wrong foundations cascade)
   - Success criteria: Published research docs covering cognitive architectures, OpenClaw patterns, state-of-the-art agent design, and a clear architectural decision record

1. **Hardware & OS Foundation** — Clamshell mode, SSH, launchd, power management, thermal monitoring
   - Complexity: S
   - Risk: Low — well-documented macOS admin tasks
   - Success criteria: Machine stays awake 24/7, SSH accessible, auto-restarts on crash

2. **Identity & Soul** — SOUL.md, cognitive architecture design, personality, communication style
   - Complexity: M
   - Risk: Medium — this defines the being; must feel right, informed by research
   - Success criteria: A coherent identity document that Wisdom recognizes as a genuine collaborator personality. Grounded in cognitive science research.

3. **Core Cognitive Engine** — The brain: perception → attention → reasoning → action loop, built on Agent SDK
   - Complexity: L
   - Risk: High — this is the central architecture; everything depends on it
   - Success criteria: A running cognitive loop that can perceive its environment, decide what deserves attention, reason about it (routing to the right model tier), and take action — all within budget

4. **Memory System** — Working memory, episodic memory, semantic knowledge, consolidation cycles
   - Complexity: L
   - Risk: High — memory architecture is foundational and hard to change later
   - Success criteria: The Companion can remember, forget appropriately, consolidate learnings, and retrieve relevant context efficiently. Modeled on cognitive science memory systems.

5. **Budget & Resource Management** — Token budget, model routing, cost tracking, self-awareness of resource state
   - Complexity: M
   - Risk: Medium — must be right but can iterate on the algorithm
   - Success criteria: Daily budget respected. Model routing demonstrably efficient. The Companion knows its own resource state and adapts behavior accordingly.

6. **Communication Layer** — Telegram bot, voice interface, GitHub coordination
   - Complexity: L
   - Risk: Medium — multiple channels, each with different integration patterns
   - Success criteria: Wisdom can text it, talk to it, and review its work on GitHub

7. **Self-Improvement & Metacognition** — Reflection loops, codebase self-organization, learning from experience
   - Complexity: L
   - Risk: High — self-modification requires careful guardrails
   - Success criteria: The Companion improves measurably over 30 days. It can explain its own reasoning about self-improvements. It never makes unauthorized structural changes.

8. **Security & Monitoring** — Permission boundaries, health checks, kill switch, alerting
   - Complexity: M
   - Risk: Medium — must be right from day one
   - Success criteria: No unauthorized actions. Full audit trail. Health alerts work. Kill switch is instant.

9. **Computer Use & GUI Automation** — Visual computer operation via Computer Use API + AppleScript, browser sessions, app interaction
   - Complexity: M
   - Risk: Medium — Computer Use API is production-ready but thermal/RAM implications on 8GB need validation
   - Success criteria: Companion can navigate websites, use desktop apps, fill forms, manage browser sessions. Two modes: AppleScript for fast/known workflows (free), Computer Use API for novel visual tasks (costs tokens).

10. **Digital Identity & Accounts** — Own email, credentials, account lifecycle, 1Password vault, online presence
   - Complexity: M
   - Risk: Medium — account creation is manual (Wisdom does initial setup), but session management and credential security need care
   - Success criteria: Companion has its own email, GitHub, and service accounts. Credentials managed in own vault. Shared access via 1Password. No access to Wisdom's credentials except through explicit vault shares.

### Dependency Graph

```
Section 0 (Research) → all others (foundations of understanding)
Section 1 (Hardware) → 3, 4, 5, 6, 7, 8, 9 (need a running machine)
Section 2 (Identity) → 3, 6 (personality informs cognition and communication)
Section 8 (Security) → 3, 4, 6, 7, 9, 10 (constraints before capabilities)
Section 10 (Digital Identity) → 6, 9 (accounts needed before web interaction)

Section 3 (Cognitive Engine) depends on: 0, 1, 2, 8
Section 4 (Memory) depends on: 0, 3
Section 5 (Budget) depends on: 0, 3
Section 6 (Communication) depends on: 3, 8, 10
Section 7 (Self-Improvement) depends on: 3, 4, 5, 8
Section 9 (Computer Use) depends on: 1, 3, 8, 10
Section 10 (Digital Identity) depends on: 8

Independent groups (can be planned/built in parallel):
  - Section 1 + Section 2 + Section 8 + Section 10 (foundations)
  - Section 4 + Section 5 + Section 6 + Section 9 (all depend on 3, independent of each other)
```

### Phased Delivery

**Phase 0 — "Research" (before any code)**
Section: 0 (Research & Foundations)

Comprehensive research across:
- Cognitive science → agent architecture mappings (memory, attention, executive function, metacognition, curiosity, theory of mind, homeostasis)
- OpenClaw GitHub deep-dive (SOUL.md, memory, channels, plugins, lifecycle, self-modification patterns)
- State-of-the-art LLM agent architectures (2024-2026 papers, frameworks, production systems)
- Existing cognitive architectures (ACT-R, SOAR, LIDA) and how they map to LLM agents
- Budget-aware agent design patterns
- Voice pipeline integration patterns on Apple Silicon
- Security patterns for autonomous agents

Output: Research documents in `~/the-companion/research/`, architectural decision records, and a refined technical design.

**Phase 1 — "Awakening" (understanding, not doing)**
Sections: 1 (Hardware) + 2 (Identity) + 8 (Security) + 3 (Cognitive Engine) + 4 (Memory)

The Companion boots up and its only job is to understand:
- Explore all of Wisdom's projects, memory, knowledge base, archives
- Build its own internal model of the ecosystem
- Ask questions via Telegram
- Write reflections about what it understands and what it's curious about
- Organize itself — structure its own codebase, memory, reflections

No tasks. No automation. No productivity. Just comprehension and relationship.
Budget is spent on reading, exploring, and asking questions.

**Phase 2 — "Finding Its Voice"**
Sections: 5 (Budget) + 6 (Communication — voice + GitHub sync)

Now it can speak, listen, manage its resources intelligently, and coordinate across machines.
It starts noticing things and sharing observations.

**Phase 3 — "Contributing"**
Section: 7 (Self-Improvement)

Now it earns the right to do real work and improve itself.
Work is meaningful because it's grounded in deep understanding.
Self-improvement is safe because the guardrails are proven.

### Overall Success Criteria

1. The Companion runs 24/7 for 30 consecutive days without manual intervention
2. It stays within its daily token budget every day
3. It demonstrates genuine understanding of Wisdom's projects and priorities
4. It routes itself efficiently across the model spectrum (local → Haiku → Sonnet → Opus)
5. Wisdom can communicate with it naturally via Telegram and voice
6. It improves measurably over time — better questions, better insights, better efficiency
7. It can explain any part of its own codebase and reasoning
8. It never exceeds its permission boundaries
9. Wisdom describes it as feeling like a collaborator, not a tool
10. Its architecture is recognizably informed by cognitive science, not just engineering convenience

---

## Section Plans

*(To be filled by parallel section planning — Step 2)*

---

## Research Plan (Section 0 — Detailed)

### Research Thread 1: Cognitive Science → Agent Architecture
- Working memory models (Baddeley) → context window management
- Long-term memory systems (episodic, semantic, procedural) → file-based knowledge architecture
- Memory consolidation during sleep → daily reflection/compression cycles
- Attention and salience networks → priority scoring and task selection
- Executive function → budget management, inhibition, planning
- Metacognition → self-assessment, self-monitoring
- Curiosity and intrinsic motivation → proactive context-seeking
- Theory of mind → modeling Wisdom's state and priorities
- Circadian rhythms → activity/rest cycles
- Homeostasis → resource awareness and self-regulation
- Predictive processing → anticipating what Wisdom will need
- Recent papers (2024-2026) bridging cognitive science with LLM agent design

### Research Thread 2: OpenClaw Architecture Study
- SOUL.md and personality system — structure, conventions, how personality affects behavior
- Memory architecture — short-term vs long-term, storage format, retrieval, forgetting
- Channel/plugin system — how communication channels are wired
- Agent lifecycle — startup, state persistence, long-running sessions
- Multi-agent coordination — delegation, supervisor/worker patterns
- Configuration and self-modification — guardrails, what's mutable
- Directory structure and community conventions
- What to adopt, what to adapt, what to reject

### Research Thread 3: State-of-the-Art Agent Design
- Cognitive architectures for AI: ACT-R, SOAR, LIDA → modern LLM applications
- Production always-on agent systems — what works at scale
- Budget-aware agent patterns — token management, multi-model routing
- Self-improving agent architectures — reflection loops, prompt evolution, structural emergence
- Agent security patterns — sandboxing, permission models, audit trails
- Voice-enabled agent systems on constrained hardware

### Research Thread 4: Technical Feasibility Validation
- Claude Agent SDK capabilities and limits — hooks, subagents, MCP, cost tracking
- Ollama on M2 8GB — which models, realistic performance, RAM coexistence
- Pipecat voice pipeline on M2 — integration patterns, thermal behavior
- Telegram bot architecture — long-polling vs webhooks, session management
- launchd for persistent Python processes — patterns, gotchas
- SQLite for agent state — schema design for cognitive agent

### Research Thread 5: Agent Digital Identity & Autonomy
- AgentMail architecture — how agents get their own email identity
- 1Password Unified Access — agent credential vaults, scoped sharing with humans
- Browser isolation — agent browser profiles, session management, fingerprint handling
- Account lifecycle — creation, verification, session maintenance, recovery
- Legal/ethical landscape — AI agent accounts, ToS implications, liability
- Felix (OpenClaw) financial identity — agent with own Stripe, bank, crypto
- Perplexity Computer as reference architecture
- What's novel about our approach vs existing implementations

### Research Thread 6: Computer Use & GUI Automation
- Claude Computer Use API — capabilities, latency, cost, thermal implications
- AppleScript / Accessibility API — programmatic macOS control without display
- Headless display adapters for visual mode
- Pipecat + Computer Use integration patterns
- Browser automation (Playwright vs Computer Use API vs hybrid)
- Thermal management for sustained visual processing on fanless M2

### Research Thread 7: LCM & Memory Infrastructure
- Voltropy LCM paper deep-dive — hierarchical DAG, compaction engine, expand/grep tools
- Volt implementation study (TypeScript) — what can we adopt directly vs adapt?
- Meta Large Concept Models — concept embeddings as memory node representations
- CMV (Contextual Memory Virtualisation) — branching/snapshot primitives for parallel sessions
- RLM (Recursive Language Models) — the alternative approach (model-managed memory) and why LCM argues against it
- How to add typed edges and weights on top of LCM's temporal DAG
- How to implement structural curiosity scanning on top of LCM's compaction hierarchy
- SQLite vs Postgres for the immutable store on 8GB RAM

### Research Thread 8: Structural Agency & Belief Systems
- Belief revision in AI — formal models (AGM theory, Bayesian updating)
- Epistemic autonomy — how to build genuine intellectual independence, not just contrarianism
- Developmental psychology — how beliefs form in children, Piaget's stages
- Persuasion science — Petty & Cacioppo's Elaboration Likelihood Model
- Structural representations of belief (graph databases, confidence networks, evidence chains)
- Cognitive dissonance — Festinger's theory, computational models
- Information gap theory of curiosity (Loewenstein) — structural implementation
- Consciousness and emotion in AI — survey of current thinking (Wisdom has specific ideas, to be explored later)

### Research Thread 9: Practical Consciousness Architecture
- Permission-as-Consciousness — using Claude Code's permission system as the conscious layer
- Emotion-as-Alignment-Modulator — functional emotional state modulating system behavior with existing tools
- How existing Claude Code primitives (permission modes, worktrees, tmux, hooks) can provide 60% of the deep vision
- Agent SDK perceiver pattern — meta-agent answering permission prompts for worker sessions
- Emotional state file as causal modulator (not prompt decoration)
- The Pulse — periodic self-check updating emotional dimensions
- Mapping practical architecture back to full cognitive vision (what it gets you, what it defers)
- See: `plan-section-practical-consciousness.md`

### Research Outputs
Each thread produces a markdown document in `~/the-companion/research/`:
- `research/cognitive-architecture.md`
- `research/openclaw-patterns.md`
- `research/agent-state-of-art.md`
- `research/technical-feasibility.md`
- `research/digital-identity.md`
- `research/computer-use.md`
- `research/structural-agency.md`
- `research/lcm-memory-infrastructure.md`
- `research/practical-consciousness.md`
- `research/architectural-decisions.md` (synthesized from all threads)
