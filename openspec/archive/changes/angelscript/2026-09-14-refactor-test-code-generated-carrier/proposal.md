## Why

The test-code database currently receives authored `.as` containers through a Windows RCDATA pipeline generated inside `AngelscriptTest.Build.cs`. That transport couples authoring to UBT rule execution, numeric resource identifiers, resource compilation, a runtime JSON index, and Windows-only loading even though the database, parser, registration, and query contracts are carrier-independent. A checked-in generated C++ carrier makes synchronization explicit and reviewable while retaining the framework behavior already delivered.

## What Changes

- Add a modular standard-library Python tool under `AngelscriptTestCode/CodeGenTool/` with a thin `codegen.py generate|check` entry.
- Discover authored `.as` files deterministically, excluding the complete tool subtree, and map each source to one mirrored `.generated.cpp` under `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/`.
- Preserve raw source bytes and register each projection through the existing `FAngelscriptTestCodeRegistration`; parse through the existing C++ parser during central activation.
- Make `generate` the sole bounded writer and `check` a read-only missing/changed/stale verifier. Ordinary UBT only compiles checked-in output and never launches Python.
- Remove the Windows RCDATA generator, RC input, runtime embedded-source loader, resource probes, and obsolete incremental resource script.
- Retain handwritten static registration and `AS_TEST_SOURCE` for fixtures owned by other C++ modules.
- Update focused Automation coverage and the test-code author guide for the new carrier.

Non-goals are diagnostics expectations, reload sequencing, LSP/DAP consumption, legacy recipe/history/catalog generation, AngelScript compilation in Python, automatic Git hooks, or changing database/query semantics.

## Capabilities

### New Capabilities

None. This Change replaces the transport of an existing test-code database capability.

### Modified Capabilities

- `angelscript/testing/code-database`: replace Windows embedded resource delivery with deterministic, checked-in per-source generated C++ while preserving authored identities, original bytes, registration, activation, and query behavior.

## Impact

- Parent repository: new authored-tool package and tests under `AngelscriptTestCode/CodeGenTool/`; current durable spec and project-local Skill guidance are updated.
- `Plugins/Angelscript` submodule: `AngelscriptTest` Build.cs/module startup, generated carrier, framework tests, and resource-only implementation are changed; the `AngelscriptTestJIT` handwritten provider remains a compatibility control.
- User entry points: `python AngelscriptTestCode/CodeGenTool/codegen.py generate` and `python AngelscriptTestCode/CodeGenTool/codegen.py check` from any current working directory.
- Build boundary: C++ source-set changes are explicit checked-in changes; UBT no longer scans the author tree or generates resource inputs.

