# Angelscript Test Conventions & Macro Guide

## Overview

This project uses a two-layer macro system defined in `Shared/AngelscriptTestMacros.h` to reduce test boilerplate. All test files still use `IMPLEMENT_SIMPLE_AUTOMATION_TEST` for test declaration, but engine creation and lifecycle management are handled by macros.

## Macro Quick Reference

### Layer 1: Engine Creation (`ASTEST_CREATE_ENGINE_*`)

| Macro | Returns | Description |
|-------|---------|-------------|
| `ASTEST_CREATE_ENGINE_FULL()` | `FAngelscriptEngine&` | Fresh isolated Full engine. Full bind environment, supports hot-reload testing. |
| `ASTEST_CREATE_ENGINE_SHARE()` | `FAngelscriptEngine&` | Shared cached Full test engine. Reuses the existing shared engine without resetting it. |
| `ASTEST_CREATE_ENGINE_SHARE_CLEAN()` | `FAngelscriptEngine&` | Shared cached Full test engine with `AcquireCleanSharedCloneEngine()` semantics before use. |
| `ASTEST_CREATE_ENGINE_SHARE_FRESH()` | `FAngelscriptEngine&` | Shared cached Full test engine with `AcquireFreshSharedCloneEngine()` semantics before use. |
| `ASTEST_CREATE_ENGINE_MODULE_CLEAN()` | `FAngelscriptEngine&` | Module-level cached source engine. Cleans only module/class deltas created inside the matching lifecycle scope and batches GC. |
| `ASTEST_CREATE_ENGINE_CLONE()` | `FAngelscriptEngine&` | Lightweight isolation. Shares source engine read-only state (bindings, types). |
| `ASTEST_CREATE_ENGINE_NATIVE()` | `asIScriptEngine*` | Raw AngelScript SDK engine, no FAngelscriptEngine wrapper. |
| `ASTEST_CREATE_ENGINE_BARE()` | `asCScriptEngine*` | Internal SDK engine for AngelScriptSDK tests. No UE bindings, minimal config. |

### Layer 2: Lifecycle (`ASTEST_BEGIN_* / ASTEST_END_*`)

| BEGIN / END | Scope | Cleanup |
|-------------|-------|---------|
| `ASTEST_BEGIN_FULL` / `ASTEST_END_FULL` | Creates `FAngelscriptEngineScope` | Auto-discards all active modules |
| `ASTEST_BEGIN_SHARE` / `ASTEST_END_SHARE` | Creates `FAngelscriptEngineScope` for the shared engine | None (modules accumulate) |
| `ASTEST_BEGIN_SHARE_CLEAN` / `ASTEST_END_SHARE_CLEAN` | Creates `FAngelscriptEngineScope` after clean shared-engine reacquire | None (reset semantics come from `ASTEST_CREATE_ENGINE_SHARE_CLEAN()`) |
| `ASTEST_BEGIN_SHARE_FRESH` / `ASTEST_END_SHARE_FRESH` | Creates `FAngelscriptEngineScope` after fresh shared-engine reacquire | None (reset semantics come from `ASTEST_CREATE_ENGINE_SHARE_FRESH()`) |
| `ASTEST_BEGIN_MODULE_CLEAN` / `ASTEST_END_MODULE_CLEAN` | Creates `FAngelscriptEngineScope` and captures a module baseline | Discards only active/raw AS modules created in the scope; clears detached `UASClass` root/standalone flags; GC is batched |
| `ASTEST_BEGIN_CLONE` / `ASTEST_END_CLONE` | Creates `FAngelscriptEngineScope` | Auto-discards all active modules |
| `ASTEST_BEGIN_NATIVE` / `ASTEST_END_NATIVE` | Validates non-null pointer | Auto `ShutDownAndRelease` |
| `ASTEST_BEGIN_BARE` / `ASTEST_END_BARE` | Validates non-null `asCScriptEngine*` pointer | Auto `ShutDownAndRelease` |

For the `SHARE` family, `ASTEST_BEGIN_*` is currently the canonical place to establish the engine scope, while `ASTEST_END_*` is intentionally kept as the paired lifecycle closeout point for future global control.

### Helper Macros

| Macro | Description |
|-------|-------------|
| `ASTEST_COMPILE_RUN_INT(Engine, ModuleName, Source, FuncDecl, OutResult)` | Compile + get function + execute int, returns false on failure |
| `ASTEST_COMPILE_RUN_INT64(Engine, ModuleName, Source, FuncDecl, OutResult)` | Same as above for int64 |
| `ASTEST_BUILD_MODULE(Engine, ModuleName, Source, OutModulePtr)` | Compile only, sets OutModulePtr, returns false on failure |

## Decision Tree: Which Macro to Use

