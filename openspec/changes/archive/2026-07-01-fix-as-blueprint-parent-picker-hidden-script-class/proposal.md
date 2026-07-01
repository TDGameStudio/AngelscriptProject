## Why

`AExampleActorType` can already be used by Angelscript's direct create-blueprint entry point, but it is not discoverable through the standard Blueprint parent-class search UI. That inconsistency makes valid script bases look unavailable and breaks the normal editor workflow for reusing Angelscript classes as Blueprint parents.

## What Changes

- Standard Blueprint parent-class and reparent-class pickers surface valid Angelscript-generated classes.
- Existing invalid-parent exclusions remain intact for classes that are `Abstract`, `Deprecated`, `HideDropdown`, or `NotBlueprintable`.
- Angelscript's direct create-blueprint popup continues to work with the same script classes.
- Regression coverage is added for `AExampleActorType` discoverability and picker eligibility.

## Capabilities

### New Capabilities
- `as-blueprint-parent-class-discovery`: Standard Unreal Blueprint parent selection can discover valid Angelscript classes.

### Modified Capabilities
None.

## Impact

- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
- `Plugins/Angelscript/Source/AngelscriptEditor/Core/AngelscriptEditorModule.cpp`
- Blueprint parent-class picker and reparent picker behavior in the Unreal editor
- Editor/test coverage that exercises `AExampleActorType` and related class-picker eligibility
