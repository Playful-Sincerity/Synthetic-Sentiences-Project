# Section 6: Continuous Cognition Loop

**Complexity:** L
**Risk:** High — integration of all components; thermal on fanless M1 Air
**Dependencies:** Sections 3 (structured output), 4 (traversal), 5 (tool compensation)
**Feeds into:** Section 9 (prototype)

---

## The Thesis This Section Tests

Well-designed architecture massively amplifies the power of LLMs. The graph carries knowledge. The tools carry judgment. The hooks carry guardrails. The skills carry patterns. The model's only job: read a small neighborhood, generate a short structured output. Everything else is architecture.

This section integrates all of that into a continuous loop and proves it runs for 8 hours on a fanless M1 Air.

---

## Loop Architecture: Six Stages

```
[PULSE] → [ATTEND] → [PERCEIVE] → [TRAVERSE] → [ACT] → [REFLECT] → [LOOP]
```

| Stage | What It Does | Cost | LLM? |
|---|---|---|---|
| PULSE | Read emotional state, check resources | <5ms | No |
| ATTEND | Select what to think about (deterministic priority) | <10ms | No |
| PERCEIVE | Load graph neighborhood for focus node | <8ms | No |
| TRAVERSE | **LLM reads context, outputs GraphOp JSON** | **~33s** | **Yes** |
| ACT | Execute GraphOp via tool bus pipeline | <8ms | No |
| REFLECT | Update loop state, log, check rest triggers | <5ms | No |

**The cycle is >99% inference time.** Non-inference overhead is ~15ms against ~33s. All performance leverage is in thermal management and prompt size.

---

## Stage 1: PULSE

**Fast path (every cycle, <5ms):** Read `emotional_state.json`, extract four dimensions.

**Slow path (every 30 cycles, background async):** Full update:
1. Read last 30 cycle logs from chronicle
2. Check thermal state (tok/s degradation as proxy)
3. Compute new dimension values
4. Write updated `emotional_state.json` + append to `pulse_history.jsonl`

**Dimension computations:**

`alignment_confidence`: rises with consistent traversal, drops with parse failures and contradictions. Clamp [0.1, 1.0].

`curiosity_pull`: rises with many low-confidence nodes and low creation rate. Falls when actively creating (curiosity being satisfied). Clamp [0.0, 1.0].

`energy`: `thermal_ceiling × (1 - active_fatigue)`. Directly from thermal state. Clamp [0.0, 1.0].

`coherence`: proportion of consecutive focus nodes that are adjacent in graph. High = purposeful. Low = random walk. Clamp [0.2, 1.0].

---

## Stage 2: ATTEND (No LLM Call — Deterministic)

Salience scoring over attention queue candidates:

```
attention_score(node) =
    edge_weight_from_current × 0.35        # topological pull
  + (1 - node.confidence) × 0.25           # low confidence = interesting
  + novelty_since_last_visit × 0.20        # older = more novel
  + curiosity_pull × is_gap_node × 0.15    # pulse-modulated curiosity
  + coherence_repair × is_flagged × 0.05   # contradiction repair
```

**Pulse modulation:**
- `energy < 0.3`: restrict to 1-hop neighbors only
- `alignment_confidence < 0.4`: force select meta/belief node for self-check
- `coherence < 0.4`: force select most recent contradiction flag

---

## Stage 3: PERCEIVE

Load graph neighborhood (~350 tokens):
- Focus node: ~80 tokens (content + type + confidence + tags)
- Outgoing edges (max 5): ~150 tokens
- Incoming edges (max 3): ~90 tokens
- Graph stats: ~30 tokens

**Total prompt: ~850 tokens** (system prompt + emotional state + prior-cycle echo + neighborhood).

---

## Stage 4: TRAVERSE (The Only LLM Call)

```python
response = ollama.chat(
    model="phi4-mini",
    messages=[{"role": "user", "content": assembled_prompt}],
    format="json",
    options={"temperature": 0.3, "num_predict": 200, "num_ctx": 1024}
)
```

- T=0.3: structured output sweet spot. Cross-validate with S3 data.
- `num_predict: 200`: GraphOp cap
- `num_ctx: 1024`: prompt is ~850 tokens

**Failure handling:** 3 consecutive failures → pause 60s, alert. Fallback: random traverse.

---

## Stage 5: ACT

Execute GraphOp via S5 tool bus:
- Pre-traversal tools already ran during context assembly (T2, T3, T4)
- Post-generation validation (T6)
- Action-specific tools fire here (T1, T5, T7)

Tool results feed into NEXT cycle's prior-cycle echo, not re-entered into current call. One LLM call per cycle — predictable latency.

**Integrity rules:** no empty content, no edges to non-existent nodes, confidence +0.3 cap per step.

---

## Stage 6: REFLECT

Log cycle record to chronicle. Check rest triggers:

```python
def should_rest(context):
    if context.active_block_cycles >= MAX_ACTIVE: return True
    if context.thermal_state == "throttled": return True
    if context.energy < 0.2: return True
    if context.consecutive_failures >= 3: return True
    return False
```

---

## Thermal Management

### M1 Air Reality
No fan. Sustained load → throttling at ~95°C after 10-20 min. Stabilizes at ~50-60% peak. Doesn't crash — throttles gracefully.

