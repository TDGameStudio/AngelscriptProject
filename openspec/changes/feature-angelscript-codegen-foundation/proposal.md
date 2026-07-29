## Why

The project has extensive native SDK and UE-Angelscript Coverage suites, but their source-shape patterns and capability evidence are currently hand-authored and cannot be composed into deterministic new test programs. A standalone generator is needed to produce reproducible positive and intentionally negative AngelScript source without coupling the generator to Unreal automation or production runtime code.

## What Changes

- Add `Tools/AngelscriptCodeGen`, a modular Python 3.10+ package that emits deterministic `.as` test cases and a machine-readable case index.
- Add a typed internal program model, source lifter, deterministic random source, and separate valid-program and single-rule invalid-program generation paths.
- Add versioned declarative profiles for native core, UE values, UE annotations, and UE World/Actor source shapes. Profiles describe reviewed capabilities and harness requirements rather than discovering the whole engine API surface.
- Add Python unit coverage for model invariants, profiles, source lifting, deterministic generation, invalid-rule isolation, catalog writing, and the command-line interface.
- Add no Unreal build, execution, CQTest renderer, reducer, fuzzer feedback loop, or automatic API discovery in this change.

## Capabilities

### New Capabilities

- `angelscript-code-generation-foundation`: Generate reproducible native and UE-Angelscript source cases from typed models and reviewed declarative profiles.

### Modified Capabilities

- None.

## Impact

- New project-owned tooling under `Tools/AngelscriptCodeGen/`, using Python standard-library runtime dependencies and pytest only for development tests.
- New OpenSpec artifacts under this change directory.
- No changes to `Plugins/Angelscript`, `AngelscriptTest/Coverage`, the active native-SDK coverage change, public plugin APIs, Unreal build dependencies, or normal test runners.
