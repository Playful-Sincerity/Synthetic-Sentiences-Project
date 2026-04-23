# Stream 7 — Earned Conviction

## Project context

The Synthetic Sentiences Project (`~/Playful Sincerity/PS Research/Synthetic Sentiences Project/`). Read [`CLAUDE.md`](../../CLAUDE.md) for the full thesis. Read [`cognition/CLAUDE.md`](../../cognition/CLAUDE.md) for this subsystem. Read also [`cognition/value-relationships.md`](../../cognition/value-relationships.md) — the mechanism that operationalizes value-evolution inside belief architecture.

## Research goal

Survey prior work supporting the central claim: **beliefs are never installed.** They are built from evidence, hold explicit confidence levels, resolve dissonance through cognitive work, and evolve through documented relationships with each core value. A sentient being's beliefs look different from an LLM's prior distribution — they are explicit, traceable, and earned.

## Claims to support / test / refine

- Dual-axis confidence (evidence quality + consensus strength) as distinct from single-probability representations
- Cognitive dissonance as a structural mechanism (not a prompt instruction) that flags contradictions
- Curiosity as a weighted queue of unknowns (dangling edges, weakly connected clusters, low-confidence nodes) — structural, not behavioral
- Persuasion protocol requiring multiple independent evidence sources to shift high-confidence beliefs (prevents social-pressure flip-flopping)
- Value-relationships as explicit mechanism — each core value has a documented relationship file with current interpretation, enactment instances, edge cases, evolution log
- Beliefs as first-class graph nodes (not implicit in weights)

## Search priorities

- **Formal belief revision.** AGM postulates (Alchourrón, Gärdenfors, Makinson); Spohn's ranking theory; belief-base revision; iterated revision.
- **Bayesian cognition.** Tenenbaum, Griffiths; probabilistic programs of thought; hierarchical Bayesian models of learning.
- **Cognitive dissonance.** Festinger original; Harmon-Jones' action-based model; contemporary computational dissonance work.
- **Scientific reasoning.** Kuhn's paradigm shifts; Lakatos' research programmes; Chinn & Brewer on evidence evaluation.
- **Calibrated uncertainty in AI.** Confidence calibration in LLMs; verbalized uncertainty; evidence-based reasoning benchmarks.
- **Persuasion and belief change.** Petty & Cacioppo ELM; motivated reasoning literature; inoculation theory.
- **Value learning in AI.** Inverse reward design; value iteration under uncertainty; moral uncertainty (Bogosian, MacAskill).

## Target output

Write synthesis + annotated bibliography to:

- `cognition/research/literature-backing.md` (synthesis, ~2000 words)
- `cognition/research/bibliography.md` (10–20 papers annotated)

Special attention to: where formal belief revision (AGM family) meets graph-based agent memory. If no prior work has implemented AGM-style revision over a navigable graph with explicit value-relationships, that's a distinctive architectural claim.

## Independence

Fully independent of other streams.
