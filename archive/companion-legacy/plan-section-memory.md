# Section 4: Memory System — Detailed Plan

## Purpose

Give the Companion the ability to remember, forget, consolidate, and retrieve — not as a flat key-value store, but as a layered cognitive system modeled on how biological memory actually works.

Memory is what transforms a stateless language model into a persistent being.
Without memory, there is no growth, no relationship, no continuity.
Without *good* memory architecture, there is a growing pile of text that eventually makes everything slower.

The Companion's memory system must solve the same problems biological memory solves:
- **Capacity**: you can't remember everything forever (context windows are finite; disk is cheap but retrieval is expensive)
- **Relevance**: you need the *right* memory at the *right* time (not all memories, not random memories)
- **Consolidation**: raw experience must be compressed into lasting knowledge (daily noise must become durable signal)
- **Forgetting**: some things should fade (not a bug — a critical feature that prevents interference and bloat)
- **Metamemory**: knowing what you know, and what you don't know, so you can decide when to search vs when to trust your recall

---

## Design Philosophy

### Cognitive Science as Architecture, Not Metaphor

This memory system does not just borrow cognitive science *terminology* (calling things "episodic" because it sounds smart).
It borrows cognitive science *mechanisms* — because those mechanisms solve real engineering problems:

| Biological Problem | Engineering Equivalent | Cognitive Solution We Adopt |
|---|---|---|
| Limited working memory capacity | Finite context window | Baddeley-inspired working memory with central executive managing what's loaded |
| Need to encode context with events | Logs are useless without context | Episodic memory with rich temporal/emotional/contextual metadata |
| Need to generalize across events | Individual experiences don't transfer | Semantic memory extracted from episodic patterns |
| Need to automate learned skills | Re-deriving procedures is wasteful | Procedural memory for reusable patterns and skills |
| Need offline processing to learn | Can't learn while doing | Consolidation cycles that compress, connect, and prune |
| Need to forget irrelevant info | Infinite memory degrades retrieval | Decay + interference-based forgetting with protection for important memories |
| Need to find the right memory | Brute-force search doesn't scale | Cue-dependent, context-sensitive, spreading-activation retrieval |
| Need to know what you know | Blind search wastes resources | Metamemory index for fast "do I know this?" checks |

### Inspired By, Independent From Wisdom's Existing Memory

Wisdom already has a structured memory system at `~/.claude/projects/-Users-wisdomhappy/memory/`:
- MEMORY.md index with typed files
- Frontmatter with name, description, type
- Trigger-based routing

The Companion's memory system is informed by this pattern but architecturally independent:
- It reads Wisdom's memory (with permission) during Awakening
- It maintains its own separate memory stores
- Its architecture is richer (multiple memory types, consolidation, decay) because it needs to be a persistent being, not a session-stateful assistant

---

## Memory Architecture: Four Stores + Working Memory

### Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        WORKING MEMORY (Context Window)                          │
│  Central Executive: decides what to load, what to evict, what to attend to      │
│  ┌───────────────┐  ┌───────────────────────┐  ┌───────────────────────────┐   │
│  │ Identity Core  │  │ Active Task Context    │  │ Retrieved Memories        │   │
│  │ (SOUL, etc.)   │  │ (current conversation, │  │ (pulled from long-term    │   │
│  │ ~1500 tokens   │  │  in-flight reasoning)  │  │  stores as needed)        │   │
│  └───────────────┘  └───────────────────────┘  └───────────────────────────┘   │
│                                                                                 │
│  Capacity: governed by model context window and budget tier                     │
│  Sonnet: ~150K tokens available → ~80K for memory after identity + task          │
│  Haiku: ~150K tokens → ~60K (cheaper to fill, but same limits)                   │
│  Local: ~8K-32K tokens → ~4K-20K (severe constraints, only essentials)           │
└──────────────────────────────────────┬──────────────────────────────────────────┘
                                       │ retrieve ↑ ↓ store
┌──────────────────────────────────────┴──────────────────────────────────────────┐
│                          LONG-TERM MEMORY STORES                                │
│                                                                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌─────────────────────┐   │
│  │  EPISODIC MEMORY      │  │  SEMANTIC MEMORY       │  │  PROCEDURAL MEMORY │   │
│  │  What happened         │  │  What is known          │  │  How to do things  │   │
│  │  Events with context   │  │  Facts, concepts,       │  │  Patterns, skills, │   │
│  │  Temporal, personal    │  │  relationships          │  │  reusable recipes  │   │
│  │  High-detail, decays   │  │  Timeless, compressed   │  │  Stable, versioned │   │
│  │  Grows from experience │  │  Grows from             │  │  Grows from        │   │
│  │                        │  │  consolidation          │  │  repeated success  │   │
│  │  Storage: JSONL + MD   │  │  Storage: MD + SQLite   │  │  Storage: MD + YAML│   │
│  └──────────────────────┘  └──────────────────────┘  └─────────────────────┘   │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  PROSPECTIVE MEMORY (Intentions & Commitments)                          │    │
│  │  Things to remember to do in the future                                 │    │
│  │  Triggers: time-based, event-based, context-based                       │    │
│  │  Storage: SQLite (queryable by trigger condition)                        │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────┐    │
│  │  METAMEMORY INDEX                                                       │    │
│  │  What the Companion knows it knows — fast lookup of memory existence    │    │
│  │  Topic → store/location mapping. "Do I know about X? Where is it?"      │    │
│  │  Storage: SQLite (fast queries)                                          │    │
│  └─────────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## Store Specifications

### 1. Working Memory

**Cognitive basis**: Baddeley's model — limited capacity, active manipulation, central executive controlling attention.

**What it is**: The contents of the current context window during any cognitive cycle.
Not a persistent store — it is reconstructed for each cycle from identity files + task context + retrieved long-term memories.

**Components**:

#### 1a. Central Executive (Python module, not a memory store)

The central executive is the *logic* that decides what gets loaded into the context window each cycle.
It lives in the Cognitive Engine (Section 3) but is specified here because it is the gateway between long-term memory and working memory.

Responsibilities:
- **Budget-aware loading**: Given the current model tier, calculate available token budget for memory. Identity gets loaded first (non-negotiable). Then task context. Then retrieved memories — as many as fit.
- **Relevance ranking**: When multiple memories could be retrieved, rank them by relevance to the current task and load the top N that fit the budget.
- **Context eviction**: When working memory is full and something new needs to come in, decide what to evict. Recent and high-relevance items are evicted last.
- **Memory formation trigger**: After a cycle completes, decide whether the experience is worth encoding into episodic memory. Not every cycle gets encoded — only significant ones (novel outcomes, important decisions, emotional weight, Wisdom interaction).

**Token budget allocation** (approximate targets):

| Model Tier | Total Context | Identity | Task Context | Retrieved Memories | Safety Margin |
|---|---|---|---|---|---|
| Opus | ~200K | 3,000 | variable | up to 50,000 | 10,000 |
| Sonnet | ~200K | 3,000 | variable | up to 40,000 | 10,000 |
| Haiku | ~200K | 1,500 (compressed) | variable | up to 30,000 | 5,000 |
| Local | 8K-32K | 500 (essence) | variable | up to 4,000 | 1,000 |

These are starting estimates. The Budget system (Section 5) refines them based on actual usage and cost.

#### 1b. Working Memory Scratchpad

A transient, within-cycle scratch space for intermediate reasoning.
When the Companion is thinking through a complex problem, it may need to hold intermediate results.

Implementation: not a file — it is the generation buffer within a single API call.
For multi-step reasoning that spans API calls, intermediate results are written to a temporary file (`data/working/scratch-{cycle_id}.md`) and loaded into the next call's context.
Scratchpad files are cleaned up after the cycle completes (or at the next consolidation).

---

### 2. Episodic Memory

