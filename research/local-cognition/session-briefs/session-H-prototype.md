# Session Brief: H — Prototype Integration (S9)

## Prerequisites
- ALL prior sessions complete (A through G, plus I)
- This is the final session — it assembles everything

Read these files from completed sessions:
- `results/structured-output-analysis.md` — best model, best condition
- `results/traversal-analysis.md` — traversal quality, proximity trap results
- `results/tool-compensation-analysis.md` — tool effectiveness
- `results/cognitive-loop-analysis.md` — duty cycle params, graph growth rates
- `results/scaling-analysis.md` — target operating scale
- `results/comparison-analysis.md` — graph vs RAG recommendation
- ALL `src/` files — you're assembling these into a working system

## Context
Combine validated graph engine + best model + tool bus + cognitive loop into a working local companion prototype. Three operating modes: autonomous cognition, dialogue, and ingestion. CLI interface. Runs on M1 MacBook Air 8GB with zero API calls.

Read these files first:
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan-section-prototype.md` — full S9 plan
- `~/Playful Sincerity/PS Software/The Companion/research/local-cognition/plan.md` — master plan (overall acceptance criteria)

## Task

### Phase A: Assembly (1-2 days)

**A1: Configuration**
Create `config.yaml`:
- `model_name`: from Session B/D results (best model)
- `duty_cycle_active_min`: from Session G results
- `duty_cycle_rest_min`: from Session G results
- `num_ctx`: 2048
- `neighborhood_token_budget`: from Session B/G findings
- `thermal_thresholds`: from Session G
- All tunable without code changes

**A2: Dialogue Manager**
Create `src/dialogue.py` — DialogueManager class:
- `respond(user_message)`: embed → find entry node → grow tree → assemble context → LLM generates freeform text → extract learnings → return response + source path
- `ingest(content, source)`: chunk → extract nodes/edges per chunk → merge check (T5) → create → return report
- Conversation history stored AS graph nodes (type: `observation` for user, `belief` for companion)

**A3: Main Entry Point**
Create `src/prototype.py`:
- Wire GraphEngine + CognitiveLoop + ToolBus + DialogueManager
- Load config from `config.yaml`
- Async architecture: cognitive loop runs in background, CLI accepts user input

**A4: CLI Interface**
- Async CLI with cognitive loop in background thread
- User types messages → dialogue manager responds
- Commands: `/status`, `/ingest <file>`, `/path`, `/stats`, `/quit`
- Display: response text + source nodes used + confidence indicators
- Graceful shutdown: finish cycle, flush chronicle, close DB

### Phase B: Seed & Bootstrap (1-2 days)

**B1: Seed Graph**
Hand-curate ~100 seed nodes:
- 30 nodes about Wisdom's projects (PS ecosystem basics)
- 20 nodes about key concepts (graphs, cognition, memory, AI)
- 20 nodes about itself (what it is, its purpose, its limitations)
- 15 nodes about the world (basic facts it should know)
- 15 meta-nodes (about how to think, what confidence means, when to be uncertain)

**B2: Ingestion Test**
Ingest 2-3 test documents. Verify node/edge creation quality.

**B3: Autonomous Cognition Test**
1 hour of loop running on seed graph. Verify stability + meaningful growth.

**B4: Dialogue Test**
10 dialogue exchanges. Verify:
- Responses reference graph content
- Source paths are traceable
- New nodes created from conversation
- Honest "I don't know" when graph lacks info

### Phase C: 8-Hour Validation (1 day)

Run on M1 Air 8GB. Start from seed graph. Intersperse 5 dialogue sessions at hours 0, 2, 4, 6, 8.

**The money test:** Ask the same 5 questions at hour 0 and hour 8:
1. "What are you?" (self-knowledge)
2. "What is Playful Sincerity?" (ingested domain knowledge)
3. "How do graphs relate to memory?" (conceptual connection)
4. "What are you uncertain about?" (meta-cognition)
5. "What have you learned today?" (temporal awareness)

Compare responses. Document improvement (or lack thereof).

Log everything: cycle records, thermal, graph growth, dialogue quality.

### Phase D: Analysis & Documentation (1 day)

**D1: Compile Results**
`results/prototype-report.md`:
- Summary of all benchmark results across all sections
- What works, what doesn't, what surprised us
- Hour-0 vs hour-8 comparison (with actual responses quoted)
- Performance characteristics: tok/s, thoughts/day, RAM, thermal
- Graph statistics: total nodes, edges, density, cluster structure

**D2: Path Forward**
Document what needs to change to evolve prototype → full Companion:
- Voice: add Whisper for speech-to-text
- Vision: integrate Phantom for visual perception
- Identity: practical consciousness layer (permission-as-consciousness)
- Autonomy: Claude Agent SDK for complex task execution
- Hardware: M5 Pro 32GB for larger models
- Scale: what graph size is needed for "useful understanding"

**D3: Archive**
Archive all raw data, benchmark results, model outputs.

## Output Format

- `src/prototype.py` — main entry point
- `src/dialogue.py` — DialogueManager
- `config.yaml` — all tunable parameters
- `data/seed-graph.db` — curated seed graph
- `results/prototype-report.md` — comprehensive results
- `results/8h-prototype-validation-YYYY-MM-DD.json` — validation data
- Git commit (tag: `v0.1-prototype`)

## Success Criteria

1. **It runs.** Start → cognitive loop cycles → dialogue works. M1 Air 8GB. Zero API.
2. **It thinks.** Autonomous cognition produces meaningful graph growth (>80% coherent by spot check).
3. **It remembers.** Info given at hour 0 retrievable at hour 8. Graph persists across restarts.
4. **It improves.** Hour-8 answers measurably better than hour-0 on the 5 comparison questions.
5. **It's auditable.** Every response includes graph path. Claims traceable to source nodes.
6. **It's honest.** Says "I don't know" when graph lacks relevant information.
