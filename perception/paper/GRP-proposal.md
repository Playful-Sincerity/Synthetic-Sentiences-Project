# Generative Reconciliation Perception

### Imagination as the substrate of computer-use cognition — a perception architecture in which the agent generates expected state first, observes second, and reconciles the two to produce interpretation.

**Wisdom Happy** · Playful Sincerity Research · April 2026

---

## Abstract

Modern computer-use agents — browser controllers, desktop automators, screen-grounded LLMs — share a perceptual posture inherited from the earliest scripting frameworks: observe, then interpret. The page or screen arrives as input; the model decides what it is and what to do about it. Imagination, when it appears at all, lives in chain-of-thought reasoning *between* steps. This paper proposes a different posture. The agent imagines what it expects to see *before* it looks. Observation does not produce interpretation directly; it produces a comparison against the imagined state, and the gap between the two — the prediction error — is the signal that drives attention, learning, and downstream action selection. We call this architecture Generative Reconciliation Perception (GRP). The contribution is not the addition of imagination as a feature. The contribution is the structural claim that imagination is the substrate on which perception runs.

The architecture supports two modes of imagination. *Next-state imagination* generates the immediate consequence of the next action — the WebDreamer-style baseline used to gate when the world model updates and which tier of perception to run. *End-state imagination* generates the target final state, optionally as a full video of the action sequence, and the system reverse-engineers the concrete actions whose execution would reproduce that target. The pipeline shifts work to where modern foundation models are strongest — imagining final states — and away from where they are weakest — grounding intermediate steps. The quality of output scales with the quality of imagination, not with the density of step-by-step reasoning. Two architectural moves complete the contribution: dual-channel perception (visual and structural) with a *collaborative* reconciler that treats inter-channel disagreement as informative cognitive dissonance rather than as error to be suppressed, and a reframe of the GAN-style adversarial paradigm into a Generative Collaborative one — the imagined world and the observed world cooperate to converge rather than competing. This paper specifies the architecture, names the two modes of imagination, situates GRP against the prior work in world models and predictive processing, and surfaces the open questions whose resolution will determine which of the contributions are paper-citable architecture and which remain useful framing.

GRP was originally conceived in March 2026 under the codename *Phantom*. It was renamed in April 2026 to name the actual mechanism rather than a stealth side property. This paper is the first standalone treatment of the architecture; an earlier specification document (`SPEC.md`) gives the technical detail on data structures, security model, and module layout.

---

## 1. Thesis

> **Imagination is not a meta-cognition trick layered on top of perception. It is the substrate. Perception is the *reconciliation* of imagination with observation, and prediction error is the primary learning signal of the system.**

A tighter way to say this: today's computer-use agents perceive in order to act. GRP imagines in order to perceive, and perceives in order to confirm or correct what was imagined. Imagination is not the optional flourish a sufficiently clever model adds when it has spare reasoning to spend. It is the layer the architecture runs on. Every observation is a comparison; every comparison produces a residual; every residual is a learning signal.

Three claims follow from the thesis.

**First, imagination is best treated as infrastructure, not as inference.** When imagination is implemented as chain-of-thought reasoning during prompting, it competes with action selection, error recovery, and other reasoning the model is trying to do in the same context. When imagination is a structural component — a dedicated engine with explicit inputs (memory, task, last action) and explicit outputs (expected state, end-state target, confidence) — it stops competing with reasoning and starts subsidizing it. The agent reasons less about *what should be there* because the imagination engine answers that question before reasoning begins.

**Second, the high-value use of imagination is end-state, not next-state.** Most prior work on predictive perception in agents (WMA, WebDreamer, MobileDreamer, CUWM) generates the immediate next state. This is useful: it gates learning, it cheapens reconciliation, it enables tiered perception. But the more valuable mode imagines the *final* state — the target page after the design change has been applied, the final video frame after the robotic task is complete — and reverse-engineers the action sequence whose execution would reproduce that target. This inverts the standard pipeline. Quality of output scales with quality of imagination; the model's reasoning load shifts from *grounding intermediate steps* (where it is brittle) to *imagining final states* (where it is strong).

**Third, reconciliation between imagination and observation is collaborative, not adversarial.** GAN-style architectures frame generation and discrimination as competition: one tries to fool, one tries to detect. GRP frames the imagined world and the observed world as collaborators working to converge. The agent adjusts its actions to bring the observation toward the imagined target, and adjusts its imagination toward what it actually observes when surprise indicates the imagination was wrong. Both sides update. Surprise is information, not failure. This is a gravitational-attraction reframe of the adversarial pattern, consistent with the broader research program of which GRP is a part.

