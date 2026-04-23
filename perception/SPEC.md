# Phantom — Visual Computer-Use Agent

**A cognitive architecture for AI agents that see, imagine, and inhabit digital environments.**

Built by Wisdom Happy / Playful Sincerity Research.
Conceived 2026-03-31 during hackathon research sprint.

---

## Vision

Phantom is a visual computer-use agent that Claude Code (or any MCP client) can dispatch as a scout. It goes out, sees any window — browser, desktop app, any screen — interacts with it using human-like behavior, and reports back with files in a sandboxed workspace.

It is not a script that pokes at a DOM. It is a small mind that inhabits a screen.

### What makes it different

Every existing browser/computer-use agent is **reactive**: observe → decide → act → repeat. They process each page from scratch, with no expectations, no memory, no sense of what elements afford, no internal model that gets surprised.

Phantom is **predictive**: it imagines what it expects to see before looking, perceives through dual channels simultaneously, understands pages as fields of affordances (action potentials), and learns from the gap between prediction and reality. The prediction error is the primary learning and attention signal.

### Core use cases

1. **Verification** — "Go check if my deploy looks right" → screenshots, analyzes, compares against expectations, reports
2. **Tool interaction** — "Log into n8n and check the last 5 workflow executions" → navigates, authenticates (credentials never in LLM context), extracts data
3. **Visual QA** — "Does this page match the Figma mock?" → screenshots both, compares layout/styling/content
4. **Form filling** — "Submit this application form with these details" → fills forms with human-like input patterns
5. **Code verification** — Write code → Phantom opens preview → screenshots what it looks like → compares against what it SHOULD look like → reports misalignments → Claude Code fixes → iterate
6. **Temporal verification** — "Does the loading animation feel smooth?" → screen sampling over time, not just single screenshots

---

## Philosophical Foundation

### Three paradigms of browser automation

**Paradigm 1: "Script the DOM"** (Selenium, Puppeteer, traditional)
> The browser is a machine. Send commands. Parse responses.
> Problem: brittle, detectable, no understanding.

**Paradigm 2: "Serialize and Prompt"** (browser-use, Stagehand, most current agents)
> Dump the page as text → send to LLM → parse action → execute.
> Problem: blind between actions, content mixes with instructions, no spatial understanding.

**Paradigm 3: "Imagine and Inhabit"** (Phantom)
> The AI looks at the page the way a human does — as a visual scene with spatial relationships. It maintains a continuous mental model. It predicts before it acts. It learns from surprise.

### The four separations

1. **SEEING ≠ ACTING** — Perception and action are different systems with different backends.
2. **THINKING ≠ TOUCHING** — The cognitive core never directly calls browser APIs; the browser never sees the task.
3. **PAGE CONTENT ≠ INSTRUCTIONS** — Web content is always untrusted data, structurally separated.
4. **CREDENTIALS ≠ CONTEXT** — Passwords/tokens never enter the LLM's context window.

### Cross-pollination from Associative Memory

Phantom's architecture draws directly from the Associative Memory project (~/Playful Sincerity/PS Research/Associative Memory/):

