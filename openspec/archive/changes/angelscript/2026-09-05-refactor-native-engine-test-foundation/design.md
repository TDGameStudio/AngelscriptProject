## Context

The current baseline compiles `NewVersion` under `WITH_ANGELSCRIPT_TESTS=1`, but `AngelscriptTest.Build.cs` adds `CQTest` only inside the `WITH_ANGELSCRIPT_UNITTESTS` legacy branch. The replacement baseline intentionally uses plain Unreal Automation and must remain intact. The legacy CQTest force include, `ASTEST_*` helpers, engine lifecycle, and engine pool are quarantined reference code.

This Change is the prerequisite for every subsequent NativeEngine frontend Change. Those Changes need a lightweight assertion layer, but they must not inherit runtime startup or module-compilation behavior from the old suite.

## Goals / Non-Goals

**Goals:**

- Make the UE CQTest library independently available to replacement tests.
- Establish a small replacement-only support surface and final public prefix.
- Keep each fixture deterministic, locally owned, and independent of live Engine state.
- Amortize the unavoidable editor-process startup by running one exact area prefix per Change.

**Non-Goals:**

- Reactivate, repair, or move the legacy test corpus.
- Restore `WITH_ANGELSCRIPT_UNITTESTS`, the CQTest force include, `ASTEST_*`, or the old engine pool.
- Add a custom commandlet, persistent test daemon, or new Harness route.
- Start lexer, parser, AST, Sema, Builder, VM, or production routing work.

## Decisions

### CQTest is a library dependency, not the old framework

`CQTest` moves into a replacement-specific editor dependency branch controlled by `WITH_ANGELSCRIPT_TESTS`. The existing legacy branch remains unchanged except that it no longer owns the only path to the dependency. Replacement tests include the CQTest API explicitly; they do not receive a module-wide force include.

The local support header exposes only neutral fixture conveniences needed by multiple NativeEngine areas. It cannot include legacy paths or manufacture an `FAngelscriptEngine`. Later frontend objects are created directly from frozen options and immutable source input.

### Public identity is stable while the directory is temporary

CQTest composes its public path as `<TestDir>.<ClassName>.<MethodName>`. Replacement tests therefore use `Angelscript.UnitTest.NativeEngine` as `TestDir`, the exact area token such as `Foundation` as the C++ class identifier, and each `TEST_METHOD` as the scenario token. An Unreal-style `F` prefix on that test class would become an unwanted public path component and is intentionally omitted. `NewVersion` never appears in the public identity. The existing `Angelscript.UnitTest.Baseline` tests remain plain Automation because they prove module-wide dormancy rather than frontend semantics.

### One exact prefix is the feedback unit

The fastest supported trustworthy path remains Harness `ue.test` with `Fast = $true`. Historical evidence measured roughly 26.8 seconds of fresh process time while the baseline test body took about 0.13 seconds, so splitting one area across multiple processes would dominate feedback time. Tests remain independently named, but all scenarios for one Change run under one area prefix.

## Risks / Trade-offs

- CQTest may transitively require editor-only modules. The dependency is added only for editor test targets and the build proof must keep non-test runtime ownership unchanged.
- A shared support header can become another hidden framework. Its contract is intentionally limited to data construction, deterministic comparison, and diagnostic capture; scenario flow and assertions stay visible in each test method.
- The first test may fail at compile time before the dependency is exposed. That is an acceptable RED proof, followed by the same editor build and exact-prefix GREEN verification.
