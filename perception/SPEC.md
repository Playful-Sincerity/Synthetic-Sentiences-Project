# GRP — Generative Reconciliation Perception

**The perception subsystem of [The Synthetic Sentiences Project](https://github.com/Playful-Sincerity/SSP-Synthetic-Sentiences-Project).**

A cognitive architecture for AI agents that see, imagine, and inhabit digital environments. Perception is generative-first: the being imagines expected state, observes the world, and reconciles the two. Prediction error is the primary learning and attention signal.

Authored by Wisdom Happy / Playful Sincerity Research.
Originally conceived 2026-03-31 under the codename "Phantom" (a stealth-property name).
Renamed and reframed 2026-04-22 to GRP — naming the actual mechanism rather than a side property.

---

## Vision

GRP is a perception subsystem that any sentience built on the SSP architecture can dispatch as a scout. It goes out, sees a window — browser, desktop application, any screen — interacts with it using human-like behavior, and reports back through the being's memory graph (MWM).

It is not a script that pokes at a DOM. It is a small mind that inhabits a screen.

### Two distinct perceptual modes

GRP supports two modes of imagine-before-act:

1. **Next-state imagination** — Predict the immediate consequence of the next action. WebDreamer-style. Used for tier selection and prediction-error-gated learning.
2. **End-state imagination** — Imagine the *final* state, or an entire video of the action sequence, and reverse-engineer the concrete actions needed to produce that imagined outcome. This is the highest-leverage use of the imagination engine.

End-state imagination is the more valuable mode. The quality of output scales with the quality of imagination, not the density of step-by-step reasoning. Imagine well, reverse-engineer fast, produce high-quality output. See [Imagine-Before-Act § Primary Use Case](#imagine-before-act--the-primary-use-case) below.

### Core use cases

1. **Web design.** Screenshot the current page → imagine how it should look (or imagine a video of a user experiencing it perfectly) → generate the code that produces that imagined result. Qualitatively different from "screenshot and describe": the imagination holds the target; reverse-engineering produces the diff.
2. **Robotics.** Imagine the task being performed end-to-end → compute motor commands whose execution would reproduce the imagined video. Same mechanism, different output channel.
3. **Verification.** "Go check if my deploy looks right" → screenshots, analyzes, compares against expectations, reports.
4. **Tool interaction.** "Log into n8n and check the last 5 workflow executions" → navigates, authenticates (credentials never in LLM context), extracts data.
5. **Visual QA.** "Does this page match the Figma mock?" → screenshots both, compares layout/styling/content.
6. **Form filling.** "Submit this application form with these details" → fills forms with human-like input patterns.
7. **Code-from-vision.** Write code → GRP opens preview → screenshots what it looks like → compares against what it SHOULD look like → reports misalignments → upstream agent fixes → iterate.
8. **Temporal verification.** "Does the loading animation feel smooth?" → screen sampling over time, not just single screenshots.

---

## Imagine-Before-Act — The Primary Use Case

The most valuable deployment of GRP's imagination engine is **end-state imagination with reverse-engineering**, not next-state prediction.

### The mechanism

```
TASK INTENT  ─────►  IMAGINE END STATE  ─────►  REVERSE-ENGINEER ACTIONS  ─────►  ACT  ─────►  RECONCILE
                    (or full video of                (motor commands or
                     action sequence)                 code that produce it)
```

### Why this matters

Step-by-step reasoning is bottlenecked by the quality of each step's grounding. End-state imagination is bottlenecked by the quality of imagination itself — and modern foundation models can imagine final states at a far higher quality than they can ground intermediate steps. Inverting the pipeline (imagine target → derive actions) shifts work to where the model is strongest.

### Two concrete instantiations

**Web design.**
- Input: current page screenshot + design intent
- Imagine: the target page (or a short video of a user experiencing it correctly)
- Reverse-engineer: the diff in HTML/CSS/JS that produces the imagined target
- Verify: render the diff, compare to the imagined target, iterate on prediction error

**Robotics / motor control.**
- Input: task description + current scene
- Imagine: the full video of the task being performed correctly
- Reverse-engineer: the motor commands whose execution reproduces the imagined video
- Verify: execute, compare observed video to imagined video, iterate

### Connection to the unification thesis

Imagine-before-act in GRP, value-aligned modulation as gap-between-perceived-and-should-world (Values), and dream-cycle simulation (Cycles) are the same mechanism applied at three scales: task-scale (GRP), being-scale (Values), moment-scale (Cycles). The imagination engine is shared infrastructure across these subsystems.

---

## Collaborative Generation — A Reframe of the Adversarial Paradigm

GANs (Generative Adversarial Networks) frame generator and discriminator as **competitors** — one tries to fool, one tries to detect. GRP's architecture is different: the imagined world and the observed world are **collaborators**. Both work to converge.

The being adjusts actions AND its own understanding so the observed matches the imagined — both sides of the architecture are trying to close the gap. Neither is the adversary of the other.

This is a gravitational-attraction reframe of a classic adversarial pattern. It is consistent with the rest of the Synthetic Sentiences Project's alignment story (Gravitationalism: the universe converges through attraction, not opposition).

**Working term:** *Generative Collaborative Network* (concept). The natural acronym GCN is taken in ML literature (Graph Convolutional Network), so a paper publication will need a different shorthand. The concept stands regardless of what it is eventually called.

**Architectural consequence.** Reconciliation is not a competition between channels (visual vs. analytical) or between expectation and observation. It is a cooperative procedure that closes the gap by updating the side that is most-cheaply-updated given current evidence. Surprise is information, not failure.

---

## Philosophical Foundation

### Three paradigms of computer-use perception

**Paradigm 1: "Script the DOM"** (Selenium, Puppeteer, traditional)
> The browser is a machine. Send commands. Parse responses.
> Problem: brittle, detectable, no understanding.

**Paradigm 2: "Serialize and Prompt"** (browser-use, Stagehand, most current agents)
> Dump the page as text → send to LLM → parse action → execute.
> Problem: blind between actions, content mixes with instructions, no spatial understanding.

**Paradigm 3: "Imagine and Inhabit"** (GRP)
> The agent looks at the page the way a human does — as a visual scene with spatial relationships. It maintains a continuous mental model. It imagines what should be there before it looks. It learns from surprise. It can imagine the end state and reverse-engineer the path.

### The four separations

1. **SEEING ≠ ACTING** — Perception and action are different systems with different backends.
2. **THINKING ≠ TOUCHING** — The cognitive core never directly calls browser APIs; the browser never sees the task.
3. **PAGE CONTENT ≠ INSTRUCTIONS** — Web content is always untrusted data, structurally separated.
4. **CREDENTIALS ≠ CONTEXT** — Passwords/tokens never enter the LLM's context window.

---

## Integration with Other SSP Subsystems

GRP is one of nine subsystems. It does not stand alone — it produces and consumes structure that other subsystems shape.

| Subsystem | Relationship to GRP |
|---|---|
| **MWM (Memory as World Model)** | Predicted states and observed states write nodes/edges into the graph. Causal edges (clicking X caused Y) become Pearl-Layer-2 entries in the being's world model. Site patterns, layouts, and learned affordances live in MWM. The graph is GRP's long-term store. |
| **Cognition (Earned Conviction)** | Page elements have confidence levels rooted in evidence chains. Disagreements between perception channels are cognitive dissonance — the same primitive cognition uses to surface unresolved beliefs. Curiosity about unknown elements is the same affect that drives investigation in cognition. |
| **Values (Value-Aligned Modulation)** | What to attend to, what to imagine, and what to consider acceptable are weighted by current value-alignment state. The alignment critic (Haiku checking each action) is a value-aligned check at the perception/action boundary. |
| **Trees (Working Memory)** | The current page or screen is a node in the working tree. Spreading activation focuses attention on goal-relevant elements. The tree grows when new perceptual content is loaded; it shrinks when perceptions stop being relevant. |
| **Action** | Perceptions feed action selection. Actions change the observed world and produce new perceptions. The IMAGINE → ACT → RECONCILE loop is what binds GRP to Action: one is the seeing arm, the other is the moving arm of the same loop. |
| **Cycles (Sleep & Dream)** | Dream cycles use GRP's imagination engine to simulate without observing — adversarial self-reflection, value-conflict tests, hypothetical scenarios. Sleep cycles consolidate experiential perception nodes into long-term graph structure. |
| **Mirror** | The mirror watches GRP's behavior across sessions. Patterns in what GRP misperceives, what it cannot reconcile, what it consistently surprises itself with, become observations the mirror writes about the being. |
| **Voice (Epistemic Prosody)** | When the being speaks about what it perceived, its acoustic prosody should reflect the confidence levels in the page model. Honest disfluency around low-confidence perceptions is prosodic accuracy, not a defect. |

---

## Architecture

### The cognitive loop

```
IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN
   ↑                                                                     │
   └──────────────── update world model from prediction errors ──────────┘
```

- **IMAGINE** — Generate expected state. Two modes: next-state (immediate consequence of next action) and end-state (target final state, optionally a video).
- **OBSERVE** — Dual perception: visual cortex (screenshot + Set-of-Mark) + analytical cortex (DOM/a11y/macOS AX) simultaneously.
- **RECONCILE** — Merge both views, flag disagreements as cognitive dissonance. Collaborative, not adversarial: each channel can update the other.
- **DIFF** — Compare imagination vs. reality; prediction error magnitude drives attention.
- **PLAN** — Select action from affordance-aware page model (spreading activation through MWM).
- **CHECK** — Alignment critic (cheap Haiku call): "Does this action serve the original intent?"
- **GUARD** — Security membrane: content isolation, URL sandbox, credential isolation.
- **ACT** — Execute via motor system with human-like dynamics.
- **LEARN** — If prediction error exceeds threshold: update the MWM graph (reconsolidation).

### System diagram

```
┌─────────────────────────────────────────────────────────┐
│                    MCP SERVER / CLI                      │
│  Interface for the parent being (PD or other entity),   │
│  Claude Code, n8n, or standalone use                    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│               IMAGINATION ENGINE                         │
│  "What do I expect to see?" / "What should it look      │
│   like at the end?"                                     │
│  Sources: MWM graph + task context + last action +      │
│           value-aligned modulation                      │
│  Outputs: ImaginedState (next-state) and/or             │
│           ImaginedEndState (target / video)             │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                DUAL PERCEPTION                           │
│                                                          │
│  VISUAL CORTEX           ANALYTICAL CORTEX               │
│  Screenshot + SoM         DOM/a11y/macOS AX              │
│  Layout, colors,          Structure, state,              │
│  visual state             handlers, exact values         │
│                                                          │
│  ──────────── RECONCILER (collaborative) ────────────    │
│  Merge → unified PageModel with confidence               │
│  Disagreements = cognitive dissonance, not error         │
│  Arbitration: visual wins for "looks right?"             │
│               analytical wins for "is clickable?"        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              PREDICTION ERROR (Diff)                     │
│  Compare ImaginedState vs PageModel                      │
│  (and ImaginedEndState vs current state if end-state    │
│   mode is active — drives reverse-engineering)          │
│  Low error → proceed (Tier 0-1 next time)               │
│  High error → reconsolidate + escalate attention         │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│            AFFORDANCE-AWARE PLANNER                      │
│  Elements perceived as action potentials:                │
│  [7] button "Deploy" → affordance: TRIGGER_ACTION        │
│  [12] input "Search" → affordance: QUERY                 │
│  Spreading activation through MWM: goal → affordances    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│         ALIGNMENT CRITIC (Haiku, every action)           │
│  "Does this action serve the original intent?"           │
│  YES → proceed | CAUTION → log | NO → re-plan            │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│             SECURITY MEMBRANE                            │
│  Content sanitizer (BrowseSafe patterns)                 │
│  HTTP-layer sandbox (ceLLMate-inspired)                  │
│  Permission tiers: auto / confirm / deny                 │
│  Credential broker (fills directly, bypasses LLM)        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│                 MOTOR SYSTEM                             │
│  Bezier curve mouse movement with Gaussian jitter        │
│  Per-character typing with normal distribution delays    │
│  Momentum-based scrolling                                │
│  All via raw input events (CDP/PyAutoGUI/AppleScript)    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│        MWM GRAPH WRITE-BACK (memory subsystem)           │
│  Predicted states, observed states, causal edges        │
│  Site patterns, learned affordances, error patterns     │
│  Reconsolidation: writes only when prediction error     │
│  exceeds threshold                                       │
│  Read-back: imagination engine queries the graph for    │
│  priors and expectations                                 │
└─────────────────────────────────────────────────────────┘
```

The world model (Matrix) lives in MWM, not inside GRP. GRP is a producer and consumer of MWM nodes/edges; it does not own the graph. This is a deliberate factoring: every subsystem in SSP that produces or consumes beliefs touches the same graph.

### Tiered perception (cost management)

| Tier | What runs | ~Tokens | When |
|------|-----------|---------|------|
| **0 Reflex** | DOM-only check, no LLM | 0 | Waiting, confirming, checking element presence |
| **1 Glance** | DOM + lightweight a11y (Haiku) | 500 | Familiar pages, expected states, form filling |
| **2 Look** | Screenshot + SoM + a11y (Sonnet vision) | 2K | New page, moderate surprise |
| **3 Study** | Full pipeline: imagination + dual perception + reconciler + affordances | 5K | First visit, high surprise, critical steps, verification, end-state imagination tasks |

Imagination enables tiered perception: if you predict accurately, cheap Tier 0–1 suffices. Only surprise triggers expensive Tier 2–3. A 10-step task costs ~15K tokens instead of ~50K.

### Temporal perception (video model)

Beyond single screenshots, GRP can sample frames over time to understand:
- Loading sequences and progress
- Animations and transitions
- Dynamic state changes (real-time updates, WebSocket data)
- Whether something is "working" vs "frozen"
- Whether an interaction "feels right" (smooth scroll, responsive hover)

Implementation: capture N frames at configurable intervals, analyze the sequence for temporal patterns. Video-scale imagination uses the same temporal substrate — the imagined "video of the action sequence" is a sequence of imagined frames against which observed frames are reconciled.

---

## Pluggable Backends

### Perception backends

| Backend | Type | Use case | Cost |
|---------|------|----------|------|
| **Claude Vision** | Visual | Deep understanding, imagination, reconciliation | High |
| **Lux Actor (OpenAGI)** | Visual+Action | Fast action grounding, 1 sec/step | Low |
| **OmniParser (Microsoft)** | Visual | Screenshot → structured elements with interactability | Medium |
| **Playwright MCP a11y** | Structural | DOM/accessibility tree (browser) | Free |
| **macOS Accessibility API** | Structural | Native app structure | Free |

### Action backends

| Backend | Environment | Anti-detection |
|---------|-------------|---------------|
| **Playwright/Patchright** | Browser (Chromium) | Stealth, undetected |
| **Camoufox** | Browser (Firefox) | C++-level fingerprint spoofing, best-in-class |
| **nodriver** | Browser (Chrome, CDP-free) | Bypasses CDP detection entirely |
| **PyAutoGUI** | Any window (OS-level) | Native input, undetectable |
| **macOS AppleScript** | Desktop apps | Native API |
| **cursory** | Mouse trajectory generation | Human-realistic Bezier paths |

### Lux integration

Lux (OpenAGI) can serve as a fast perception-action backbone:
- API-based: `OAGI_API_KEY` + `OAGI_BASE_URL`
- 83.6 on Mind2Web (SOTA, 23 points ahead of Operator)
- 1 sec/step in Actor mode
- Pluggable via `ScreenshotProvider` / `ActionHandler` interfaces
- MIT-licensed SDK (`agiopen-org/oagi-python`)
- OSGym (MIT) available for future fine-tuning if needed

---

## Security Model

### Filesystem sandbox

- GRP writes ONLY to `~/.grp/workspace/`
- Each task gets a subdirectory: `task-YYYY-MM-DD-description/`
- Contains: screenshots, findings.md, page-model.json, causal-log.json
- GRP NEVER edits existing files outside its sandbox
- The parent being (Claude Code, PD, or other SSP entity) reads these files and decides what to do with them

### Content isolation

- Web content and agent instructions NEVER share the same string
- Observations wrapped in tamper-evident delimiters
- Hidden elements stripped before agent sees content
- Prompt injection patterns detected and flagged (BrowseSafe, 14K+ patterns)

### Alignment critic

- Cheap Haiku call on EVERY action before execution
- "Does this action serve the user's original intent?"
- No existing framework ships this — GRP's differentiator

### HTTP-layer sandbox (ceLLMate-inspired)

- All side effects = HTTP requests
- Domain allowlist, method restrictions
- Even if AI is tricked, blocked at the wire

### Credential management

- Credentials stored in encrypted local vault
- Filled directly via browser engine, bypassing LLM entirely
- Agent sees: `[credentials filled for github.com]` — never the values

### Permission tiers

| Tier | Actions | Approval |
|------|---------|----------|
| Auto | Navigate allowed domains, click, scroll, read | None |
| Confirm | Submit sensitive forms, navigate new domains, download | User confirms |
| Deny | Access filesystem, execute commands, modify extensions | Blocked |

---

## Data Structures

### ImaginedState (next-state mode)

```typescript
interface ImaginedState {
  url_pattern: string;
  expected_elements: ExpectedElement[];
  layout_expectations: LayoutHint[];
  confidence: number;
  source: 'mwm_graph' | 'task_context' | 'action_consequence' | 'url_pattern';
}

interface ExpectedElement {
  role: string;
  probable_text: string[];
  probable_position: 'top' | 'center' | 'bottom' | 'sidebar' | 'modal';
  affordance: string;
  confidence: number;
}
```

### ImaginedEndState (end-state mode)

```typescript
interface ImaginedEndState {
  target_kind: 'final_screenshot' | 'video_sequence' | 'structural_target';
  target_screenshot?: ImageRef;     // for final-state mode
  target_video_frames?: ImageRef[]; // for video mode
  target_structure?: PageModel;     // for structural targets
  intent: string;
  confidence: number;
  reverse_engineering_strategy: 'diff_then_codegen' | 'motor_inverse' | 'plan_search';
}
```

### PageModel (reconciled dual perception)

```typescript
interface PageModel {
  url: string;
  title: string;
  timestamp: number;
  elements: PageElement[];
  layout: LayoutModel;
  disagreements: Disagreement[];
  confidence: number;
  affordances: Affordance[];
}

interface PageElement {
  id: string;
  dom_role: string;
  dom_tag: string;
  aria_label?: string;
  is_interactive: boolean;
  is_visible: boolean;
  visual_description?: string;
  visual_position?: BoundingBox;
  visual_state?: 'normal' | 'highlighted' | 'disabled' | 'loading' | 'error';
  unified_label: string;
  confidence: number;
  source_agreement: 'both' | 'visual_only' | 'analytical_only' | 'conflict';
  affordance?: Affordance;
}

interface Disagreement {
  element_id: string;
  visual_says: string;
  analytical_says: string;
  resolution: 'trust_visual' | 'trust_analytical' | 'flag_uncertain' | 'investigate';
}
```

### Affordance

```typescript
interface Affordance {
  element_id: string;
  action_type: 'click' | 'type' | 'select' | 'scroll' | 'hover' | 'drag' | 'read' | 'wait';
  expected_outcome: string;
  confidence: number;
  relevance_to_task: number;
  risk: 'safe' | 'caution' | 'dangerous';
  preconditions?: string[];
  source: 'element_analysis' | 'mwm_graph' | 'task_inference';
}
```

### MWM-side nodes/edges produced by GRP

GRP does not define its own world-model schema. It writes to MWM using MWM's node/edge primitives. The shapes below describe the *content* GRP contributes; the storage layer is MWM's responsibility.

```typescript
// Content GRP writes into MWM nodes
type GRPNodeContent =
  | { kind: 'site_pattern'; domain: string; description: string }
  | { kind: 'page_layout'; url_pattern: string; layout: LayoutModel }
  | { kind: 'element_behavior'; element_signature: string; behavior: string }
  | { kind: 'flow_step'; from: string; to: string; trigger: Affordance }
  | { kind: 'error_pattern'; trigger: string; manifestation: string };

// Edges GRP creates between MWM nodes
type GRPEdgeKind =
  | 'association'  // co-occurrence
  | 'causal'       // action X led to state Y (Pearl Layer 2)
  | 'affordance'   // element offers action
  | 'sequence';    // step before/after another step
```

---

## Module Map

```
perception/                          # GRP source tree (within SSP repo)
  packages/
    core/                            # Cognitive pipeline (universal)
      src/
        imagination.ts               # Next-state and end-state imagination engines
        reverse_engineer.ts          # End-state → action sequence
        perception/
          visual.ts                  # Screenshot + SoM via Claude/Lux/OmniParser
          analytical.ts              # DOM/a11y/macOS AX extraction
          reconciler.ts              # Merge views, handle disagreements
          temporal.ts                # Screen sampling over time (video model)
        affordance.ts                # Elements as action potentials
        diff.ts                      # Imagination vs reality
        planner.ts                   # Affordance-aware action selection
        critic.ts                    # Alignment check (Haiku)
        guard.ts                     # Security membrane
        learner.ts                   # Prediction-error-gated MWM writes
        pipeline.ts                  # Orchestrate full cycle
        types.ts                     # Shared types

    mwm-bridge/                      # Connect to MWM (separate repo)
      src/
        write.ts                     # Write GRP nodes/edges into MWM
        read.ts                      # Read priors / expectations from MWM
        spreading.ts                 # In-page spreading activation via MWM

    adapters/                        # Pluggable per-environment
      browser/                       # Browser adapter (MVP)
        playwright.ts                # Playwright/Patchright
        stealth.ts                   # Camoufox/nodriver
        dom-perception.ts            # A11y tree extraction
      desktop/                       # Desktop adapter (future)
        macos-ax.ts
        applescript.ts
      screen/                        # Any-window adapter (future)
        screenshot.ts
        pyautogui.ts
      lux/                           # Lux (OpenAGI) adapter
        provider.ts                  # ScreenshotProvider for Lux API
        handler.ts                   # ActionHandler from Lux output

    interface/                       # How other tools connect
      mcp-server/                    # MCP server for Claude Code / PD
        server.ts
        tools.ts
        resources.ts
      cli/                           # Standalone CLI
        index.ts
      sandbox/                       # Filesystem sandbox
        workspace.ts                 # Manages ~/.grp/workspace/
        policy.ts                    # Write permissions

    motor/                           # Human-like input system
      src/
        mouse.ts                     # Bezier curves + Gaussian jitter
        keyboard.ts                  # Per-char normal distribution delays
        scroll.ts                    # Momentum-based scrolling
```

---

## Build Phases

### Phase 1: Walking (MVP)
- Playwright browser adapter + screenshot capture
- Basic visual perception (Claude Vision + SoM)
- Simple action planner (no imagination yet)
- MCP server with: navigate, screenshot, click, type
- Sandbox workspace

### Phase 2: Seeing Double
- Add analytical cortex (a11y tree)
- Build reconciler (merge + disagreement detection, collaborative arbitration)
- Add affordance layer
- Tiered perception (Tier 0-2)

### Phase 3: Dreaming (next-state)
- Next-state imagination engine
- Prediction error computation
- MWM bridge (read priors, write reconsolidations)
- Learning loop (reconsolidation under surprise)
- Full Tier 0-3 perception

### Phase 4: Imagining the End
- End-state imagination (single-frame and video)
- Reverse-engineering: end-state → action sequence
- Web-design and code-from-vision pipelines
- Robotic motor-inverse pipeline (if motor backend available)

### Phase 5: Feeling
- Temporal perception (screen sampling, video model) integrated with imagination
- Stealth mode (Patchright/Camoufox)
- Motor system (Bezier mouse, Gaussian typing)
- Lux integration as fast perception backend

### Phase 6: Speaking
- Alignment critic
- Full security membrane
- Credential vault
- CLI tool
- Desktop adapter (macOS)

End-state imagination (Phase 4) is intentionally introduced *after* the next-state loop is working, because the reverse-engineering pipeline depends on having a stable IMAGINE → OBSERVE → RECONCILE substrate to verify against.

---

## Novel Contributions (vs. literature)

Based on 8 research agents, ~65 papers, ~80 repos surveyed (2026-03-31). The 2026-04-22 sharpening adds two further contributions: end-state imagination with reverse-engineering, and the Generative Collaborative reframe.

| Contribution | Status in literature |
|---|---|
| **End-state imagination with reverse-engineering to action** | Unpublished as a unified mechanism — pieces exist (image-to-code; video prediction) but not as a perception-action loop |
| **Generative Collaborative reframe of GAN-style architectures** | Novel framing — collaboration over adversarial dynamics in generation |
| Dual perception reconciler with principled disagreement handling | Unpublished — no paper or project does this |
| In-page spreading activation for element attention | Unpublished — all spreading activation work is document-level |
| Active inference framing for web navigation | Completely unoccupied in browser agent literature |
| Online causal graph building during live browsing | Unpublished — existing work is offline/simulation |
| Prediction-error-gated tiered perception (Kahneman dual-process for cost) | Novel application to browser agents |
| MWM Three-Plane substrate applied to perception | Novel cross-pollination |
| Alignment critic on every action | Not shipped by any existing framework |
| Temporal perception / video model for browser state | Emerging but not integrated with world models |

---

## Key Research References

### World models for browser agents
- WMA (arXiv:2410.13232) — transition-focused observation abstraction
- WebDreamer (arXiv:2411.06559) — LLM as world model, "dream before act"
- MobileDreamer (arXiv:2601.04035) — textual sketch world model
- WebWorld (arXiv:2602.14721) — 1M+ trajectory simulator
- CUWM (arXiv:2602.17365) — two-stage: predict semantic change, then visual
- DreamerV3 (arXiv:2301.04104) — foundational world model architecture

### Visual grounding
- SeeAct (arXiv:2401.01614) — grounding is the bottleneck, not reasoning
- Set-of-Mark / SoM (Microsoft) — numbered bounding boxes for grounding
- OmniParser (arXiv:2408.00203) — screenshot → structured elements
- UGround (arXiv:2410.05243) — universal visual grounding, ICLR 2025 Oral
- WebVoyager (arXiv:2401.13919) — SoM-based vision agents: 59.1% vs 30.8% text-only

### Benchmarks
- WebArena (arXiv:2307.13854) — 812 tasks, best agent 72.7% (trymeka/agent)
- Mind2Web (arXiv:2306.06070) — 2000+ tasks across 137 real websites
- VisualWebArena (arXiv:2401.13649) — vision-requiring web tasks

### Security
- BrowseSafe (arXiv:2511.20597) — 14,719 injection samples, multi-layer defense
- ceLLMate (arXiv:2512.12594) — HTTP-layer sandboxing, agent-agnostic
- WASP (arXiv:2504.18575) — indirect prompt injection against web agents
- IntentGuard (arXiv:2512.00966) — intent analysis before action execution

### Agent architectures
- ReAct (arXiv:2210.03629) — interleaved reasoning + acting
- OpAgent (arXiv:2602.13559) — 71.6% WebArena, Reflector for error recovery
- LATS (arXiv:2310.04406) — tree search over action sequences
- Survey of WebAgents (arXiv:2503.23350) — comprehensive field survey

### Active inference & causality
- EFE as Variational Inference (arXiv:2504.14898) — free energy reduces to prediction error
- Robust Agents Learn Causal World Models (arXiv:2402.10877) — proved mathematically
- Language Agents Meet Causality (arXiv:2410.19923) — causal variables linked to language

### Existing tools (build on, not reinvent)
- browser-use (85K stars) — de facto community standard
- playwright-mcp (30K stars) — Microsoft's a11y-based MCP server
- UI-TARS (29K stars, ByteDance) — dual perception with MCP kernel
- OmniParser (24K stars) — visual grounding layer
- Camoufox (6.5K stars) — C++-level fingerprint spoofing
- Patchright (2.7K stars) — undetected Playwright, Apache-2.0
- Lux/OpenAGI — 83.6 Mind2Web SOTA, MIT SDK, API-based

---

## Related Projects (within Playful Sincerity)

- **The Synthetic Sentiences Project** — the umbrella program GRP belongs to. SSP's CLAUDE.md surveys the nine subsystems and the alignment-through-architecture thesis.
- **Memory as World Model (MWM)** — the memory subsystem GRP writes into and reads from. Sister repo, four-month Anthropic Fellows 2026 target.
- **Cognition / Values / Mirror / Trees / Action / Cycles / Voice** — the other SSP subsystems GRP integrates with (see Integration with Other SSP Subsystems above).
- **Gravitationalism** — alignment foundation; informs the collaborative-over-adversarial reframe.
- **PSSO** — philosophical roots; Earned Conviction and Emotivation pillars.
- **Spatial Workspace** — could visualize GRP's contributions to MWM as a 2D graph view.
- **Claude Code Entities (PD)** — the operational entity that will eventually dispatch GRP as a perception scout.
