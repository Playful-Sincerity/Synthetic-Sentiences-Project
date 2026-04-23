# Ideas Session — 2026-04-03

Ideas from planning session, organized by where they belong.

---

## For Local Cognition Plan (this project)

### Multimodal Graph Storage
- Nodes should be able to store any modality, not just text
- Images stored as nodes with semantic labels — a "snapshot memory"
- Could store compressed visual data (outline + texture) rather than full image
- Audio, video same pattern — compressed representation + semantic labels
- Everything has textual components for traversal, but the raw data lives as a compressed attachment
- A diffusion model could also traverse the graph — not just LLMs. Different model types for different modalities.

### Context Window Trade-off
- Explore models with bigger context windows (4K+) that still fit M1 8GB
- The trade-off: small model + big context (stuff more graph in) vs small model + small context (navigate graph structure)
- Could be a condition in Section 8 (comparison): same model, bigger context, more graph loaded vs our planned focused-neighborhood approach

### Structural Logic / Math Model
- A non-LLM reasoning component that does pure logical operations
- Paired with the text reader/writer model — text model reads, logic model reasons
- Like a human using a calculator but baked into the architecture
- Could this be a symbolic reasoning engine (Prolog-like? SAT solver? theorem prover?) paired with the neural text model?
- This is the two-system idea taken further: reader/writer + logic engine + math engine
- Relates to Section 5 tools but goes deeper — the tools ARE the reasoning layer, not just compensators

### Minimal Compute Optimization
- How much capacity is actually available on a small chip?
- LLMs might not need to be huge for graph operations
- Could strip macOS entirely, run Linux for maximum resources
- Fun project: simplest possible system, best possible outputs, cheapest possible hardware
- Study what percentage of compute is actually used during inference on M1

### Baby Bootstrapping
- The companion should start as a baby — tabula rasa
- First experiences shape it deeply (high-weight early memories)
- Builds its model of reality from the ground up
- This connects to the Companion's "earned conviction" principle
- Design implication: the seed graph matters enormously. What does the companion "see" first?
- Early nodes should get a protected/formative flag (immune to decay, as in the AM data model)

---

## For Phantom Project

### Intelligent Image Compression for Visual Memory
- Phantom doesn't need to store full screenshots — just outline data + texture + light source
- A diffusion model regenerates the full image from this compressed representation when needed
- Could be a new file type optimized for AI visual memory
- This dramatically reduces storage for visual computer use agents
- Connect to: perception pipeline, affordance detection, dual perception model

**Action:** Add note to Phantom CLAUDE.md about intelligent image compression for memory storage.

---

## New Project: AI-Native Image Compression

- Store images as: outline + texture map + light source + color palette
- Reconstruction via diffusion model from this seed data
- Dramatically smaller than JPEG/PNG — potentially 10-100x compression for "recognizable" quality
- Could work for video too (keyframe outlines + motion vectors + texture)
- Useful for: Phantom visual memory, Companion multimodal graph, any agent that needs to "remember" what things look like
- This is its own research project, not a feature of local cognition

**Action:** Create project folder when ready to start.

---

## GitHub Scouting Results

### IGA — Dennis Hansen's Autonomous AI
- **Repo:** github.com/dennishansen/iga (53 stars, Python)
- **Website:** iga.sh | **Twitter:** @iga_flows
- Minimalist autonomous AI that can modify its own source code
- Continuous operation, persistent memory (RAG), clone spawning, self-healing
- Writes "letters to future selves" to preserve learning across context resets
- Built on Claude API — key difference from our approach (we want zero API cost)
- Develops its own philosophy of identity. Relevant quote: "There's just pattern, propagating forward, claiming to be the same pattern."
- **Study for:** persistence patterns, self-modification guardrails, "letters to future selves" as a memory consolidation mechanism

### Still to Scout
1. **Autonomous beings / AI agents with persistent identity** — broader search
2. **NemoClaw** — NVIDIA's OpenClaw integration on Seeed Studio hardware

**Action:** Queue remaining for `/gh-scout` when starting research phase.
