# Open Questions — GRP

Living list of what GRP doesn't know yet. Append-only, date-stamped. Resolved questions get a `[resolved YYYY-MM-DD]` marker and a one-line note pointing to where the answer landed; they are not deleted.

---

## 2026-04-22 — Surfaced by the imagine-final-state sharpening

### Q1. How does end-state imagination scale in compute?
End-state imagination — generating a target screenshot or full video of an action sequence — is much more expensive than next-state imagination. WebDreamer-style next-state generation is one forward pass; a 30-second video target is hundreds of frames.

- What is the minimum-viable representation of an end-state target? Single frame? Sparse keyframes? Structural target (PageModel) plus visual hint?
- Where does the cost-benefit curve flatten? At what task complexity does end-state imagination beat extended chain-of-thought, and where does it lose?
- Can the imagination be progressive — start sparse, refine where reverse-engineering disagrees? This is the same pattern as tiered perception, applied to imagination.

### Q2. How do we evaluate imagined-vs-observed when both sides are uncertain?
Reconciliation assumes the observation is a more reliable anchor than the imagination. End-state mode breaks this — the imagination IS the target; observation is what we are trying to bend toward it. Both sides have confidence levels that may be similar.

- What is the right confidence-arbitration rule when |conf(imagined)| ≈ |conf(observed)|?
- How does the reconciler avoid pathological self-reinforcement (the model "imagines" the world and then "observes" what it expected because the imagination shaped the perception)?
- Is there a useful prior-work analogy in active inference / variational message passing for two-anchor reconciliation? (See arXiv:2504.14898 for next-state variational framing — the two-anchor case is open.)

### Q3. How does GRP write back into MWM without polluting the graph?
GRP produces a flood of perception nodes and causal-edge candidates. MWM's graph is a long-term world-model substrate; not every perception belongs there.

- What is the consolidation threshold? Prediction-error-magnitude is the obvious knob, but the right value isn't known.
- How does GRP distinguish "this is a stable site pattern" (worth a node in MWM) from "this is a one-off page state" (ephemeral)?
- How is provenance tracked — when a belief in MWM came from GRP perception vs. from another subsystem, does that affect how it should be queried or trusted?
- Coordination with sleep cycles: should GRP write candidates to a staging area that sleep consolidates into MWM proper? This is the cleanest factoring but adds latency.

### Q4. Reverse-engineering reliability across the two paths
End-state → action sequence is two distinct problems with different failure modes:
- **Web-design path** (visual diff → code): well-studied as image-to-code, but iterative refinement under prediction error is open.
- **Motor / robotics path** (imagined video → motor commands): well-studied as inverse dynamics in classical robotics, but the imagined-video-as-target is novel and the inverse-dynamics network must accept imagined frames as legitimate input. Does it generalize when the imagined video is slightly off-distribution from real video?

Open: are there hybrid tasks where both paths run in parallel and reconcile against each other?

---

## 2026-04-22 — Surfaced by the Generative Collaborative reframe

### Q5. What is the formal mathematical content of "collaborative" vs "adversarial"?
GAN training has a well-defined minimax objective. The collaborative reframe says the two sides cooperate to converge — but what is the loss function?

- Is there a single shared loss both sides minimize?
- Or is it two separate losses (the imagination minimizes generation cost, the reconciler minimizes reconciliation cost) that happen to be aligned in expectation?
- Does the gravitational-attraction framing have a formal information-theoretic statement, or is it a useful philosophical reframe without a specific math counterpart yet?

This is the question that determines whether "Generative Collaborative Network" stays a framing or becomes a paper-citable architecture.

### Q6. Acronym
GCN is taken (Graph Convolutional Network). If this becomes a paper term, what is the paper-friendly shorthand for "Generative Collaborative Network"? Candidates: CoGN (Collaborative Generative Network), GCol, ColGAN-replacement-name. Defer until paper draft, but the question stands.

---

## Earlier-era questions (carried forward from the Phantom era)

### Q7. Spreading activation in MWM during in-page attention
The original architecture treated in-page spreading activation as in-perception (within GRP). With MWM as the world-model substrate, spreading activation should run there. Open: does the latency budget allow for cross-process spreading activation per attention shift, or does GRP need a working-memory cache?

### Q8. Alignment critic generalization beyond browsers
The Haiku-on-every-action critic was specified for browser actions. How does it generalize to motor actions in robotics? "Does this motor command serve the user's original intent?" is harder to evaluate than "does this click serve the intent?"

### Q9. Stealth-mode incentive alignment
GRP can be configured for stealth (Camoufox / Patchright / nodriver). Stealth is sometimes legitimate (testing, accessibility audits) and sometimes not (evading ToS). What is the right policy — should stealth be off-by-default and require explicit task-level opt-in? Coupled to the Values subsystem: this is a value-aligned modulation question, not a pure technical one.

---

## Worth a focused research stream later

Three questions stand out as worth a dedicated stream when GRP gets to implementation:

1. **Q1 (imagination compute scaling)** — directly determines whether end-state imagination is economically viable for production use.
2. **Q3 (MWM write-back hygiene)** — determines whether GRP's outputs make MWM more useful or pollute it. Cross-cutting with the cycles subsystem.
3. **Q5 (formal collaborative-vs-adversarial)** — determines whether the GCN reframe is paper-citable as a contribution or stays as framing.

Q2, Q4, Q7, Q8, Q9 are important but addressable inside implementation cycles; they don't need a standalone research stream first.
