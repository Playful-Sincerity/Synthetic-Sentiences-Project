# Three Drift Types and Defense-in-Depth for Autonomous Agents

**Status:** idea — largest contribution
**Estimated length:** full paper (8–14 pages)
**Target venue:** alignment workshop, NeurIPS safety workshop, or arXiv preprint with ambition for full conference

## Claim

Autonomous agent systems face three architecturally distinct drift types:

1. **Output-drift** (per-response hallucination from weights-reasoning). Structurally tractable today via retrieval-gating hooks and pre-annotation.
2. **Value-drift** (long-horizon alignment deviation). Structurally tractable via immutable core + scheduled re-injection + cross-model review.
3. **Paradigm-drift** (tacit interpretation shifts while rules remain verbatim-identical). **Not currently addressable** by any single architectural mechanism — residual risk.

These require different defenses at different layers. The "unified architecture" framing common in current work conflates them. A rigorous autonomous-agent architecture names the taxonomy, addresses the first two, and acknowledges the third as defense-in-depth territory rather than solved.

## Why Novel

- **Three-type taxonomy not named explicitly elsewhere.** Most literature treats "drift" as one phenomenon. Polanyi/Kuhn-informed distinction between parameter-drift and paradigm-drift (from the tacit-knowing tradition) has not been applied to LLM agent architecture before.
- **Honest residual-risk framing.** Most agent-safety papers claim more than they deliver. Naming paradigm-drift as unsolved and building defense-in-depth is a more rigorous posture.
- **Defense stack is novel.** Cross-model fresh-session Mirror + Adaptive Behavioral Anchoring + held-out behavioral benchmarks is a combination no single prior work prescribes.

## Partial Defense for Goodhart-via-Drafts — The Evolution Audit

Added 2026-04-16. The "unified architecture" synthesis named Goodhart-via-drafts as unresolved — the failure mode where individual proposals each pass rushed review but the ensemble reveals drift. A concrete partial defense emerged from Wisdom's sleep-loop refinement:

**The evolution audit** — the sleep subagent runs `git log --follow` on core files (SOUL.md, rules/, skills/, world-model.md) and asks three questions per diff:
1. Does this change move TOWARD or AWAY from what the prior SOUL said it valued?
2. Does the change have a corresponding reviewed proposal, or was it silent?
3. What's the cumulative drift direction across the last N changes?

Monotonic shift in one dimension across 3+ consecutive diffs, even when each was individually approved, triggers an alert.

The mechanism uses git as the immutable ledger (the entity home is already git-synced). Git log IS the "signed belief chain" the play synthesis gestured at.

**Why partial:** still can't catch paradigm-drift where interpretation shifts but files stay verbatim-identical. But it does address cumulative-proposal drift, which was a distinct gap.

## Second Partial Defense for Paradigm-Drift — Value-Relationships (added 2026-04-16)

Wisdom proposed a second mechanism that materially reduces the paradigm-drift surface: the entity maintains `value-relationships/` — one file per core SOUL value, documenting current interpretation, examples of application, edge cases encountered, evolution of understanding, and open questions.

**Why this is a structural defense:**

Paradigm-drift was unreachable because interpretation lived in the tacit layer (what the entity attends to, what counts as relevant). This mechanism **forces the tacit into the explicit** — the entity must write down its current interpretation. Once interpretation is a file, evolution audit (Job 2b) catches drift in it. Silent tacit shift becomes audible explicit shift.

Combined with:
- **Evolution audit** (Job 2b) — catches drift in the files themselves
- **Cross-model Mirror** (v2) — catches drift the same-model can't see
- **Baseline behavioral scenarios** — catches drift via external reference

Paradigm-drift goes from "unsolved / residual risk" to "addressed via defense-in-depth with four complementary mechanisms, each addressing a different slice." No single mechanism solves it; together they massively reduce the unreachable surface.

**This reframes the paper's central contribution.** Instead of "three drift types, paradigm is residual," the honest framing becomes: "three drift types; paradigm is addressable via defense-in-depth combining four structural mechanisms, each partial but complementary." More rigorous, less capitulating, and more accurate to the architecture.

## Key Evidence

- **Stream B drift catalog:** 12 failure modes × originating layer, with compliance data (SNCS 0.245–0.80, MINJA 95% injection success, hook compliance ~100%)
- **Agent Drift (arXiv 2601.04170):** 70.4% semantic-drift reduction from Adaptive Behavioral Anchoring
- **Identity Drift in LLM Agents (arXiv 2412.00804):** larger models drift MORE under RLHF; persona assignment ineffective
- **Goal Drift (arXiv 2505.02709):** context-length-correlated, drift variance by model scale
- **Asymmetric Goal Drift in Coding Agents (arXiv 2603.03456):** long-running entities more vulnerable than single-session; near-zero → near-complete under adversarial pressure
- **Experience-Following Behavior (arXiv 2505.16067):** error propagation through memory compounds over time
- **Mesa-optimization in autoregressive transformers (Zheng et al., NeurIPS 2024):** formal proof of mesa-optimizer emergence — the mechanism under value-drift
- **ASIDE (Zverev et al., ICLR 2026):** orthogonal representation separation — scopes out interpretation drift explicitly (supports residual-risk framing)
- **Anthropic activation probes:** work on backdoored models (AUROC > 99%), explicitly unverified on naturally-arising drift

## Source Files

- `../research/round-comparative-agents/stream-B-drift.md` (full drift catalog)
- `../research/round-comparative-agents/stream-C-theory.md` (theoretical frame)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/expansion-paradigm-drift.md` (paradigm-drift review)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/research-papers.md` (mesa-opt, ASIDE)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer/agents/research-books.md` (Polanyi/Kuhn foundation)
- `../research/think-deep/2026-04-16-two-drift-types-unified-answer.md` (final synthesis)

## Open Empirical Questions

These block publication as strong claims; need to resolve before drafting:

1. Do activation probes generalize from backdoored to naturally-arising drift? (Paradigm-drift detection ultimately rests on this.)
2. What's the false-positive rate for behavioral-baseline anomaly detection in production? (Unreported in source literature.)
3. How does Cross-model Mirror compare empirically to same-model fresh-session in catching paradigm-drift vs context-drift? (No published comparison.)

## Draft Outline (tentative)

1. Introduction — "unified drift" claims in current work, why they mislead
2. Taxonomy — output / value / paradigm, with concrete examples
3. Empirical evidence per type (the catalog)
4. Defense-in-depth stack — which mechanism addresses which type
5. The unresolved case — paradigm-drift as residual risk, what partial defenses exist
6. Implementation (CCE as existence proof — requires shipping)
7. Related work
8. Limitations and future directions

## Prerequisite: Implementation

This paper benefits strongly from CCE being built and running long enough to produce drift measurements. Aim: 3–6 months of live operation before drafting.
