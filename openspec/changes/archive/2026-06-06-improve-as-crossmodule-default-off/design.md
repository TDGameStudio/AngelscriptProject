## Context

Cross-module direct-bind generation is currently profile-driven. `cross-module-generation-modules.json` selects `common + source` for source-engine workspaces and `common + installed` for installed builds. Those profile entries become `CrossModuleOnlyModules`, and UHT writes `AS_FunctionTable_<Module>_CrossModule_*.cpp` into each target module's output directory. The generator also writes an Engine link probe shard whenever the Engine module is present.

This is useful for coverage and performance experiments, but it means a source-engine build compiles generated code inside engine modules by default. The desired default is safer: no engine-side CrossModule generated code unless the user opts in.

## Goals / Non-Goals

**Goals:**
- Make CrossModule target-module shard generation disabled by default.
- Keep normal AngelscriptRuntime generated function tables enabled.
- Preserve the existing profile module lists so CrossModule generation can be explicitly re-enabled without reconstructing the allowlist.
- Make the enabled/disabled state visible in summary diagnostics.
- Ensure disabling also suppresses the Engine link probe.

**Non-Goals:**
- Do not add a runtime CVAR.
- Do not change reflective fallback behavior.
- Do not remove CrossModule support or its existing profile data.
- Do not change parameter marshalling coverage.

## Decisions

- Add a JSON configuration gate instead of clearing module lists. This separates "feature enabled" from "which modules are eligible", so the current allowlist remains useful for opt-in builds.
- Treat a missing gate field as disabled. This makes the default conservative even if an older or hand-written config omits the field.
- Thread the gate through generation rather than only through profile loading. The generator must suppress both cross-module-only modules and runtime-linked `unexported-symbol` wrapper generation; otherwise disabling only the profile list would still allow CrossModule wrappers for runtime-linked modules.
- Skip the Engine link probe while disabled. The probe is engine-side generated code and belongs to the same opt-in surface as target-module wrapper shards.
- Extend `AS_FunctionTable_Summary.json` with the gate state. Build diagnostics should make it clear whether zero CrossModule output is intentional.

## Risks / Trade-offs

- Existing source-engine workspaces that relied on CrossModule wrappers by default will lose those direct-bind wrappers until they explicitly enable the gate. Mitigation: keep the profile lists intact and document the opt-in flag in the config.
- Tests that previously assumed source profiles always emit CrossModule outputs must be updated to assert the new disabled default and the opt-in path separately.
- Stale generated files from a previous enabled build may remain until UHT runs and `DeleteStaleOutputs` sees their module output directories. Mitigation: keep generated path tracking and stale cleanup active for runtime-linked module output directories.

## Migration Plan

1. Add the config gate with default disabled behavior.
2. Update UHTTool tests to cover disabled default and explicit opt-in behavior.
3. Run the UHTTool resolver tests and a serialized build through the project runners.
4. Users who want the prior behavior can set the new config gate to enabled in `cross-module-generation-modules.json`.

## Open Questions

None.
