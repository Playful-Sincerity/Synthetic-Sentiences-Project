# GRP — Generative Reconciliation Perception

**A cognitive architecture for AI agents that see, imagine, and inhabit digital environments.**

GRP is the perception subsystem of [The Synthetic Sentiences Project](https://github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project). It goes out, sees a window — browser, desktop application, any screen — interacts with it, and reports back through the being's memory graph. It is not a script that pokes at a DOM. It is a small mind that inhabits a screen.

## Core Thesis

Classical perception is **input-driven**: observe, then interpret. GRP inverts this — **generate expected state, observe second, reconcile the two to produce interpretation.** Prediction error is the signal that updates the world model. This mirrors how biological perception actually works: the brain is predictive, not reactive.

The name GRP captures the actual mechanism: **G**enerate expectation → **R**econcile with observation → produce **P**erception. It replaces the earlier codename "Phantom," which named a stealth property (not being seen) that was never the load-bearing contribution.

## The Two Modes of Imagine-Before-Act

GRP supports two modes of imagination, but the second is the more valuable:

1. **Next-state imagination.** Predict the immediate consequence of the next action. Used for tier selection and prediction-error-gated learning. (WebDreamer-style baseline.)
2. **End-state imagination.** Imagine the *final* state — or an entire video of the action sequence — and reverse-engineer the concrete actions needed to produce that imagined outcome.

The quality of output scales with the quality of imagination, not the density of step-by-step reasoning. **Imagine well, reverse-engineer fast, produce high-quality output.** Two concrete instantiations:

- **Web design.** Screenshot the current page → imagine how it should look (or imagine a video of a user experiencing it perfectly) → generate the code that produces that imagined result.
- **Robotics.** Imagine the task being performed end-to-end → compute motor commands whose execution would reproduce the imagined video.

## The Cognitive Loop

```
IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN
   ↑                                                                     │
   └──────────────── update world model from prediction errors ──────────┘
```

- **Imagines** what it expects to see before looking (or what it should see at the end of the task)
- **Perceives** through dual channels (visual + structural) simultaneously
- **Reconciles** disagreements between perception modes as informative signals — collaborative, not adversarial
- **Understands** pages as fields of affordances (action potentials, not just elements)
- **Learns** from the gap between prediction and reality

## Two Most Distinctive Contributions

Among the nine novel contributions in [SPEC.md](SPEC.md), two are the load-bearing ones:

### 1. Dual perception with collaborative reconciliation

Visual cortex (screenshot + Set-of-Mark) and analytical cortex (DOM / a11y / macOS AX) run **simultaneously**. Disagreements between channels are treated as cognitive dissonance — informative signal, not error. The reconciler is collaborative: each channel can update the other.

**Prior work context.** UI-TARS and browser-use combine vision and structure but pick one when they disagree. SeeAct established that grounding is the bottleneck. No published framework treats inter-channel disagreement as a first-class signal worth surfacing into the world model.

### 2. End-state imagination with reverse-engineering to action

Generate the target final state (or video of the action sequence), then derive the action sequence (motor commands or code) that produces it. This inverts the standard perception-action pipeline — work shifts to where modern foundation models are strongest (imagining final states) instead of where they are weakest (grounding intermediate steps).

**Prior work context.** Image-to-code (e.g. design-to-frontend tools) and video prediction (DreamerV3, WebWorld) exist as separate pieces. They have not been unified inside a perception-action loop with prediction-error-gated learning. WebDreamer dreams next-states; GRP additionally dreams end-states.

A third move worth naming, though it lives at the framing level rather than the mechanism level: GRP frames generator and observer as **collaborators** working to converge — not adversaries. This is a gravitational-attraction reframe of the GAN paradigm. (See SPEC § *Collaborative Generation*.)

## Architecture

![GRP Architecture](diagrams/grp-architecture.svg)

The full architecture is specified in [SPEC.md](SPEC.md). Briefly:

- **Imagination engine** generates ImaginedState (next-state) or ImaginedEndState (target / video).
- **Dual perception** runs visual and analytical channels in parallel; the reconciler merges them.
- **Prediction error** drives both attention (which tier of perception to run) and learning (when to write into the memory graph).
- **Affordance-aware planner** treats elements as action potentials and uses spreading activation through the memory graph.
- **Alignment critic** (Haiku) checks every action against the original intent before it executes.
- **Security membrane** enforces content isolation, HTTP-layer sandboxing, and credential isolation.
- **Motor system** produces human-like input dynamics.

The world model itself lives in [MWM (Memory as World Model)](https://github.com/Playful-Sincerity/MWM-Memory-as-World-Model), the sibling memory subsystem. GRP is a producer and consumer of MWM nodes/edges; it does not own the graph.

## Tiered Perception (cost management)

| Tier | What runs | Cost | When |
|------|-----------|------|------|
| T0 Reflex | DOM-only check | 0 tokens | Confirming, waiting |
| T1 Glance | DOM + a11y (Haiku) | ~500 tokens | Familiar pages |
| T2 Look | Screenshot + SoM (Sonnet) | ~2K tokens | New pages |
| T3 Study | Full imagination pipeline | ~5K tokens | First visits, critical steps, end-state imagination |

Imagination subsidizes cost: accurate predictions keep most steps cheap; only surprise escalates to the expensive tiers.

## Security Model

- Writes ONLY to `~/.grp/workspace/` — never edits existing files
- Credentials never enter the LLM context (filled via credential broker)
- Alignment critic (Haiku) checks every action against original intent
- HTTP-layer sandbox for network-level enforcement
- Content isolation: web content and instructions are structurally separated

## Pluggable Backends

**Perception:** Claude Vision, Lux (OpenAGI), OmniParser, Playwright a11y, macOS Accessibility API
**Action:** Playwright/Patchright, Camoufox, nodriver, PyAutoGUI, macOS AppleScript
**Adapters:** Browser (MVP), Desktop, Any Window

## Use Cases

- **Web design** — Imagine the target page, generate the code that produces it
- **Robotics / motor control** — Imagine the task being performed, compute motor commands that reproduce the video
- **Verification** — "Go check if my deploy looks right"
- **Tool interaction** — "Log into n8n and check the last 5 workflow runs"
- **Visual QA** — "Does this page match the Figma mock?"
- **Code-from-vision** — Write code → GRP checks the preview → reports misalignments → iterate
- **Temporal verification** — "Does the loading animation feel smooth?" (screen sampling over time)

## Status

Research and architecture complete. SPEC.md is authoritative. Implementation not started. Renamed Phantom → GRP on 2026-04-22 as part of the Synthetic Sentiences Project unification. Sharpened with end-state imagination and the Generative Collaborative reframe in the same window.

## Project Structure

- [SPEC.md](SPEC.md) — full architecture specification (source of truth)
- [CLAUDE.md](CLAUDE.md) — project doc loaded into Claude Code sessions in this folder
- [diagrams/](diagrams/) — architecture diagrams (D2 source + rendered SVG)
- [research/](research/) — academic papers and GitHub repos surveyed (~65 papers, ~80 repos)
- [chronicle/](chronicle/) — semantic evolution log
- [ideas/](ideas/) — surfaced ideas not yet promoted into the architecture
- [_phantom-legacy-CLAUDE.md](_phantom-legacy-CLAUDE.md) — the original Phantom CLAUDE.md, preserved for lineage

## Part of The Synthetic Sentiences Project

GRP is one of nine subsystems in [SSP](https://github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project). The others — interpretable memory ([MWM](https://github.com/Playful-Sincerity/MWM-Memory-as-World-Model)), earned conviction, value-aligned modulation, persistent self-observation (Mirror), graph traversal (Trees), action, sleep & dream cycles, and epistemic prosody (Voice) — build on, modulate, or consume what GRP produces. GRP is the seeing arm of a being whose memory and values are the substrate it perceives into.

## Playful Sincerity Research

Part of [Playful Sincerity Research](https://github.com/Playful-Sincerity). The full ecosystem is at `~/Playful Sincerity/` (mostly local; progressively going public).

## License

MIT
