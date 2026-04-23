---
timestamp: "2026-04-14 16:00"
category: idea
related_project: Claude Code Entities
source: ClaudeClaw v2 analysis
---

# Memory Decay + Pinning

Our MEMORY.md is append-only and grows forever. ClaudeClaw uses importance-weighted decay:
- Pinned (user-controlled): 0% decay, persist forever
- High importance (≥0.8): 1%/day
- Mid importance (≥0.5): 2%/day
- Low importance (<0.5): 5%/day
- Hard-delete at salience <0.05

Plus relevance feedback: after each response, evaluate which surfaced memories were useful. Useful ones get salience boost, unused get penalty.

For entities: heartbeat could run decay sweep. Pinned memories are like our "core values" — they never fade. Observations decay unless they prove useful.

Priority: V2 — after basic memory works.
