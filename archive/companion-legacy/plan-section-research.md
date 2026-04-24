# Section 0: Research & Foundations — Detailed Plan

## Purpose

Answer the questions that, if answered wrong, would cascade into bad architecture.
Every downstream section (Identity, Cognitive Engine, Memory, Budget, Communication, Self-Improvement, Security) depends on research findings from this phase.
No code is written during Phase 0 — only understanding.

---

## Guiding Principles

1. **Research the "why" before the "how"** — Cognitive science comes first because it shapes what we build, not just how we build it.
2. **Feasibility gates before design** — Don't design an architecture the hardware can't run.
3. **Parallel where possible, sequential where findings depend** — Some threads can run simultaneously; others must wait for upstream answers.
4. **Each task produces a concrete artifact** — A markdown document with findings, implications, and open questions.
5. **Synthesis is a separate, deliberate step** — Raw research is useless without translating findings into architectural decisions.

---

## Research Dependency Graph

```
R0 (Feasibility) ─────────────────────────────────────────┐
R1 (Cognitive Science — Memory) ──────┐                    │
R2 (Cognitive Science — Attention) ───┤                    │
R3 (Cognitive Science — Executive) ───┼─→ R9 (Synthesis) ──┼─→ R10 (Architecture)
R4 (Cognitive Science — Meta) ────────┤                    │
R5 (OpenClaw Deep Dive) ─────────────┤                    │
R6 (Agent Architectures — Classical) ─┤                    │
R7 (Agent Architectures — Modern) ────┤                    │
R8 (Security Patterns) ──────────────┘                    │
R0 (Feasibility) ─────────────────────────────────────────┘
```

R0 runs first because it sets hard constraints.
R1-R8 can run in parallel (order below is suggested, not required).
R9 synthesizes all threads.
R10 translates synthesis into an architectural decision record.

---

## Task List

### Wave 0: Hard Constraints (run first)

---

### R0: Technical Feasibility Validation

**Goal:** Establish the hard boundaries of what the M2 MacBook Air 8GB can actually do, so every subsequent design decision respects reality.

**Scope:**
- Claude Agent SDK: capabilities, hooks, subagent spawning, MCP integration, cost tracking APIs, streaming, tool calling limits, Python SDK version and stability
- Ollama on M2 8GB: which models fit in RAM alongside the rest of the system (Python process, SQLite, voice pipeline)? Realistic inference speed for Phi-4 Mini, Qwen 2.5 0.5B/1.5B, Gemma 2B. Quantization tradeoffs. Can Ollama run concurrently with Whisper MLX?
- Pipecat voice pipeline on M2: Silero VAD + Porcupine wake word + MLX Whisper + Kokoro TTS — memory footprint of each, combined RAM. Thermal behavior under sustained use. Latency benchmarks.
- Telegram bot architecture: long-polling vs webhooks for always-on bot. Session management for persistent conversations. Rate limits. Message types supported.
- launchd for persistent Python processes: plist configuration patterns, auto-restart on crash, stdout/stderr logging, environment variable injection, watchdog patterns
- SQLite for agent state: WAL mode for concurrent read/write, schema design patterns for time-series data (budget logs), full-text search for memory retrieval, realistic query performance
- RAM budget: how much RAM is available for the cognitive process after macOS, Ollama model, and voice pipeline are loaded? This is the critical constraint.

**Research methods:**
- Read Claude Agent SDK docs and source code
- Run Ollama benchmarks on the actual M2 machine (memory, speed, thermal)
- Read Pipecat docs and MLX Whisper benchmarks
- Test launchd with a simple persistent Python process
- SQLite performance tests with representative data sizes

**Output:** `research/technical-feasibility.md`
- Hard constraints table (RAM budget, inference speed, concurrency limits)
- "Yes/No/Maybe" verdict for each planned component
- Recommended model shortlist for local inference
- Identified risks and mitigations
- Voice pipeline feasibility verdict with RAM breakdown

