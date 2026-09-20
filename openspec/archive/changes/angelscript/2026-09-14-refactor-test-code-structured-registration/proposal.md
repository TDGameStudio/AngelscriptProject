## Why

The checked-in AngelScript test-code carrier currently expands each complete authored `.as` container into an opaque C++ byte array and delays fixture metadata, version-tree, annotation and origin parsing until Unreal module activation. This makes generated diffs difficult to review, performs authoring-protocol work during startup, and lets registration metadata differ from the final Case metadata reconstructed by the C++ parser.

The existing Python generator already owns deterministic discovery, rendering and synchronization. Moving fixture-protocol parsing into that pre-mutation stage lets generated translation units directly describe the immutable materials they register while retaining the C++ parser for independent handwritten/dynamic inputs and protocol conformance.

## What Changes

- Parse the v1 `.as` fixture protocol in the modular Python CodeGenTool, including file/version metadata, explicit version boundaries, annotations, clean UTF-8 bytes, compact authored-origin projection and version topology.
- Render one readable structured `.generated.cpp` per authored `.as`, using real metadata, `AS_TEST_SOURCE`, typed annotation descriptors, origin spans plus `AuthoredEnd`, a captureless Builder lambda and a FileTag-derived namespace-scope static registration.
- Add public `FAngelscriptTestSourceDescriptor` construction data and `FAngelscriptTestCodeBuilder` overloads that validate and admit it without exposing mutable Source internals.
- Preserve `FAngelscriptTestSourceParser` as an independent C++ fixture-protocol path and prove semantic conformance against Python.
- Advance signed generated output from opaque carrier format v1 to structured format v2 while retaining explicit `generate`, read-only `check`, atomic synchronization and no ordinary-UBT Python execution.
- Keep deliberately invalid AngelScript source admissible when its fixture protocol is valid; reject malformed fixture protocol before any output mutation.

## Capabilities

### New Capabilities

None. This Change refines the existing test-code database and authoring delivery contract rather than introducing a second capability.

### Modified Capabilities

- `angelscript/testing/code-database`: replace activation-time parsing of generated authored bytes with checked-in structured registrations, add descriptor admission and require an independent conforming C++ parser path.

## Impact

- Repository root: `AngelscriptTestCode/CodeGenTool/`, authored fixtures and their Python tests.
- `Plugins/Angelscript` submodule: `AngelscriptTest` Source/Builder/Parser framework, generated test-code translation units and focused CQTest coverage; `AngelscriptTestJIT` remains a handwritten cross-module provider control.
- Public testing API: new `FAngelscriptTestSourceDescriptor` and overloads of existing `FAngelscriptTestCodeBuilder::AddRoot/AddVersion`.
- Author entry points remain `python AngelscriptTestCode/CodeGenTool/codegen.py check` and `generate`; ordinary UBT still consumes checked-in C++ only.
- No gameplay/runtime API, Windows resource, external package or engine modification is added.
- Before product implementation, planning-only `angelscript/refactor-testing-unified-framework` requires a separate update/replan to remove overlapping TestCode source-history, byte-shard and aggregate-release ownership.
