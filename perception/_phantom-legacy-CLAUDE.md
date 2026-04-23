# Phantom — Visual Computer-Use Agent

## What This Is
A cognitive architecture for AI agents that see, imagine, and inhabit digital environments. Not just a browser agent — a visual computer-use agent for any window.

## Architecture
The cognitive loop: IMAGINE → OBSERVE → RECONCILE → DIFF → PLAN → CHECK → GUARD → ACT → LEARN

Three Planes (from Associative Memory):
- **Mirror** = Imagination (generates expectations, detects prediction errors)
- **Trees** = Dual Perception (visual + analytical cortex → reconciler)
- **Matrix** = World Model (SQLite graph, causal edges, spreading activation)

## Key Files
```
SPEC.md                          — Full architecture specification (source of truth)
README.md                        — Project overview and novel contributions
diagrams/phantom-architecture.d2 — Editable architecture diagram (D2)
diagrams/phantom-architecture.svg — Rendered architecture diagram
research/references.md           — Academic papers and GitHub repos surveyed
research/landscape.md            — Competitive landscape and open gaps
research/lux-analysis.md         — Lux (OpenAGI) analysis for integration
```

## Status
Research and architecture complete (2026-03-31). Implementation not started.

## Build Phases
1. **Walking** — Playwright + Claude Vision + MCP server + sandbox
2. **Seeing Double** — Dual perception + reconciler + affordances
3. **Dreaming** — Imagination engine + world model + learning loop
4. **Feeling** — Temporal perception + stealth + motor system + Lux integration
5. **Speaking** — Alignment critic + full security + CLI + desktop adapter

## Tech Stack (planned)
- TypeScript / Node.js / pnpm monorepo
- Playwright (browser), PyAutoGUI (any window), macOS AX (desktop)
- Claude Vision for perception, Haiku for alignment critic
- Lux (OpenAGI) as fast perception backend option
- SQLite for world model persistence
- MCP server for Claude Code integration

## Security Constraints
- Phantom writes ONLY to ~/.phantom/workspace/
- Credentials NEVER enter LLM context
- Every action checked by alignment critic before execution
- Web content structurally separated from instructions

## Cross-Pollination
- **Associative Memory** → Three Planes, spreading activation, reconsolidation, causal edges
- **The Companion** → cognitive dissonance detection, belief confidence, earned conviction
- **Spatial Workspace** → could visualize the world model graph

## Related
- ~/Playful Sincerity/PS Research/Associative Memory/ — theoretical foundation
- ~/Playful Sincerity/PS Software/The Companion/ — may adopt Phantom as visual layer
- Memory: ~/.claude/projects/-Users-wisdomhappy/memory/project_phantom.md
