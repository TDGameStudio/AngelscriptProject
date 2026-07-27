# Runtime and Module case-owned raw-engine lifecycle repair

Date: 2026-07-27

## Scope

This coherent task 4.5 batch handles exactly the 21 files classified as
`ChangeRequiredClassOwnedMutableOrUnjustified` under `Runtime` and `Module` in
`handoffs/fixture-and-large-file-quality-review.csv`:

- Runtime: 13 files;
- Module: 8 files.

`Runtime/AngelscriptNativeScriptFunctionReferenceTests.cpp` was explicitly
excluded because the `scriptobject_api_next` workstream is adding it
concurrently. It is not one of the 21 CSV rows and was not edited or used as a
patch target by this batch.

No file was split. No product code, catalog, task list, proposal, design, or
specification was changed. Existing product markers, cases, generated
AngelScript source, assertion predicates, and expected results were preserved.

## Lifecycle repair

All 21 class-owned `FNativeTestEngine` instances and their CQTest
`BEFORE_ALL`, `BEFORE_EACH`, and `AFTER_ALL` hooks were removed.

Each of the 49 `TEST_METHOD` cases now owns a raw engine:

```cpp
AngelscriptNativeTestSupport::FNativeTestEngine Engine;
Engine.Create(*TestRunner);
ON_SCOPE_EXIT
{
	Engine.Destroy();
};
```

The Destroy guard immediately follows the successful Create and is declared
before module, function, context, debug-recorder, callback, parser, script
object, or other engine-dependent case resources. Reverse C++ destruction
order therefore releases case resources before the raw engine. Early returns
are covered.

Static lifecycle reconciliation:

- target files: 21;
- test methods: 49;
- case-owned engine declarations: 49;
- immediate multiline Destroy guards: 49;
- remaining class-owned raw engines: 0;
- remaining fixture lifecycle hooks: 0.

`Module/AngelscriptNativeModuleApiContractTests.cpp` intentionally exercises
an explicit destroy-and-recreate transition inside
`UserDataTransitionsAndCleanup`. Consequently the source-wide Create/Destroy
call totals are 50/50 while method-owned guards remain 49/49. The final guard
owns the recreated engine and still covers every exit.

The module API user-data cleanup callback must be a non-capturing native
function pointer, so its callback observation fields remain class-static by
necessity. Their reset was moved from the deleted fixture hooks into the
owning `UserDataTransitionsAndCleanup` case, with an exit guard declared
before the engine guard. Destruction therefore occurs before callback
observation state is cleared.

The module API `PrintSource` helper was retained but no longer reaches through
the CQTest class to `TestRunner`; it now receives
`FAutomationTestBase& Test` explicitly, and every caller passes
`*TestRunner`. Other retained helpers already received their engine, runner,
asserter, context, module, or source dependencies explicitly.

## Files

| File | Test methods / case-owned engines |
| --- | ---: |
| `Module/AngelscriptNativeModuleApiContractTests.cpp` | 8 |
| `Module/AngelscriptNativeModuleBuildFailureTests.cpp` | 1 |
| `Module/AngelscriptNativeModuleFunctionTests.cpp` | 3 |
| `Module/AngelscriptNativeModuleImportTests.cpp` | 5 |
| `Module/AngelscriptNativeModuleLifecycleTests.cpp` | 7 |
| `Module/AngelscriptNativeModuleNamespaceTests.cpp` | 3 |
| `Module/AngelscriptNativeModuleSectionTests.cpp` | 5 |
| `Module/AngelscriptNativeModuleStateTableTests.cpp` | 2 |
| `Runtime/AngelscriptNativeContextAccessorDepthTests.cpp` | 1 |
| `Runtime/AngelscriptNativeScriptObjectLifecycleDepthTests.cpp` | 3 |
| `Runtime/Debug/AngelscriptNativeCallbackLifecycleTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeCallstackTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeExceptionCaughtQueryTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeFunctionDebugMetadataTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeInstructionPhaseDepthTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeLineCallbackSourceTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeLocalVariableTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeNestedContextDepthTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeNestedContextTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeStackPopCallbackDepthTests.cpp` | 1 |
| `Runtime/Debug/AngelscriptNativeThisPointerTests.cpp` | 1 |
| **Total** | **49** |

At verification time, seven target files were tracked and modified in the
shared plugin worktree; fourteen target files were pre-existing untracked
work. This batch did not revert or rewrite unrelated changes in either group.

## Ordered static verification

The checks were deliberately run sequentially because
`ValidateCoverageCatalogs.ps1` writes the CSV consumed by
`ReconcileNativeSdkSource.ps1`.

1. `ValidateCoverageCatalogs.ps1`: PASS
   - products: 318
   - expected cases: 46,426
   - current-fork cases: 46,280
   - future Disabled cases: 65
   - unique IDs: 46,426
2. `ReconcileNativeSdkSource.ps1 -RequireComplete`: PASS
   - products: 318
   - implemented: 317
   - Disabled implemented: 1
   - incomplete products: 0
   - methods: 687
   - product-owned methods: 313
   - explicit non-product methods: 374
   - unresolved methods: 0
3. `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS
   - violations: 0
4. `AuditInlineAsFormatting.ps1 -RequireClean`: PASS
   - raw sources: 296
   - conforming: 296
   - escaped-newline sources: 2
   - violations: 0
5. Scoped whitespace validation: PASS
   - seven tracked targets: `git diff --check`;
   - fourteen untracked targets: equivalent
     `git diff --no-index --check`.
6. Dedicated lifecycle reconciliation: PASS
   - 49 methods;
   - 49 local engine declarations;
   - 49 immediate multiline Destroy guards;
   - zero class-owned engines or fixture hooks.

The catalog and method counts increased from the preceding Frontend batch
because another scoped workstream landed additional cataloged Runtime source
in the shared workspace before these ordered checks. This batch did not edit
that source or its catalog records.

Build and runtime test status: **not run by instruction**.
