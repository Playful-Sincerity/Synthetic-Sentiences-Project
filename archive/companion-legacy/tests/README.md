# Tests

## Framework
**vitest** (TypeScript). Will be configured when implementation begins.

## Run Tests (planned)
```bash
npm test
```

## What to Test First
- Agent lifecycle: initialization, memory loading, shutdown
- Permission system: consent verification, boundary enforcement
- Memory graph: node creation, traversal, association formation

## Philosophy
- Smoke tests first, expand coverage as code grows
- auto-test.sh hook runs tests on Stop — tests must be discoverable
- Test files: `*.test.ts`
