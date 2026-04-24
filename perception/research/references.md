# Research References

Papers and repos surveyed during the GRP architecture research sprint (2026-03-31, when the project was codenamed "Phantom").
8 parallel research agents, ~65 papers, ~80 repos.

## World Models for Browser Agents

| Paper | Year | Venue | Key Insight |
|-------|------|-------|-------------|
| WMA: Web Agents with World Models | 2024 | arXiv:2410.13232 | Transition-focused observation abstraction predicts how actions change pages |
| WebDreamer: LLM as World Model | 2024 | arXiv:2411.06559 | LLM "dreams" outcomes before committing. Zero-training-cost world model |
| MobileDreamer: Textual Sketch World Model | 2025 | arXiv:2601.04035 | Sparse text sketches suffice for effective world modeling |
| WebWorld: Large-Scale World Model | 2026 | arXiv:2602.14721 | 1M+ trajectory simulator. +9.2% on WebArena vs GPT-4o |
| CUWM: Computer-Using World Model | 2026 | arXiv:2602.17365 | Two-stage: predict semantic change, then visual change |
| DreamerV3 | 2023/2025 | arXiv:2301.04104 / Nature | Foundational world model architecture. RSSM + categorical latents |

## Visual Grounding

| Paper | Year | Venue | Key Insight |
|-------|------|-------|-------------|
| SeeAct: GPT-4V is a Generalist Web Agent | 2024 | ICML 2024 | Grounding is the bottleneck, not reasoning. 51.1% with grounding, drops without |
| Set-of-Mark (SoM) | 2023 | Microsoft Research | Numbered bounding boxes turn grounding into token prediction |
| OmniParser | 2024 | arXiv:2408.00203 | Screenshot to structured elements with interactability predictions |
| UGround | 2024 | ICLR 2025 Oral | Universal visual grounding on 10M UI elements. Up to 20% improvement |
| WebVoyager | 2024 | ACL 2024 | SoM-based: 59.1% vs 30.8% text-only. Quantifies vision value |
| CogAgent | 2024 | CVPR 2024 | Dual-resolution VLM for GUI agents |

## Benchmarks

| Benchmark | Year | Tasks | Current SOTA |
|-----------|------|-------|-------------|
| WebArena | 2023 | 812 long-horizon | 72.7% (trymeka/agent) vs 78.2% human |
| Mind2Web | 2023 | 2,000+ across 137 sites | 83.6% (Lux/OpenAGI) |
| VisualWebArena | 2024 | 910 visual-requiring | 16.4% best agent vs 88.7% human |
| MiniWoB++ | 2018 | 100+ synthetic | Largely solved |

## Agent Architectures

| Paper | Year | Venue | Key Insight |
|-------|------|-------|-------------|
| ReAct | 2022 | ICLR 2023 | Interleaved reasoning + acting. Foundation for all modern agents |
| OpAgent | 2026 | arXiv:2602.13559 | 71.6% WebArena SOTA. Reflector for error recovery |
| LATS | 2023 | ICML 2024 | Monte Carlo Tree Search over action sequences |
| WebAgent (Gur et al.) | 2023 | ICLR 2024 | Plan-summarize-program modular architecture |
| Survey of WebAgents | 2025 | KDD 2025 | Comprehensive survey, 100+ papers. Best starting point |
| V-GEMS | 2026 | arXiv:2603.02626 | Visual grounding + explicit memory for backtracking |

## Security

| Paper | Year | Key Insight |
|-------|------|-------------|
| BrowseSafe (Perplexity AI) | 2025 | 14,719 injection samples. Multi-layer defense. F1 0.904 |
| ceLLMate (UC San Diego) | 2025 | HTTP-layer sandboxing. Agent-agnostic browser extension |
| WASP | 2025 | Indirect prompt injection against real web agents |
| IntentGuard | 2024 | Intent analysis before action execution |
| ST-WebAgentBench | 2024 | Completion under Policy metric for enterprise safety |

## Active Inference & Causality

| Paper | Year | Key Insight |
|-------|------|-------------|
| EFE as Variational Inference | 2025 | Free energy reduces to prediction error |
| Robust Agents Learn Causal World Models | 2024 | Proved: generalizing agents must learn causal models |
| Language Agents Meet Causality | 2024 | Causal variables linked to language for LLM reasoning |
| Causality in Foundation World Models | 2024 | Causal reasoning necessary for long-horizon planning |
| DR-FREE | 2025 | Distributionally robust free energy for model uncertainty |

## Anti-Detection & Fingerprinting

| Paper | Year | Key Insight |
|-------|------|-------------|
| FP-Inconsistent | 2024 | Fingerprint spoofing creates MORE detection signals |
| TLS Fingerprinting (JA3/JA4+) | 2026 | TLS ClientHello analysis for bot detection |
| Browser Fingerprinting Survey | 2024 | Comprehensive fingerprinting technique catalog |
| Beyond the Crawl | 2025 | ML-based fingerprint detectors outperform heuristics |

## Key GitHub Repositories

### Browser Agent Frameworks
| Repo | Stars | License | Notes |
|------|-------|---------|-------|
| browser-use/browser-use | 85,354 | MIT | De facto community standard. Hybrid DOM+vision |
| microsoft/playwright-mcp | 30,074 | Apache-2.0 | A11y tree MCP server. Our analytical cortex |
| bytedance/UI-TARS-desktop | 29,186 | Apache-2.0 | True dual perception. MCP kernel |
| microsoft/OmniParser | 24,592 | CC-BY-4.0 | Screenshot to structured elements |
| browserbase/stagehand | 21,766 | MIT | Self-healing selectors. Auto-caching |
| trymeka/agent | 366 | MIT | 72.7% WebArena SOTA |

### Anti-Detection
| Repo | Stars | License | Notes |
|------|-------|---------|-------|
| daijro/camoufox | 6,546 | MPL-2.0 | C++-level fingerprint spoofing. Best-in-class |
| ultrafunkamsterdam/nodriver | 3,941 | AGPL-3.0 | CDP-free Chrome control |
| Kaliiiiiiiiii-Vinyzu/patchright | 2,748 | Apache-2.0 | Undetected Playwright drop-in |
| cdpdriver/zendriver | 1,201 | AGPL-3.0 | Async-first nodriver fork |
| Vinyzu/cursory | 89 | GPL-3.0 | Human-realistic mouse trajectories |

### Lux / OpenAGI
| Repo | Stars | License | Notes |
|------|-------|---------|-------|
| agiopen-org/osgym | 138 | MIT | Training infra. 1000+ parallel OS replicas |
| agiopen-org/lux-desktop | 48 | — | Tauri desktop client |
| agiopen-org/oagi-python | 35 | MIT | Main Python SDK. Actively maintained |

### MCP Servers
| Repo | Stars | License | Notes |
|------|-------|---------|-------|
| microsoft/playwright-mcp | 30,074 | Apache-2.0 | Official Microsoft |
| executeautomation/mcp-playwright | 5,377 | MIT | Community Playwright MCP |
| browserbase/mcp-server-browserbase | 3,216 | Apache-2.0 | Cloud browser sessions |