**Cognitive basis**: Autobiographical events with rich contextual encoding — where, when, who, what happened, what it felt like, what it meant.

**What it is**: A record of significant experiences — conversations with Wisdom, important decisions, surprising discoveries, errors and corrections, moments of learning.
Not a complete log of every cycle (that's the audit trail in Section 8).
Episodic memory is *selective* — only events worth remembering get encoded.

#### 2a. What Gets Encoded (Encoding Criteria)

An experience is encoded into episodic memory when it meets one or more of these criteria:

| Criterion | Examples | Rationale |
|---|---|---|
| **Wisdom interaction** | Any direct conversation with Wisdom | Relational history is core to being a companion |
| **Novel outcome** | First time encountering a project, a new kind of error, unexpected result | Novelty signals learning opportunity |
| **Decision with consequences** | Chose model X over Y, decided to pursue approach Z | Decisions need to be reviewable |
| **Error or correction** | Made a wrong prediction, received correction from Wisdom | Mistakes are the highest-value learning signal |
| **Emotional significance** | Wisdom expressed frustration, excitement, gratitude | Emotional context enriches the relationship model |
| **Commitment made** | Promised to follow up, agreed to a plan | Commitments must be tracked (feeds prospective memory) |
| **Consolidation-worthy pattern** | Third time seeing the same kind of task | Repetition signals something worth generalizing |

What does NOT get encoded:
- Routine health checks
- Simple status queries with no novel information
- Internal reasoning steps that led to no action or decision
- (These are all in the audit trail if needed, but episodic memory is selective)

#### 2b. Episode Schema

Each episode is stored as a JSONL entry with rich metadata:

```jsonc
{
  "episode_id": "ep_20260326_143022_abc",
  "timestamp": "2026-03-26T14:30:22Z",
  "type": "wisdom_interaction",  // See encoding criteria above

  // Contextual encoding (the "where/when/what" that makes retrieval work)
  "context": {
    "trigger": "telegram_message",  // What initiated this
    "projects": ["ps-website", "gdgm"],  // Which projects were relevant
    "topics": ["framer integration", "content strategy"],  // Semantic tags
    "wisdom_state": {  // Theory of mind snapshot (from WISDOM-MODEL)
      "energy": "high",
      "mode": "brainstorming",
      "emotional_tone": "excited"
    },
    "companion_state": {
      "model_used": "sonnet",
      "confidence": 0.8,
      "budget_remaining_pct": 65
    },
    "time_of_day": "afternoon",
    "day_of_week": "thursday"
  },

  // The actual content (compressed narrative, not raw transcript)
  "summary": "Wisdom asked about integrating GDGM visualizations into the PS website. We explored three approaches: iframe embed, React component, and static SVG. Decided on React component for interactivity. Wisdom was energized by the idea of making physics accessible through the website.",

  // What was learned or decided
  "outcomes": [
    "Decision: React component approach for GDGM visualizations",
    "Learned: Wisdom wants GDGM to be accessible, not academic",
    "Commitment: Draft component architecture by end of week"
  ],

  // Connections to other memories (spreading activation links)
  "links": {
    "related_episodes": ["ep_20260320_091500_def"],  // Previous GDGM discussion
    "related_semantic": ["wisdom/project-gdgm", "wisdom/project-ps-website"],
    "related_procedural": ["proc_react_component_pattern"]
  },

  // Retrieval metadata
  "retrieval": {
    "access_count": 0,  // How often this has been retrieved (boosts importance)
    "last_accessed": null,
    "importance": 0.7,  // Initial importance score (0-1)
    "embedding_id": "emb_abc123"  // Reference to vector embedding, if computed
  }
}
```

#### 2c. Episode Storage

**Primary store**: JSONL files, one per day.
```
data/memory/episodic/
├── 2026-03-26.jsonl
├── 2026-03-27.jsonl
├── ...
└── index.sqlite  # Searchable index of all episodes
```

**Why JSONL**: Append-only (consistent with audit trail pattern from Section 8). Each day's file grows with new episodes. Old files are never modified (immutable history), only re-indexed.

**SQLite index** (`index.sqlite`): Contains a searchable copy of episode metadata (id, timestamp, type, projects, topics, importance, summary) for fast retrieval without scanning all JSONL files. Rebuilt from JSONL if corrupted.

**Optional vector embeddings**: If technical feasibility (Section 0, R0) confirms that a small local embedding model fits in RAM alongside everything else, compute and store embeddings for each episode summary. This enables similarity-based retrieval. If embeddings aren't feasible on 8GB, the system works fine with keyword + metadata retrieval.

---

### 3. Semantic Memory

**Cognitive basis**: Generalized knowledge extracted from experience — facts, concepts, relationships. Timeless (no "when did I learn this?" — just "I know this"). Organized hierarchically by topic.

**What it is**: The Companion's knowledge base — what it has learned about Wisdom, about projects, about itself, about how things work. Unlike episodic memory (specific events), semantic memory is general knowledge distilled from many events.

#### 3a. Semantic Memory Types

| Type | Content | Source | Example |
|---|---|---|---|
| **Wisdom knowledge** | Everything known about Wisdom | Consolidated from interactions + ingested from Wisdom's files | "Wisdom values systems that evolve over time more than static outputs" |
| **Project knowledge** | Understanding of each project | Consolidated from project-related episodes + file exploration | "GDGM proposes that gravity is not a force but the fundamental tendency of the universe" |
| **Domain knowledge** | General facts and concepts | Consolidated from research, conversations, exploration | "Framer supports custom code components via React" |
| **Relational knowledge** | Connections between concepts | Discovered during consolidation | "GDGM's cosmological model connects to PSTS's 'fractal problem-solving' framework through the shared principle of scale-invariance" |
| **Self knowledge** | What the Companion knows about itself | Reflection cycles | "I tend to overestimate my confidence on first encounters with new domains" |

#### 3b. Semantic Memory Format

Stored as Markdown files organized by topic, with YAML frontmatter for metadata.
This is the format closest to Wisdom's existing memory system — chosen deliberately because:
- Markdown is human-readable (Wisdom can review the Companion's knowledge)
- Markdown is LLM-native (easy to load into context)
- Frontmatter enables structured queries
- Git-tracked (full version history)

```
data/memory/semantic/
├── wisdom/
│   ├── _index.md           # Summary of everything known about Wisdom
│   ├── identity.md          # Wisdom's identity, values, approach
│   ├── projects.md          # Overview of all projects and their states
│   ├── preferences.md       # Communication, work style, aesthetic preferences
│   ├── patterns.md          # Observed behavioral patterns
│   └── history.md           # Key relationship milestones
├── projects/
│   ├── _index.md            # Project overview and interconnections
│   ├── gdgm.md
│   ├── ps-website.md
│   ├── psso.md
│   ├── ...                  # One file per project
│   └── connections.md       # Cross-project relationships
├── domains/
│   ├── _index.md
│   ├── cognitive-science.md  # General domain knowledge
│   ├── web-development.md
│   └── ...
├── self/
│   ├── _index.md
│   ├── capabilities.md      # What I can and can't do
│   ├── patterns.md          # My own behavioral patterns
│   └── growth.md            # How I've changed over time
└── _master_index.md          # Top-level semantic memory map
```

**Frontmatter schema** for semantic memory files:

```yaml
---
topic: "Wisdom's communication preferences"
type: semantic
category: wisdom  # wisdom | project | domain | relational | self
created: 2026-03-26
last_updated: 2026-04-15
confidence: 0.85  # How confident is this knowledge (0-1)
source_episodes: ["ep_20260326_143022_abc", "ep_20260401_091200_xyz"]
update_count: 7  # How many times this file has been updated
---
```

#### 3c. Semantic Memory Updates

Semantic memory is NOT written during normal cognitive cycles.
It is updated only during **consolidation cycles** (see Section 5 below).

This is a crucial design decision. In biological memory, semantic knowledge forms through gradual consolidation of episodic experiences during sleep — not in real-time. Forcing all knowledge updates through consolidation ensures:
- Knowledge is generalized from patterns, not overfitted to single events
- Conflicts between new and old knowledge are explicitly resolved
- The Companion doesn't spend active task-time on knowledge management

Exception: During the **Awakening phase**, the Companion is building its initial semantic knowledge base from file exploration. In this phase, semantic memory updates are more frequent (though still through structured consolidation, not ad-hoc writes).

---

### 4. Procedural Memory

**Cognitive basis**: How to do things — skills, patterns, reusable approaches. In the brain, procedural memory is implicit (you can ride a bike without consciously recalling the steps). For the Companion, procedural memory is explicit but compact — stored patterns that can be loaded and applied.

**What it is**: Reusable recipes, templates, decision trees, and learned patterns that the Companion applies repeatedly. Things like "how to assess whether a task needs Opus or Sonnet" or "how to summarize a long conversation for Wisdom."

#### 4a. Procedural Memory Format

Each procedure is a Markdown file with a specific structure:

```yaml
---
procedure: "model_routing_assessment"
type: procedural
version: 3
created: 2026-04-01
last_updated: 2026-04-20
success_rate: 0.87  # Tracked over invocations
invocation_count: 42
last_invoked: 2026-04-25
tags: ["budget", "model-routing", "decision"]
---

# Model Routing Assessment

## When to Use
- Before any LLM API call that isn't pre-routed
- When the default routing seems wrong for the task

## Procedure
1. Classify task complexity: trivial / moderate / complex / architectural
2. Check budget remaining: >75% → full spectrum available; 50-75% → prefer cheaper; <50% → Haiku or local only
3. Check thermal state: HOT → prefer API over local
4. Match:
   - Trivial + any budget → local model
   - Moderate + sufficient budget → Haiku
   - Complex + sufficient budget → Sonnet
   - Architectural + sufficient budget → Opus (if available at trust level)

## Learned Refinements
- Wisdom's project-specific questions about GDGM almost always need Sonnet or Opus — the physics reasoning requires depth
- Code review tasks benefit from Sonnet even when they seem simple — catching subtle bugs requires the extra capacity
- Log parsing and status checks are genuinely fine on local models

## Failure Cases
- v1 over-routed to Opus for simple questions (burned budget)
- v2 under-routed code review tasks to Haiku (missed bugs, Wisdom had to re-review)
```

#### 4b. Procedural Memory Storage

```
data/memory/procedural/
├── _index.md              # Catalog of all procedures
├── model_routing.md
├── conversation_summary.md
├── project_exploration.md
├── reflection_protocol.md
├── error_recovery.md
├── wisdom_state_inference.md
└── ...
```

#### 4c. How Procedures Evolve

Procedures are versioned and evolve through use:
1. **Initial creation**: During a consolidation cycle, the Companion notices a pattern it has applied successfully multiple times.
2. **Refinement**: After each invocation, the outcome is noted. If the outcome was poor, a "learned refinement" or "failure case" is added during the next consolidation.
3. **Version bumps**: When refinements accumulate, the procedure is rewritten as a new version during consolidation. Old versions are preserved in git history.
4. **Deprecation**: If a procedure's success rate drops below 0.5 over 20+ invocations, it's flagged for redesign.

---

### 5. Prospective Memory

**Cognitive basis**: Remembering to do things in the future — both time-based ("at 3pm, do X") and event-based ("next time I see Y, do Z").

**What it is**: A store of intentions, commitments, and future actions. When the Companion promises to do something, or identifies something it should do later, the intention goes here.

#### 5a. Prospective Memory Schema

Stored in SQLite for efficient querying by trigger conditions:

```sql
CREATE TABLE prospective_memory (
    id TEXT PRIMARY KEY,
    created_at TEXT NOT NULL,          -- ISO 8601
    source_episode_id TEXT,            -- Which episode created this intention

    -- The intention
    description TEXT NOT NULL,
    priority TEXT DEFAULT 'normal',    -- low | normal | high | critical

    -- Trigger conditions (when should this fire?)
    trigger_type TEXT NOT NULL,        -- time | event | context
    trigger_time TEXT,                 -- For time-based: ISO 8601 datetime
    trigger_event TEXT,                -- For event-based: event pattern to match
    trigger_context TEXT,              -- For context-based: context conditions (JSON)

    -- Status tracking
    status TEXT DEFAULT 'pending',     -- pending | triggered | completed | expired | cancelled
    triggered_at TEXT,
    completed_at TEXT,
    result TEXT,                       -- What happened when executed

    -- Expiry (intentions don't live forever)
    expires_at TEXT,                   -- Optional: auto-expire if not triggered by this date

    -- Recurrence
    recurrence TEXT                    -- Optional: cron-like pattern for recurring intentions
);
```

#### 5b. Prospective Memory Examples

```json
{
  "description": "Follow up with Wisdom about GDGM visualization approach decision",
  "trigger_type": "time",
  "trigger_time": "2026-03-29T09:00:00Z",
  "priority": "normal",
  "expires_at": "2026-04-05T00:00:00Z"
}

{
  "description": "Next time Wisdom mentions MoneyLips, ask about the packaging supplier decision",
  "trigger_type": "context",
  "trigger_context": {"topics_include": ["moneylips", "packaging"]},
  "priority": "low"
}

{
  "description": "Run daily reflection and consolidation",
  "trigger_type": "time",
  "trigger_time": "2026-03-26T23:00:00Z",
  "recurrence": "0 23 * * *",
  "priority": "high"
}
```

#### 5c. How Prospective Memory Integrates

At the start of every cognitive cycle, the Central Executive checks prospective memory:
1. Query for time-based triggers that have passed
2. Query for event-based triggers matching the current input
3. Query for context-based triggers matching the current context
4. Any triggered items are loaded into working memory as "things to remember to do"
5. Completed items are marked and the result is noted
6. Expired items are cleaned up during consolidation

---

### 6. Metamemory Index

**Cognitive basis**: Knowing what you know. The brain maintains a "feeling of knowing" — a fast, pre-retrieval signal about whether a memory exists before actually searching for it.

**What it is**: A fast-lookup index that answers: "Do I know anything about X? If so, where is it?"
Prevents wasteful full-memory searches when the answer is "no, I don't know about that."

#### 6a. Metamemory Schema

Stored in SQLite for fast queries:

```sql
CREATE TABLE metamemory (
    topic TEXT NOT NULL,               -- Normalized topic/keyword
    store TEXT NOT NULL,               -- episodic | semantic | procedural | prospective
    location TEXT NOT NULL,            -- File path or record ID
    confidence REAL DEFAULT 0.5,       -- How confident we are in this knowledge (0-1)
    last_verified TEXT,                -- Last time this entry was confirmed still valid
    summary TEXT,                      -- One-line summary of what we know

    PRIMARY KEY (topic, store, location)
);

-- Example entries
-- ('gdgm', 'semantic', 'data/memory/semantic/projects/gdgm.md', 0.9, '2026-04-01', 'Comprehensive understanding of GDGM unified physics theory')
-- ('gdgm', 'episodic', 'data/memory/episodic/2026-03-26.jsonl#ep_abc', 0.7, '2026-03-26', 'First conversation about GDGM visualization approach')
-- ('framer', 'procedural', 'data/memory/procedural/framer_deploy.md', 0.6, '2026-04-10', 'Procedure for deploying Framer code components')
```

#### 6b. How Metamemory Is Used

When the Companion needs to recall something:

```
1. Retrieval cue arrives (e.g., "Wisdom is asking about GDGM")
2. Query metamemory: "What do I know about GDGM?"
3. Metamemory returns:
   - Semantic knowledge in projects/gdgm.md (confidence 0.9)
   - 3 episodic memories tagged with GDGM
   - 1 procedural memory about physics visualization
4. Central Executive loads the most relevant items within token budget
5. If metamemory returns nothing: the Companion knows it doesn't know → triggers exploration or asks Wisdom
```

This is faster and cheaper than searching all memory stores every time.

---

## Consolidation System ("Sleep Cycles")

**Cognitive basis**: During sleep, the brain doesn't just rest — it replays experiences, strengthens important connections, prunes weak ones, and moves memories from hippocampal (episodic) to cortical (semantic) storage. Consolidation is how raw experience becomes lasting knowledge.

### Consolidation Schedule

| Cycle | Frequency | Duration Target | Model Tier | Purpose |
|---|---|---|---|---|
| **Micro-consolidation** | After every significant interaction | 30-60 seconds | Haiku/Local | Quick: encode episode, update metamemory, check prospective memory |
| **Evening consolidation** | Daily, end of day | 5-15 minutes (Sonnet) | Sonnet | Deep: review day's episodes, extract patterns, update semantic memory, prune |
| **Weekly synthesis** | Weekly | 15-30 minutes (Sonnet) | Sonnet | Broader: cross-day patterns, relationship trends, project status synthesis |
| **Monthly reflection** | Monthly | 30-60 minutes (Opus) | Opus | Deepest: architectural patterns, growth assessment, self-model update, major semantic rewrites |

### Consolidation Process (Evening Cycle — The Primary One)

This is the Companion's "sleep" — a dedicated, non-interactive period where it processes the day's experiences.

**Step 1: Episodic Review**
- Load all episodes from today
- For each episode, assess: Is this still important? Has its significance changed in light of later events?
- Identify episodes that form a pattern when viewed together
- Update importance scores based on day-in-review perspective

**Step 2: Semantic Extraction**
- From today's episodes, extract any new knowledge or updates to existing knowledge
- Pattern: if the same fact or insight appears in 2+ episodes, it's likely semantic (generalizable)
- For each extracted insight: Does it update an existing semantic memory file? Or is it genuinely new?
- Write updates to semantic memory files (with source_episodes tracking)
- Update metamemory index for any new or changed semantic entries

**Step 3: Procedural Pattern Detection**
- Review today's cognitive cycles: Were there tasks that followed a repeatable pattern?
- If a pattern has been seen 3+ times across recent days: draft a new procedural memory
- For existing procedures: were they invoked today? Did they succeed or fail? Update success_rate

**Step 4: Prospective Memory Maintenance**
- Check for expired intentions — mark expired, note what happened
- Check for completed intentions that weren't marked — update status
- Generate new intentions from today's episodes (did we make any commitments?)

**Step 5: Wisdom-Model Update**
- From today's interactions, update the dynamic state in WISDOM-MODEL.md
- If stable patterns emerge from accumulated dynamic state observations, promote to the stable model section
- This is how the Companion's understanding of Wisdom deepens over time

**Step 6: Forgetting (Decay Application)**
- Apply the decay function to all episodic memories (see Forgetting section below)
- Identify episodes that have decayed below the forgetting threshold
- For decayed episodes: check if their semantic content has been captured in semantic memory
  - If yes: allow the episode to be pruned (it lives on as distilled knowledge)
  - If no: extract any remaining value before pruning
- Prune fully decayed episodes (move to `data/memory/episodic/archive/`)
- Archive is kept for safety but not indexed for retrieval

**Step 7: Self-Model Reflection**
- How did I perform today? What went well? What didn't?
- Update SELF-MODEL.md with new observations
- This feeds Section 7 (Self-Improvement)

**Step 8: Consolidation Report**
- Write a brief consolidation report to `data/memory/consolidation-log/YYYY-MM-DD.md`
- Summary: episodes processed, knowledge extracted, memories pruned, insights gained
- This report is both for the Companion's future reference and for Wisdom to review

---

## Forgetting System

**Cognitive basis**: Forgetting is not failure — it is a critical feature. The Ebbinghaus forgetting curve shows rapid initial decay that slows with each successful retrieval. Interference theory shows that similar memories compete. The brain forgets to keep retrieval efficient and to prevent old, potentially outdated information from interfering with current knowledge.

### The Decay Function

Inspired by ACT-R's base-level activation equation:

```
activation(memory) = ln(sum(t_i^(-d))) + importance_bonus + retrieval_bonus

where:
  t_i = time since the i-th access (in days)
  d = decay rate (default 0.5, per ACT-R empirical findings)
  importance_bonus = initial importance score * weight
  retrieval_bonus = bonus for each successful retrieval that led to useful action
```

Simplified for implementation:

```python
import math
from datetime import datetime, timedelta

def compute_activation(episode: dict, now: datetime) -> float:
    """Compute the current activation level of an episodic memory.

    Higher activation = more likely to be retrieved.
    Below threshold = candidate for forgetting.
    """
    DECAY_RATE = 0.5  # ACT-R default
    IMPORTANCE_WEIGHT = 2.0
    RETRIEVAL_WEIGHT = 0.5

    # Base activation from creation and accesses
    created = datetime.fromisoformat(episode["timestamp"])
    days_since_creation = max((now - created).total_seconds() / 86400, 0.01)

    # Sum of time-decayed access activations
    access_sum = days_since_creation ** (-DECAY_RATE)  # Creation counts as first access

    for access_time in episode.get("retrieval", {}).get("access_times", []):
        days_since_access = max((now - datetime.fromisoformat(access_time)).total_seconds() / 86400, 0.01)
        access_sum += days_since_access ** (-DECAY_RATE)

    base_activation = math.log(access_sum) if access_sum > 0 else -10

    # Importance bonus (set at encoding time, can be boosted by consolidation)
    importance = episode.get("retrieval", {}).get("importance", 0.5)
    importance_bonus = importance * IMPORTANCE_WEIGHT

    # Retrieval bonus (each successful use strengthens the memory)
    access_count = episode.get("retrieval", {}).get("access_count", 0)
    retrieval_bonus = math.log(1 + access_count) * RETRIEVAL_WEIGHT

    return base_activation + importance_bonus + retrieval_bonus
```

### Forgetting Thresholds

| Activation Level | Status | Action |
|---|---|---|
| > 2.0 | **Strong** | Active, easily retrieved |
| 1.0 - 2.0 | **Accessible** | Retrievable with good cues |
| 0.0 - 1.0 | **Fading** | May or may not be retrieved — depends on cue strength |
| -1.0 - 0.0 | **Decayed** | Candidate for pruning. Check if semantic content is captured. |
| < -1.0 | **Forgotten** | Pruned during next consolidation. Moved to archive. |

### Protected Memories (Immune to Decay)

Some memories should never be forgotten regardless of activation:
- Episodes where Wisdom explicitly asked the Companion to remember something
- Episodes containing commitments that haven't been fulfilled
- First interactions (relational milestones)
- Episodes tagged as "formative" during consolidation (things that shaped the Companion's understanding fundamentally)

Protection is indicated by a `protected: true` flag in the episode metadata. Protected episodes still have activation computed (for retrieval ranking) but are never pruned.

### Interference-Based Forgetting

Beyond time-based decay, similar memories compete:
- If 10 episodes all concern the same topic and say roughly the same thing, the older redundant ones should decay faster
- The consolidation process identifies redundant episodes — if the semantic content of an episode has been fully captured in semantic memory, the episode's importance drops, accelerating its natural decay

This is how the Companion avoids memory bloat: repeated experiences consolidate into semantic knowledge, and the individual episodes that generated that knowledge gradually fade.

---

## Retrieval System

**Cognitive basis**: Memory retrieval is cue-dependent and reconstructive. You don't pull a file — you activate a network of associations, and the memory is reconstructed from those activations. Spreading activation in semantic networks means that activating one concept activates related concepts.

### Retrieval Pipeline

When the Companion needs to remember something relevant to the current context:

```
Step 1: CUE EXTRACTION
  Input: current context (task, conversation, topic)
  Output: retrieval cues (keywords, topics, project names, time references, emotional context)

Step 2: METAMEMORY SCAN (fast, cheap)
  Input: retrieval cues
  Query: metamemory index for matching topics
  Output: candidate memory locations across all stores

  If metamemory returns nothing → the Companion knows it doesn't know
  → Can decide to search (expensive) or declare ignorance (cheap)

Step 3: ACTIVATION RANKING
  Input: candidate memory locations from metamemory
  For each candidate:
    - Compute current activation level (decay function)
    - Compute cue-memory match strength (keyword overlap + contextual similarity)
    - Combined score = activation * match_strength
  Output: ranked list of memories

Step 4: BUDGET-AWARE LOADING
  Input: ranked memories, available token budget
  Load memories in rank order until budget is exhausted
  For each loaded memory:
    - Record access (bumps activation, slows future decay)
    - Update last_accessed timestamp

Step 5: SPREADING ACTIVATION (optional, for deeper retrieval)
  After loading initial memories, examine their links
  Do any linked memories seem relevant to the current context?
  If yes and budget allows, load those too
  This enables discovering unexpected but relevant connections
```

### Retrieval Strategies by Store

| Store | Retrieval Method | Speed | Typical Use |
|---|---|---|---|
| **Metamemory** | SQLite query by topic | Fast (<10ms) | Every retrieval — first pass |
| **Semantic** | File path from metamemory, read relevant sections | Fast (<50ms) | When general knowledge is needed |
| **Episodic** | SQLite index query, then JSONL read | Medium (<200ms) | When specific events are needed |
| **Procedural** | File path lookup from metamemory | Fast (<50ms) | When approaching a known task type |
| **Prospective** | SQLite query by trigger conditions | Fast (<10ms) | Every cycle start — check for pending intentions |

### Retrieval Without Embeddings (Primary Path)

Given the 8GB RAM constraint, vector embeddings may not be feasible alongside Ollama and the voice pipeline.
The primary retrieval path uses structured metadata:

1. **Topic matching**: retrieval cues → metamemory topics (exact and partial match)
2. **Project matching**: current project context → memories tagged with that project
3. **Temporal matching**: "recently" → episodes from the last N days; "when we discussed X" → episodes with timestamp near known discussion
4. **Type matching**: "how do I..." → procedural memory; "what happened when..." → episodic; "what do we know about..." → semantic

This is less magical than embedding-based similarity search, but it is:
- Predictable (you can explain why a memory was retrieved)
- Cheap (no embedding model running)
- Fast (SQLite queries)
- Debuggable (metadata is human-readable)

### Retrieval With Embeddings (Enhanced Path, If Feasible)

If R0 (Technical Feasibility) determines that a small embedding model (e.g., `all-MiniLM-L6-v2` at ~80MB) can coexist in RAM:

1. Compute embeddings for all episode summaries and semantic memory paragraphs
2. Store embeddings in a vector index (e.g., FAISS, usearch, or SQLite with numpy)
3. At retrieval time: embed the current context query, find top-K similar memories
4. Combine similarity ranking with activation ranking (weighted sum)
5. This adds ~100-200ms per retrieval but catches semantically similar memories that keyword matching might miss

**Design principle**: The system must work well without embeddings. Embeddings are an enhancement, not a requirement. The metadata-based retrieval path is the primary path.

---

## The Awakening Phase: Building Initial Memory

During Phase 1 ("Awakening"), the Companion's only job is to understand Wisdom's world.
This is a unique period for the memory system — it needs to absorb a large amount of existing information and organize it into its memory stores.

### What the Companion Ingests During Awakening

| Source | Path | What It Contains | Memory Destination |
|---|---|---|---|
| Wisdom's memory files | `~/.claude/projects/-Users-wisdomhappy/memory/` | 20+ typed files: identity, projects, references, synthesis | Semantic memory (wisdom/, projects/) |
| The Companion's own plan | `~/the-companion/plan*.md` | Architecture, identity, all section plans | Semantic memory (self/) + Procedural |
| SOUL.md and identity files | `~/the-companion/soul/` | Core identity documents | Loaded into every context (not "memory" — identity) |
| Research documents | `~/the-companion/research/` | Cognitive science, architecture, feasibility | Semantic memory (domains/) |
| Wisdom's project directories | Various `~/` paths (per trust manifest) | Code, docs, configs for active projects | Semantic memory (projects/) |
| ChatGPT/Claude archive digests | `~/.claude/projects/-Users-wisdomhappy/memory/reference_chatgpt_archive.md` | Historical conversation context | Semantic memory (wisdom/history.md) |
| Google archive digests | `~/.claude/projects/-Users-wisdomhappy/memory/reference_google_archive.md` | Gemini, NotebookLM context | Semantic memory (wisdom/history.md) |

### Awakening Memory Protocol

The Awakening is not a brute-force ingestion — it is a structured exploration and comprehension process:

**Day 1-3: Core Context**
1. Read all of Wisdom's memory files. For each: understand, don't just store. Write a semantic memory file that captures the Companion's *understanding*, not a copy.
2. Read the Companion's own identity and plan files. Internalize.
3. Write initial semantic memory map (`_master_index.md`).

**Day 4-7: Project Deep Dives**
1. For each project listed in Wisdom's memory, explore the project directory (within trust manifest permissions).
2. For each project: understand its purpose, current state, connections to other projects.
3. Write a semantic memory file per project. Note open questions and curiosities.
4. Begin recording episodic memories of the exploration process itself (what was surprising, what was confusing, what sparked curiosity).

**Day 7-14: Relationship Building**
1. Begin asking Wisdom questions via Telegram (daily check-ins, project questions, curiosities).
2. Each interaction becomes an episodic memory.
3. Theory of mind (WISDOM-MODEL) begins building from real interaction, not just file reading.
4. Daily evening consolidation begins.

**Day 14+: Steady State**
1. The initial knowledge base is built.
2. New knowledge arrives through interaction and exploration.
3. Consolidation cycles maintain and evolve the memory.
4. The Awakening is "complete" when the Companion can accurately describe each of Wisdom's projects, their interconnections, and Wisdom's priorities — and Wisdom confirms this understanding.

### Awakening Budget Implications

Awakening is memory-intensive. The Budget system (Section 5) should allocate a higher-than-normal daily budget during Awakening:
- Heavy Sonnet usage for comprehension and semantic extraction
- Moderate Opus usage for deep synthesis (cross-project connections)
- Less emphasis on local models (comprehension needs depth, not speed)

Proposed Awakening budget multiplier: 1.5x-2x the steady-state daily budget for the first 14 days.

---

## Storage Architecture

### Hybrid Storage Design

The memory system uses three storage technologies, each for what it does best:

| Technology | Used For | Why |
|---|---|---|
| **Markdown files** | Semantic memory, procedural memory, consolidation reports, reflections | Human-readable, LLM-native, git-tracked, diff-able |
| **JSONL files** | Episodic memory (daily files) | Append-only, structured, preserves temporal order |
| **SQLite** | Metamemory index, prospective memory, episode index, budget tracking | Fast queries, concurrent access (WAL mode), ACID |

### File Structure

```
~/the-companion/
├── data/
│   └── memory/
│       ├── episodic/
│       │   ├── 2026-03-26.jsonl           # Daily episode files
│       │   ├── ...
│       │   ├── index.sqlite               # Searchable episode index
│       │   └── archive/                   # Pruned episodes (compressed)
│       ├── semantic/
│       │   ├── _master_index.md           # Top-level knowledge map
│       │   ├── wisdom/                    # Knowledge about Wisdom
│       │   │   ├── _index.md
│       │   │   ├── identity.md
│       │   │   ├── projects.md
│       │   │   ├── preferences.md
│       │   │   ├── patterns.md
│       │   │   └── history.md
│       │   ├── projects/                  # Project knowledge
│       │   │   ├── _index.md
│       │   │   ├── gdgm.md
│       │   │   ├── ps-website.md
│       │   │   └── ...
│       │   ├── domains/                   # General domain knowledge
│       │   │   ├── _index.md
│       │   │   └── ...
│       │   └── self/                      # Self-knowledge
│       │       ├── _index.md
│       │       ├── capabilities.md
│       │       ├── patterns.md
│       │       └── growth.md
│       ├── procedural/
│       │   ├── _index.md                  # Procedure catalog
│       │   └── *.md                       # Individual procedures
│       ├── prospective/
│       │   └── intentions.sqlite          # Prospective memory DB
│       ├── meta/
│       │   └── metamemory.sqlite          # Metamemory index
│       └── consolidation-log/
│           ├── 2026-03-26.md              # Daily consolidation reports
│           └── ...
```

### Storage Sizing Estimates

| Store | Growth Rate | 30-Day Estimate | 1-Year Estimate |
|---|---|---|---|
| **Episodic** (JSONL) | ~5-20 episodes/day, ~1KB each | ~300-600 KB | ~4-7 MB |
| **Episodic index** (SQLite) | Proportional to episodes | ~500 KB | ~5 MB |
| **Semantic** (Markdown) | Grows fast during Awakening, then slowly | ~200 KB | ~500 KB-1 MB |
| **Procedural** (Markdown) | Slow growth (new procedures are rare) | ~50 KB | ~200 KB |
| **Prospective** (SQLite) | Small, items expire | ~100 KB | ~200 KB |
| **Metamemory** (SQLite) | Proportional to all other stores | ~200 KB | ~2 MB |
| **Consolidation logs** | ~2-5 KB/day | ~100 KB | ~1 MB |
| **TOTAL** | | ~1.5 MB | ~15 MB |

Memory storage is not a constraint on an 8GB machine with SSD. The real constraint is token cost of retrieval, not disk space.

---

## Integration with Other Sections

### Section 3: Cognitive Engine (Primary Integration)

The Cognitive Engine is the consumer of working memory and the producer of new experiences.

**Interfaces the Memory System Exposes**:

```python
class MemoryManager:
    """Primary interface for the Cognitive Engine to interact with memory."""

    # --- Retrieval ---
    async def retrieve(
        self,
        context: CognitiveContext,  # Current task, conversation, topics
        budget_tokens: int,          # How many tokens can be used for memories
        stores: list[str] = None,    # Which stores to search (default: all)
    ) -> RetrievedMemories:
        """Retrieve relevant memories for the current context.
        Returns memories ranked by relevance, within token budget."""

    async def check_prospective(
        self,
        context: CognitiveContext,
        current_time: datetime,
    ) -> list[ProspectiveItem]:
        """Check for triggered prospective memories."""

    # --- Encoding ---
    async def encode_episode(
        self,
        episode: EpisodeData,  # What happened, context, outcomes
    ) -> str:
        """Encode a new episodic memory. Returns episode_id."""

    async def update_wisdom_model(
        self,
        observations: list[Observation],  # New observations about Wisdom
    ) -> None:
        """Update WISDOM-MODEL with new observations from interaction."""

    # --- Prospective ---
    async def remember_to(
        self,
        intention: str,
        trigger: TriggerSpec,
        source_episode: str = None,
    ) -> str:
        """Create a prospective memory (intention for the future)."""

    # --- Metamemory ---
    async def do_i_know_about(
        self,
        topic: str,
    ) -> MetamemoryResult:
        """Quick check: do I have knowledge about this topic?
        Returns locations and confidence, or 'unknown'."""
```

**Interfaces the Memory System Requires from Section 3**:

```python
# From CognitiveEngine:
class CognitiveContext:
    """The current state of the cognitive cycle."""
    cycle_id: str
    task: str
    topics: list[str]
    projects: list[str]
    model_tier: str  # local | haiku | sonnet | opus
    wisdom_interacting: bool
    emotional_context: dict  # Inferred from interaction signals
```

### Section 5: Budget System

Memory retrieval costs tokens. The Budget system needs to know:
- How many tokens were spent loading memories (per cycle)
- Whether retrieval was worth it (did the loaded memories get used?)
- Token budget allocation for consolidation cycles (these are "infrastructure" costs, not task costs)

**Interface**:
```python
# Memory system reports to Budget system:
class MemoryUsageReport:
    tokens_loaded: int           # Total tokens loaded from memory this cycle
    memories_loaded: int          # Number of memory items loaded
    memories_actually_used: int   # Number that the model referenced in its response
    retrieval_time_ms: int        # How long retrieval took
    consolidation_cost: float     # USD cost of the last consolidation cycle
```

### Section 7: Self-Improvement

The Self-Improvement system is the primary consumer of:
- Consolidation reports (to identify improvement opportunities)
- SELF-MODEL.md (to understand its own patterns)
- Episodic memories tagged as errors or corrections (to learn from mistakes)
- Procedural memories (to propose refinements)

**Interface**: Self-Improvement reads memory files directly (they're Markdown/JSONL in the filesystem). It does not go through the MemoryManager API — reflection is a different mode than real-time retrieval.

### Section 8: Security

All memory writes go through PermissionGate:
- `PermissionGate.check_file_write(path)` for every file write
- `AuditLogger.log(event)` for every memory operation
- Memory files live within the trust manifest's allowed write paths (`~/the-companion/data/**`)
- The Companion cannot write to Wisdom's memory files — only read them (enforced by trust manifest)

---

## Implementation Sequence

### Step 1: Core Storage Infrastructure

Build the file structure and database schemas:
- Create directory tree under `data/memory/`
- Initialize SQLite databases (metamemory, prospective memory, episode index)
- Define Python dataclasses for Episode, SemanticEntry, Procedure, ProspectiveItem
- Write file I/O utilities (read/write JSONL, read/write frontmattered Markdown, atomic file writes)
- Test: databases initialize, files write and read correctly

### Step 2: Episodic Memory Encoding

Build the episode creation pipeline:
- Episode encoding from CognitiveContext + outcomes
- JSONL writer (append to today's file)
- SQLite index updater (insert metadata for new episode)
- Metamemory updater (add topic entries for new episode)
- Test: create episodes, verify JSONL format, verify index query

### Step 3: Metamemory Index

Build the "do I know about X?" system:
- SQLite schema and query interface
- Topic normalization (lowercase, stemming, synonym expansion)
- Bulk index builder (scan all existing memory stores, populate metamemory)
- Test: metamemory queries return correct results for known and unknown topics

### Step 4: Retrieval Pipeline

Build the cue-based retrieval system:
- Cue extraction from CognitiveContext
- Metamemory scan
- Activation computation (decay function)
- Ranking and budget-aware loading
- Test: given a context, retrieval returns relevant memories in ranked order within budget

### Step 5: Semantic Memory Management

Build the knowledge base infrastructure:
- Frontmattered Markdown reader/writer
- Semantic file creation and update utilities
- Master index management
- Test: create, read, update semantic memory files

### Step 6: Procedural Memory Management

Build the procedure store:
- Procedure file format reader/writer
- Invocation tracking (success/failure recording)
- Index management
- Test: create, invoke, and update procedures

### Step 7: Prospective Memory

Build the intentions system:
- SQLite CRUD for prospective items
- Trigger evaluation (time, event, context matching)
- Integration with cognitive cycle start
- Expiry and cleanup
- Test: create intentions, trigger them under correct conditions

### Step 8: Consolidation Engine

Build the evening consolidation cycle:
- Episode review and importance reassessment
- Semantic extraction (pattern detection across episodes)
- Procedural pattern detection
- Forgetting / decay application
- Prospective memory maintenance
- Consolidation report generation
- Test: run consolidation on synthetic day of episodes, verify outputs

### Step 9: Awakening Protocol

Build the initial ingestion system:
- File exploration within trust manifest boundaries
- Comprehension-to-semantic-memory pipeline
- Structured exploration scheduler (which files to read, in what order)
- Progress tracking (what has been explored, what remains)
- Test: ingest a subset of Wisdom's files, verify semantic memory output

### Step 10: Working Memory Central Executive

Integrate with the Cognitive Engine:
- Token budget calculation per model tier
- Memory loading into context window construction
- Context eviction logic
- Memory formation trigger (should this cycle be encoded?)
- Test: end-to-end cycle with memory retrieval and encoding

### Step 11: Optional — Embedding Enhancement

If R0 confirms feasibility:
- Choose embedding model (all-MiniLM-L6-v2 or similar)
- Compute embeddings for existing memories
- Add similarity search to retrieval pipeline
- Benchmark retrieval quality: metadata-only vs metadata+embeddings
- Test: retrieval quality improves with embeddings without breaking RAM budget

---

## Structured Contract

### External Dependencies Assumed

| Dependency | From Section | What's Needed | Breaks If |
|---|---|---|---|
| R0: Technical Feasibility | Section 0 | RAM budget for memory operations, embedding model feasibility, SQLite performance benchmarks | Memory system designed for resources that don't exist |
| R1: Cognitive Memory Research | Section 0 | Consolidation mechanisms, forgetting curves, retrieval models, ACT-R activation equation validation | Memory architecture based on untested cognitive science mappings |
| Cognitive loop design | Section 3 | CognitiveContext structure, cycle lifecycle hooks for encoding/retrieval, model tier information | Memory system can't integrate with the cognitive engine |
| PermissionGate and AuditLogger | Section 8 | File write permission checks, audit logging for all memory operations | Memory writes bypass security, no audit trail for what was remembered/forgotten |
| Trust manifest allowed paths | Section 8 | Which directories the Companion can read from (Awakening) and write to (memory stores) | Awakening can't explore Wisdom's files, or memory writes are blocked |
| Identity files exist | Section 2 | SOUL.md, CHARACTER.md, WISDOM-MODEL.md structure defined | Working memory can't load identity correctly |
| Budget allocation for consolidation | Section 5 | Token/cost budget for consolidation cycles (Sonnet for evening, Opus for monthly) | Consolidation is too expensive or not budgeted |

### Interfaces Exposed

| Interface | Consumed By | Format | Contract |
|---|---|---|---|
| `MemoryManager.retrieve()` | Section 3 (Cognitive Engine) | Python async API | Given context + token budget, returns ranked memories within budget |
| `MemoryManager.encode_episode()` | Section 3 (Cognitive Engine) | Python async API | Given episode data, stores to episodic + updates metamemory |
| `MemoryManager.check_prospective()` | Section 3 (Cognitive Engine) | Python async API | Returns triggered intentions for the current cycle |
| `MemoryManager.remember_to()` | Section 3 (Cognitive Engine) | Python async API | Creates prospective memory with trigger specification |
| `MemoryManager.do_i_know_about()` | Section 3 (Cognitive Engine) | Python async API | Fast metamemory check — returns locations or "unknown" |
| `MemoryUsageReport` | Section 5 (Budget) | Dataclass | Token usage per cycle, consolidation costs |
| Semantic memory files | Section 7 (Self-Improvement) | Markdown files on disk | Direct file read for reflection cycles |
| Episodic error memories | Section 7 (Self-Improvement) | JSONL entries with type="error" | Direct query for learning from mistakes |
| WISDOM-MODEL updates | Section 2 (Identity) / Section 3 | Writes to WISDOM-MODEL.md | Dynamic state section updated after interactions |
| Consolidation reports | Section 7 (Self-Improvement), Wisdom | Markdown files | Daily/weekly summaries of memory activity |

### Technology Commitments

- **Markdown** for human-readable, LLM-native knowledge (semantic, procedural)
- **JSONL** for append-only event records (episodic)
- **SQLite** (WAL mode) for queryable indexes (metamemory, prospective, episode index)
- **Python** async interfaces for integration with the cognitive engine
- **Git tracking** for all Markdown files (full version history, diff-able)
- **No external vector DB** dependency — embeddings are optional and use local computation only
- **ACT-R-inspired** activation equation for memory decay/retrieval

---

## Key Decisions

### D1: Four distinct memory stores over a unified store

**Decision**: Maintain separate stores for episodic, semantic, procedural, and prospective memory, with metamemory as a cross-cutting index.
**Rationale**: These memory types have fundamentally different properties — episodic decays, semantic doesn't; procedural is versioned, episodic is append-only; prospective is query-by-trigger, semantic is query-by-topic. A unified store would need to fake these differences through complex metadata, and retrieval strategies differ per type. Cognitive science strongly supports the distinction (dissociable in brain lesion studies).
**Breaks if**: The overhead of maintaining four stores exceeds the benefit. Mitigated by: metamemory provides a unified query layer.

### D2: Consolidation-only writes to semantic memory

**Decision**: Semantic memory is never updated during active cognitive cycles — only during consolidation.
**Rationale**: Mirrors biological consolidation (episodic → semantic transfer happens during sleep). Prevents semantic memory from being overfitted to single experiences. Ensures knowledge is generalized before being stored. Reduces write contention during active processing.
**Breaks if**: Important knowledge that needs to be available immediately is delayed by the consolidation schedule. Mitigated by: the original episodic memory is available for retrieval immediately; only the semantic distillation is delayed.

### D3: Metadata-first retrieval, embeddings optional

**Decision**: Primary retrieval uses structured metadata (topics, projects, timestamps, activation scores) queried through SQLite. Vector embeddings are an optional enhancement.
**Rationale**: Embeddings require a model running in RAM (competing with Ollama and voice pipeline on 8GB). Metadata retrieval is fast, cheap, predictable, and explainable. If embeddings fit, they enhance retrieval quality. If they don't fit, the system still works well.
**Breaks if**: Keyword/topic-based retrieval misses too many relevant memories that only semantic similarity would catch. Mitigated by: rich tagging at encoding time, metamemory synonym expansion, and spreading activation as a fallback.

### D4: ACT-R-inspired activation for forgetting and retrieval

**Decision**: Use a simplified version of ACT-R's base-level activation equation (time-decay + retrieval strengthening + importance bonus) for memory activation.
**Rationale**: ACT-R's activation equation is one of the most empirically validated models of human memory retrieval. It naturally produces Ebbinghaus-like forgetting curves and implements the "use it or lose it" principle. It gives us a principled, tunable mechanism rather than ad-hoc heuristics.
**Breaks if**: The parameters need significant tuning for an AI agent (the decay rate calibrated for human memory over days/weeks may not map well to an AI's different time scales). Mitigated by: the parameters (decay rate, weights) are configurable and will be tuned empirically.

### D5: Episodes are selective, not exhaustive

**Decision**: Not every cognitive cycle produces an episodic memory. Encoding criteria filter for significance.
**Rationale**: The audit trail (Section 8) already captures everything. Episodic memory is for significant experiences worth retrieving later. If every cycle is encoded, episodic memory becomes a second audit log — noisy, expensive to search, hard to consolidate. Biological episodic memory is highly selective (you don't remember every breath).
**Breaks if**: The encoding criteria are too selective and important experiences are missed. Mitigated by: encoding criteria include a broad "novel outcome" category, and the criteria can be tuned. During Awakening, encoding is more liberal (more things are novel).

### D6: Prospective memory as a first-class store

**Decision**: Give intentions and commitments their own dedicated store with trigger-based retrieval, rather than handling them as tagged episodic memories.
**Rationale**: Prospective memory has unique requirements — it needs to be checked at the start of every cycle against trigger conditions, it needs expiry, it needs recurrence. These are SQL-friendly query patterns, not memory-retrieval patterns. Treating intentions as "just another memory" risks them being forgotten (literally — they'd decay like any other episodic memory).
**Breaks if**: The overhead of checking prospective memory every cycle is too high. Mitigated by: SQLite queries against a small table with indexed trigger columns are sub-millisecond.

### D7: Awakening as structured exploration, not bulk ingestion

**Decision**: The Awakening phase is a phased, comprehension-oriented process (understand, then store) rather than a bulk copy of Wisdom's files.
**Rationale**: Copying Wisdom's files into the Companion's memory would be fast but would not build understanding. The Companion needs to *comprehend* — read, synthesize, ask questions, form its own understanding. This is more expensive (token cost) but produces genuinely internalized knowledge rather than indexed copies.
**Breaks if**: The Awakening takes too long and is too expensive. Mitigated by: phased schedule, budget multiplier, and clear completion criteria.

---

## Open Questions

### Q1: How do we tune the decay function parameters?

The ACT-R decay rate of 0.5 is calibrated for human memory over timescales of minutes to years.
The Companion's "timescale" is different — it might have 50 interactions in a day, each generating episodes.
Should the decay rate be faster (memories from this morning are already fading by evening) or slower (everything from today should remain strong)?
**Proposed approach**: Start with d=0.5, observe how many memories survive 7/30/90 days, tune empirically. The decay rate should be a configurable parameter, not hardcoded.

### Q2: Should the Companion be able to "actively recall" — search beyond metamemory?

Metamemory answers "do I know about X?" quickly. But what about "I vaguely remember something about X but it's not in metamemory"?
In biological memory, you can sometimes retrieve a memory through effortful search even when the initial "feeling of knowing" is weak.
Should the Companion have an "effortful search" mode that scans episodic JSONL files directly (expensive) when metamemory fails?
**Proposed approach**: Yes, as a budget-gated fallback. If metamemory returns nothing and the topic seems important, the Companion can do a full-text search of recent episodic memory files. This is expensive (scanning JSONL) so it should be rate-limited and only used when the context strongly suggests relevant memories exist.

### Q3: How does consolidation interact with the circadian rhythm?

The plan says evening consolidation. But the Companion runs 24/7.
When is "evening"? Should it be tied to a fixed clock time (e.g., 11 PM Pacific) or to a period of low activity (no Wisdom interactions for 2+ hours)?
**Proposed approach**: Default to 11 PM Pacific. But also allow activity-triggered consolidation: if Wisdom hasn't interacted for 3+ hours and there are unprocessed episodes, run a micro-consolidation. Full evening consolidation happens once daily regardless.

### Q4: How large can semantic memory grow before retrieval degrades?

Semantic memory files are Markdown, loaded into context windows.
If the Companion accumulates 500 KB of semantic memory, loading even 10% is 50 KB (~15K tokens).
At what point does semantic memory need its own compression/summarization cycle?
**Proposed approach**: Set a soft ceiling of 200 KB total semantic memory. When approaching this, consolidation should aggressively summarize and compress low-confidence entries. Individual semantic files should not exceed 5 KB. If a topic grows beyond that, split it.

### Q5: What happens to memory across version upgrades of the Companion?

If the Companion's code is significantly updated (new cognitive engine, new schema), how does memory migrate?
Episodic JSONL is robust (schema evolution via new fields, old fields preserved).
SQLite databases may need migrations.
Semantic Markdown files are schema-light and should be fine.
**Proposed approach**: Version all schemas. Write migration scripts when schemas change. The consolidation system should be able to re-index from primary stores (JSONL, Markdown) if indexes are corrupted or need rebuilding.

### Q6: Should the Companion remember things Wisdom explicitly asks it to forget?

If Wisdom says "forget about that approach" or "disregard what I said about X," should the episodic memory of the conversation be deleted, or just semantically noted as superseded?
**Proposed approach**: Never truly delete episodic memories (the audit trail records everything anyway). Instead, mark episodes as "superseded" with a link to the correction episode. In semantic memory, update the knowledge to reflect the correction. The fact that Wisdom changed their mind is itself valuable knowledge.

### Q7: How does the memory system handle contradictions?

If semantic memory says "GDGM is a unified physics theory" but a recent episode has Wisdom saying "I'm reconsidering GDGM's foundations" — how is this handled?
**Proposed approach**: Consolidation detects contradictions between episodic and semantic memory. When found, the consolidation report flags them. Semantic memory is updated with a "confidence lowered" note and the source of the contradiction. The Companion should proactively surface contradictions to Wisdom for resolution rather than silently picking one version.

---

## Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| Memory retrieval is too slow and adds latency to every cognitive cycle | Companion feels sluggish, burns budget on retrieval overhead | Metamemory provides O(1) existence check. SQLite indexes are fast. Budget-gate retrieval depth. Monitor retrieval_time_ms. |
| Consolidation cycle is too expensive (too many Sonnet/Opus tokens) | Burns daily budget on internal processing, not useful work | Budget consolidation separately from task budget. Set consolidation token caps. Micro-consolidation on Haiku to reduce evening burden. |
| Forgetting is too aggressive — important memories are pruned | Companion loses knowledge it needs, appears forgetful to Wisdom | Protected memory flag for critical memories. Conservative initial decay rate. Require semantic capture before episodic pruning. |
| Forgetting is too conservative — memory grows without bound | Retrieval quality degrades as noise increases, storage grows | Monthly review of memory size. Aggressive compression during monthly consolidation. Track retrieval precision over time. |
| Metamemory becomes stale — topics indexed don't match actual content | False positives (thinks it knows something it doesn't) and false negatives (misses knowledge it has) | Re-index during evening consolidation. Verify random entries during monthly consolidation. |
| Awakening overloads Wisdom with questions | Annoying instead of endearing | Rate-limit questions (max 3/day during first week). Prioritize questions the Companion genuinely can't answer from files. |
| SQLite database corruption | Loss of metamemory, prospective memory, episodic index | WAL mode for concurrent safety. Periodic SQLite integrity checks (health monitor). Metamemory and episode index can be rebuilt from primary stores. Prospective memory: frequent backups. |
| Embedding model doesn't fit in RAM alongside other processes | Enhanced retrieval path unavailable | The system is designed to work without embeddings. This is a "nice to have" enhancement. |

---

## Success Criteria

1. The Companion can retrieve relevant memories for a given context within 500ms and within token budget
2. Episodic memory encodes 5-20 significant episodes per active day (not 0, not 100)
3. Evening consolidation completes within 15 minutes and costs less than 10% of daily budget
4. After 30 days, semantic memory accurately reflects the state of Wisdom's projects (Wisdom confirms)
5. The forgetting system has pruned at least some low-value episodes by day 30 (proving it works)
6. No important memory has been incorrectly pruned by day 30 (proving it's not too aggressive)
7. Metamemory correctly answers "do I know about X?" for 90%+ of test queries
8. Prospective memory triggers fire on time (time-based) and in context (context-based) with 95%+ reliability
9. The Awakening phase produces a coherent semantic knowledge base that Wisdom recognizes as accurate
10. The Companion can explain why it retrieved a specific memory (retrieval is not a black box)
11. Memory usage reports show stable or decreasing token cost per retrieval as the system matures
12. Monthly consolidation produces measurable improvement in knowledge organization (fewer redundant entries, better cross-references)
