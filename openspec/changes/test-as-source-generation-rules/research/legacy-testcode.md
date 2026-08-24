# Legacy `FAngelscriptTestCode` Experiment

## Evidence boundary

This evidence was read from the old dirty `script-corpus` worktree and is research-only. That worktree is not modified or treated as current main source.

Key files:

- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestCode.h`
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestCode.cpp`
- `openspec/changes/test-as-testcode-bindings2-entry/_inventory-scan.json`

## What was useful

- `FAngelscriptTestCode` is a clear, compact name for C++ access to AS test code.
- Stable logical CaseKeys and memory virtual paths separated test identity from physical disk paths.
- A common descriptor attempted to unify source, category, execute declaration, expectations, diagnostics, and tags.
- Lookup/enumeration APIs showed the value of one C++ entry point for test code.
- The experiment proved large-scale mechanical extraction was feasible: its snapshot recorded 189 TestCode `.cpp` files, 2,161 registrars, and 2,163 AS bodies.

## What was too shallow or coupled

### Oracle model

The enum centered on `ExecuteAndExpectInt`, `ExecuteAndExpectException`, compile success/failure, and custom C++ assertions. The snapshot had 85 `ExecuteAndExpectInt`, one exception case, 337 compile failures, and 1,738 custom assertions. `ExpectedInt` plus one diagnostic string could not describe the actual return/metadata/writeback/lifecycle surface.

The snapshot itself demonstrates the mismatch: global functions included bool, signed/unsigned widths, float/double, FString/FName/FText, FVector/FRotator/FTransform/FQuat/FLinearColor/FColor, UObject, and void, while most complex observations remained hidden behind `CustomCppAssert`.

### Registration architecture

`FAngelscriptTestCodeCase` constructors populated a mutable global `TMap` through static registration and also registered into a snippet index. This makes availability dependent on translation-unit linking/initialization and encourages ForceLink plumbing. The new release design uses generated named static functions and a generated immutable sorted table instead.

### Corpus/index coupling

The implementation depended on `AngelscriptTestScriptCorpus`, snippet records, canonical tags, virtual paths, and store/origin registration. Those concepts mixed source ownership, runtime loading, test dispatch, and experimental corpus migration. The new design returns a complete value and leaves runner integration for a later adoption change.

### Generated granularity

The experiment mechanically created thousands of registrar bodies. The new design emits one function per fixture/product and stores expanded cells as result data, limiting plugin C++ bloat.

## Retained and rejected decisions

| Decision | Outcome |
| --- | --- |
| Class name `FAngelscriptTestCode` | Retained |
| Logical CaseKeys | Retained and specified independently of virtual paths |
| One common C++ access surface | Retained |
| Static registrar constructors | Rejected |
| Mutable global registry | Rejected |
| ForceLink/load-order discovery | Rejected |
| `ExpectedInt` as primary oracle | Rejected |
| Corpus/snippet-index ownership in the value API | Rejected |
| One C++ registration body per extracted source/cell | Rejected |
| Existing current-test replacement as part of generation | Rejected for this change |

## Conclusion

The experiment is valuable architecture evidence, not code to copy wholesale. The new `FAngelscriptTestCode` keeps the recognizable access concept while changing its data depth, generation ownership, linkage model, and adoption boundary.
