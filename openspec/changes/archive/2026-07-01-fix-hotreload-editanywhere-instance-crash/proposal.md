## Why

Hot reloading an Angelscript actor after changing a property to `EditAnywhere` can crash when a Blueprint subclass of that actor already exists. The crash happens during reload propagation for `UBlueprintGeneratedClass` objects, which is a common editor workflow after placing or deriving from a script actor.

## What Changes

- Add a focused HotReload regression test that creates a Blueprint child instance before reloading the script parent.
- Fix the reload propagation path so Blueprint generated classes derived from `UASClass` parents do not dereference a null `UASClass` cast.
- Preserve the existing full reload semantics for property definition changes such as `NotEditable` to `EditAnywhere`.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- None. This is a crash fix for existing hot reload behavior.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/HotReload/`
