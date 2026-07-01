## Why

Delegate hot reload tests already cover primitive, native struct, container, script-struct, Blueprint, global function, and world-tick flows, but reference-style delegate parameters remain undercovered. That leaves a gap around object/class/soft-reference marshaling after a delegate signature replacement.

## What Changes

- Add focused hot reload coverage for delegate signatures that expand from a simple UObject-derived argument to object, UClass, TSubclassOf, TSoftObjectPtr, and TSoftClassPtr arguments.
- Assert both generated `UDelegateFunction` parameter metadata and post-reload runtime invocation.
- Keep the runtime scene tests separate from the parameter matrix tests.

## Capabilities

### New Capabilities
- `hotreload-delegate-reference-parameters`: verifies delegate hot reload for reference-like parameter families.

### Modified Capabilities
- None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptHotReloadDelegateTests.cpp`
- No runtime API, public scripting API, or module dependency changes are intended.
