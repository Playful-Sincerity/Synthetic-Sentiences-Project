# Phantom

**A cognitive architecture for AI agents that see, imagine, and inhabit digital environments.**

Phantom is a visual computer-use agent. It goes out, sees any window — browser, desktop app, any screen — interacts with it, and reports back. It's not a script that pokes at a DOM. It's a small mind that inhabits a screen.

## What makes it different

Every existing browser/computer-use agent is **reactive**: observe, decide, act, repeat. They process each page from scratch — no expectations, no memory, no sense of what elements afford, no internal model that gets surprised.

Phantom is **predictive**:

```
IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN
```

- **Imagines** what it expects to see before looking
- **Perceives** through dual channels (visual + structural) simultaneously
- **Reconciles** disagreements between perception modes as informative signals
- **Understands** pages as fields of affordances (action potentials, not just elements)
- **Learns** from the gap between prediction and reality

The prediction error is the primary learning and attention signal.

## Architecture

![Phantom Architecture](diagrams/phantom-architecture.svg)

### The Three Planes (from Associative Memory theory)

| Plane | Role in Phantom |
|-------|-----------------|
| **The Mirror** | Imagination layer — generates expectations, detects prediction errors |
| **The Trees** | Dual perception — visual cortex + analytical cortex → reconciler → page model |
| **The Matrix** | World model — SQLite graph of site patterns, causal edges, learned affordances |

### Novel contributions

Based on a survey of ~65 papers and ~80 repos (March 2026):

| Contribution | Status in literature |
|---|---|
| Dual perception reconciler with principled disagreement handling | Unpublished |
| In-page spreading activation for element attention | Unpublished |
| Active inference framing for web navigation | Completely unoccupied |
| Online causal graph building during live browsing | Unpublished |
| Prediction-error-gated tiered perception | Novel application |
| Alignment critic on every action | Not shipped by any framework |

### Tiered perception (cost management)

| Tier | What runs | Cost | When |
|------|-----------|------|------|
| T0 Reflex | DOM-only check | 0 tokens | Confirming, waiting |
| T1 Glance | DOM + a11y (Haiku) | ~500 tokens | Familiar pages |
| T2 Look | Screenshot + SoM (Sonnet) | ~2K tokens | New pages |
| T3 Study | Full imagination pipeline | ~5K tokens | First visits, critical steps |

### Security model

- Writes ONLY to `~/.phantom/workspace/` — never edits existing files
- Credentials never enter the LLM context (filled via credential broker)
- Alignment critic (Haiku) checks every action against original intent
- HTTP-layer sandbox for network-level enforcement
- Content isolation: web content and instructions are structurally separated

### Pluggable backends

**Perception:** Claude Vision, Lux (OpenAGI), OmniParser, Playwright a11y, macOS Accessibility API

**Action:** Playwright/Patchright, Camoufox, nodriver, PyAutoGUI, macOS AppleScript

**Adapters:** Browser (MVP), Desktop, Any Window

## Use cases

- **Verification** — "Go check if my deploy looks right"
- **Tool interaction** — "Log into n8n and check the last 5 workflow runs"
- **Visual QA** — "Does this page match the Figma mock?"
- **Code verification** — Write code → Phantom checks the preview → reports misalignments → iterate
- **Temporal verification** — "Does the loading animation feel smooth?" (screen sampling over time)

## Status

Research and architecture complete. Implementation not yet started.

See [SPEC.md](SPEC.md) for the full architecture specification.

## Research foundation

The architecture draws from 8 parallel research agents surveying:
- ~65 academic papers (world models, visual grounding, active inference, browser security, affordances)
- ~80 GitHub repositories (browser agents, anti-detection, MCP servers, stealth tools)
- Cross-pollination from two related PS Research projects (Associative Memory, The Companion)

Key references in [research/](research/).

## Part of Playful Sincerity

Phantom is a [Playful Sincerity](https://playfulsincerity.org) Software project. It draws from the Associative Memory architecture (PS Research) and may eventually serve as the visual perception layer for The Companion (PS Software).

## License

MIT
