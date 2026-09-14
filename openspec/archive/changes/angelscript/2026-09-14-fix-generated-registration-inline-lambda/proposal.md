## Why

The completed generated-carrier migration emits a separate named `BuildSource_<digest>` function for every generated fixture. The user had already selected direct captureless-lambda registration so generated translation units do not carry redundant formatting and symbols. The discrepancy was found during the post-archive handoff audit.

This is a clear, mechanical follow-up fix; the design gate is intentionally skipped because the desired code shape and affected registration factory signature are already settled.

## What Changes

- Change the pure C++ renderer to pass a unary-plus captureless lambda directly to `FAngelscriptTestCodeRegistration`.
- Remove the generated named factory function while retaining digest-suffixed byte-array and registration names for Unity safety.
- Regenerate `Language/Counter.generated.cpp` and verify the parser call, database behavior, and authored source identity are unchanged.

Non-goals are new public APIs, carrier behavior changes, database changes, or edits to the archived parent Change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This fixes a generated implementation shape without changing durable observable behavior.

## Impact

The parent repository Python renderer and its focused test change. The `Plugins/Angelscript` submodule receives a deterministic regenerated `Counter` translation unit. No module startup, Build.cs, spec, or consumer changes are required.

