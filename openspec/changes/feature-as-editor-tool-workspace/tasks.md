## 1. Dependency and controller foundation

- [ ] 1.1 Confirm `feature-as-stateful-tool-execution` and `feature-as-editor-tool-host-extensions` public contracts are implemented and update this plan only for proven UHT-required signature differences. <!-- Non-TDD -->
- [ ] 1.2 Add failing controller tests for the `Draft`, `Compiling`, `CompileFailed`, `Ready`, `Running` and `RunFailed` state transitions and same-controller Busy rejection. <!-- TDD -->
- [ ] 1.3 Implement focused workspace document/view-model types and `FAngelscriptToolWorkspaceController` behind a mockable backend interface. <!-- TDD -->
- [ ] 1.4 Add and satisfy validation tests for the 20-document limit, unique canonical SourceId, exact ToolClassName, 1 MiB source bound and normalized SessionKey. <!-- TDD -->

## 2. Compile run context and reset orchestration

- [ ] 2.1 Add failing tests proving Compile is compile-only, Run Active never preprocesses, Compile & Run dispatches only a successful attempted source and nested statuses remain independent. <!-- TDD -->
- [ ] 2.2 Implement backend adaptation to `CompileToolSource`, `RunCompiledTool` and `CompileAndRunSource` with no Output Log parsing. <!-- TDD -->
- [ ] 2.3 Add failing last-known-good tests proving failed source remains in the buffer and only the separate Run Last Known Good action dispatches the exact revalidated active class. <!-- TDD -->
- [ ] 2.4 Implement attempted-versus-active controller state and conditional last-known-good action. <!-- TDD -->
- [ ] 2.5 Add failing tests for fresh context capture per execution, unavailable-context no-dispatch, context/session identity independence and arguments omission from persistence. <!-- TDD -->
- [ ] 2.6 Implement current-click context capture and exact SessionId-based Reset Session without history/draft/module side effects. <!-- TDD -->
- [ ] 2.7 Add and satisfy run-summary-setting tests for default-off `None`, compile `SourceAndDiagnostics` and explicit `SourceDiagnosticsAndRunSummary`. <!-- TDD -->

## 3. Bounded inert draft recovery

- [ ] 3.1 Add failing pure-store tests for the v1 root, 32-hex DocumentId validation, schema/identity/UTF-8 size checks and data-minimized record fields. <!-- TDD -->
- [ ] 3.2 Implement `FAngelscriptToolWorkspaceDraftStore` with explicit test root/clock/failure seams and production `ProjectSavedDir` routing. <!-- TDD -->
- [ ] 3.3 Add failing atomic-publication tests for record-before-index ordering, same-directory temporary files, stale-temp inertness and write/index failure recovery. <!-- TDD -->
- [ ] 3.4 Implement atomic draft/index publication and validated newest-first recovery. <!-- TDD -->
- [ ] 3.5 Add failing retention tests for 20 drafts, 1 MiB source, 2 MiB record, 4 MiB index, 32 MiB root, deterministic LRU eviction and active-draft protection. <!-- TDD -->
- [ ] 3.6 Implement deterministic retention, independent capacity warnings and exact Forget Draft. <!-- TDD -->
- [ ] 3.7 Add and satisfy autosave tests for two-second idle scheduling, tab-close/subsystem-shutdown flush and compile/run independence after save failure. <!-- TDD -->

## 4. History browsing and source export

- [ ] 4.1 Add failing controller tests proving recent/revision limits, metadata selection inertness, exact Load Into Buffer, dirty-buffer confirmation and no direct Tool History filesystem reads. <!-- TDD -->
- [ ] 4.2 Implement bounded history-panel adapters using only `ListRecentSources`, `ListRevisions`, `LoadRevision` and `LoadLastKnownGood`. <!-- TDD -->
- [ ] 4.3 Add failing export tests for dialog cancellation, `.as` enforcement, exact current/revision source selection, UTF-8-no-BOM atomic replacement and failure preservation. <!-- TDD -->
- [ ] 4.4 Implement `FAngelscriptToolWorkspaceExporter` with a testable save-dialog/filesystem seam and no managed destination convention. <!-- TDD -->
- [ ] 4.5 Add and satisfy watched-root tests proving export never invokes compilation directly and leaves normal DirectoryWatcher behavior unchanged. <!-- TDD -->

## 5. Workspace subsystem and Slate surface

- [ ] 5.1 Add failing subsystem tests proving one explicitly created runner, tab-close retention, exact reset and process-restart non-restoration. <!-- TDD -->
- [ ] 5.2 Implement `UAngelscriptToolWorkspaceSubsystem` as the sole workspace runner/document/draft scheduler owner. <!-- TDD -->
- [ ] 5.3 Implement `SAngelscriptToolWorkspace` with document identity fields, bounded source editor, explicit action row and Diagnostics/Result/Context/Recovery panes. <!-- Non-TDD -->
- [ ] 5.4 Add test seams and failing registration tests for the singleton nomad tab, Tools-menu entry, layout restore, no duplicate runner and headless inertness. <!-- TDD -->
- [ ] 5.5 Wire workspace registration into `FAngelscriptEditorModule` through the tool-host registry while leaving `FAngelscriptSnippetRunnerWindow` unchanged. <!-- TDD -->
- [ ] 5.6 Add UI-controller tests proving synchronous busy disables conflicting actions, no Stop/Cancel is exposed and diagnostic selection navigates the current buffer. <!-- TDD -->

## 6. Documentation

- [ ] 6.1 Update `Documents/Knowledges/ZH/Guide_EditorExtension.md` first with the workspace workflow, runner host scope, explicit last-known-good action and source/history/draft separation. <!-- Non-TDD -->
- [ ] 6.2 Document draft and Tool History Saved roots, data minimization, exact Reset/Forget effects, export ownership and synchronous no-cancel limitation. <!-- Non-TDD -->
- [ ] 6.3 Update `Plugins/Angelscript/README.md` with a concise English workspace section and no-catalogue/no-IDE-replacement boundary. <!-- Non-TDD -->

## 7. Verification

- [ ] 7.1 Build through `Tools\RunBuild.ps1 -Label as-editor-tool-workspace -TimeoutMs 1800000 -NoXGE`. <!-- Non-TDD -->
- [ ] 7.2 Run `Angelscript.Editor.ToolWorkspace`, `Angelscript.Editor.ToolExecution`, `Angelscript.Editor.ToolHistory` and `Angelscript.Editor.ToolHost` through separate test invocations. <!-- Non-TDD -->
- [ ] 7.3 Run `Angelscript.TestModule.Core.SnippetExecution` and existing Editor module menu regressions. <!-- Non-TDD -->
- [ ] 7.4 Run `Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-editor-tool-workspace-smoke -TimeoutMs 600000`. <!-- Non-TDD -->
- [ ] 7.5 Package Development and Shipping through `Tools\RunPackage.ps1` and confirm no Editor workspace/draft code enters non-Editor targets. <!-- Non-TDD -->
- [ ] 7.6 Re-run `openspec validate feature-as-editor-tool-workspace --type change --strict --no-interactive` and record evidence outside `tasks.md`. <!-- Non-TDD -->
