## Why

The former `AngelscriptTest/ClassGenerator` layout mixed script-generated behavior tests with tests that exercise `FAngelscriptClassGenerator` itself. The flat directory also made reload planning look like an integration-only concern, even though part of it can be tested as deterministic graph propagation. The test-facing theme should be `Generator` because the suite covers generated classes, functions, structs, script classes, validation, and reload planning, not only class generation.

## What Changes

- Move the test theme to `AngelscriptTest/Generator` and split it into semantic subdirectories.
- Rename Automation prefixes to `Angelscript.TestModule.Generator.*` so runner filters match the broader test theme.
- Add a small `FAngelscriptClassReloadPlanner` seam for pure reload requirement propagation.
- Add direct planner tests for dependency propagation, multi-hop escalation, cycles, and reset behavior.
- Document how to choose between generated-behavior tests and generator-capability tests.

## Capabilities

### New Capabilities

- `as-classgenerator-test-layout`: Generator test organization and reload planner seam.

### Modified Capabilities

- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/`
- `Plugins/Angelscript/Source/AngelscriptTest/Generator/`
- `Documents/Guides/TestConventions.md`