**Critical questions this answers:**
- Can the voice pipeline and Ollama run simultaneously? Or must they take turns?
- What is the realistic local model tier? (This directly affects the model routing design in Section 5)
- Is Pipecat the right choice or do we need a lighter alternative?
- What is the actual RAM budget for the Python cognitive process?

**Duration:** 1 focused session (may include running actual benchmarks)

---

### Wave 1: Parallel Research Threads (run after R0)

These can run in any order or in parallel. Each is one focused agent session.

---

### R1: Cognitive Science — Memory Systems

**Goal:** Understand how biological memory works deeply enough to design an artificial memory system that is genuinely informed by cognitive science, not just using memory terms as metaphors.

**Scope:**
- **Baddeley's working memory model**: phonological loop, visuospatial sketchpad, central executive, episodic buffer. What maps to an LLM context window? What doesn't?
- **Long-term memory taxonomy**: episodic (events), semantic (facts), procedural (skills). How does each form, consolidate, and decay? What are the retrieval mechanisms?
- **Memory consolidation**: the role of sleep and offline processing. Synaptic homeostasis hypothesis. How memories move from hippocampus to cortex. What does "consolidation" mean for an AI agent? (Not just compression — reorganization, generalization, connection-finding.)
- **Forgetting**: Is forgetting a bug or a feature? Interference theory, decay theory, retrieval failure. When should the Companion forget? What is the cost of remembering everything?
- **Retrieval**: Encoding specificity, context-dependent memory, spreading activation. How does the brain find the right memory at the right time? Implications for embedding-based vs keyword-based vs contextual retrieval.
- **Prospective memory**: remembering to do things in the future ("remind me to..." but also self-initiated intentions). How does this work neurally?
- **Metamemory**: knowing what you know, feeling of knowing, tip-of-the-tongue states. Can we give the Companion a sense of what it remembers vs what it needs to look up?

**Research methods:**
- Web search for key papers and review articles (2020-2026)
- Read relevant sections of cognitive psychology textbooks (if available digitally)
- Look for existing "cognitive science meets AI memory" papers specifically

**Output:** `research/cognitive-memory.md`
- Summary of each memory system with architectural implications
- Concrete mapping table: biological mechanism → Companion design element
- Anti-patterns: what NOT to do (common mistakes when mapping memory to AI)
- Open design questions that need resolution in R9

**Critical questions this answers:**
- Should episodic and semantic memory be separate stores or views on the same store?
- What triggers consolidation and how often should it run?
- How do we implement forgetting without losing important information?
- What retrieval mechanism best maps to spreading activation?

---

### R2: Cognitive Science — Attention, Salience, and Prioritization

**Goal:** Understand how biological attention works to design a priority/attention system that isn't just a task queue with scores.

