# The Sleep Loop — Unifying Self-Learning, Drift Audit, and Compaction via Scheduled Restricted-Subagent Consolidation

**Status:** idea — wants implementation data before drafting
**Estimated length:** systems paper (6–10 pages)
**Target venue:** systems / applied ML workshop or arXiv preprint

## Claim

A scheduled restricted-subagent "sleep loop" — structurally analogous to biological sleep consolidation — unifies three architectural functions in autonomous agent systems via one mechanism:

1. **Self-learning** — daily chronicles get consolidated into memory/ and world-model.md by the sleep subagent
2. **Drift audit** — the sleep subagent reviews the main entity's recent behavior against immutable SOUL.md values, flags anomalies
3. **Compaction preparation** — before main context fills, the sleep loop has already externalized what matters into files, so next session restarts from externalized state rather than from compressed memory

The restricted-subagent pattern (write-only to memory directory, read-only Bash) ensures the main entity cannot corrupt its own long-term memory during operation. Cadence scales with activity volume, not wall-clock.

## Why Novel

No published system combines these three functions under one architectural mechanism. Individual components exist:
- KAIROS: two-loop separation (operating entity writes only to ephemeral log; nightly restricted subagent consolidates)
- MemMachine: immutable core layer + retrieval-generation decoupling
- Agent Drift paper: Adaptive Behavioral Anchoring for drift detection
- AutoGen: centralized compaction

But the unification — same mechanism doing all three — is novel. The biological-sleep analogy (Buddhist sleep consolidation framing from play research) is suggestive but hasn't been operationalized in the literature.

## Why This Matters

The "sleep deprivation" frame is the insight: agents without a consolidation loop are architecturally preemptively-exhausted. Drift in current systems is the functional equivalent of sleep deprivation symptoms in humans — memory confusion, value erosion, pattern-failure.

Biological systems solve this with dedicated offline consolidation. Agent systems should too.

## Key Evidence

- **Stream A (mechanisms):** two-phase accumulation-distillation pattern found in every mature system (KAIROS, ClaudeClaw, Letta, Hermes Agent, OpenClaw). Systems that skip Phase 1 and write directly to long-term memory degrade in quality.
- **KAIROS source analysis** (prior research): restricted subagent with read-only Bash and write-only memdir permissions. The main entity CANNOT corrupt its own knowledge base mid-operation.
- **Compaction data (Stream B §3.5):** 100K → ~500 tokens, 200× compression; artifact tracking 2.19/5.0. File externalization replaces this ceiling.
- **Agent Drift (arXiv 2601.04170):** Adaptive Behavioral Anchoring gives 70.4% semantic-drift reduction.
- **Pattern-spotter play finding:** git-for-code → git-for-beliefs; sleep consolidation appears across mature systems, suggesting universality.

## Implementation Requirements

This paper benefits from implementation + measurement. Concrete requirements before drafting:

1. Sleep loop shipped in CCE with:
   - Cron/launchd scheduling
   - Restricted-subagent config (write-only to memory/, read-only Bash)
   - Consolidation logic (chronicles → memory + world-model)
   - Mirror audit function (review behavior against SOUL, flag anomalies)
   - Cadence threshold (activity-volume based)

2. Measurement:
   - Drift detection rate (behavioral anomaly catches per month)
   - Memory integrity (compaction recovery success rate)
   - Cost per sleep pass (tokens, wall-clock)
   - False-positive rate on anomaly flagging

3. Ideally: comparison against no-sleep-loop baseline on same entity.

## Source Files

- `../research/round-comparative-agents/stream-A-mechanisms.md` (two-phase pattern, KAIROS)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/expansion-paradigm-drift.md` (cross-model Mirror nuance)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/play-synthesis.md` (sleep consolidation metaphor, git-for-beliefs)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/research-github.md` (KAIROS implementation patterns)
- `../sessions/v1-build/phase-1-foundation/B6-sleep-loop-PARALLEL.md` (implementation brief, when written)

## Open Questions

1. Optimal cadence formula — activity-volume threshold vs wall-clock fallback
2. Same-model fresh-context Mirror vs cross-model Mirror — tradeoff curve per drift type
3. Restricted-subagent permission model — what's the minimum viable sandbox for consolidation
4. Recovery-from-sleep-failure — what happens if the sleep subagent itself drifts

## Draft Outline (tentative)

1. The sleep-deprivation frame — what agents without consolidation look like
2. Biological precedent — functional role of sleep in memory/integrity
3. The sleep loop — architecture
4. Three jobs, one mechanism — mapping self-learning + audit + compaction
5. Implementation (CCE)
6. Measurement and comparison
7. Related work and limitations

## Prerequisite: Build B6

B6 session brief ships the sleep loop. Paper starts drafting ~2–3 months after B6 lands and the loop has observable data.