```
Need to test engine core / bind environment / hot-reload?
  YES --> ASTEST_CREATE_ENGINE_FULL + BEGIN/END_FULL

Lightweight compile-and-execute, no isolation needed?
  YES --> ASTEST_CREATE_ENGINE_SHARE + BEGIN/END_SHARE

Need cached bind/type database behavior, but only this test's module/class delta must be cleaned?
  YES --> ASTEST_CREATE_ENGINE_MODULE_CLEAN + BEGIN/END_MODULE_CLEAN

Need shared full-engine behavior but must reset shared state first?
  YES --> ASTEST_CREATE_ENGINE_SHARE_CLEAN + BEGIN/END_SHARE_CLEAN

Need shared full-engine behavior and full shared/global teardown before reacquire?
  YES --> ASTEST_CREATE_ENGINE_SHARE_FRESH + BEGIN/END_SHARE_FRESH

Need isolation but don't want Full engine cost?
  YES --> ASTEST_CREATE_ENGINE_CLONE + BEGIN/END_CLONE

Testing raw AngelScript SDK APIs?
  YES --> ASTEST_CREATE_ENGINE_NATIVE + BEGIN/END_NATIVE

Testing AngelScript SDK internal classes (asCBuilder, asCByteCode, asCParser)?
  YES --> ASTEST_CREATE_ENGINE_BARE + BEGIN/END_BARE

Testing engine creation itself / multi-engine interaction / production engine?
  YES --> Use IMPLEMENT_SIMPLE_AUTOMATION_TEST directly, no macros.
```

## Usage Examples

### FULL Engine Test

```cpp
#include "Shared/AngelscriptTestMacros.h"

IMPLEMENT_SIMPLE_AUTOMATION_TEST(
    FMyFullEngineTest,
    "Angelscript.TestModule.Category.Feature",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter)

bool FMyFullEngineTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_FULL();
    ASTEST_BEGIN_FULL

    int32 Result = 0;
    ASTEST_COMPILE_RUN_INT(Engine, "MyModule",
        TEXT("int Run() { return 42; }"),
        TEXT("int Run()"), Result);

    TestEqual(TEXT("Should return 42"), Result, 42);

    ASTEST_END_FULL
    return true;
}
```

### SHARE Engine Test

```cpp
bool FMyShareEngineTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE();
    ASTEST_BEGIN_SHARE

    int32 Result = 0;
    ASTEST_COMPILE_RUN_INT(Engine, "MyModule",
        TEXT("int Run() { return 7; }"),
        TEXT("int Run()"), Result);

    TestEqual(TEXT("Should return 7"), Result, 7);

    ASTEST_END_SHARE
    return true;
}
```

### SHARE_CLEAN Engine Test

```cpp
bool FMySharedResetTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_CLEAN();
    ASTEST_BEGIN_SHARE_CLEAN

    int32 Result = 0;
    ASTEST_COMPILE_RUN_INT(Engine, "MySharedResetModule",
        TEXT("int Run() { return 17; }"),
        TEXT("int Run()"), Result);

    ASTEST_END_SHARE_CLEAN
    return TestEqual(TEXT("Shared clean engine should start from a reset state"), Result, 17);
}
```

### MODULE_CLEAN Engine Test

```cpp
bool FMyModuleCleanTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_MODULE_CLEAN();
    ASTEST_BEGIN_MODULE_CLEAN

    int32 Result = 0;
    ASTEST_COMPILE_RUN_INT(Engine, "MyModuleCleanModule",
        TEXT("int Run() { return 23; }"),
        TEXT("int Run()"), Result);

    ASTEST_END_MODULE_CLEAN
    return TestEqual(TEXT("Module-clean engine should clean this test's module delta"), Result, 23);
}
```

### SHARE_FRESH Functional-Style Test

```cpp
bool FMySharedFreshTestCaseTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_SHARE_FRESH();
    ASTEST_BEGIN_SHARE_FRESH

    // Keep explicit module teardown/reset logic when the test semantics require it.
    ASTEST_END_SHARE_FRESH
    return true;
}
```

### CLONE Engine Test

```cpp
bool FMyCloneEngineTest::RunTest(const FString& Parameters)
{
    FAngelscriptEngine& Engine = ASTEST_CREATE_ENGINE_CLONE();
    ASTEST_BEGIN_CLONE

    // Engine is isolated but shares bindings with source engine
    int32 Result = 0;
    ASTEST_COMPILE_RUN_INT(Engine, "MyModule",
        TEXT("int Run() { return 99; }"),
        TEXT("int Run()"), Result);

    TestEqual(TEXT("Should return 99"), Result, 99);

    ASTEST_END_CLONE
    return true;
}
```

### NATIVE SDK Test

```cpp
bool FMyNativeTest::RunTest(const FString& Parameters)
{
    asIScriptEngine* NativeEngine = ASTEST_CREATE_ENGINE_NATIVE();
    ASTEST_BEGIN_NATIVE

    // Direct AngelScript SDK calls using NativeEngine pointer
    asIScriptModule* Module = NativeEngine->GetModule("test", asGM_ALWAYS_CREATE);
    // ...

    ASTEST_END_NATIVE
    return true;
}
```

