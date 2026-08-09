## Why

The plugin already supports script-defined Engine, GameInstance, World, LocalPlayer, and Editor subsystems, but their lifecycle state machines and user-facing boundary are inconsistent. In particular, `UScriptEngineSubsystem` does not clear its tick gate during deinitialization, `UScriptEditorSubsystem` bypasses base lifecycle calls, scripts cannot declare UE subsystem initialization dependencies, and the plugin-owned `UAngelscriptSubsystem` is accidentally exposed through the generic native `::Get()` generation path.

## What Changes

- Make all script subsystem lifecycle bridges consistently call their UE base implementation and prevent Tick after deinitialization.
- Add a deliberately restricted script-facing way to declare a subsystem dependency while the subsystem is initializing; do not expose `FSubsystemCollectionBase` directly.
- Define `UScriptEngineSubsystem`, `UScriptGameInstanceSubsystem`, `UScriptWorldSubsystem`, `UScriptLocalPlayerSubsystem`, and editor-only `UScriptEditorSubsystem` as the complete script-author subsystem surface.
- Remove the plugin runtime host `UAngelscriptSubsystem` from automatically generated AngelScript native subsystem `::Get()` accessors; it remains the C++ owner of the primary `FAngelscriptEngine`.
- Add functional coverage for collection-owned script subsystem creation, lifecycle callbacks, tick gating, retrieval, dependency ordering, and the relevant PIE/editor boundaries.

## Capabilities

### New Capabilities

- `as-script-subsystem-lifecycle`: Consistent lifecycle, dependency, retrieval, and test contracts for script-defined UE subsystems.

### Modified Capabilities

- `as-subsystem-production-surface`: Keep the plugin-owned engine subsystem out of the AngelScript author-facing subsystem surface.

## Impact

- Runtime subsystem bases in `Plugins/Angelscript/Source/AngelscriptRuntime/Subsystem/`.
- Editor subsystem base in `Plugins/Angelscript/Source/AngelscriptEditor/BaseClasses/`.
- Native subsystem accessor generation in `Binds/Bind_Subsystems.cpp` and script-class static generation in the preprocessor.
- UE Functional, Bindings, HotReload, and Editor automation coverage, plus subsystem examples and Chinese-first documentation.
