## Why

UE emits a deprecation warning during startup because `Plugins/Angelscript/Angelscript.uplugin` still depends on the deprecated `StructUtils` plugin. It was deprecated in UE 5.5 and the `FInstancedStruct` / `FStructUtils` runtime surface now lives under `CoreUObject` in UE 5.8. Remove the stale plugin and module dependency declarations to eliminate the warning and avoid future build failures if plugin resolution for the removed plugin becomes stricter.

## What Changes

- Remove the `{ "Name": "StructUtils", "Enabled": true }` entry from the `Plugins` list in `Plugins/Angelscript/Angelscript.uplugin`.
- Remove `"StructUtils"` from `PublicDependencyModuleNames` in `AngelscriptRuntime.Build.cs`; UE 5.8 exports the used `FInstancedStruct` / `FStructUtils` symbols from `CoreUObject`.
- Keep include paths unchanged: the existing `#include "StructUtils/InstancedStruct.h"` remains valid in UE 5.8.
- The file lives inside the `Plugins/Angelscript` git submodule, so use the submodule change flow: commit inside the submodule, then update the parent repository gitlink.

### Scope Correction Compared With Original Issue #3

The original issue was based on UE 5.5 and claimed four modules were affected: Angelscript, AngelscriptGAS, AngelscriptGameplayTags, and AngelscriptProjectEditor. Investigation confirmed:

- The actual engine baseline is **UE 5.8**.
- **Only the Angelscript plugin** declared and used StructUtils directly: AngelscriptRuntime and AngelscriptTest reference `FInstancedStruct`, but those references resolve through `CoreUObject` in UE 5.8.
- AngelscriptGAS, AngelscriptGameplayTags, and AngelscriptProjectEditor have **no StructUtils references**, so they are out of scope for this change.

## Capabilities

### New Capabilities
None. This is dependency maintenance only; it does not introduce script-visible or tool-visible capability and does not change spec-level behavior.

### Modified Capabilities
None. There is no spec-level behavior change.

## Impact

- Changed files inside the submodule: `Plugins/Angelscript/Angelscript.uplugin` and `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`.
- Main risk: UE versions before the `CoreUObject` migration may still require the old `StructUtils` module dependency. This repository targets UE 5.8, so the dependency should be removed for the active baseline.
- Verification: build `AngelscriptRuntime` and `AngelscriptTest`, confirm the deprecation warning is gone, and confirm `FInstancedStruct` bindings still link.
- Investigation note: `FInstancedStruct` is declared in `Engine/Source/Runtime/CoreUObject/Public/StructUtils/InstancedStruct.h` and exported with `COREUOBJECT_API`; `FStructUtils` is declared in `CoreUObject/Public/UObject/Class.h` and exported with `COREUOBJECT_API`.