This is not a proposal to add imagination to existing browser agents. It is a proposal to restructure the perception pipeline around imagination as the substrate, with observation as the residual-producing comparison and reconciliation as the collaborative procedure that produces the agent's understanding of where it is.

---

## 2. The Architectural Inversion

### 2.1 The current configuration — observe, then interpret

Modern computer-use agents fall into three paradigms. The oldest — Selenium, Puppeteer, classical scripting — treats the page as a machine to send commands to. The dominant current paradigm — browser-use, Stagehand, Atlas, Comet — serializes the page or screen into a textual or visual representation, prompts a language model with that representation alongside the task, parses an action out of the response, and executes it. The frontier — UI-TARS, Lux, OmniParser-driven systems — adds dual-channel perception (visual plus structural) and improves the grounding pipeline.

What unifies all three is the order of operations. Input arrives first. The agent decides what it is. The agent acts. The next observation overwrites the previous one. There is no expectation, no memory of what was supposed to be there, no internal model that gets surprised. If the page changed in an unexpected way, the agent has no mechanism for noticing — only for re-grounding. Each step starts from scratch.

Three structural problems follow.

**(1) The agent is blind between actions.** Actions take time. Pages load, animations run, modals appear, transitions happen. The reactive agent has no model of what it expects during this interval, so it either polls the screen at high cost or guesses when to move on. Time-to-grounding is high; cost is high; reliability is low.

**(2) Surprise is invisible.** When something unexpected happens — a layout shift, a new error state, a previously unseen element — the agent has no way to register the surprise as such. Re-grounding produces a new representation; the *change* between old and new representations is not part of the architecture's vocabulary. The most informative moments in a session are precisely the moments the architecture cannot see.

**(3) Quality scales with chain-of-thought density.** When the agent has to reason its way to a correct action — "this button is in the top right; I want to click it; let me verify the SoM index; let me check the DOM role; let me confirm" — quality scales with the number of reasoning tokens it produces. Performance on complex tasks tracks the depth of the prompt scaffold rather than the depth of the model's understanding. This is expensive and brittle.

### 2.2 GRP's configuration — imagine, then observe, then reconcile

In GRP, the order changes. The agent generates an expected state from its memory graph, the task context, and the last action. The expected state describes what the agent thinks the page or screen *should* look like — the layout, the elements, the affordances, the confidence. Only then does the agent observe. Observation produces a percept; the percept is compared against the expectation; the comparison produces a prediction error. Prediction error drives attention (high error escalates the perception tier; low error allows cheap perception), drives learning (high error triggers reconsolidation in the memory graph), and drives planning (the action that closes the most prediction error is the one most aligned with the task). The architecture has imagined what should be there, and it knows the moment when reality and imagination diverge.

```
TODAY'S COMPUTER-USE AGENT          GRP

  observe                              imagine
  ─────                                ───────
  parse                                observe
  reason                               ───────
  act                                  reconcile
  ─────                                ─────────
  re-observe (from scratch)            diff (prediction error)
                                       plan
                                       check
                                       guard
                                       act
                                       learn (write to memory iff surprise)
```

The inversion is not cosmetic. It changes what the architecture is *capable of noticing*. A reactive agent cannot notice surprise because it has no expectation. A predictive agent can — surprise is a measurable quantity, computed against a representation that was already in memory before the observation arrived. The same shift made predictive processing the dominant framework in computational neuroscience over the past two decades. Animals do not perceive; they predict and reconcile. The brain is generative, and observation is the residual the generative model is trying to minimize. GRP applies the same architecture to computer-use agents.

---

## 3. The Cognitive Loop

The full loop is:

```
IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN
   ↑                                                                     │
   └──────────────── update memory from prediction errors ───────────────┘
```

