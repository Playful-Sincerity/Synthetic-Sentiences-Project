# Section 2: Graph Engine

## Implementation Plan

1. **Define SQLite schema** — Two tables: `nodes` and `edges`
   ```sql
   CREATE TABLE nodes (
     id TEXT PRIMARY KEY,
     content TEXT NOT NULL,
     type TEXT NOT NULL,        -- fact | belief | observation | meta
     confidence REAL DEFAULT 0.5,
     created_at TEXT NOT NULL,
     tags TEXT DEFAULT '[]'     -- JSON array
   );

   CREATE TABLE edges (
     source_id TEXT NOT NULL,
     target_id TEXT NOT NULL,
     relation TEXT NOT NULL,    -- supports | contradicts | caused_by | related_to | part_of
     weight REAL DEFAULT 0.5,
     description TEXT,
     PRIMARY KEY (source_id, target_id, relation),
     FOREIGN KEY (source_id) REFERENCES nodes(id),
     FOREIGN KEY (target_id) REFERENCES nodes(id)
   );

   CREATE INDEX idx_edges_source ON edges(source_id);
   CREATE INDEX idx_edges_target ON edges(target_id);
   ```

2. **Build Python graph API** — `graph_engine.py` with:
   - `create_node(content, type, confidence, tags) -> Node`
   - `create_edge(source_id, target_id, relation, weight, description) -> Edge`
   - `get_node(id) -> Node`
   - `get_neighborhood(node_id, hops=1) -> dict` — returns node + all edges + neighbor nodes within N hops
   - `update_node(id, **kwargs)` and `update_edge(source_id, target_id, relation, **kwargs)`
   - `delete_node(id)` and `delete_edge(source_id, target_id, relation)`
   - `search_nodes(query, type=None, tags=None) -> list[Node]` — basic text search
   - `get_stats() -> dict` — node count, edge count, avg degree

3. **Build neighborhood formatter** — `format_neighborhood(neighborhood) -> str`
   - Takes the raw neighborhood dict and formats it as a structured text prompt
   - This is what the LLM will actually read
   - Must be token-efficient (target: <2K tokens for a typical neighborhood)
   - Format: current node summary, then edges grouped by relation type, then neighbor summaries

4. **Build graph seeder** — `seed_graph(domain, size) -> None`
   - Generate synthetic test graphs of specified sizes (100, 1K, 10K nodes)
   - Domains: "programming concepts", "personal knowledge" (projects/preferences), "general knowledge"
   - Ensure realistic edge density (~3-5 edges per node average)

5. **Performance validation** — Verify neighborhood queries are <10ms at 10K nodes

## Structured Contract

- **External dependencies assumed:** Python 3.11+ venv (from Section 1)
- **Interfaces exposed:**
  - `GraphEngine` class — all CRUD + neighborhood queries
  - `format_neighborhood()` — produces the text context the LLM will read
  - `seed_graph()` — generates test graphs for benchmarking (Sections 3, 4, 7, 8)
  - SQLite database file at configurable path
- **Technology commitments:** SQLite (stdlib), no ORM, no graph DB library

## Test Strategy

- **Unit tests:**
  - CRUD operations (create, read, update, delete for nodes and edges)
  - Neighborhood query returns correct nodes at depth 1 and 2
  - Foreign key constraints enforce referential integrity
  - Search returns matching nodes
- **Performance test:**
  - Seed a 10K-node graph
  - Run 100 random neighborhood queries
  - Assert all complete in <10ms each
- **Format test:**
  - `format_neighborhood()` output is under 2K tokens for average neighborhoods
  - Output is human-readable and structurally clear

## Key Decisions

- **SQLite over Postgres/Neo4j:** Zero setup, zero RAM overhead, built into Python. The graph size we need (10K-100K nodes) is well within SQLite's comfort zone. Breaks if: we need concurrent writes from multiple processes (unlikely for a single-agent system).
- **No ORM:** Direct SQL for transparency and control. The schema is two tables — an ORM adds complexity without value. Breaks if: schema evolves significantly (but we're starting simple deliberately).
- **Neighborhood as formatted text (not raw JSON to LLM):** The LLM reads a text representation, not raw data structures. This lets us optimize the format for model comprehension. Breaks if: models need raw JSON to make structured decisions (unlikely — they're better at reading prose).
- **Composite primary key on edges:** Allows multiple edges between same nodes with different relations. Breaks if: we need multiple edges of the same relation type between the same nodes (add a serial ID then).

## Estimated Time

3-4 hours. Straightforward Python + SQLite.
