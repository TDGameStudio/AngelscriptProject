# Canonical debug-line metadata contract gate — 2026-08-24

## Scope

This gate closes the immediate CanonicalAST frontend regression in
`CodeGenParserSourceEmitsDebugLinesAndMatchesLegacy` and improves the read-only
Bytecode diagnostic dump. It is evidence for the source-line portion of Task
9.6 only; local-variable tables, coverage/timeout roles, multi-section
transitions, exception tables, and the rest of `ScriptFunctionData` remain open.

## Red evidence and root cause

The isolated test failed at `FindNextLineWithCode(0) > 0`:

- `Saved/Tests/cta-debug-line-metadata-dump-red/20260824_143858_746_aa1d2954/Summary.json`

The enriched dump proved that Canonical CodeGen had already emitted a valid
line table:

```text
debug section=CanonSrc sectionIdx=0 declaredRow=1 declaredColumn=5 lineEntries=1 sectionTransitions=0
  line pc=0 row=1 column=11 encoded=11534337
```

`asCScriptFunction::FindNextLineWithCode` intentionally returns `-1` when the
query is before `declaredAt`. The regression was therefore a stale test
contract: row zero is outside a function declared on row one. It was not an
empty Canonical line table.

The old differential half had a second flaw. `CompileNativeModule()` observes
the Engine's current default, which is currently CANONICAL, so a module named
`LegacySrc` did not by itself prove legacy compilation.

## Change

`asCBytecodeCodeGenDumpFunction` now emits deterministic debug metadata before
the opcode list:

- primary logical section and section index;
- declared row and column;
- line-entry and section-transition counts;
- each program-position/row/column/encoded line tuple;
- each program-position/section-index transition.

The test now asserts the actual public contract:

1. querying row zero returns `-1` because it precedes `declaredAt`;
2. querying from the declared row finds the first executable row;
3. the comparison build explicitly selects `asCOMPILER_PIPELINE_LEGACY` and
   restores the previous selection before asserting;
4. the comparison module reports `asBYTECODE_PUBLISHER_COMPILER` and at least
   one legacy compiler invocation;
5. Canonical and LEGACY declaration rows, first executable rows, and execution
   results match.

## Green evidence

- Runtime/Editor build:
  `Saved/Build/cta-debug-line-contract-fix-build/20260824_144045_940_7da3077d/RunMetadata.json`
- Exact differential test: **1/1 PASS**
  `Saved/Tests/cta-debug-line-contract-green/20260824_144110_886_a9601a47/Summary.json`
- Complete Frontend CanonicalAST gate: **123/123 PASS**
  `Saved/Tests/cta-debug-line-frontend-canonical-final/20260824_144159_976_f375c071/Summary.json`

## Non-claims

This gate does not close Task 9.6. Canonical CodeGen still needs direct gates
for cross-section `sectionIdxs`, variable tables, coverage/timeout/safe-point
metadata, dependency relocations, exception/cleanup tables, and complete stack
and local publication.
