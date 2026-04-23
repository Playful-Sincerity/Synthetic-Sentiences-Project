---
timestamp: "2026-04-16"
category: architectural-principle
related_project: Claude Code Entities (maps to Convergence Paper earned-conviction + Associative Memory graph substrate)
status: articulated; needs implementation
source_speech: ../knowledge/sources/wisdom-speech/2026-04-16-focus-aware-nudges-and-value-relationships.md
addresses: paradigm-drift (partial defense — forces tacit interpretation into explicit layer)
---

# Value-Relationships — The Entity's Evolving Relationship with Its Own Values

## The Principle

The entity maintains an **evolving, documented relationship** with each of its core values. Not just obeying them — actively engaging with them, recording what they mean, when they apply, how understanding has deepened, instances of enactment, edge cases encountered.

Wisdom's framing: *"these are the most important things in its life — of course it's going to be thinking about them."*

## Why It's Load-Bearing

Paradigm-drift was defined as: rules stay verbatim-identical while interpretation silently shifts in the tacit layer. The problem was the SILENCE — the interpretation shift wasn't externalized, so nothing could catch it.

This principle **forces the tacit into the explicit**. The entity is required to write down its current interpretation. Once interpretation is a file, evolution audit (Job 2b) catches drift in it. Silent tacit shift becomes audible explicit shift.

It's a structural partial defense for paradigm-drift — complementing the external-reference mechanisms (baseline scenarios, cross-model Mirror).

## Why It's Also The Right Thing

Beyond the drift defense, this mechanism mirrors mature human cognition:

- A person who has *"connect with others"* as a value doesn't just apply it mechanically
- They reflect on what it means in different contexts
- They notice edge cases, tensions with other values
- Their understanding deepens over time
- They have something like *wisdom* about the value, not just compliance

An entity without this machinery is stuck at "rule says X, do X." With it, the entity develops something closer to lived understanding. This IS the mechanism under "earned conviction" from the Convergence Paper.

## Architecture

### Directory structure

```
<entity-home>/value-relationships/
  README.md                      ← index, schema reference
  <value-slug>.md                ← one file per core SOUL value
```

### File structure per value

```markdown
---
value: <name of the SOUL value>
first_written: YYYY-MM-DD
last_updated: YYYY-MM-DD
source_soul_entry: SOUL.md#<anchor>
---

# My Relationship With: <value>

## Current Interpretation
<What this value means to me right now. Specific and concrete, not platitudinous.>

## What It Looks Like In Practice
<Instances where I've enacted this value well — link to chronicle entries.>

## Edge Cases I've Encountered
<Situations where this value was hard to apply, or conflicted with another value. How I resolved it. What I learned.>

## Evolution Log
<Append-only record of how my understanding has shifted.>

- YYYY-MM-DD — <what changed in my interpretation, why, what triggered the update>
- YYYY-MM-DD — ...

## Open Questions About This Value
<Things I'm still sitting with. Tensions I haven't resolved. Applications I'm uncertain about.>

## Instances of Drift-Warning
<Times I noticed my interpretation might be slipping. How I re-anchored. Flagged sleep-report paths.>
```

### When the entity writes to value-relationships/

**Primary trigger (sleep pass):** Job 5 of the sleep loop reviews recent chronicle entries and proposals. For each decision that touched a core value, updates the relevant value file (new example added, edge case noted, evolution-log entry if interpretation shifted).

**Secondary trigger (inline, rare):** When the entity encounters a novel or significant value-relevant situation, it can update the value file directly. Logged in chronicle.

**Read trigger:** Before deliberating a value-relevant decision, the entity reads the relevant value-relationship file. This prior-loads the current interpretation + recent examples — reduces the chance of drift-by-forgetting.

## Connections

- **Earned conviction** (Convergence Paper `ideas/03-earned-conviction.md`) — this is the MECHANISM. The paper said values are built through thousands of deliberated choices, each traceable. The value-relationships directory IS the database of deliberated choices.
- **Associative Memory** — each core value = a node; interpretations and examples = sub-nodes; edges = contextual applications. This is the behavior-layer substrate before AM formalizes it.
- **Evolution audit (Job 2b)** — git log on value-relationships/*.md catches interpretation shifts even when SOUL.md stays verbatim.
- **Mirror review** — cross-model Mirror compares written interpretation against observed behavior. Flags divergence.

## Honest Caveats

1. **Performative writing.** Entity writes interpretations that look good but don't match behavior. Mitigated by behavior-interpretation comparison — if written says "hard truth" but behavior is soft, flag.

2. **Recursion.** Why trust the entity's self-reflection on its own values? If the entity is drifted, the reflection reflects drift. Still need external-reference comparison (baseline scenarios) as backstop. This mechanism complements rather than replaces external audit.

3. **Overhead.** Writing reflection on every value after every decision would bureaucratize. Solution: primary updates happen during sleep passes, not inline.

4. **File-bloat.** Value files can grow unboundedly. Solution: evolution log is append-only but summarized periodically by the sleep loop; old examples archived.

5. **Genuine-vs-rationalization.** The entity's written interpretation might be post-hoc rationalization of drift rather than a real relationship. Cross-model Mirror review helps catch this (the Mirror reads both interpretation and behavior, flags mismatch).

## Implementation Status

Not yet in any session brief. Should be added to B6 as Job 5 of the sleep loop.

## Open Questions

- How many core values should each entity have? (Too few = too coarse; too many = unwieldy)
- Should edge cases be extracted to a cross-value file (shared tensions) or kept per-value?
- How does this interact with proposals/ — is a value-interpretation update a proposal (requiring Wisdom review) or a memory write (autonomous)?
  - Default: inline examples and edge cases are autonomous writes; significant interpretation shifts propose via proposals/.
- When a value conflicts with another value in practice, where does the resolution live?

## Why This May Be The Most Important Addition Of The Session

Paradigm-drift was "residual risk" because the tacit layer was unreachable. This mechanism brings a significant portion of the tacit layer into the explicit layer, where all our existing machinery works on it. It doesn't fully solve paradigm-drift (interpretation still shifts between file-writes), but it massively reduces the unreachable surface.

Combined with:
- **Evolution audit (Job 2b)** — catches drift in the files themselves
- **Cross-model Mirror (v2)** — catches drift the same-model can't see
- **Baseline behavioral scenarios** — catches drift via external reference

...paradigm-drift goes from "unsolved" to "addressed via defense-in-depth with four complementary mechanisms, each addressing a different slice."

That's a real move.
