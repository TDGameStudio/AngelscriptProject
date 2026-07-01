## Why

UE emits a deprecation warning for `Plugins/Angelscript/Angelscript.uplugin` during startup: it depends on `StructUtils`, which is no longer an independent plugin. It was deprecated in UE 5.5 and later merged into engine core as an engine module. This repository targets **UE 5.8**, where that plugin no longer exists, so the declaration triggers a warning. Remove the stale plugin dependency to eliminate the warning and avoid future build failures if plugin resolution for the removed plugin becomes stricter.

## What Changes

- Remove the `{ "Name": "StructUtils", "Enabled": true }` entry from the `Plugins` list in `Plugins/Angelscript/Angelscript.uplugin`.
- **Keep** `"StructUtils"` in `PublicDependencyModuleNames` in `AngelscriptRuntime.Build.cs`. This is an engine **module** dependency, not a plugin dependency, and still provides types such as `FInstancedStruct`. Removing it would cause link errors.
- Keep include paths unchanged: the existing `#include "StructUtils/InstancedStruct.h"` remains valid in UE 5.8.
- The file lives inside the `Plugins/Angelscript` git submodule, so use the submodule change flow: commit inside the submodule, then update the parent repository gitlink.

### Scope Correction Compared With Original Issue #3

The original issue was based on UE 5.5 and claimed four modules were affected: Angelscript, AngelscriptGAS, AngelscriptGameplayTags, and AngelscriptProjectEditor. Investigation confirmed:

- The actual engine baseline is **UE 5.8**.
- **Only the Angelscript plugin** declares and uses StructUtils directly: AngelscriptRuntime and AngelscriptTest have roughly 60 API references, mostly for `FInstancedStruct`.
- AngelscriptGAS, AngelscriptGameplayTags, and AngelscriptProjectEditor have **no StructUtils references**, so they are out of scope for this change.

## Capabilities

### New Capabilities
None. This is dependency maintenance only; it does not introduce script-visible or tool-visible capability and does not change spec-level behavior.

### Modified Capabilities
None. There is no spec-level behavior change.

## Impact

- Only changed file: `Plugins/Angelscript/Angelscript.uplugin` inside the submodule.
- Main risk: distinguish the plugin dependency to remove from the Build.cs module dependency to keep. Confusing the two would turn a deprecation warning into a link error.
- Verification: build `AngelscriptRuntime` and `AngelscriptTest`, confirm the deprecation warning is gone, and confirm `FInstancedStruct` bindings still link.
- Open question: whether `StructUtils` remains an independently linkable module name in UE 5.8. Current include paths and the Build.cs module name both indicate that the module still exists. If the build reports that the module cannot be found, the fallback is to depend on `CoreUObject` and re-check the include path.