| Associative Memory | Phantom |
|---|---|
| The Matrix (long-term graph) | Site Knowledge Graph — accumulated patterns, layouts, login flows |
| The Trees (working memory) | Page Model — current page's dual-perception output, ephemeral |
| The Mirror (consciousness) | Imagination Layer — watches everything, generates expectations, detects prediction errors |
| Navigation, not retrieval | In-page spreading activation for element attention |
| Causal edges from tool use | Click X → page Y loads = Pearl's Layer 2 interventional knowledge |
| Reconsolidation under prediction error | World model updates only when surprised |
| Epistemic humility + curiosity | Unknown elements become weighted exploration targets |
| Action-oriented meaning | Elements perceived as affordances (Gibson's ecological psychology) |

### Cross-pollination from The Companion

| The Companion | Phantom |
|---|---|
| Earned conviction, not installed beliefs | Agent learns site patterns from experience, not hardcoded rules |
| Cognitive dissonance detector | When visual and analytical cortex disagree = dissonance = information |
| Belief graph with confidence | Page model elements have confidence levels |
| Information gap tracking | Unknown elements become curiosity-weighted exploration targets |

---

## Architecture

### The cognitive loop

```
IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN
   ↑                                                                     │
   └──────────────── update world model from prediction errors ──────────┘
```

- **IMAGINE** — Generate expected state from world model + task + last action
- **OBSERVE** — Dual perception: visual cortex + analytical cortex simultaneously
- **RECONCILE** — Merge both views, flag disagreements as cognitive dissonance
- **DIFF** — Compare imagination vs reality; prediction error magnitude drives attention
- **PLAN** — Select action from affordance-aware page model (spreading activation)
- **CHECK** — Alignment critic (cheap Haiku call): "Does this serve the original intent?"
- **GUARD** — Security membrane: content isolation, URL sandbox, credential isolation
- **ACT** — Execute via motor system with human-like dynamics
- **LEARN** — If prediction error > threshold: update world model (reconsolidation)

### System diagram

```
┌─────────────────────────────────────────────────────────┐
│                    MCP SERVER / CLI                       │
│  Interface for Claude Code, n8n, or standalone use       │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│               IMAGINATION ENGINE (Mirror)                │
│  "What do I expect to see?"                              │
│  Sources: world model + task context + last action       │
│  Output: ImaginedState (text description of expected)    │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│            DUAL PERCEPTION (Trees)                       │
│                                                          │
│  VISUAL CORTEX           ANALYTICAL CORTEX               │
│  Screenshot + SoM         DOM/a11y/macOS AX              │
│  Layout, colors,          Structure, state,              │
│  visual state             handlers, exact values         │
│                                                          │
│  ──────────── RECONCILER ────────────                    │
│  Merge → unified PageModel with confidence               │
│  Flag disagreements as cognitive dissonance               │
│  Arbitration: visual wins for "looks right?"             │
│               analytical wins for "is clickable?"        │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              PREDICTION ERROR (Diff)                     │
│  Compare ImaginedState vs PageModel                      │
│  Low error → proceed (Tier 0-1 next time)               │
│  High error → reconsolidate + escalate attention         │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│            AFFORDANCE-AWARE PLANNER                      │
│  Elements perceived as action potentials:                │
│  [7] button "Deploy" → affordance: TRIGGER_ACTION        │
│  [12] input "Search" → affordance: QUERY                 │
│  Spreading activation: goal → relevant affordances       │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│         ALIGNMENT CRITIC (Haiku, every action)           │
│  "Does this action serve the user's original intent?"    │
│  YES → proceed | CAUTION → log | NO → re-plan           │
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
│  All via raw input events (CDP/PyAutoGUI/AppleScript)   │
└──────────────────────┬──────────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────────┐
│              WORLD MODEL (Matrix)                        │
│  SQLite graph of site patterns + causal edges            │
│  Spreading activation for pattern retrieval              │
│  Reconsolidation: updates only under prediction error    │
│  Grows smarter with use                                  │
└─────────────────────────────────────────────────────────┘
```

### Tiered perception (cost management)

| Tier | What runs | ~Tokens | When |
|------|-----------|---------|------|
| **0 Reflex** | DOM-only check, no LLM | 0 | Waiting, confirming, checking element presence |
| **1 Glance** | DOM + lightweight a11y (Haiku) | 500 | Familiar pages, expected states, form filling |
| **2 Look** | Screenshot + SoM + a11y (Sonnet vision) | 2K | New page, moderate surprise |
| **3 Study** | Full pipeline: imagination + dual perception + reconciler + affordances | 5K | First visit, high surprise, critical steps, verification |

Imagination enables tiered perception: if you predict accurately, cheap Tier 0-1 suffices. Only surprise triggers expensive Tier 2-3. A 10-step task costs ~15K tokens instead of ~50K.

### Temporal perception (video model)

Beyond single screenshots, Phantom can sample frames over time to understand:
- Loading sequences and progress
- Animations and transitions
- Dynamic state changes (real-time updates, WebSocket data)
- Whether something is "working" vs "frozen"
- Whether an interaction "feels right" (smooth scroll, responsive hover)

Implementation: capture N frames at configurable intervals, analyze the sequence for temporal patterns.

---

## Pluggable Backends

### Perception backends

| Backend | Type | Use case | Cost |
|---------|------|----------|------|
| **Claude Vision** | Visual | Deep understanding, imagination, reconciliation | High |
| **Lux Actor (OpenAGI)** | Visual+Action | Fast action grounding, 1sec/step | Low |
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

- Phantom writes ONLY to `~/.phantom/workspace/`
- Each task gets a subdirectory: `task-YYYY-MM-DD-description/`
- Contains: screenshots, findings.md, page-model.json, causal-log.json
- Phantom NEVER edits existing files outside its sandbox
- Claude Code reads these files and decides what to do with them

### Content isolation

- Web content and agent instructions NEVER share the same string
- Observations wrapped in tamper-evident delimiters
- Hidden elements stripped before agent sees content
- Prompt injection patterns detected and flagged (BrowseSafe, 14K+ patterns)

### Alignment critic

- Cheap Haiku call on EVERY action before execution
- "Does this action serve the user's original intent?"
- No existing framework ships this — Phantom's differentiator

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

### ImaginedState

```typescript
interface ImaginedState {
  url_pattern: string;
  expected_elements: ExpectedElement[];
  layout_expectations: LayoutHint[];
  confidence: number;
  source: 'world_model' | 'task_context' | 'action_consequence' | 'url_pattern';
}

interface ExpectedElement {
  role: string;
  probable_text: string[];
  probable_position: 'top' | 'center' | 'bottom' | 'sidebar' | 'modal';
  affordance: string;
  confidence: number;
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
  source: 'element_analysis' | 'world_model' | 'task_inference';
}
```

### World Model (simplified Matrix)

```typescript
interface SitePatternNode {
  id: string;
  type: 'site_pattern' | 'page_layout' | 'element_behavior' | 'flow_step' | 'error_pattern';
  content: string;
  domain?: string;
  url_pattern?: string;
  created_at: number;
  last_accessed: number;
  access_count: number;
  confidence: number;
  source: 'observation' | 'prediction_error' | 'consolidation';
}

interface PatternEdge {
  source_id: string;
  target_id: string;
  type: 'association' | 'causal' | 'affordance' | 'sequence';
  weight: number;
  action?: string;
  expected_outcome?: string;
  success_count: number;
  failure_count: number;
}
```

---

## Module Map

```
phantom/
  packages/
    core/                       # Cognitive pipeline (universal)
      src/
        imagination.ts          # Generate expected state before acting
        perception/
          visual.ts             # Screenshot + SoM via Claude/Lux/OmniParser
          analytical.ts         # DOM/a11y/macOS AX extraction
          reconciler.ts         # Merge views, handle disagreements
          temporal.ts           # Screen sampling over time (video model)
        affordance.ts           # Elements as action potentials
        diff.ts                 # Imagination vs reality
        planner.ts              # Affordance-aware action selection
        critic.ts               # Alignment check (Haiku)
        guard.ts                # Security membrane
        learner.ts              # Prediction-error-gated updates
        pipeline.ts             # Orchestrate full cycle
        types.ts                # Shared types

    world-model/                # The Matrix (simplified)
      src/
        store.ts                # SQLite graph
        nodes.ts                # SitePattern, PageLayout, ElementBehavior
        edges.ts                # Association, causal, affordance edges
        query.ts                # Spreading activation traversal
        update.ts               # Reconsolidation logic

    adapters/                   # Pluggable per-environment
      browser/                  # Browser adapter (MVP)
        playwright.ts           # Playwright/Patchright
        stealth.ts              # Camoufox/nodriver
        dom-perception.ts       # A11y tree extraction
      desktop/                  # Desktop adapter (future)
        macos-ax.ts
        applescript.ts
      screen/                   # Any-window adapter (future)
        screenshot.ts
        pyautogui.ts
      lux/                      # Lux (OpenAGI) adapter
        provider.ts             # ScreenshotProvider for Lux API
        handler.ts              # ActionHandler from Lux output

    interface/                  # How other tools connect
      mcp-server/               # MCP server for Claude Code
        server.ts
        tools.ts
        resources.ts
      cli/                      # Standalone CLI
        index.ts
      sandbox/                  # Filesystem sandbox
        workspace.ts            # Manages ~/.phantom/workspace/
        policy.ts               # Write permissions

    motor/                      # Human-like input system
      src/
        mouse.ts                # Bezier curves + Gaussian jitter
        keyboard.ts             # Per-char normal distribution delays
        scroll.ts               # Momentum-based scrolling
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
- Build reconciler (merge + disagreement detection)
- Add affordance layer
- Tiered perception (Tier 0-2)

### Phase 3: Dreaming
- Imagination engine (LLM-simulated expected state)
- Prediction error computation
- World model (SQLite graph)
- Learning loop (reconsolidation)
- Full Tier 0-3 perception

### Phase 4: Feeling
- Temporal perception (screen sampling, video model)
- Stealth mode (Patchright/Camoufox)
- Motor system (Bezier mouse, Gaussian typing)
- Lux integration as fast perception backend

### Phase 5: Speaking
- Alignment critic
- Full security membrane
- Credential vault
- CLI tool
- Desktop adapter (macOS)

---

## Novel Contributions (vs. literature)

Based on 8 research agents, ~65 papers, ~80 repos surveyed (2026-03-31):

| Contribution | Status in literature |
|---|---|
| Dual perception reconciler with principled disagreement handling | **Unpublished** — no paper or project does this |
| In-page spreading activation for element attention | **Unpublished** — all spreading activation work is document-level |
| Active inference framing for web navigation | **Completely unoccupied** in browser agent literature |
| Online causal graph building during live browsing | **Unpublished** — existing work is offline/simulation |
| Prediction-error-gated tiered perception (Kahneman dual-process for cost) | **Novel application** to browser agents |
| Associative Memory Three Planes applied to browser navigation | **Novel cross-pollination** |
| Alignment critic on every action | **Not shipped** by any existing framework |
| Temporal perception / video model for browser state | **Emerging** but not integrated with world models |

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

## Related Projects (Playful Sincerity)

- **Associative Memory** — the theoretical foundation (Three Planes, spreading activation, reconsolidation)
- **The Companion** — may eventually use Phantom as its visual perception layer
- **Spatial Workspace** — could visualize Phantom's world model as a 2D graph
- **Digital Core** — Phantom will be an MCP server accessible from Claude Code
