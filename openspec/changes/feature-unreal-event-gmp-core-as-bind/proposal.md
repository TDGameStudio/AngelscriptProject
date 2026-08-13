## Why

`AngelscriptProject` has no reusable, GameInstance-isolated event bus that combines the bounded Hub core and low-overhead dispatch architecture proven by GenericMessagePlugin (GMP) with the repository's maintained AngelScript binding and Hot Reload model. The existing `D:\Workspace\UnrealEvent` prototype proves useful behavior and tests, but its process-global `TMap<FName, TArray<Listener>>` Hub is not a GMP core port and cannot provide the configured, pre-created fast path required for hot events.

## What Changes

- Plan a self-contained sibling `UnrealEvent` plugin with an engine-only Runtime core, a separate AngelScript adapter, and an Editor automation-test module.
- Port and rename only the bounded GMP Hub core needed for static/direct signal storage, small-buffer erased callbacks, raw address dispatch, weak listener lifetime, mutation-safe ordered fire, and optional Monolithic inline dispatch; the deliverable does not depend on or compile GMP, while a project-owned performance suite may stage the pinned upstream plugin in an independent transient comparison host.
- Own all listeners, handles, signatures, scopes, and signal stores per `UGameInstance`; allow only immutable configured-symbol metadata to be process-wide.
- Add `UUnrealEventSettings` backed by `Config/DefaultUnrealEvent.ini`. Its structured `HighPerformanceEvents` allowlist declares the exact Key and payload signature for events whose symbols and per-GameInstance stores are pre-created.
- Keep ordinary `FName` calls in C++ and AngelScript. Runtime automatically routes configured names through an immutable Key-to-`SymbolIndex` router and unconfigured names through a dynamic store; callers do not use a Fast API or key macro.
- Transparently rewrite configured AngelScript literal calls to reserved internal typed adapters that already hold `SymbolIndex` and marshalling metadata, while preserving the small public `Event::Listen*`, `Event::Send*`, and unlisten surface.
- Make configuration deterministic and fail-safe: bad entries fall back to the dynamic path in Editor/Development, fail Cook/Commandlet validation, and never produce an unsafe partial fast binding.
- Define structural hot-path gates and a Monolithic Shipping performance target no slower than `1.2x` an equivalent UE native multicast delegate workload.
- Record an exact GMP source/symbol adoption map, provenance obligations, rejected subsystems, and the changes required to preserve multi-PIE isolation.

## Capabilities

### New Capabilities

- `unreal-event-core`: Standalone UnrealEvent Runtime, GMP-derived Hub core, `DefaultUnrealEvent.ini` settings, configured-symbol registry, automatic FName routing, per-GameInstance configured/dynamic stores, scoped synchronous dispatch, handles, exact signatures, weak lifetime, diagnostics, and performance contracts.
- `unreal-event-angelscript-bind`: Minimal public `Event` namespace, generic fallback marshalling, configured-literal transparent rewrite, reserved typed adapters, named `UFUNCTION` callbacks, cached `UASFunction` dispatch, StaticJIT parameter-entry fast path, reflective fallback, and Hot Reload invalidation.

### Modified Capabilities

None.

## Impact

- Future implementation adds `Plugins/UnrealEvent/` as a normal sibling plugin containing `UnrealEventRuntime`, `UnrealEventAngelscript`, and `UnrealEventTest`. No remote repository is assigned, so this change does not plan a Git submodule conversion.
- `UnrealEventRuntime` depends only on engine modules (`Core`, `CoreUObject`, `Engine`, and `DeveloperSettings`). It never includes or links GMP or AngelScript. `UnrealEventAngelscript` depends on `UnrealEventRuntime` and `AngelscriptRuntime`; the descriptor declares Angelscript as required.
- The plugin adds `Config/DefaultUnrealEvent.ini` and Project Settings → Plugins → Unreal Event. It does not read or generate `DefaultGMPMeta.ini`, MessageTags configuration, generated C++ headers, or generated C++ translation units.
- C++ and AS remain FName-based. Configured events are selected automatically in the background; unconfigured events remain valid through the dynamic route.
- The host project will enable UnrealEvent for validation, and the configured All suite will include `Angelscript.UnrealEvent.*` after implementation.
- GMP commit `85283fbec0edba1a04c1cff8181455c5d97ba60a` is the fixed Apache-2.0 reference baseline. Any substantially derived source must carry license, provenance, upstream-path, destination-path, and local-change records.
- The GMP timing control is isolated from the plugin build graph: `UnrealEventTest` has no GMP dependency, and only the dedicated performance suite may copy the verified pinned plugin into a disposable comparison host.
- This OpenSpec change records the intended plugin and implementation plan only; it does not itself claim UE build, test, or benchmark results.
