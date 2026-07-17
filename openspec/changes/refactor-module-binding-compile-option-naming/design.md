## Context

The ModuleBinding implementation is already named consistently in the Runtime bridge and UHT output, but its compile gate was introduced as `ModuleLocal`. The gate is read independently by `AngelscriptRuntime.Build.cs` and the UHT generator, while Editor settings validation and tests inspect the same names. A partial rename would allow UBT, UHT, or Runtime to disagree about whether the bridge is compiled.

## Goals / Non-Goals

**Goals:**

- Use `bCompileAngelscriptModuleBindings` and `WITH_ANGELSCRIPT_MODULE_BINDINGS` as the only active compile-gate names.
- Keep UBT and UHT reading the same ini setting and applying the same source-engine rejection.
- Keep the default disabled state and generated-output behavior unchanged.
- Update maintained documentation and focused source-scan tests.

**Non-Goals:**

- Do not change the ModuleBinding ABI, generated shard names, Modular Feature key, or safety filters.
- Do not rename historical OpenSpec records that document the previous implementation state.
- Do not rename every descriptive use of `ModuleLocal` when it means target-module compilation location.

## Decisions

1. **Canonical option name:** `bCompileAngelscriptModuleBindings`. The setting controls whether the ModuleBinding feature is compiled and generated; `ModuleLocal` describes an implementation location and is not suitable as the user-facing switch name.
2. **Canonical macro name:** `WITH_ANGELSCRIPT_MODULE_BINDINGS`. The macro mirrors the setting and gates the Runtime bridge and runtime-only tests.
3. **Single-source gate parsing:** Keep the existing UBT and UHT independent parsing paths, but make both compare the new exact setting string. This preserves build invalidation and protects against UHT/UBT drift.
4. **Migration scope:** Update active source, config, tests, README, and maintained guides. Leave completed historical OpenSpec changes and the previous implementation plan unchanged.

## Risks / Trade-offs

- [Risk] Existing projects still use the old ini key. → Treat the rename as source/config breaking and document the new key; the default remains safe because an old-only key is ignored.
- [Risk] One gate consumer retains the old macro. → Source-scan tests reject the legacy active names and the focused UHT gate test checks all consumers.
- [Risk] Descriptive `ModuleLocal` text is over-renamed. → Keep it only where it describes target-module output location, not option or macro identity.

## Migration Plan

1. Update tests to require the new setting and macro names.
2. Rename the config/build/UHT/Editor identifiers and active documentation.
3. Build the editor and run the focused UHT resolver/generated-table tests.
4. Existing users enabling the old option must rename the ini key to `bCompileAngelscriptModuleBindings`.

## Open Questions

None.
