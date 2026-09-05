## Why

The reconstruction baseline deliberately excludes the legacy AngelScript test corpus and its custom framework surface. Replacement tests currently use plain Unreal Automation, while `CQTest` is available only inside the disabled legacy dependency branch. The rebuilt native frontend needs richer matcher assertions and scenario-oriented fixtures without reactivating the old force include, engine pool, test bootstrap, or legacy Automation namespaces.

This change establishes that narrow foundation first so every later frontend Change can begin with a focused failing test and share one final public identity.

## What Changes

- Expose the Unreal `CQTest` module to replacement tests when `WITH_ANGELSCRIPT_TESTS=1`, independently of `WITH_ANGELSCRIPT_UNITTESTS`.
- Add replacement-only test support beneath `AngelscriptTest/NewVersion/NativeEngine/` with no dependency on legacy headers, `ASTEST_*` macros, `FAngelscriptEngine`, or the legacy engine pool.
- Register scenario-oriented CQTests beneath `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>`.
- Keep the existing plain-Automation dormant baseline intact; CQTest is the assertion and registration layer for new native-engine frontend tests, not restoration of the old AngelScript test framework.
- Update the testing guidance and durable baseline after the focused build and Automation proof pass.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `angelscript/testing/baseline`: Add an isolated CQTest contract for replacement NativeEngine tests while preserving the legacy/replacement compile boundary.

## Impact

The implementation changes the `Plugins/Angelscript` submodule (`AngelscriptTest.Build.cs` and replacement test sources) and later synchronizes the parent repository testing spec and focused test Skill. It does not enable legacy sources, move `.ubtignore` boundaries, create a persistent Unreal process, alter runtime startup, or change Harness APIs. The only real-UE verification is an incremental editor build followed by one exact Fast Automation prefix.
