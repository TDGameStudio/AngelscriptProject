## Why

`FunctionReview_UASFunction_*` reports identify high-risk `UASFunction` dispatch paths: direct optimized calls, BPVM/Parms wrappers, JIT/non-JIT handoff, virtual dispatch, and metadata predicates. Existing tests mostly prove positive smoke paths, so regressions in ABI-sensitive wrappers or stale-function fallback behavior can still escape.

## What Changes

- Add focused runtime-integration coverage for `UASFunction` direct optimized calls, including primitive edge values, reference writeback, exception/default fallback, and discard/stale behavior.
- Add wrapper ABI coverage for `ProcessEvent` / `RuntimeCallFunction` and direct `RuntimeCallEvent` across byte, bool, dword, qword, float, double, object-return, primitive-return, and reference shapes.
- Add virtual dispatch coverage proving optimized/JIT-capable paths do not bypass script overrides.
- Extend metadata predicate/source metadata tests for AS-generated function/property/world-context classification and stale metadata behavior.
- No breaking API or behavior changes are intended; production code changes are limited to minimal fixes or test-only helpers if tests expose a defect.

## Capabilities

### New Capabilities

- `uasfunction-runtime-dispatch-coverage`: Regression coverage for `UASFunction` runtime dispatch, optimized direct calls, wrapper ABI behavior, virtual resolution, and metadata predicates.

### Modified Capabilities

- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptTest/ClassGenerator/`: expands ASFunction-focused runtime integration tests.
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/`: may receive small test-only helpers if needed to avoid duplicate reflected-parameter boilerplate.
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.*`: only touched if new regression tests expose a real behavior defect or if a narrowly scoped test-only hook is required.