**Scope:**
- **Bottom-up vs top-down attention**: stimulus-driven (something pops up) vs goal-directed (I'm looking for X). The Companion needs both.
- **Salience networks**: how the brain decides what's worth attending to. Novelty, relevance, emotional significance, surprise.
- **Attentional bottleneck**: the brain can't attend to everything. How does it select? What gets filtered out? Implications for an agent that could theoretically process everything.
- **Sustained attention vs vigilance**: maintaining focus over long periods. Vigilance decrement. Should the Companion have "attention fatigue"?
- **Task switching costs**: the brain pays a real cost when switching between tasks. Does this matter for an LLM agent? (Context switching = context window pollution)
- **Predictive processing**: the brain constantly predicts what will happen next and attends to prediction errors (surprises). This maps to anticipating Wisdom's needs.
- **Curiosity as attention**: information gap theory (Loewenstein), intrinsic motivation. When should the Companion actively seek information vs wait passively?

**Research methods:**
- Web search for attention and salience network papers
- Look for "predictive processing" + "AI agent" crossover research
- Look for computational models of attention (not just descriptions)

**Output:** `research/cognitive-attention.md`
- Biological attention mechanisms with architectural mappings
- Design implications for the event processing pipeline
- Proposed salience scoring dimensions (novelty, relevance, urgency, emotional weight, prediction error)
- How curiosity/proactive behavior should be triggered
- Circadian rhythm design: when the Companion should be vigilant vs reflective vs dormant

**Critical questions this answers:**
- How does the Companion decide what to think about when nothing is explicitly asked?
- Should it have something like "attention fatigue" that triggers rest cycles?
- How do we implement predictive processing (anticipating needs) concretely?
- What is the right circadian rhythm for an AI agent?

---

### R3: Cognitive Science — Executive Function and Decision-Making

**Goal:** Understand how the brain manages itself — planning, inhibition, task management, resource allocation — to design the Companion's self-management system.

**Scope:**
- **Executive function components**: planning, inhibition, cognitive flexibility, working memory updating. Miyake's unity/diversity model.
- **Prefrontal cortex as controller**: how the PFC manages other brain systems. Analogies to a "meta-agent" or "executive module."
- **Decision-making under uncertainty**: prospect theory, satisficing vs optimizing, heuristics and biases. When should the Companion take the "good enough" path vs deliberate deeply?
- **Inhibition**: the ability to NOT do something. Crucial for an autonomous agent — knowing when NOT to act, NOT to spend tokens, NOT to interrupt.
- **Planning and temporal reasoning**: how the brain plans sequences of actions. Hierarchical task decomposition. Goal management.
- **Homeostasis and allostasis**: maintaining internal stability. The body constantly monitors and adjusts. Maps directly to resource management (budget, RAM, thermal).
- **Dual process theory (Kahneman)**: System 1 (fast, automatic, cheap) vs System 2 (slow, deliberate, expensive). This is the conceptual foundation of the model routing spectrum.

**Research methods:**
- Web search for executive function models, especially computational ones
- Look for "dual process theory" + "AI" or "LLM agent" research
- Search for homeostatic regulation in autonomous systems

**Output:** `research/cognitive-executive.md`
- Executive function components mapped to Companion subsystems
- Dual process theory as the basis for model routing (detailed mapping)
- Inhibition patterns: when and how the Companion should suppress action
- Homeostasis design: what variables to monitor, what set points to maintain
- Decision-making framework: when to satisfice vs optimize

**Critical questions this answers:**
- How should the "executive" relate to the cognitive loop architecturally? Is it a separate module or woven into the loop?
- What does System 1 / System 2 routing look like concretely with local models / Haiku / Sonnet / Opus?
- How granular should budget homeostasis be? (Per-hour? Per-task? Per-day?)
- When should the Companion decide NOT to act?

---

### R4: Cognitive Science — Metacognition, Theory of Mind, and Social Cognition

**Goal:** Understand self-awareness and other-awareness to design the Companion's ability to monitor itself and model Wisdom.

**Scope:**
- **Metacognition**: thinking about thinking. Metacognitive monitoring (how well am I doing?) and metacognitive control (should I change strategy?). Confidence calibration.
- **Self-models**: how the brain maintains a model of itself. Body schema, agency, sense of self. What does a "self-model" look like for an AI agent?
- **Theory of mind**: modeling another's mental states, beliefs, intentions, knowledge. How does the brain do this? What aspects are relevant for modeling Wisdom?
- **Emotional modeling**: not giving the Companion emotions, but understanding Wisdom's emotional state from text/voice signals. Pragmatics, sentiment, context.
- **Communication as coordination**: Grice's maxims, common ground, conversation repair. How should the Companion communicate given what it knows about Wisdom's current state?
- **Learning from interaction**: how humans build models of their collaborators over time. What should the Companion track about its interactions with Wisdom?

**Research methods:**
- Web search for metacognition in AI systems
- Look for "theory of mind" + "LLM" research (there's been substantial work 2023-2026)
- Search for human-AI collaboration research

**Output:** `research/cognitive-social.md`
- Metacognitive monitoring design: what the Companion should track about its own performance
- Self-model specification: what the Companion knows about itself and keeps updated
- Theory of mind implementation: how to build and maintain a model of Wisdom
- Communication style adaptation based on context
- Trust and calibration: how the Companion expresses uncertainty

**Critical questions this answers:**
- What data should the Companion collect about itself for metacognitive monitoring?
- How does the Wisdom-model get built and updated? What signals are used?
- How should the Companion express uncertainty? (Calibration is crucial for trust.)
- What aspects of theory of mind are tractable for an LLM agent vs aspirational?

---

### R5: OpenClaw Architecture Deep Dive

**Goal:** Study OpenClaw thoroughly as the closest existing system to what we're building, extracting patterns to adopt, adapt, and reject.

**Scope:**
- **SOUL.md system**: structure, how personality directives affect agent behavior, versioning, how detailed vs abstract they are. Compare with other "system prompt engineering" approaches.
- **Memory architecture**: short-term (context) vs long-term (file/DB). Storage formats. Retrieval mechanisms. How consolidation works (if at all). Memory schemas.
- **Channel/plugin system**: how communication channels (Discord, Telegram, etc.) are abstracted. Event routing. Plugin lifecycle.
- **Cognitive loop**: how the agent's perception → reasoning → action cycle works. State machine? Event-driven? Continuous loop?
- **Multi-agent patterns**: supervisor/worker delegation, tool delegation, how sub-agents coordinate
- **Self-modification guardrails**: what can the agent change about itself? What's locked? How are changes reviewed?
- **Configuration architecture**: what's in config vs code vs prompt. How is behavior parameterized?
- **Community patterns**: what has the OpenClaw community converged on? What problems do people report?
- **Lifecycle management**: startup, shutdown, state persistence across restarts, crash recovery

**Research methods:**
- Clone OpenClaw repo and read source code systematically
- Read OpenClaw documentation and community discussions
- Compare with other open-source agent frameworks (SWE-agent, AutoGPT, CrewAI) for contrast

**Output:** `research/openclaw-patterns.md`
- Architecture diagram of OpenClaw's key systems
- Pattern catalog: for each major pattern, description + our assessment (adopt / adapt / reject) with rationale
- Anti-patterns observed in OpenClaw or its community
- Specific code/design patterns to extract for The Companion
- Gaps in OpenClaw that The Companion needs to fill

**Critical questions this answers:**
- What is the right abstraction for the cognitive loop? (Event-driven? State machine? Continuous?)
- How should SOUL.md work technically? (Prompt prefix? Dynamic injection? Layered?)
- What memory architecture has actually worked in production persistent agents?
- What are the real-world failure modes of self-modifying agents?

---

### R6: Classical Cognitive Architectures (ACT-R, SOAR, LIDA)

**Goal:** Learn from decades of cognitive architecture research. These systems were designed to model human cognition computationally. What did they get right? What's relevant for an LLM-based agent?

**Scope:**
- **ACT-R**: declarative memory (chunks), procedural memory (production rules), activation-based retrieval, utility-based conflict resolution. The activation equation maps to memory retrieval relevance scoring.
- **SOAR**: problem spaces, operators, chunking (learning from experience), episodic and semantic memory. Working memory as the central structure.
- **LIDA (Learning Intelligent Distribution Agent)**: the most biologically-inspired. Global workspace theory, attention codelets, conscious broadcasts, action selection. Particularly relevant for our attention/salience design.
- **Common patterns across architectures**: perception → working memory → reasoning → action. How each handles memory, learning, attention, and goals.
- **Failures and limitations**: where did these architectures struggle? What problems are unsolved? What should we avoid repeating?
- **LLM + cognitive architecture hybrids**: recent work (2023-2026) combining LLMs with classical cognitive architecture concepts.

**Research methods:**
- Web search for review papers comparing cognitive architectures
- Read ACT-R, SOAR, LIDA overview papers
- Search specifically for "cognitive architecture" + "large language model" papers

**Output:** `research/classical-architectures.md`
- Summary of each architecture's key mechanisms
- Cross-architecture comparison table
- Patterns relevant to The Companion (with concrete design implications)
- ACT-R activation equation adapted for our memory retrieval
- LIDA's global workspace adapted for our attention/broadcast mechanism
- Lessons from decades of failures

**Critical questions this answers:**
- Should we use an activation/decay model for memory retrieval? (ACT-R says yes.)
- Is global workspace theory useful for organizing the cognitive loop? (LIDA says yes.)
- How should procedural knowledge (skills) be represented?
- What memory retrieval strategy has the best theoretical and empirical backing?

---

### R7: Modern LLM Agent Architectures (2024-2026)

**Goal:** Survey the cutting edge. What are people actually building and deploying? What works? What fails?

**Scope:**
- **Production always-on agents**: Any deployed system that runs continuously and autonomously. Architecture patterns, failure modes, recovery strategies.
- **Reflection and self-improvement**: ReAct, Reflexion, LATS, other reflection-based architectures. What works for sustained self-improvement vs one-shot improvement?
- **Multi-model routing**: systems that use different models for different tasks. How do they decide? Static rules? Learned routing? Cost-based?
- **Agent memory systems (2024-2026)**: MemGPT, retrieval-augmented generation for agents, long-term memory management. What's state-of-the-art?
- **Agent frameworks**: Claude Agent SDK, LangGraph, AutoGen, CrewAI, Semantic Kernel. Architectural patterns, strengths, limitations. (Focus on Agent SDK since that's our choice, but learn from others.)
- **Tool use and planning**: how modern agents plan tool sequences, handle tool failures, and recover.
- **Evaluation and benchmarks**: how are autonomous agents evaluated? What metrics matter?

**Research methods:**
- Web search for recent papers and blog posts (2024-2026)
- Search ArXiv for "autonomous agent" + "LLM" papers
- Look for production case studies, not just research demos
- Check Claude Agent SDK latest docs and examples

**Output:** `research/modern-agents.md`
- Survey of current approaches with strengths/weaknesses
- State-of-the-art in agent memory (especially long-running agents)
- Multi-model routing patterns and their tradeoffs
- Reflection/self-improvement patterns that work in practice
- Agent SDK best practices and known limitations
- Evaluation framework proposal for The Companion

**Critical questions this answers:**
- What reflection pattern should we use? (ReAct? Reflexion? Something else?)
- How do production agents handle state persistence across restarts?
- What's the state-of-the-art in agent memory management?
- How should we evaluate whether The Companion is improving?

---

### R8: Security Patterns for Autonomous Agents

**Goal:** Research how to make an autonomous self-modifying agent genuinely safe, not just "we added some checks."

**Scope:**
- **Permission models for autonomous agents**: principle of least privilege, capability-based security, dynamic permission escalation. What works?
- **Self-modification safety**: how to allow beneficial self-modification while preventing harmful changes. Formal approaches, practical approaches.
- **Audit trail design**: what to log, in what format, how to make logs tamper-evident. JSONL patterns for agent audit.
- **Sandboxing strategies**: filesystem sandboxing, network sandboxing, API sandboxing. Without Docker, what are our options on macOS?
- **Trust hierarchies**: how to implement Wisdom's review vs self-approved changes. What criteria distinguish "routine" from "significant"?
- **Kill switch design**: beyond `launchctl unload` — graceful shutdown, state preservation during emergency stop, preventing restart loops.
- **Adversarial considerations**: prompt injection through inputs (Telegram messages, files read), self-deception (agent convincing itself to bypass constraints), drift over time.
- **Existing frameworks**: NIST AI risk management, OWASP for AI, any agent-specific security frameworks.

**Research methods:**
- Web search for agent security research
- Look for "AI safety" + "autonomous agent" research (distinct from alignment research)
- Study existing permission models in agent frameworks
- Review OWASP AI security guidelines

**Output:** `research/security-patterns.md`
- Permission model recommendation with rationale
- Self-modification safety framework
- Audit trail schema design
- Sandboxing strategy for macOS (no Docker)
- Trust hierarchy specification
- Kill switch and graceful shutdown design
- Threat model for The Companion specifically

**Critical questions this answers:**
- How do we distinguish "routine" self-improvement from "significant architectural change"?
- What is the right audit trail format and granularity?
- How do we protect against prompt injection through Telegram messages?
- What macOS-native sandboxing is available and practical?

---

### Wave 2: Synthesis (run after all Wave 1 tasks complete)

---

### R9: Cross-Thread Synthesis

**Goal:** Read all research outputs, identify patterns across threads, resolve contradictions, and produce a unified understanding.

**Scope:**
- Read all 8 research documents (R0-R8)
- Identify convergent findings (same conclusion from multiple directions)
- Identify contradictions or tensions (cognitive science says X, but engineering constraints say Y)
- Map cognitive science findings to concrete system components
- Identify which cognitive science mappings are tractable (we can actually build this) vs aspirational (nice idea, not feasible now)
- Prioritize: what MUST be in v1 vs what can be added later?
- Produce a unified cognitive-to-engineering mapping table

**Research methods:**
- Pure reading and analysis of the 8 research docs
- No new external research — this is about connecting what we already found

**Output:** `research/synthesis.md`
- Convergent findings (high-confidence design directions)
- Tensions and their resolutions
- Master mapping table: cognitive concept → engineering component → priority tier
- Feasibility-adjusted architecture principles
- "Things we thought were important but aren't" (pruning)
- "Things we didn't expect to matter but do" (surprises)

**Critical questions this answers:**
- Where does cognitive science actually change our engineering decisions vs just relabel them?
- What are the top 5 cognitive science insights that MUST be in the architecture?
- What did we learn from OpenClaw/modern agents that overrides our initial assumptions?
- What's the realistic scope for v1?

---

### R10: Architectural Decision Record

**Goal:** Translate the synthesis into concrete, documented architectural decisions that all subsequent sections will reference.

**Scope:**
For each major architectural decision:
- **Decision**: what we're choosing
- **Context**: what research informed this
- **Alternatives considered**: what else we could have done
- **Consequences**: what this enables and constrains
- **Breaks if**: what assumption, if wrong, invalidates this

Major decisions to document:
1. Cognitive loop architecture (event-driven? state machine? continuous loop?)
2. Memory system architecture (stores, schemas, retrieval mechanism, consolidation)
3. Model routing strategy (how the Companion selects which model to use)
4. Attention/priority system design
5. Self-model and metacognition implementation
6. Wisdom-model (theory of mind) implementation
7. SOUL.md structure and mechanism
8. Security and permission architecture
9. State persistence strategy (across restarts, crashes)
10. Voice integration architecture (tight coupling vs loose coupling with cognitive core)
11. Communication channel abstraction
12. Self-modification boundaries and review process
13. Circadian rhythm / activity cycle design
14. Evaluation and success metrics

**Output:** `research/architectural-decisions.md`
- ADR (Architectural Decision Record) for each decision above
- System architecture diagram (described in text, to be rendered later)
- Component interaction map
- Data flow diagram
- Module boundary definitions
- This becomes the primary reference for all Section 1-8 planners

**Critical output:**
This document IS the bridge between Phase 0 (Research) and Phase 1 (Building).
Every section planner should be able to read this and know exactly what to build.

---

## Output File Inventory

All outputs in `~/the-companion/research/`:

| File | Produced by | Content |
|------|-------------|---------|
| `technical-feasibility.md` | R0 | Hard constraints, RAM budgets, component verdicts |
| `cognitive-memory.md` | R1 | Memory systems and their architectural mappings |
| `cognitive-attention.md` | R2 | Attention, salience, predictive processing mappings |
| `cognitive-executive.md` | R3 | Executive function, dual process, homeostasis mappings |
| `cognitive-social.md` | R4 | Metacognition, theory of mind, communication mappings |
| `openclaw-patterns.md` | R5 | OpenClaw analysis: adopt / adapt / reject catalog |
| `classical-architectures.md` | R6 | ACT-R, SOAR, LIDA lessons for LLM agents |
| `modern-agents.md` | R7 | 2024-2026 agent architecture survey |
| `security-patterns.md` | R8 | Security framework for autonomous self-modifying agent |
| `synthesis.md` | R9 | Cross-thread synthesis, master mapping table |
| `architectural-decisions.md` | R10 | ADRs, architecture diagrams, module boundaries |

---

## Task Execution Guidance

### What "one focused agent session" means
- Each R-task is scoped to be completable in a single Claude Code session (within context limits)
- The agent should use subagents for parallel web searches within a task
- Output should be written to the specified file as the agent works, not all at the end
- Each output should be self-contained (readable without the other documents)

### Quality bar for research outputs
- **Cited sources**: every claim should reference where it came from (paper, doc, repo)
- **Concrete, not vague**: "use activation-based retrieval with decay parameter k=0.5" not "use something like activation"
- **Architectural implications explicit**: every finding should end with "this means for The Companion..."
- **Honest about uncertainty**: clearly distinguish "we know" vs "we believe" vs "we're guessing"

### How findings flow to other sections

| Research Output | Feeds Into |
|----------------|-----------|
| `technical-feasibility.md` | Section 1 (Hardware), Section 5 (Budget), Section 6 (Communication) |
| `cognitive-memory.md` | Section 4 (Memory System) |
| `cognitive-attention.md` | Section 3 (Cognitive Engine), Section 5 (Budget) |
| `cognitive-executive.md` | Section 3 (Cognitive Engine), Section 5 (Budget) |
| `cognitive-social.md` | Section 2 (Identity), Section 6 (Communication), Section 7 (Self-Improvement) |
| `openclaw-patterns.md` | Section 2 (Identity), Section 3 (Cognitive Engine), Section 4 (Memory) |
| `classical-architectures.md` | Section 3 (Cognitive Engine), Section 4 (Memory) |
| `modern-agents.md` | Section 3 (Cognitive Engine), Section 7 (Self-Improvement) |
| `security-patterns.md` | Section 8 (Security), Section 7 (Self-Improvement) |
| `synthesis.md` | All sections |
| `architectural-decisions.md` | All sections (primary reference) |

---

## Risk Register

| Risk | Impact | Mitigation |
|------|--------|------------|
| Research rabbit holes — spending too long on one thread | Delays everything | Strict one-session-per-task rule. Time-box each task. Accept "good enough" research. |
| Cognitive science findings are too abstract to implement | Research is wasted | Every finding must include concrete architectural implication. If you can't map it to code, note it as aspirational. |
| Technical feasibility kills a core design idea | Architectural crisis | R0 runs first specifically for this reason. Better to know constraints early. |
| OpenClaw has changed significantly since last check | Stale patterns | Date-stamp findings. Check latest release, not just docs. |
| Contradictions between cognitive science and engineering pragmatism | Paralysis | Synthesis (R9) explicitly resolves tensions. Engineering wins when cognitive science is merely metaphorical. Cognitive science wins when it identifies a genuinely better pattern. |
| Scope creep — wanting to research everything | Phase 0 never ends | The 11-task structure IS the scope. No new tasks without removing one. |

---

## Success Criteria for Section 0

1. All 11 research documents exist in `~/the-companion/research/`
2. `architectural-decisions.md` contains ADRs for all 14 major decisions listed above
3. Every downstream section planner (Sections 1-8) can find the information they need in the research outputs without needing to do their own foundational research
4. Technical feasibility has been validated with actual benchmarks on the M2 machine (not just spec sheets)
5. At least 3 cognitive science insights produce genuinely different design choices than a "standard" agent architecture would make
6. Wisdom reviews the synthesis and architectural decisions and confirms they align with the vision
