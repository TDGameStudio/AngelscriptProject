# Current state audit: SDK namespace consolidation

Date: 2026-07-06

## Current source inventory

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/` currently has 76 `.cpp` files.
- 75 of those files contain at least one `TEST_METHOD` definition.
- The directory contains 433 source-level `TEST_METHOD` definitions.
- These are source counts only. They are not a fresh Automation pass count.

## Structural cleanup evidence

- Source-level `ASSDK` naming residue is gone from `Plugins/Angelscript/Source` for files/classes/helpers/automation IDs. The only current matches are prose references in `TESTING_GUIDE.md` and `TESTING_GUIDE_ZH.md` that say `ASSDK/raw SDK`.
- `AngelscriptTest_*_Private` namespaces are gone from `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK`.
- Shared SDK support exists:
  - `AngelscriptNativeTestSupport.h`: native engine, module, tokenizer/parser/bytecode, save/load, and diagnostic helpers.
  - `AngelscriptSDKTestExecutionHelpers.h`: `FSdkFunctionInvoker`, `ExecuteScriptFunction<T>()`, and `ExecuteScriptVoidFunction()`.
  - `AngelscriptSDKTestUtilities.h`: compatibility aliases for older helper names.
- `AngelscriptSDKOperatorTests.cpp` contains test methods for arithmetic, comparison, logical, bitwise, assignment, ternary, pow, call, index, precedence, and short-circuit behavior.

## Current gaps not owned by this refactor

These are real SDK test issues, but they are behavior coverage or prerequisite work rather than namespace/helper consolidation.

### Compile-only or metadata-only behavior cases

- `AngelscriptObjectTests.cpp`: `ValueType`, `ConstructorChain`, and `NativeFloatWrapper` still resolve functions such as `CopyObjectValue()`, `ConstructNestedMember()`, and `StoreNativeFloat()` without executing the behavior.
- `AngelscriptOOPTests.cpp`: `MixinNamespace` and `InheritedInterfaceMethod` compile/resolve script functions, but they do not prove runtime OOP behavior on the bare engine.
- `AngelscriptSDKTypeTests.cpp`: `Auto` still resolves `CreateAutoValue()` without executing it.
- `AngelscriptConversionTests.cpp`: `ImplicitValueType` still resolves `ConvertTestToInt()` without executing it.
- `AngelscriptRuntimeTests.cpp`: `Suspend` still behaves like an aggregate `Entry()` execution check rather than a true suspend/resume test.

### Disabled native SDK files

- `AngelscriptAtomicTests.cpp` is disabled with `#if WITH_ANGELSCRIPT_UNITTESTS && 0` because `asCAtomic` symbols are not exported from `AngelscriptRuntime`.
- `AngelscriptThreadTests.cpp` is disabled with `#if WITH_ANGELSCRIPT_UNITTESTS && 0` because `asCThreadManager` symbols are not exported from `AngelscriptRuntime`.
- `AngelscriptStringUtilTests.cpp` is disabled with `#if WITH_ANGELSCRIPT_UNITTESTS && 0` because its `RegisterStringFactory` usage follows a newer API shape than this 2.33-derived fork currently exposes.

### Bare-engine boundary cases

- Script-reference-class operator runtime cases such as `opCall` and `opIndex` currently compile and resolve wrapper functions, but bare-engine execution is constrained by script reference-class instantiation behavior.
- String concatenation should not be claimed as implemented in the operator matrix while string runtime support remains disabled.
- Thiscall execution remains a separate investigation item because previous notes mention a fork crash.

## Verification status

No fresh clean SDK prefix run is recorded by this audit.

The previous OpenSpec task list contained old evidence from 2026-06 (`342/342 PASS`) and should not be treated as current proof. A later local attempt during this evaluation discovered 421 tests for `Angelscript.TestModule.AngelScriptSDK`, but the editor exited with process exit code `-1` before a clean report summary was produced.

Before archiving with a fresh pass claim, run:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK" -Label sdk-namespace-consolidation-archive -TimeoutMs 1200000
```

If that run exits early again, archive can still be considered for record accuracy, but the final note must say no fresh SDK pass was established.

## Recommended follow-up split

- Keep `refactor-as-sdk-test-namespace-consolidation` as the structural cleanup record.
- Create a future `test-as-sdk-behavior-coverage` change for compile-only behavior cases, runtime-control semantics, script-class limitations, and broader semantic coverage.
- Create smaller prerequisite changes for disabled string, atomic, and thread tests if those need linkage or API compatibility work before behavior tests can run.
