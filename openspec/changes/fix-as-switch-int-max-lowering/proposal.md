## Why

`asCCompiler::CompileSwitchStatement()` performed range-gap and dense-table
arithmetic in signed 32-bit values. Case labels near `INT_MAX` could overflow
the lowering heuristic or loop counter, exclude a valid case, emit the default
path, or wrap table generation.

## What Changes

- Own production hunks P066, P067, P068, and P069 as one compiler repair.
- Keep switch range comparisons and dense-table iteration in `asINT64` while
  preserving the script-visible signed 32-bit selector contract.
- Preserve the existing high-end execution regression and ordinary controls.
- Require fresh linked build, focused ControlFlow, and aggregate SDK evidence
  before final acceptance.

## Capabilities

### New Capabilities

- `as-switch-int-max-lowering`: Defines overflow-safe switch lowering at the
  upper signed 32-bit boundary.

### Modified Capabilities

None.

## Impact

- Production: P066-P069 only in
  `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`,
  `asCCompiler::CompileSwitchStatement()`, current lines 5143-5205.
- Regression:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/ControlFlow/AngelscriptNativeSwitchTests.cpp`,
  `FSwitchTests::SelectorsByCaseAndExit`, product `LANG-CF-SWITCH`.
- No parser syntax, selector type, interpreter dispatch, serialization, or
  unrelated optimizer behavior changes.
