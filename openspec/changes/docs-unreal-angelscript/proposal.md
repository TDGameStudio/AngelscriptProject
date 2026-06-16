## Why

The current version label `AS 2.33` no longer accurately describes the project's AngelScript engine because the UE integration has become a deeply diverged fork with UE-specific memory, type, module, hot reload, binding, debug, and bytecode compatibility behavior.

This change records a naming and documentation plan for adopting `Unreal AngelScript` as the project-facing identity while preserving upstream AngelScript version lineage as technical metadata.

## What Changes

- Establish `Unreal AngelScript` as the user-facing project/plugin identity for the UE AngelScript integration.
- Establish `UEAS Runtime` as the runtime/fork version label used for the deeply customized AngelScript engine.
- Replace public-facing wording that presents the current engine as plain `AS 2.33` with wording that distinguishes product identity, fork version, and upstream lineage.
- Preserve `AngelScript 2.33-WIP lineage + selective 2.38 backports` in technical documentation where source provenance and backport strategy matter.
- Document that this is a naming and documentation change only; it does not change compiler behavior, runtime behavior, bindings, serialized bytecode, or plugin/module names.
- No implementation is performed in this change-recording session.

## Capabilities

### New Capabilities

- `unreal-angelscript-identity`: Defines the naming, version-label, and documentation rules for presenting the deeply forked UE AngelScript runtime as `Unreal AngelScript`.

### Modified Capabilities

- None.

## Impact

- Documentation impact: root project README, plugin README, AGENTS guidance, Chinese guidance, fork strategy guide, and any other user-facing docs that currently describe the runtime as plain `AS 2.33`.
- Source impact: no C++/C#/AngelScript implementation changes are planned.
- API impact: no public API, module name, plugin descriptor, runtime behavior, or serialization contract changes are planned.
- Validation impact: OpenSpec validation plus documentation grep checks are sufficient for the naming pass; no build or automation test run is required unless implementation scope expands later.
