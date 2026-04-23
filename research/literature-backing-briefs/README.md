# Literature-Backing Briefs

Seven research streams, one per substantive thesis claim in The Synthetic Sentiences Project. Each brief is a self-contained prompt for a separate Claude Code conversation (or research subagent) to execute independently. Results from each stream land in the relevant subsystem's `research/literature-backing.md`.

The goal is not to prove the thesis is novel (some of it isn't — that's fine). The goal is to show where our claims connect to, extend from, or diverge from the existing literature. A dense repo with honest literature grounding reads as serious research in progress; a thin repo that gestures at prior work reads as a pitch.

## Streams

1. [stream-1-memory-as-world-model.md](stream-1-memory-as-world-model.md) — graph IS world model; LLM as traversal engine; neurosymbolic/interpretable memory lineage
2. [stream-2-predictive-perception.md](stream-2-predictive-perception.md) — imagine-before-act; predictive coding, active inference, WebDreamer lineage
3. [stream-3-affect-as-alignment.md](stream-3-affect-as-alignment.md) — emotion as gap between perceived and should-world-graph; computational affect; alignment-mechanism framing
4. [stream-4-self-model-drift.md](stream-4-self-model-drift.md) — persistent self-observation; metacognition; mesa-optimization and goal drift (extends three-drift-types)
5. [stream-5-sleep-and-dream.md](stream-5-sleep-and-dream.md) — sleep-as-consolidation vs dream-as-simulation; replay in RL; systems comparison (extends sleep-loop-unification)
6. [stream-6-epistemic-prosody.md](stream-6-epistemic-prosody.md) — confidence through voice quality; psycholinguistics of prosody; honest disfluency
7. [stream-7-earned-conviction.md](stream-7-earned-conviction.md) — belief revision; evidence chains; confidence calibration; dissonance detection

## How to run

Each brief is independent; run in any order, in parallel if capacity allows. Each assumes the runner has read the root [`CLAUDE.md`](../../CLAUDE.md) for project context before starting.

## Target output

Each brief produces two artifacts at the location specified in its body:

1. **Synthesis** (~2000 words) — prior work survey, how our thesis connects to / extends / diverges from it, specific citations that strengthen our claims, honest notes where we're on thinner ice
2. **Annotated bibliography** (10–20 papers) — one-paragraph annotation per paper

Both land inside the relevant subsystem's `research/` directory. The subsystem CLAUDE.md then links to them.
