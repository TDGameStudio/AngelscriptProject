# Design — feature-as-blueprint-parent-jump-to-source

## Background And Root Cause

The Blueprint editor's top-right "open parent class source" action is implemented by the engine, typically in `SBlueprintEditorToolbar`/`FBlueprintEditorToolbar`, which is not vendored here. It usually applies native-class gating: it is only shown/enabled when `ParentClass->HasAnyClassFlags(CLASS_Native)`, then invokes `FSourceCodeNavigation::NavigateToClass(ParentClass)`.

AS-generated classes are marked as `CLASS_CompiledFromBlueprint` in `AngelscriptClassGenerator.cpp:3319`, not `CLASS_Native`. As a result, the engine either hides the button for AS parent classes or treats them as ordinary Blueprint parent classes and opens a Blueprint instead of an IDE. In both cases it **never calls** `NavigateToClass`, so the registered AS handler never gets a chance to respond.

## Existing Capability To Reuse

1. **Source-location data**: `UASFunction::GetSourceFilePath()`/`GetSourceLineNumber()` in `ASClass.h:193-194`; `FAngelscriptClassDesc::LineNumber` in `AngelscriptEngine.h:1343`; reverse lookup from `UASClass`/`UASStruct` to descriptor and module through `FAngelscriptEngine::Get().GetClass(prefix+name, &OutModule)`.
2. **VS Code launch**: `OpenVsCode()` in `AngelscriptSourceCodeNavigation.cpp` calls `FPlatformMisc::OsExecute(nullptr, "code", *Params)` with `code --goto "<path>:<line>"`, controlled by `UAngelscriptSettings::VSCodeWorkspacePath` and `bOpenFolderOnVSCodeSourceLinks`.
3. **Registered handler**: `FAngelscriptSourceCodeNavigation : ISourceCodeNavigationHandler` implements `CanNavigateToClass`/`NavigateToClass` and is registered through `FSourceCodeNavigation::AddNavigationHandler` in `FAngelscriptEditorModule::StartupModule()` at `AngelscriptEditorModule.cpp:815`.
4. **Existing pattern**: `ScriptEditorMenuExtension.cpp:68` already uses `FSourceCodeNavigation::NavigateToClass(Class)` for a right-click "Go to source" action, proving the path is usable in the editor.

## Approach

Add an **Angelscript-owned Blueprint editor entry point** in the AngelscriptEditor module that does not depend on the engine button's native-class gating:

- Extend the Blueprint editor toolbar/menu through `UToolMenus`. The module already depends on `ToolMenus` in `AngelscriptEditor.Build.cs:45`, and `ScriptEditorMenuExtension.cpp` provides an existing extension precedent.
- Entry visibility: `Cast<UASClass>(Blueprint->ParentClass) != nullptr`, mirroring the handler's `CanNavigateToClass` condition.
- Execution: call the existing `FAngelscriptSourceCodeNavigation::NavigateToClass(ParentClass)` path, or `FSourceCodeNavigation::NavigateToClass`; both should route into the AS handler.

Use an owned entry point instead of "fixing the engine button" because the native gating lives in engine toolbar source that this repository does not own. An owned entry bypasses that gate and keeps the behavior controlled in the plugin.

## Points To Confirm During Implementation

1. **Exact engine gating shape**: determine whether the engine hides the button for non-native parents or shows it but short-circuits before calling navigation. Observe a Blueprint with an AS parent during implementation. In either case, the owned entry remains valid, so this does not block the design.
2. **Headless line-number population**: class/property line numbers may not be populated under `#ue57-headless`; tests should use a production-like fixture or target function/class navigation data that is actually populated.
3. **`code` missing from PATH**: `OsExecute` failure is silent in existing behavior and is not a regression from this change. Surface it through documentation or visible logging.

## Test Strategy

- Reuse the test seams in `AngelscriptSourceCodeNavigation.h`, such as `SetOpenLocationOverrideForTesting` / `NavigateToClassForTesting`, to assert "AS parent class -> correct path:line" without launching VS Code.
- Test layer: Editor tests under `AngelscriptEditor/Tests/`, with filenames starting with the `Angelscript` prefix.
- Use existing `AngelscriptSourceNavigationTests.cpp` as the reference because it already asserts path and line data.

## Key Files

| File | Role |
|---|---|
| `AngelscriptEditor/EditorMenuExtensions/ScriptEditorMenuExtension.cpp` | Add the toolbar/menu entry using the existing `UToolMenus` and `NavigateToClass` pattern |
| `AngelscriptEditor/SourceNavigation/AngelscriptSourceCodeNavigation.cpp/.h` | Reuse the navigation handler, VS Code launch path, and test seams |
| `AngelscriptEditor/Core/AngelscriptEditorModule.cpp` | Handler registration point; usually reference-only |
| `AngelscriptEditor/Tests/Angelscript*Tests.cpp` | New regression test |
