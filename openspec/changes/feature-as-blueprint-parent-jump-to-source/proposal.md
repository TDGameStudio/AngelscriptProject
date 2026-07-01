## Why

The Blueprint editor's top-right "open parent class source in IDE" action can navigate to C++ parent classes, but clicking it is ineffective when the Blueprint parent is an Angelscript class. Root cause: the engine only enables that action for `CLASS_Native` parent classes, while AS-generated classes are marked as `CLASS_CompiledFromBlueprint`; the engine therefore never calls the registered `ISourceCodeNavigationHandler`. The underlying capability already exists: source file path and line data, VS Code launch logic, and the navigation handler are all present. The missing piece is a UI entry point.

## What Changes

- Add an Angelscript-owned Blueprint editor toolbar/menu entry in the AngelscriptEditor module via `UToolMenus`. It is visible/enabled when the current Blueprint's `ParentClass` is a `UASClass`/`UASStruct`.
- On click, reuse the existing `FAngelscriptSourceCodeNavigation::NavigateToClass` path, or `FSourceCodeNavigation::NavigateToClass(ParentClass)`, to resolve the AS parent class to `path:line` and open it in VS Code.
- Do not add a new source-location pipeline or change AS compilation; this only wires an existing capability into the UI.

### Difference From The Existing Change

`fix-as-blueprint-parent-picker-hidden-script-class` addresses AS class discoverability in the parent-class **picker/dropdown** when creating or reparenting a Blueprint. This change addresses **source navigation after an AS parent class is already assigned**, via the Blueprint editor IDE/source action. The UI surfaces and engine seams are different, so the changes are independent.

## Capabilities

### New Capabilities
- `as-blueprint-parent-source-navigation`: navigate from the Blueprint editor to the `.as` source file and line for an Angelscript parent class, opening it in the configured external editor, VS Code.

### Modified Capabilities
None. No existing specification is modified.

## Impact

- Primary module changed: `Plugins/Angelscript/Source/AngelscriptEditor` inside the submodule.
- Reused files:
  - `AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp/.h`, which already implements the handler plus `OpenVsCode`/`OpenModule`
  - `AngelscriptEditor/EditorMenuExtensions/ScriptEditorMenuExtension.cpp` with existing `UToolMenus` extension and `NavigateToClass` usage patterns
  - `AngelscriptEditor/Core/AngelscriptEditorModule.cpp:815`, where the handler is registered
- Data sources, read-only: `ASClass.h:193-194` for `GetSourceFilePath`/`GetSourceLineNumber`, and `AngelscriptEngine.h` for `FAngelscriptClassDesc::LineNumber`.
- Risks/unknowns: the exact engine toolbar gating for native parents is not available in vendored source. Implementation must confirm whether the action is hidden or short-circuited before invocation, to decide between adding an owned entry, which is the recommended robust path, or reusing the engine button. Class/property line numbers may not be populated in headless mode under `#ue57-headless`, so tests should target function/class navigation that is actually populated in editor contexts or use a production-like fixture.
