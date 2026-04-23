# Competitive Landscape & Open Gaps

Surveyed 2026-03-31. 8 research agents, ~80 repos analyzed.

## Existing Approaches

### Three Paradigms

| Paradigm | Champions | Tradeoff |
|----------|-----------|----------|
| **DOM-first** | playwright-mcp | Fast, token-efficient, deterministic. Misses visual elements |
| **Vision-first** | magnitude/browser-agent | Generalizes to any UI. Expensive, slower |
| **Dual** | browser-use, UI-TARS | Both benefits, higher complexity. Where the field is going |

### What Exists Today

**Consumer products:**
- Perplexity Comet (July 2025) — Full Chromium browser, autonomous navigation. Most documented security vulnerabilities
- ChatGPT Atlas (October 2025) — Agent Mode in every tab. Acknowledged as security-porous
- Google Chrome auto-browse (January 2026) — Gemini 3 powered
- Opera Neon (2025) — Four specialized agents

**Developer frameworks:**
- browser-use (85K stars) — LLM-agnostic, hybrid DOM+vision, 89.1% WebVoyager
- Playwright MCP (30K stars) — Accessibility-snapshot-based, Microsoft official
- Stagehand v3 — CDP-direct, self-healing selectors
- Browserbase / Steel — Cloud-hosted browser infrastructure

**Emerging:**
- WebMCP (Chrome 146, Feb 2026) — Browser-native API. Sites declare tools as schemas. 89% token efficiency improvement. Behind Chrome Canary flag.
- Lux (OpenAGI) — Purpose-built computer-use model. 83.6 on Mind2Web SOTA

## Confirmed Open Gaps

These are verified unoccupied territories based on literature survey + GitHub scout:

| Gap | Evidence | Phantom's Answer |
|-----|----------|-----------------|
| **Internal world model** | No OSS browser agent implements prediction before action | Imagination engine (WebDreamer-style, LLM as world model) |
| **Dual perception reconciler** | No paper has principled disagreement resolution | Reconciler treats disagreements as cognitive dissonance |
| **In-page spreading activation** | All spreading activation work is document-level | Goal-directed activation through page elements |
| **Active inference for web** | Zero results in browser agent literature | Prediction error as attention/learning signal |
| **Online causal learning** | All causal web papers learn offline/simulation | Real-time causal edge creation during browsing |
| **Affordance graph as planning structure** | No project builds explicit affordance state machine | Elements perceived as action potentials |
| **Graph-based navigation memory** | Every agent uses linear history or no memory | SQLite graph of site patterns (Matrix) |
| **Alignment critic** | Mentioned in papers, not shipped in any framework | Haiku check on every action |

## Anti-Detection Landscape (2026)

Modern detection operates in 5 layers. Bypassing one doesn't bypass the system:

1. **TLS Fingerprinting** — JA3/JA4+ analysis of ClientHello. Pre-JS, transport level
2. **CDP Protocol Detection** — Anti-bot vendors detect Chrome DevTools Protocol itself. Stealth plugins don't help
3. **Canvas/WebGL/Audio Fingerprinting** — GPU-specific rendering, cross-referenced for consistency
4. **Navigator/System Properties** — Composite fingerprint of screen, timezone, fonts, hardware
5. **Behavioral Analysis** — ML models on mouse trajectories, typing cadence, scroll patterns

**Key insight:** Fingerprint spoofing creates MORE detection signals than it removes (FP-Inconsistent, IMC 2025). Use real browsers, don't patch fake ones.

## Security Threat Landscape

### Documented Attacks (2025)
- **Perplexity Comet** — White-on-white text extracted credentials via Reddit comment
- **HashJack** — Malicious instructions in URL fragments (#)
- **Tainted Memories** — CSRF poisoned agent's long-term memory across sessions
- **Screenshot injection** — Invisible text in images readable by vision models
- **Task injection** — Tricks agent into believing malicious sub-task is legitimate

By the 10th fuzzing iteration, best agentic browsers fail to 58-74% of injection attempts.

### Best Defense: ceLLMate Architecture
- Sandboxes at HTTP layer (all side effects = HTTP requests)
- Agent-agnostic browser extension
- Collaborative permission model: developer policies + user task constraints
- Blocks WASP benchmark attacks at 7-15% latency overhead
