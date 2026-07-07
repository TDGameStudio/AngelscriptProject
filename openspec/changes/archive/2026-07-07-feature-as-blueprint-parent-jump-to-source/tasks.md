# Tasks — feature-as-blueprint-parent-jump-to-source

> Changes live in the `Plugins/Angelscript/Source/AngelscriptEditor` submodule path. Follow `Documents/Guides/SubmoduleWorktreeWorkflow.md` for the submodule commit and parent repository gitlink update.
> Tests follow project conventions: Editor layer under `AngelscriptEditor/Tests/`, filenames with the `Angelscript` prefix, existing navigation test seams, and no real VS Code launch.

## 1. Confirm Engine Gating Shape

- [ ] 1.1 In a Blueprint editor whose parent is an AS class, manually confirm the top-right "open parent class source" action state: hidden, visible but ineffective, or treated as a normal Blueprint parent. Record the result.
- [ ] 1.2 Re-check the `CLASS_CompiledFromBlueprint` flag in `AngelscriptClassGenerator.cpp:3319` and confirm AS parent classes are not treated as native classes by the engine.
- [ ] 1.3 Re-check the registered `FAngelscriptSourceCodeNavigation` handler in `AngelscriptSourceCodeNavigation.cpp/.h` and the registration point at `AngelscriptEditorModule.cpp:815`; confirm `NavigateToClass` supports `UASClass`/`UASStruct`.

## 2. Implement Toolbar Entry <!-- TDD -->

- [ ] 2.1 Write the failing Editor-layer test first: create a scenario whose parent class is an AS class, trigger the action through the navigation test seam, and assert the resolved `path:line` without launching VS Code. Use `AngelscriptSourceNavigationTests.cpp` as reference.
- [ ] 2.2 Add an "Open Angelscript Parent Source" entry for the Blueprint editor in `ScriptEditorMenuExtension.cpp` through `UToolMenus`.
- [ ] 2.3 Bind entry visibility/availability to `Cast<UASClass>(Blueprint->ParentClass) != nullptr`, mirroring `CanNavigateToClass`.
- [ ] 2.4 Implement the action by calling the existing `FSourceCodeNavigation::NavigateToClass(ParentClass)` path, which routes to the AS handler and then `OpenVsCode`/`OpenModule`.
- [ ] 2.5 When the parent class cannot be resolved to script source, emit visible logging or notification; do not fail silently or open the wrong location.
- [ ] 2.6 Run the 2.1 test until it passes.

## 3. Boundaries And Regressions

- [ ] 3.1 Verify that C++ parent class behavior is unaffected: the engine-provided action still works, and the Angelscript-owned entry is hidden or does not interfere.
- [ ] 3.2 Verify that an AS parent class with an existing source file navigates to the correct `path:line`.
- [ ] 3.3 Verify that missing `code` on PATH does not crash; document that this follows the existing `OsExecute` behavior.

## 4. Verify And Finish

- [ ] 4.1 `Tools\RunBuild.ps1 -NoXGE` passes.
- [ ] 4.2 `Tools\RunTests.ps1`, or `RunTestSuite.ps1`, runs the new Editor test successfully.
- [ ] 4.3 Commit inside the submodule and update the parent repository gitlink.
- [ ] 4.4 Link the conclusion and implementation back to GitHub Issue #2.
