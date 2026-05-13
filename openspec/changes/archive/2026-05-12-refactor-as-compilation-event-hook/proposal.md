## Why

The Angelscript compiler path needs stable hook points for diagnostics, LearningGuide output, and future pipeline refactors, but preprocessing and module compilation currently expose only ad hoc callbacks and implicit `FAngelscriptEngine` state. This change establishes explicit preprocessing inputs and structured compilation observation before attempting a larger phase-based rewrite.

## What Changes

- Add an explicit preprocessor context/options capability so preprocessing can be configured from a value object instead of directly reading engine-global state throughout construction and execution.
- Add read-only preprocessor summary output for hook consumers, avoiding direct dependence on mutable `FAngelscriptPreprocessor::Files` and chunk internals.
- Add a default-quiet compilation events capability that broadcasts structured UE-style events for preprocessing, compile begin/end, module stage boundaries, parse/typegen/layout/codegen/globals, and class-generation handoff.
- Introduce a thin per-run compilation context for shared compile-state summaries and future phase extraction, without replacing the current `CompileModules()` flow in this change.
- Preserve existing public behavior and compatibility constructors; this is a staged refactor, not a wholesale pipeline rewrite.
- No **BREAKING** API removals are intended in this change.

## Capabilities

### New Capabilities
- `as-preprocessor-context`: Explicit preprocessing environment and option construction for Angelscript preprocessing.
- `as-preprocessor-summary`: Stable, read-only preprocessing summaries for hooks, tests, and diagnostics.
- `as-compilation-events`: Structured, default-quiet compilation events across preprocessing and module compilation boundaries.

### Modified Capabilities

None. No existing OpenSpec capabilities are registered in this repository at proposal time.

## Impact

- Runtime preprocessing code under `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/`.
- Runtime compile orchestration in `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` and related Core headers.
- New runtime compilation events/context files under `Plugins/Angelscript/Source/AngelscriptRuntime/Core/` or `Core/Compilation/`.
- Runtime and Learning/Preprocessor tests under `Plugins/Angelscript/Source/AngelscriptTest/`.
- Documentation that describes compiler hooks, preprocessing behavior, and test entry points.
