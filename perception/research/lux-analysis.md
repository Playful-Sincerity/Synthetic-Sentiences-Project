# Lux (OpenAGI) Analysis

Researched 2026-03-31 for potential integration with GRP (then codenamed "Phantom").

## What It Is

A **foundation model purpose-built for computer use** — not a general LLM retrofitted with a browser plugin. Takes screenshots as input, outputs executable actions. Built by researchers from MIT, CMU, UIUC. CEO: Zengyi Qin.

**Key differentiator:** Trained from scratch to produce actions rather than text. Architecture optimized for perception-action loop, not conversation.

## Benchmarks

| Model | Mind2Web Score | Speed | Relative Cost |
|-------|--------------|-------|---------------|
| **Lux (OpenAGI)** | **83.6** | 1 sec/step | 1x |
| Google Gemini CUA | 69.0 | — | — |
| OpenAI Operator | 61.3 | 3 sec/step | 10x |
| Claude Sonnet 4 | 61.0 | — | — |

23-point lead over OpenAI Operator at 1/10th cost.

## Screen Sampling Architecture

Clean, pluggable loop:

1. **Capture** — Screenshot via PyAutoGUI (macOS/Win) or Flameshot (Linux). Multi-screen support via `ScreenManager`
2. **Compress** — JPEG at 85% quality, resize to 1260x700 (reduces token cost)
3. **Send** — Base64-encoded POST to Lux API
4. **Model output** — Structured actions (click coordinates, type strings, scroll amounts)
5. **Execute** — `AsyncPyautoguiActionHandler` (Python) or `robotjs` (TypeScript)
6. **Loop** — Repeat until task complete or max_steps

## Three Operational Modes

| Mode | Speed | Use Case |
|------|-------|----------|
| **Actor** (`lux-actor-1`) | ~1 sec/step | Fast, well-specified tasks |
| **Thinker** (`lux-thinker-1`) | Slower | Complex, vague, multi-step goals |
| **Tasker** | Controlled | Python list of todos, executed sequentially with retry |

## Training: Agentic Active Pre-training

Uses **OSGym** (open-source, MIT):
- 1,000+ OS replicas in parallel (Docker/VM-based)
- REST endpoints: `/reset`, `/step`, `/screenshot`, `/shutdown`
- 1,000+ data points/minute at scale
- ReplayBuffer + MultiTurnDataloader for batch training

## GitHub Repos

| Repo | Stars | License | Status |
|------|-------|---------|--------|
| agiopen-org/osgym | 138 | MIT | Stable (May 2025) |
| agiopen-org/lux-desktop | 48 | — | 3 releases (Dec 2025) |
| agiopen-org/oagi-python | 35 | MIT | Active (Feb 2026, v0.15.3) |
| agiopen-org/oagi-lux-samples | 8 | — | Examples (Dec 2025) |
| agiopen-org/stagehand (fork) | — | — | Signal: building browser integration |

## Integration with GRP

### How Lux fits

Lux is perception-action. Fast, accurate, but **reactive** (no imagination, no world model, no security membrane). GRP adds the cognitive layer:

```
GRP Cognitive Core (imagination, reconciler, planner, critic, guard)
    │
    ├── Claude Vision (deep understanding, expensive, slow)
    ├── Lux Actor (fast action grounding, 1sec, cheap)    ← HERE
    ├── OmniParser (screenshot → structured elements)
    └── Playwright a11y (DOM/structural, free)
```

### What to adopt
- **Pluggable interfaces**: `ScreenshotProvider` + `ActionHandler` pattern
- **Image compression defaults**: JPEG 85%, 1260x700
- **Three-mode design**: Actor/Thinker/Tasker abstraction
- **OSGym**: Future fine-tuning infrastructure (MIT, open source)

### What Lux doesn't have (GRP adds)
- Imagination before action (world model)
- Dual perception with reconciliation
- Affordance-native perception
- Security membrane / alignment critic
- Causal learning from interactions
- Persistent site knowledge graph

### Important limitation
Lux is a **closed model** accessed via API key (developer.agiopen.org). SDK is MIT, but model requires account. For full sovereignty, eventually want option to swap in open-weights alternatives.

### Reference integration: Kernel + OAGI
`github.com/kernel/kernel-oagi` shows the pattern:
- `KernelScreenshotProvider` — captures via Computer Controls API
- `KernelActionHandler` — converts Lux outputs to commands
- `KernelBrowserSession` — lifecycle with MP4 recording

GRP would follow same pattern with `GRPScreenshotProvider` + `GRPActionHandler`.
