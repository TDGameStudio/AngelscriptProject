# Frontend case-owned raw-engine lifecycle repair

Date: 2026-07-27

## Scope

This batch implements task 4.5 for the 11 `Frontend` files classified as
`ChangeRequiredClassOwnedMutableOrUnjustified` in
`handoffs/fixture-and-large-file-quality-review.csv`.

The change is intentionally limited to raw-engine fixture ownership:

- no large-file split;
- no test case, product marker, generated source, assertion condition, or
  expected result was added, removed, or changed;
- no production code was changed;
- no catalog, `tasks.md`, proposal, design, or specification was changed;
- no build or automation test was run.

## Lifecycle repair

The class-owned `inline static FNativeTestEngine`, `BEFORE_ALL`,
`BEFORE_EACH`, and `AFTER_ALL` fixtures were removed from all 11 files.

Each of the 82 test methods that actually accesses a raw engine now declares
its own engine and installs the cleanup guard immediately after `Create`:

```cpp
AngelscriptNativeTestSupport::FNativeTestEngine Engine;
Engine.Create(*TestRunner);
ON_SCOPE_EXIT
{
	Engine.Destroy();
};
```

The guard is declared before any raw engine pointer, module, builder, parser,
script code, script node, or context used by the case. Reverse C++ destruction
order therefore releases those dependent objects before `Engine.Destroy()`.
Early returns remain covered.

Two methods do not use a raw engine and intentionally remain fixture-free:

- `AngelscriptNativeParserCartesianDepthTests.cpp`:
  `ScriptCodeRowColumnCartesianProduct`;
- `AngelscriptNativeScriptNodeCoreTests.cpp`:
  `ScriptNodeCoreTypes`.

Static lifecycle reconciliation after the edit:

- files: 11;
- test methods: 84;
- methods accessing `Engine.Get()`: 82;
- case-owned `Engine.Create(*TestRunner)` calls: 82;
- matching multiline `Engine.Destroy()` guards: 82;
- remaining class-owned raw engines: 0;
- remaining `BEFORE_ALL` / `BEFORE_EACH` / `AFTER_ALL`: 0.

Existing parser and script-node helpers remain in place and continue to take
the engine pointer, test runner, or asserter explicitly. The engine-null
diagnostics were changed from “shared raw SDK engine” to “case-owned raw SDK
engine” so the test intention describes the new ownership accurately; the
assertion predicates and control flow are unchanged.

`AngelscriptNativeParserDeclarationsTests.cpp` also had a class-owned
`bArrayTemplateRegistered` flag whose validity depended on the former shared
engine. It was removed. `RegisterArrayTemplate` now registers the parser-only
template on the case-owned engine passed to it and directly returns the
registration assertion. Without this adjustment, a later fresh engine could
incorrectly skip its required registration.

## Files

| File | Test methods | Case-owned engines |
| --- | ---: | ---: |
| `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp` | 9 | 8 |
| `Frontend/AngelscriptNativeParserCoreTests.cpp` | 5 | 5 |
| `Frontend/AngelscriptNativeParserDeclarationsTests.cpp` | 18 | 18 |
| `Frontend/AngelscriptNativeParserErrorsTests.cpp` | 9 | 9 |
| `Frontend/AngelscriptNativeParserExpressionsTests.cpp` | 10 | 10 |
| `Frontend/AngelscriptNativeParserInternalTests.cpp` | 2 | 2 |
| `Frontend/AngelscriptNativeScriptNodeCopyTests.cpp` | 7 | 7 |
| `Frontend/AngelscriptNativeScriptNodeCoreTests.cpp` | 3 | 2 |
| `Frontend/AngelscriptNativeScriptNodeOwnershipDepthTests.cpp` | 2 | 2 |
| `Frontend/AngelscriptNativeScriptNodeShapeTests.cpp` | 13 | 13 |
| `Frontend/AngelscriptNativeScriptNodeSourceRangeTests.cpp` | 6 | 6 |
| **Total** | **84** | **82** |

At the time of this repair, eight target files were already tracked and
modified in the shared plugin worktree. The following three target files were
already untracked work:

- `AngelscriptNativeParserCartesianDepthTests.cpp`;
- `AngelscriptNativeParserInternalTests.cpp`;
- `AngelscriptNativeScriptNodeOwnershipDepthTests.cpp`.

No unrelated work in those files was reverted or rewritten.

## Static verification

All requested final static checks passed:

1. `ValidateCoverageCatalogs.ps1`
   - products: 316
   - expected cases: 46,407
   - current-fork cases: 46,261
   - future Disabled cases: 65
   - unique IDs: 46,407
2. `ReconcileNativeSdkSource.ps1 -RequireComplete`
   - products: 316
   - implemented: 315
   - Disabled implemented: 1
   - incomplete products: 0
   - methods: 685
   - product-owned methods: 311
   - explicit non-product methods: 374
   - unresolved methods: 0
3. `AuditNativeSdkBoundaries.ps1 -RequireClean`
   - violations: 0
4. `AuditInlineAsFormatting.ps1 -RequireClean`
   - raw sources: 295
   - conforming: 295
   - escaped-newline sources: 2
   - violations: 0
5. Scoped whitespace validation
   - tracked eight files: `git diff --check` passed;
   - untracked three files: equivalent `git diff --no-index --check` passed.
6. Dedicated lifecycle reconciliation
   - 84 methods inspected;
   - 82 engine consumers have exactly one local Create and Destroy;
   - the two fixture-free methods are the two intentional non-consumers;
   - no class fixture or CQTest lifecycle hook remains.

## Issue discovered during validation

The first attempt ran `ValidateCoverageCatalogs.ps1` and
`ReconcileNativeSdkSource.ps1` concurrently. Both use
`audits/expected-coverage.csv`; reconciliation observed that file while the
catalog validator was rewriting it and temporarily reported the unrelated
`RT-SCRIPTFUNCTION-REFERENCE-RELEASE` marker as unknown.

This was a validation-order race, not a source or catalog defect. Running the
validator first and reconciliation second produced the clean final result
listed above. Future validation should keep these two scripts sequential.

Build and runtime test status: **not run by instruction**.
