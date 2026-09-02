# `CompileFunction` retained-snapshot invalidation

Worktree: `D:\as-cta` (junction to
`.worktrees\refactor-as-canonical-typed-ast-compiler`)

Change: `refactor-as-canonical-typed-ast-compiler`  
Date: 2026-08-23

## Problem

The maintained legacy `asCModule::CompileFunction()` can successfully append
an executable function using `asCOMP_ADD_TO_MODULE`. Before this repair, a
module that had earlier retained a canonical AST continued to publish that
old snapshot as its *current* generation. Its declaration graph necessarily
omitted the newly added executable function.

That violates the meaning of `IsCurrentGeneration()`: a current public AST
must describe the module's complete executable declaration set, not merely
the last source-module `Build()`.

## Chosen safe boundary

Full canonical merge for one appended function is not implemented. Instead,
after a successful `CompileFunction(..., asCOMP_ADD_TO_MODULE, ...)`, the
module calls `ReleaseCanonicalASTSnapshot()` before completing the build
operation.

```text
full Build (retain)  --> current sealed snapshot A
                              |
CompileFunction ADD_TO_MODULE |--> executable function B is appended
                              |
                              +--> retire module-owned A
                                      |-- existing A leases: still readable
                                      `-- new AcquireASTSnapshot(V1): null

next full Build      --> complete sealed snapshot C, then publish C
```

The distinction is intentional:

- **Existing leases** retain their reference and remain valid read-only
  snapshots. Their `IsCurrentGeneration()` becomes false.
- **Fresh acquires** return null rather than a stale, incomplete AST.
- **A later full Build** is the only current implementation that creates and
  publishes a complete replacement snapshot.
- A failed or non-module `CompileFunction` does not invalidate a snapshot,
  because it has not changed the module declaration set.

This is fail closed with respect to public AST authority. It is safer than
pretending an incremental LEGACY compile has performed the canonical merge.

## Test-first evidence

The new real-engine SDK test
`CompileFunctionAddToModuleInvalidatesRetainedSnapshot` creates a retained
module with `F`, takes generation A, appends `Added` through
`asCOMP_ADD_TO_MODULE`, and independently checks all three observable facts:

1. the executable `int Added()` is on the module;
2. A is no longer current; and
3. a new V1 snapshot acquire is null.

The initial attempt to target an individual CQTest method omitted the CQTest
class component and therefore matched no Automation test. The class-prefix
run is the valid red evidence:

| Stage | Evidence | Result |
| --- | --- | --- |
| Test compile | `Saved/Build/build/20260823_050351_323_916b0165` | UBT succeeded; test was compiled into `Module.AngelscriptTest.15.cpp` |
| Discovery correction | `cta-compilefunction-snapshot-red/20260823_050428_342_342a7d54` | Invalid target spelling: no test matched; **not** treated as behavioral RED |
| Behavioral RED | `Saved/Tests/cta-compilefunction-snapshot-discovery/20260823_050525_343_1f88255e` | **5/6 passed, 1 failed**. The new test failed at `ADD_TO_MODULE must retire an incomplete retained AST generation`. |
| Implementation build | `Saved/Build/build/20260823_050617_426_f90fd552` | UBT `Result: Succeeded`, runner ExitCode `0` |
| Behavioral GREEN | `Saved/Tests/cta-compilefunction-snapshot-green/20260823_050654_103_65fb9c1b` | **6/6 passed**, 0 failures/skips |
| Standalone parity | `cta-compilefunction-snapshot-standalone-v2` / `Plugins/Angelscript/Standalone/out/build/win64-msvc/Testing/Temporary/LastTest.log` | **21/21** start rows and **21/21** `Test Passed.` rows; `AngelscriptStandalone.CanonicalAST` passed |

The first Standalone rerun intentionally exposed its obsolete expectation
that `CompileFunction` must keep a stale snapshot current. The corresponding
Standalone test now holds an old lease across the append, verifies that the
lease is retired-but-readable, and verifies that a new acquire is null. The
corrected full suite above is the final parity evidence.

## Scope and non-claims

- This does **not** route `CompileFunction` through Parser Sema actions,
  canonical sealing, or `asCBytecodeCodeGen`.
- It does **not** merge a fragment AST into an existing snapshot, republish a
  generation, or complete Task 3.4/3.7/10.3.
- It makes the public snapshot contract honest until such a complete merge
  protocol exists. Default compilation remains LEGACY.
- No OpenSpec checkbox is changed by this repair.