### BARE SDK Internal Test

```cpp
bool FMyBareSDKTest::RunTest(const FString& Parameters)
{
    asCScriptEngine* BareEngine = ASTEST_CREATE_ENGINE_BARE();
    ASTEST_BEGIN_BARE

    // Direct SDK internal class operations
    asCModule* Module = static_cast<asCModule*>(BareEngine->GetModule("test", asGM_ALWAYS_CREATE));
    asCBuilder Builder(BareEngine, Module);
    asCByteCode ByteCode(&Builder);
    // ...

    ASTEST_END_BARE
    return true;
}
```

### Test with Custom Logic (No Macros)

```cpp
bool FMyCustomEngineTest::RunTest(const FString& Parameters)
{
    // When testing engine creation, multi-engine, or production-like test cases,
    // use the utility functions directly:
    FAngelscriptEngineConfig Config;
    FAngelscriptEngineDependencies Dependencies = FAngelscriptEngineDependencies::CreateDefault();
    TUniquePtr<FAngelscriptEngine> EngineA = FAngelscriptEngine::CreateForTesting(Config, Dependencies);
    TUniquePtr<FAngelscriptEngine> EngineB = FAngelscriptEngine::CreateForTesting(Config, Dependencies);
    // ... test multi-engine interaction ...
    return true;
}
```

## Naming Conventions

### File Names

```
Angelscript[Category][SubCategory]Tests.cpp
```

Examples: `AngelscriptControlFlowTests.cpp`, `AngelscriptEngineBindingsTests.cpp`, `AngelscriptASSDKEngineTests.cpp`

### Test Class Names

```
FAngelscript[Category][Feature]Test
```

Examples: `FAngelscriptControlFlowForLoopTest`, `FAngelscriptPrimitiveTypeTest`

### Test Paths

```
Angelscript.TestModule.[Category].[Feature]
```

Examples: `Angelscript.TestModule.Angelscript.ControlFlow.ForLoop`, `Angelscript.TestModule.Bindings.ValueTypes`

### Script Module Names (compile-time)

```
AS[Category][Feature]
```

Examples: `ASControlFlowForLoop`, `ASTypePrimitiveAndEnum`

## When NOT to Use Macros

The following test cases should use `IMPLEMENT_SIMPLE_AUTOMATION_TEST` directly without the `ASTEST_*` macros:

1. **Engine creation tests** - Testing `CreateForTesting`, `CreateTestingFullEngine`, etc.
2. **Multi-engine interaction tests** - Tests that create and manage multiple engine instances
3. **Engine isolation / context stack tests** - Tests verifying engine scope behavior
4. **Production-like engine tests** - Tests using `AcquireProductionLikeEngine`
5. **Debugger session tests** - Tests under `Debugger/` that attach to a running debug server and need socket/session fixtures
6. **Native ASSDK tests with custom adapters** - Tests using `CreateASSDKTestEngine` with `FAngelscriptSDKTestAdapter`
7. **Tests whose helper semantics are still under review** - For example, paths that currently require explicit shared/global teardown beyond the existing lifecycle macros

## Module-Clean Pool Notes

- `ASTEST_CREATE_ENGINE_MODULE_CLEAN()` uses `Shared/AngelscriptTestEnginePool.h` and caches a source Full engine instead of copying `FAngelscriptTypeDatabase` or `FAngelscriptBindDatabase`.
- The pool is lazy by default. Pass `-AngelscriptTestPrewarmEngine` to prewarm the source engine when a suite intentionally wants to pay bind cost at module startup.
- Prefer `MODULE_CLEAN` for ordinary compile/execute and binding smoke tests. Keep `FULL`, `SHARE_CLEAN`, or `SHARE_FRESH` for HotReload, Debugger, GC, Subsystem/global-engine ownership, and tests that require physical UObject collection timing.

## Files

- **Macro definitions**: `Shared/AngelscriptTestMacros.h`
- **Utility functions**: `Shared/AngelscriptTestUtilities.h`
- **Module-clean test engine pool**: `Shared/AngelscriptTestEnginePool.h`
- **Compile/execute helpers**: `Shared/AngelscriptTestEngineHelper.h`
- **Debugger session helpers**: `Shared/AngelscriptDebuggerTestSession.h`
- **Debugger client helpers**: `Shared/AngelscriptDebuggerTestClient.h`
- **Debugger script fixtures**: `Shared/AngelscriptDebuggerScriptFixture.h`
- **Functional test utils**: `Shared/AngelscriptFunctionalTestUtils.h`
- **Native test support**: `AngelScriptSDK/AngelscriptNativeTestSupport.h`
- **Native test adapter**: `AngelScriptSDK/AngelscriptTestAdapter.h`