- **IMAGINE** generates either an `ImaginedState` (next-state mode: the immediate consequence of the next action) or an `ImaginedEndState` (end-state mode: the target final state, optionally as a video).
- **OBSERVE** runs dual perception: a visual channel (screenshot plus Set-of-Mark numbering) and an analytical channel (DOM, accessibility tree, macOS Accessibility API), in parallel.
- **RECONCILE** merges the two channels into a unified `PageModel`. Channel disagreements are surfaced as cognitive dissonance — first-class structural information — and resolved by a collaborative arbitration rule rather than by suppressing one channel in favor of the other.
- **DIFF** computes prediction error: how far is the imagined state from the observed `PageModel`? In end-state mode, the diff also computes how far the observed state is from the target.
- **PLAN** selects the next action from an affordance-aware view of the page. Elements are perceived as action potentials (Gibson's ecological psychology) rather than as inert structure. Spreading activation through the memory graph weights affordances by relevance to the task.
- **CHECK** runs the alignment critic — a cheap Haiku-class call evaluating the candidate action against the original task intent. The critic exists to interrupt the loop when the agent's action drifts from what was asked, not because the model has gone rogue but because the prediction-error path is locally optimal.
- **GUARD** enforces the security membrane: content isolation, HTTP-layer sandboxing, credential isolation, permission tiers.
- **ACT** executes the action through the motor system, with human-like input dynamics where the environment requires it.
- **LEARN** writes back to the memory graph if the prediction error exceeds a threshold. Most observations do not produce a write. Memory consolidates surprise, not routine.

The dashed return arrow — from action back to imagination — is the cycle that makes this system *learn from experience*. Every action changes the world; every observation of that change produces a residual against the imagined consequence; every residual that exceeds threshold updates the model that generated the imagination in the first place. The agent's world model is the cumulative residual of its own predictions over time. Reconsolidation is the mechanism by which it improves.

---

## 4. Two Modes of Imagination

The imagination engine supports two distinct modes, each addressing a different kind of question.

### 4.1 Next-state imagination

Given the current state of the page or screen, the most recent action, and the agent's memory of similar contexts, generate the expected next state. This is the WebDreamer-style baseline. It runs on every action and serves three purposes: it gates the perception tier (if the next state is highly predictable, cheap analytical-only perception suffices; if it is uncertain, expensive full visual perception is warranted); it gates the memory write (if the prediction was correct, no reconsolidation is needed; if it was wrong, the surprise is encoded); and it cheapens reconciliation (the reconciler has a strong prior to compare against, and inter-channel disagreement is easier to interpret when the expected state is known).

The contribution at this layer is not novelty in the imagination — WMA, WebDreamer, MobileDreamer, and CUWM all do versions of this. The contribution is treating the imagination as *infrastructure* rather than as inference: it runs always, it produces a typed object (`ImaginedState`), and downstream components depend on it as a structural input. Cost is amortized across the whole loop.

### 4.2 End-state imagination

Given the task intent and the current state, imagine the *target* — the final state of the page or screen after the task is complete, or, more powerfully, an entire video of the action sequence playing out correctly. Then reverse-engineer the action sequence whose execution would reproduce that target.

This is the load-bearing contribution of the paper. Two concrete instantiations make the move clear.

**Web design.** The current page is a screenshot. The task is "make this page match the design intent." The imagination engine generates a target screenshot — what the page should look like after the change — or a short video of a user experiencing the page as it is supposed to be experienced. Reverse-engineering takes that target and produces the diff in HTML, CSS, and JavaScript that closes the gap. The agent runs the diff, observes the result, reconciles it against the imagined target, and iterates. The pipeline shifts work to where modern foundation models are strongest — imagining final states — and away from where they are weakest — grounding intermediate code edits.

**Robotics and motor control.** The task is "pick up the cup and pour it." The imagination engine generates a video of the task being performed correctly: the trajectory of the arm, the grip on the handle, the angle of the pour, the rest. Inverse dynamics derives the motor commands whose execution reproduces those frames. The agent executes the commands, observes the actual video, reconciles it against the imagined video, and updates either the motor model (if the actions did not produce the imagined effects) or the imagination engine itself (if the imagined target was off-distribution from what the embodiment can actually do).

The mechanism is the same in both cases. The output channel — code or motor commands — is different. The pipeline structure is *imagine target → derive actions → execute → reconcile against target → iterate*. This is not a chain-of-thought trick. It is an architectural inversion of how the agent decides what to do. Quality of output scales with quality of imagination, because the imagination *is* the specification.

### 4.3 Why end-state matters more

Three reasons.

**(1) It plays to the model's strengths.** Foundation models are trained on enormous corpora of finished artifacts: completed pages, finished videos, photographed scenes. They can imagine final states with detail and consistency. They are much weaker at producing reliable intermediate-step reasoning, where errors compound, hallucinations creep in, and brittleness scales with depth. End-state imagination skips the brittle middle.

**(2) It compresses long-horizon planning.** A sequence of fifty actions is hard to plan as fifty decisions. It is much easier to plan as one imagined target plus an inverse procedure. The agent does not have to reason about each step; it has to reverse-engineer the trajectory that produces the imagined end state. This is closer to how humans plan complex tasks: imagine the outcome, work backward to the actions.

**(3) It produces verifiable artifacts.** The imagined target is an artifact the agent can *show* — a screenshot, a video, a specification. This makes the agent's intent legible to a human reviewer in a way intermediate reasoning chains usually are not. Alignment debugging becomes possible at the imagination layer: ask the agent what it imagines, look at it, decide whether that is what you wanted.

The trade-off is computational. Imagining a full thirty-second video at frame rate is expensive. Sparse keyframes, structural targets, and progressive refinement are all open optimizations. Section 10 returns to the open questions.

---

## 5. Dual Perception with Collaborative Reconciliation

GRP runs two perception channels in parallel.

**Visual cortex.** A screenshot of the page or screen is processed by a vision-language model, with Set-of-Mark numbering applied to interactable elements. The output describes the spatial layout, the visual states of elements (highlighted, disabled, loading, error), the colors and typography, the overall composition. Strengths: it sees what is actually rendered, including custom widgets, dynamic content, and visual feedback that is not exposed in structured form. Weaknesses: grounding is approximate, exact text values are sometimes hallucinated, and the channel is expensive.

**Analytical cortex.** The DOM, accessibility tree, or macOS Accessibility API is queried directly. The output describes the structural layout: element roles, ARIA labels, exact text values, click handlers, form state. Strengths: ground truth on structure and interactivity, free or near-free in token cost, deterministic. Weaknesses: it cannot see dynamic visual state, custom-painted canvases, animations, or anything not exposed through accessibility APIs.

The two channels disagree often. The visual cortex sees a button labeled "Submit"; the analytical cortex reports a `<div role="button">` with no `aria-label`. The visual cortex sees a loading spinner; the analytical cortex reports the page as fully loaded. The visual cortex sees a modal blocking the page; the analytical cortex reports the modal as hidden behind a `display:none` rule that is being overridden by an inline style. These are not channel errors. They are *information*. The disagreement itself is the signal.

The reconciler treats inter-channel disagreement as cognitive dissonance: a structural property of the joint representation, not an error to be suppressed by picking one channel. Each disagreement is recorded as a `Disagreement` object with the visual claim, the analytical claim, and a resolution rule. The arbitration is collaborative — visual wins for "looks right?" questions, analytical wins for "is clickable?" questions, both are flagged as uncertain when neither wins, and the disagreement itself becomes a node in the agent's memory graph for future reference. The next time a similar disagreement arises on the same site, the agent does not have to re-derive the resolution.

No published browser-agent framework treats inter-channel disagreement as a first-class informative signal. UI-TARS combines vision and structure but picks one when they disagree. browser-use does the same. The published work assumes the channels should agree, that disagreement is a defect, and that the architecture should hide it. GRP makes the opposite assumption: disagreement is the most informative thing the dual perception produces, and it should be surfaced.

---

## 6. The Generative Collaborative Reframe

The standard generative-discriminative pattern in machine learning is adversarial. A generator produces candidates; a discriminator tries to detect them; the system reaches equilibrium at the saddle point of a minimax loss. This pattern has shaped how researchers think about generation-plus-evaluation systems for over a decade.

GRP rejects the framing for its own architecture. The imagined world and the observed world are not adversaries. They are collaborators working to converge. The agent adjusts its actions so the observed world bends toward the imagined one; the agent adjusts its imagination so the imagined world tracks what is actually true about the observed one. Both sides update. Both sides cooperate. The reconciler is not a discriminator picking a winner — it is a collaborative procedure that closes the gap by updating whichever side is most-cheaply-updated given current evidence.

We call the resulting framing *Generative Collaborative*. The natural acronym, GCN, is taken in the machine-learning literature (Graph Convolutional Networks); a paper publication will need a different shorthand, but the concept stands regardless of how it is eventually labeled.

Three things follow from the reframe.

**(1) Surprise is not failure.** In a GAN, the generator failing to fool the discriminator means the generator must improve. In GRP, the imagined state failing to match the observed state means the world model has new information. Surprise is the input the reconciler is *for*. Suppressing surprise — picking a winner channel, hiding disagreements, training the imagination to never be wrong — would defeat the architecture.

**(2) The two sides share a loss.** What loss, exactly, the imagination and the observation share is an open question (Section 10). The framing says they cooperate; the formal mathematical content of "cooperate" — single shared loss, two losses provably aligned in expectation, or something more complex — is not yet settled. Until that mathematical content is grounded, the reframe is framing rather than architecture-with-a-citable-loss-function. This is the most important open question in the paper.

**(3) The framing is consistent with a broader research program.** GRP is one subsystem of a larger project (the Synthetic Sentiences Project) whose alignment thesis is that aligned behavior emerges from architectures whose internal substrates *converge through attraction* rather than being constrained by external penalties. The collaborative reconciler is the same move at the perception layer that the broader project makes at the value-alignment layer: cooperation rather than competition, attraction rather than penalization. This is not coincidence. It is design.

---

## 7. Cost Management — Tiered Perception

The full GRP pipeline is expensive: imagination, dual perception, reconciliation, alignment critic, motor system, memory write-back. Running it on every action would defeat the architecture for any task with more than a handful of steps.

The architecture defines four tiers of perception, selected by the prediction error from the previous step.

| Tier | What runs | Approximate cost | When to run |
|------|-----------|------------------|-------------|
| **0 — Reflex** | DOM-only check, no LLM call | Free | Confirming an expected state, waiting for a known transition |
| **1 — Glance** | DOM plus lightweight accessibility check, Haiku-class read | ~500 tokens | Familiar pages, expected states, form-filling |
| **2 — Look** | Screenshot plus Set-of-Mark plus accessibility, Sonnet-class vision | ~2,000 tokens | New pages, moderate surprise |
| **3 — Study** | Full pipeline including imagination, dual perception, reconciliation, affordance-aware planning | ~5,000 tokens | First visit to a new context, high surprise, critical steps, end-state imagination tasks |

The tier escalates on surprise. A ten-step task with mostly familiar transitions runs at Tier 0 or 1 for most steps and at Tier 3 only at the moments the agent is genuinely uncertain. The cost of a typical task drops from ~50,000 tokens (running the full pipeline every step) to ~15,000 tokens. The architecture is not just better; it is also cheaper to run, because imagination subsidizes attention.

This tier structure is the same Kahneman dual-process pattern applied to perception. Familiar inputs run on System 1 (cheap, automatic). Surprising inputs escalate to System 2 (expensive, deliberate). Imagination is what makes the distinction possible — without an expectation, every observation looks equally novel, and there is nothing to escalate from.

---

## 8. Architecture in Brief

The full architectural specification is in `SPEC.md` (640 lines, including data structures, security model, and module map). What follows is the structural summary at the level needed for this paper.

**Data structures.** `ImaginedState` (next-state mode) carries the expected URL pattern, expected elements with positions and affordances, layout expectations, and a confidence value with provenance. `ImaginedEndState` (end-state mode) carries a target screenshot or video sequence, the intent, a confidence value, and a reverse-engineering strategy (visual-diff-then-codegen, motor-inverse, or plan-search). `PageModel` is the reconciled output of dual perception: elements with confidence, layout, disagreements, and affordances. `Affordance` describes an element's action potential — type, expected outcome, confidence, risk, source. `Disagreement` describes inter-channel conflicts with their resolution.

**Memory.** The world model is not part of GRP. It lives in a separate subsystem (`MWM` — Memory as World Model), and GRP writes content into MWM's primitives rather than owning a graph schema. This factoring is deliberate: every subsystem in the broader project that produces or consumes beliefs touches the same graph, and GRP's perception flood is one input among several. Section 9 elaborates.

**Pluggable backends.** Perception is pluggable across Claude Vision, Lux (OpenAGI), OmniParser, Playwright accessibility, and macOS Accessibility API. Action is pluggable across Playwright, Patchright, Camoufox, nodriver, PyAutoGUI, and macOS AppleScript. Adapters cover browser, desktop, and any-window environments.

**Security membrane.** Filesystem sandbox at `~/.grp/workspace/`; content isolation between web text and agent instructions; HTTP-layer sandbox with domain allowlist and method restrictions; credential broker that fills directly through the browser engine without exposing credentials to the LLM context; alignment critic on every action; permission tiers (auto, confirm, deny) governing different action classes.

**Module organization.** The codebase is a monorepo with a cognitive core (imagination, reverse-engineering, perception channels, reconciler, planner, critic, guard, motor, learner), a memory bridge (writes to and reads from the MWM graph), pluggable adapters, and a thin interface layer (MCP server, CLI, sandbox).

**Build phases.** Implementation proceeds in six phases: Walking (basic Playwright + visual perception), Seeing Double (dual perception + reconciler), Dreaming (next-state imagination), Imagining the End (end-state imagination + reverse-engineering), Feeling (temporal perception + motor system), Speaking (alignment critic + full security membrane). End-state imagination is intentionally introduced after the next-state loop is working, because reverse-engineering depends on a stable substrate to verify against.

---

## 9. Where GRP Belongs

GRP does not stand alone, even though this paper presents it as a standalone contribution. It is the perception subsystem of a broader research program — the Synthetic Sentiences Project — whose other subsystems consume GRP's outputs and shape what GRP imagines.

**Memory.** The world model lives in MWM. GRP writes predicted states, observed states, and causal edges (clicking X led to state Y) into MWM as nodes and edges. The graph is the agent's long-term substrate; GRP is the perceptual input layer that feeds it. When the agent asks "have I seen this site before?" or "what usually happens after this action?", the answer is a traversal of the MWM graph, not an internal-to-GRP lookup.

**Earned conviction (cognition).** Page elements have confidence levels rooted in evidence chains. The dissonance-as-information primitive in GRP's reconciler is the same primitive the cognition subsystem uses to surface unresolved beliefs. Curiosity about unknown elements (low-confidence nodes) is the same affect that drives investigation in the broader cognitive layer.

**Value-aligned modulation.** What to attend to, what to imagine, and what counts as an acceptable action are weighted by the agent's current value-alignment state. The alignment critic that evaluates each action before execution is a value-check at the perception/action boundary. The imagination engine itself is conditioned on what the agent cares about: the same task can produce different imagined end-states depending on the values active.

**Working memory and dream cycles.** The page being perceived lives in a working tree that grows when new perceptual content is loaded and shrinks when relevance fades. Sleep cycles consolidate GRP's perceptual outputs into long-term graph structure. Dream cycles use GRP's imagination engine to *simulate* without observing — adversarial self-reflection, value-conflict tests, hypothetical scenarios. Imagination is the substrate of perception when the agent is awake and the substrate of simulation when the agent is asleep.

**Voice.** When the agent speaks about what it perceived, the acoustic prosody of its voice should reflect the confidence levels in the page model. Honest disfluency around low-confidence perceptions is prosodic accuracy, not a speech defect. This is treated in detail in a separate subsystem; it is mentioned here because it closes the perception-to-expression loop.

The factoring is deliberate. The imagination engine GRP uses for end-state targets, the should-world model that drives value-aligned modulation, and the simulation substrate dream cycles run on are the *same mechanism* applied at three scales: task-scale (GRP), being-scale (values), moment-scale (cycles). One imagination engine, three uses. This is the unification thesis the broader project rests on.

---

## 10. Prior Work

GRP draws from and stands against four overlapping bodies of work.

**World models for browser and computer-use agents.** WMA (arXiv:2410.13232) introduced transition-focused observation abstraction for predicting how actions change pages. WebDreamer (arXiv:2411.06559) used the LLM itself as a world model, "dreaming" outcomes before committing — closest in spirit to GRP's next-state mode but with no end-state mode, no reconciler, and no architectural integration with memory. MobileDreamer (arXiv:2601.04035) showed sparse text sketches suffice for effective world modeling. WebWorld (arXiv:2602.14721) and CUWM (arXiv:2602.17365) advanced trajectory simulation and two-stage prediction respectively. GRP's contribution against this line is end-state imagination with reverse-engineering as a unified architectural mode, not an emergent capability.

**Visual grounding for agents.** SeeAct (arXiv:2401.01614) established that grounding is the bottleneck, not reasoning. Set-of-Mark (Microsoft) and OmniParser (arXiv:2408.00203) provide standard tools for converting screenshots into addressable elements. UGround (arXiv:2410.05243) showed universal visual grounding generalizes across UIs. WebVoyager (arXiv:2401.13919) demonstrated a 28-point gap between SoM-based and text-only agents. GRP uses these tools as the visual channel of dual perception; the contribution is the reconciler that combines them with structural input rather than picking between them.

**Active inference and predictive processing.** The free-energy principle and predictive processing literature (Friston and successors) provide the theoretical grounding for imagination-then-observation as a perceptual architecture. EFE as Variational Inference (arXiv:2504.14898) shows expected free energy reduces to prediction error in the relevant limit. *Robust Agents Learn Causal World Models* (arXiv:2402.10877) proves causal world models are necessary for robust generalization. *Language Agents Meet Causality* (arXiv:2410.19923) connects causal variables to language. GRP applies this framing to a domain — browser and computer-use agents — where it is, as of this writing, completely unoccupied in the published literature.

**Generative adversarial architectures.** The GAN literature (Goodfellow 2014 onward) establishes the dominant pattern for generation-plus-evaluation systems. GRP rejects the framing for its perception layer. The Generative Collaborative reframe is, to our knowledge, novel — though related ideas exist in cooperative multi-agent learning, the architectural application to perception specifically does not appear in the published work we surveyed.

A complete reference list with annotations is in `research/references.md` in the project repository.

---

## 11. Open Questions

The architecture is specified. The implementation has not started. Five questions are paper-relevant; nine are tracked in `research/open-questions.md` in the project repository. The five most important:

**Q1. How does end-state imagination scale in compute?** A thirty-second video target is hundreds of frames. The cost-benefit curve relative to extended chain-of-thought reasoning is unknown. Open: the minimum-viable representation of an end-state target (single frame? sparse keyframes? structural target plus visual hint?) and the task complexity at which end-state imagination beats chain-of-thought.

**Q2. How does reconciliation arbitrate when both sides are uncertain?** The standard reconciler assumes the observation is the more reliable anchor. End-state mode breaks this — the imagination *is* the target; observation is what we are trying to bend toward it. Both sides have confidence levels that may be similar. The right confidence-arbitration rule when the imagined and observed sides have comparable confidence is not yet specified.

**Q3. How does GRP write back into memory without polluting the graph?** GRP produces a flood of perception nodes and causal-edge candidates. Not every perception belongs in long-term memory. The consolidation threshold, the distinction between stable site patterns and one-off page states, and the coordination with sleep cycles for staged consolidation are all open.

**Q4. What is the formal mathematical content of "collaborative" versus "adversarial"?** The Generative Collaborative reframe is currently framing, not architecture-with-a-citable-loss-function. Until there is a single shared loss, or two losses provably aligned in expectation, the reframe is paper-citable as a framing decision but not as an architectural contribution. This is the most important open question in the paper.

**Q5. Reverse-engineering reliability across the two paths.** End-state to action sequence is two distinct problems with different failure modes. The web-design path (visual diff to code) is well-studied as image-to-code, but iterative refinement under prediction error is open. The motor path (imagined video to motor commands) is well-studied as inverse dynamics, but with imagined frames as legitimate input rather than observed frames; whether the inverse model generalizes when the imagined video is slightly off-distribution is an empirical question.

---

## 12. Falsification

The architecture commits to specific predictions. Four are sharp enough to falsify.

**(F1) End-state imagination outperforms chain-of-thought for tasks of complexity above a threshold.** On a benchmark of web-design and motor-control tasks of varying complexity, measured by step count and error compounding, end-state imagination plus reverse-engineering should produce higher success rates than chain-of-thought reasoning at matched compute, with the gap growing with complexity. If end-state imagination underperforms or matches chain-of-thought across the complexity spectrum, the central claim of the paper is wrong.

**(F2) Disagreement between dual perception channels is informative.** Channel disagreements should correlate with locations in the page where prediction error is later highest, with elements that subsequently produce action errors, and with sites where causal-edge updates in the memory graph are highest-weighted. If disagreements are random noise — uncorrelated with downstream signal — the reconciler's claim that they are informative is wrong.

**(F3) Imagination subsidizes perception cost.** A complete GRP pipeline running on a benchmark of mixed-difficulty tasks should produce a token cost distribution where the median step runs at Tier 0 or 1, escalating to Tier 3 only at moments of high prediction error. If the cost distribution is flat across tiers, the architecture is not actually subsidizing cheap perception with imagination — it is just adding cost.

**(F4) The collaborative reconciler is more accurate than a winner-takes-all reconciler.** A controlled comparison where one variant of the system uses GRP's collaborative arbitration and the other variant picks the higher-confidence channel should show the collaborative variant produce more accurate `PageModel` outputs and fewer downstream action errors. If the winner-takes-all variant matches or beats the collaborative variant, the dissonance-as-information claim is empirically unsupported.

These predictions cannot all be checked at once; they require an implementation, a benchmark, and a controlled comparison. They are stated here so future work can confirm, refine, or reject each.

---

## 13. Outlook

GRP is an architectural commitment, not a finished system. The specification is complete; the implementation is in front of us. The most immediate work is the next-state pipeline (Phases 1–3 in the build plan), the integration with the memory subsystem, and the first benchmark of imagination-subsidized perception on a representative web-control task. The end-state mode (Phase 4) follows the next-state mode is working, because reverse-engineering depends on a stable verification loop.

The paper-blocking work is Q4 — the formal mathematical content of the collaborative reframe. Until that is grounded, the Generative Collaborative claim should be presented as a framing decision and a research direction, not as a citable architectural contribution. This is the honest version of where the paper stands.

The broader bet is that imagination-as-substrate generalizes beyond computer-use. The same architecture — generate expectation, observe, reconcile, learn from residual — applies to robotics (Section 4.2 already names this), to scientific instrumentation (an experiment is an act, the readout is an observation, the prior model is the imagination), to human-AI collaboration (the agent imagines what the human wants, observes the human's reaction, reconciles). The computer-use case is the most immediately tractable, the cheapest to benchmark, and the closest to deployment. It is also the case that demonstrates the move most clearly. If the move works there, the architectural commitment generalizes.

What we are committing to, in writing: imagination is not a feature of sufficiently sophisticated reasoning. It is the substrate. Perception is reconciliation. The architecture's job is to imagine well, observe carefully, and learn from the gap.

---

## Acknowledgments

The original architecture was conceived under the codename *Phantom* during a research sprint on March 31, 2026, and was developed through April 2026 with the assistance of the Playful Sincerity Digital Core — a configuration of Claude Code rules, skills, hooks, and chronicles maintained as a research and methodology partner. The codename was changed to GRP (Generative Reconciliation Perception) on April 22, 2026, to name the actual mechanism rather than a stealth side property, alongside a sharpening that introduced end-state imagination and the Generative Collaborative reframe. Eight parallel research agents surveyed approximately 65 papers and 80 GitHub repositories to validate the originality of the architecture's claimed contributions; the results are in `research/landscape.md` and `research/references.md`. The Synthetic Sentiences Project, of which GRP is the perception subsystem, provides the broader architectural context within which GRP's contributions cohere.

*Correspondence:* wisdomhappy@playfulsincerity.org · [github.com/Playful-Sincerity/GRP-Generative-Reconciliation-Perception](https://github.com/Playful-Sincerity/GRP-Generative-Reconciliation-Perception)

---

## References

The references below are the load-bearing prior work cited in this paper. The full annotated list — approximately 65 papers and 80 GitHub repositories surveyed during the architecture sprint — is in `research/references.md`.

**World models and predictive perception.** WMA (arXiv:2410.13232). WebDreamer (arXiv:2411.06559). MobileDreamer (arXiv:2601.04035). WebWorld (arXiv:2602.14721). CUWM (arXiv:2602.17365). DreamerV3 (arXiv:2301.04104).

**Visual grounding for agents.** SeeAct (arXiv:2401.01614). Set-of-Mark (Microsoft Research, 2023). OmniParser (arXiv:2408.00203). UGround (arXiv:2410.05243). WebVoyager (arXiv:2401.13919). CogAgent (arXiv:2312.08914).

**Benchmarks.** WebArena (arXiv:2307.13854). Mind2Web (arXiv:2306.06070). VisualWebArena (arXiv:2401.13649).

**Security and prompt injection.** BrowseSafe (arXiv:2511.20597). ceLLMate (arXiv:2512.12594). WASP (arXiv:2504.18575). IntentGuard (arXiv:2512.00966).

**Agent architectures.** ReAct (arXiv:2210.03629). OpAgent (arXiv:2602.13559). LATS (arXiv:2310.04406). Survey of WebAgents (arXiv:2503.23350).

**Active inference and causality.** EFE as Variational Inference (arXiv:2504.14898). Robust Agents Learn Causal World Models (arXiv:2402.10877). Language Agents Meet Causality (arXiv:2410.19923).

**Generative adversarial frameworks.** Goodfellow et al., *Generative Adversarial Nets* (NeurIPS 2014). The literature that follows is too large to enumerate here; what matters for this paper is the framing the GAN tradition established and that GRP rejects for its perception layer.

**Sibling project papers.**
- Memory as World Model (MWM): the memory subsystem of the Synthetic Sentiences Project, treated in [github.com/Playful-Sincerity/MWM-Memory-as-World-Model](https://github.com/Playful-Sincerity/MWM-Memory-as-World-Model). MWM specifies the graph that GRP writes into.
- The Synthetic Sentiences Project: the broader research program. See [github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project](https://github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project).
