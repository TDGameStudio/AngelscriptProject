# Missing raw-engine destruction repair

Date: 2026-07-27

## Scope

Implemented the minimum lifecycle repair for the 12 files classified as
`ChangeRequiredMissingEngineDestroy` in
`handoffs/fixture-and-large-file-quality-review.csv`.

No large-file split, class-owned fixture conversion, catalog/task change,
documentation rewrite, build, or automation test was performed.

## Change

Added a multiline scope guard immediately after each previously unguarded
case-local `FNativeTestEngine::Create()`:

```cpp
ON_SCOPE_EXIT
{
	Engine.Destroy();
};
```

The guard is declared before the script-engine pointer, module scope, raw
module, or execution context. C++ reverse destruction order therefore cleans
contexts/modules and their own scope guards first, then destroys the raw
engine last.

Existing equivalent guards were retained without duplication:

- the first method in `Language/AngelscriptNativeFunctionsTests.cpp`;
- the first raw-engine method in
  `TypeSystem/AngelscriptNativeDataTypeTests.cpp`;
- the paired source/comparison-engine cleanup in
  `Module/AngelscriptNativeRestorePrimitiveTests.cpp`.

## Files repaired

| File | Newly guarded `Engine.Create` paths |
| --- | ---: |
| `Language/AngelscriptNativeConversionsTests.cpp` | 5 |
| `Language/AngelscriptNativeFunctionsTests.cpp` | 3 |
| `Language/AngelscriptNativeReferencesTests.cpp` | 3 |
| `Language/Expressions/AngelscriptNativeExpressionValueCategoryTests.cpp` | 1 |
| `Language/Expressions/AngelscriptNativePrimaryExpressionTests.cpp` | 1 |
| `Language/References/AngelscriptNativeReferenceDirectionTests.cpp` | 2 |
| `Language/References/AngelscriptNativeReferenceFailureTests.cpp` | 1 |
| `Language/References/AngelscriptNativeReferenceIdentityTests.cpp` | 2 |
| `Language/References/AngelscriptNativeReferenceLifetimeTests.cpp` | 3 |
| `Language/References/AngelscriptNativeReferenceResolutionTests.cpp` | 1 |
| `Module/AngelscriptNativeRestorePrimitiveTests.cpp` | 6 |
| `TypeSystem/AngelscriptNativeDataTypeTests.cpp` | 1 |
| **Total** | **29** |

Post-change static accounting across the 12 files:

- ordinary `Engine.Create` paths: 32;
- multiline `Engine.Destroy` guards: 32;
- previously guarded paths retained: 3 ordinary paths;
- newly guarded paths: 29;
- paired `SourceEngine` / `ComparisonEngine` path remains covered by its
  existing joint scope guard.

## Verification

All requested static checks passed:

1. Scoped `git diff --check` for the five tracked target files: PASS.
2. Equivalent scoped `git diff --no-index --check` for the seven currently
   untracked target files: PASS, zero whitespace errors.
3. `AuditInlineAsFormatting.ps1 -RequireClean`: PASS.
   - raw sources: 295
   - conforming: 295
   - violations: 0
   - escaped-newline sources retained: 2
4. `AuditNativeSdkBoundaries.ps1 -RequireClean`: PASS.
   - violations: 0

The audit outputs were written to the system temporary directory, not to the
OpenSpec audit baselines.

Build and runtime test status: **not run by instruction**.
