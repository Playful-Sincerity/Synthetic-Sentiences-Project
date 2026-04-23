# Session Briefs — Local Cognition Research

Self-contained session briefs for parallel execution of the research streams.

## Dependency Graph

```
Session A: Setup + Graph Engine (S1+S2)     ← START HERE, FIRST
    │
    ├──→ Session B: Structured Output (S3)   ← needs A complete
    │        │
    │        ├──→ Session D: Traversal (S4)  ← needs B + C(graph gen)
    │        │        │
    │        │        ├──→ Session F: Tool Compensation (S5b)
    │        │        │        │
    │        │        │        └──→ Session G: Cognitive Loop (S6)
    │        │        │                 │
    │        │        │                 └──→ Session H: Prototype (S9)
    │        │        │
    │        ├──→ Session E: Tool Validator (S5a)  ← needs B only
    │        │
    ├──→ Session C: Scaling + Graph Gen (S7) ← needs A, parallel with B
    │
    └──→ Session C also feeds into D (graph generator)
    
    Session I: Graph vs RAG (S8)            ← needs A only, fully parallel
```

## Execution Order

**Wave 1 (parallel):** A
**Wave 2 (parallel):** B, C, I  (all need only A)
**Wave 3 (parallel):** D + E    (D needs B+C, E needs B)
**Wave 4:** F                    (needs D)
**Wave 5:** G                    (needs F)
**Wave 6:** H                    (needs everything)

## Session Brief Files

| File | Sections | Wave | Est. Time |
|------|----------|------|-----------|
| `session-A-foundation.md` | S1 + S2 | 1 | 1 day |
| `session-B-structured-output.md` | S3 | 2 | 4-5 days |
| `session-C-scaling.md` | S7 (+ graph generator) | 2 | 2-3 days |
| `session-D-traversal.md` | S4 | 3 | 8-12 days |
| `session-E-tool-validator.md` | S5a (T6 only) | 3 | 1-2 days |
| `session-F-tool-compensation.md` | S5b (T1-T5, T7) | 4 | 3-5 days |
| `session-G-cognitive-loop.md` | S6 | 5 | 3-5 days |
| `session-H-prototype.md` | S9 | 6 | 5-7 days |
| `session-I-comparison.md` | S8 | 2 | 3-4 days |