### Duty Cycle: 20 min active / 10 min rest

```
ACTIVE BLOCK (~36 cycles at peak)
├── Cycles 1-5:    Warm-up — prefer familiar territory
├── Cycles 6-25:   Core cognition — full salience scoring
├── Cycles 26-36:  Wind-down — prefer updates over creates
└── End: REST trigger

REST PERIOD (10 min)
├── Graph consolidation (prune orphans, compute centrality)
├── Attention queue reset (fresh perspective)
├── Optional mini-reflection (1 LLM call)
└── Pulse update (fresh emotional_state.json)
```

### Thermal States

| State | Condition | Response |
|---|---|---|
| COOL | <70°C | Full speed |
| WARM | 70-85°C | Monitor |
| HOT | 85-95°C | Reduce active block by 25% |
| THROTTLED | >95°C or tok/s drop >40% | End block immediately, 20 min rest |

### Rest Duration Ladder

| Trigger | Duration |
|---|---|
| Normal completion | 10 min |
| Thermal HOT | 12 min |
| Thermal THROTTLED | 20 min |
| 3 consecutive failures | 10 min + alert |
| alignment_confidence < 0.3 | 15 min + reflection |

**Key insight:** The `energy` emotional dimension IS the thermal monitor. One measurement serves both purposes.

---

## Throughput Numbers

| Metric | Peak (30 tok/s) | 50% Throttle (15 tok/s) |
|---|---|---|
| Cycle time | ~33s | ~67s |
| Cycles/hour (continuous) | 109 | 54 |
| Cycles/day (2:1 duty cycle) | ~1,745 | ~872 |
| New nodes/8h session | ~173 | ~86 |
| New edges/8h session | ~87 | ~43 |
| Nodes/week | ~1,215 | ~610 |

**Feasibility plan said 14,400/day** — that was 14B on M5/32GB. On M1 Air with 3.8B and duty cycle: ~1,745/day. Still ~1,215 new nodes/week — meaningful understanding in days.

---

## Memory Footprint

| Component | Start | After 8h |
|---|---|---|
| OS + system | ~2.5GB | ~2.5GB |
| Ollama + Phi-4 Mini | ~2.5GB | ~2.5GB |
| SQLite + graph | ~50MB | ~150MB |
| Python + libs | ~80MB | ~100MB |
| Chronicle + embedding cache | ~105MB | ~220MB |
| **Total** | **~3.2GB** | **~3.5GB** |

**Memory is not a risk.** 3.5GB against 5.5GB available. Storage: ~7MB new data after 8h.

---

## Graph Growth Design

**Create when:** focus node references something not in graph; proposed content < 0.7 similarity to any existing node.

**Traverse only when:** focus node recent (<5 cycles); energy < 0.4; graph grew >50 nodes this session.

**Update-over-create rule:** check 0.85 cosine similarity threshold before creating. If match → update instead.

---

## Implementation Files

```
src/
  cognitive_loop.py    — CognitiveLoop class, do_cycle(), do_rest()
  pulse.py             — EmotionalState, dimension computations
  attention.py         — AttentionQueue, salience scoring
  neighborhood.py      — GraphNeighborhood assembly, prompt construction
  chronicle.py         — CycleRecord, append, flush, query-last-N
  thermal.py           — ThermalState, monitor_thermal() background task
  consolidation.py     — Rest-period graph maintenance
```

---

## Acceptance Criteria

- Loop runs 8h without crash (400+ cycle records)
- tok/s never drops below 50% of initial for >2 consecutive 10-min samples
- Graph has ≥50 new nodes AND ≥25 new edges
- RSS after 8h within 200MB of RSS after first 30 min (no leak)

## Test Strategy

**Smoke tests (CI):** single cycle mocked (<1s), pulse update (<100ms), attention scoring (<50ms), thermal throttle trigger (<1s), 30 live cycles (~15-20 min).

**8-hour validation:** run on M1 Air (target hardware). Elevated on stand. Log every 10 min: tok/s, RSS, node count, edge count, thermal state. Output: `results/8h-validation-YYYY-MM-DD.json`.

---

## Structured Contract

- **Requires:** Graph Engine CRUD (S2), JSON mode ≥95% (S3), traversal quality ≥80% (S4), similarity_score + check_contradiction tools (S5)
- **Exposes:** `CognitiveLoop.run(duration_hours)` (S9), `emotional_state.json`, `chronicle/` JSONL, `pulse_history.jsonl`

## Key Decisions

1. **20/10 duty cycle** — may need tuning to 15/10 empirically
2. **One LLM call per cycle** — predictable latency; tool results enter next cycle
3. **Pulse every 30 cycles (count-based)** — stable under throttling
4. **Temperature 0.3** — cross-validate with S3 data
5. **Pre-generated neighbor summaries** — keeps PERCEIVE <10ms

## Open Questions

1. Actual throttle onset time for Phi-4 Mini + Ollama on M1 Air?
2. Is 30 tok/s peak or sustained? Sustained at 20 tok/s changes throughput ~33%.
3. Minimum seed graph size for 8h test? ~100 nodes is probably the floor.
4. Should `reflect` ops be forced every N cycles?
5. Boredom mechanism for when model spins on same cluster?
