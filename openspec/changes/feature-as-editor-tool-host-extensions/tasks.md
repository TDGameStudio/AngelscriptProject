## 1. Explicit Editor tool context

- [ ] 1.1 Add failing Editor tests for owner validation, Game Thread enforcement, Editor-world capture, empty/combined selections and asset metadata capture without loads in `AngelscriptEditorToolContextTests.cpp`. <!-- TDD -->
- [ ] 1.2 Add failing bound tests for 4096 actors/assets/folders, stable ordering and independent truncation flags. <!-- TDD -->
- [ ] 1.3 Implement `UAngelscriptEditorToolContext`, its captured-world `GetWorld()` behavior and `UAngelscriptEditorToolContextLibrary::CaptureCurrentEditorContext`. <!-- TDD -->
- [ ] 1.4 Add and satisfy point-in-time tests proving later selection/map changes do not refresh or retarget an existing context and no Saved/config write occurs. <!-- TDD -->

## 2. Dynamic AngelScript command extensions

- [ ] 2.1 Add UHT-visible command test classes and failing registry tests for concrete-class discovery, ShouldRegister, name validation, deterministic duplicate rejection and ordinary-class exclusion. <!-- TDD -->
- [ ] 2.2 Implement reflected command/chord types and focused `FAngelscriptEditorToolHostRegistry` command discovery with the `AngelscriptEditorTools` binding context. <!-- TDD -->
- [ ] 2.3 Add failing command-list tests for default/unbound/conflicting chords, user override preservation, PIE/SIE gating and CDO CanExecute behavior. <!-- TDD -->
- [ ] 2.4 Implement dynamic `FUICommandInfo` creation and Level Editor global-command-list mapping without changing existing menu-extension command behavior. <!-- TDD -->
- [ ] 2.5 Add failing execution tests proving one temporary instance and one fresh context per invocation, no field persistence, unavailable-context no-dispatch and exception-safe cleanup. <!-- TDD -->
- [ ] 2.6 Implement guarded synchronous command dispatch and bounded registration diagnostics. <!-- TDD -->

## 3. Dock-tab extension host

- [ ] 3.1 Add UHT-visible tab test classes and failing tests for valid registration, deterministic duplicate rejection, abstract/unrelated exclusion and AngelScript Tools workspace grouping. <!-- TDD -->
- [ ] 3.2 Implement `UScriptEditorTabExtension`, `UAngelscriptEditorTabSession` and nomad-tab spawner registration with validated stable TabName. <!-- TDD -->
- [ ] 3.3 Add failing lifecycle tests for one session per open singleton tab, exactly-once Initialize/Deinitialize, close/reopen fresh state and idempotent shutdown. <!-- TDD -->
- [ ] 3.4 Implement the standard Details-view property surface, explicit zero-parameter `CallInEditor` action section, empty state and reflected session ownership without exposing `SWidget` to script. <!-- TDD -->
- [ ] 3.5 Add failing explicit-context-refresh tests proving selection changes are inert until refresh, successful refresh replaces the snapshot and failed refresh preserves the prior one. <!-- TDD -->
- [ ] 3.6 Implement the native Refresh Context header and `BP_ContextRefreshed` dispatch. <!-- TDD -->
- [ ] 3.7 Add and satisfy body-only/compatible-structural/incompatible Full Reload tests for instance preservation, reflected fix-up, Details refresh and deterministic tab closure. <!-- TDD -->

## 4. Editor lifecycle and AngelScript integration

- [ ] 4.1 Wire one registry service into `FAngelscriptEditorModule` startup, initial compile, Full Reload, shutdown and engine pre-exit with test dependency seams. <!-- TDD -->
- [ ] 4.2 Add an inline AngelScript integration fixture proving script subclasses can register a command and tab, receive a captured context and invoke reflected properties/actions. <!-- TDD -->
- [ ] 4.3 Add headless/commandlet regression coverage proving no commands, tabs or sessions are registered without Slate/Level Editor availability. <!-- TDD -->
- [ ] 4.4 Confirm the host does not create a runner, scan tool source roots, persist tool/context data or modify Snippet/MenuExtension semantics. <!-- Non-TDD -->

## 5. Documentation and examples

- [ ] 5.1 Update `Documents/Knowledges/ZH/Guide_EditorExtension.md` first with command identity, shortcut, context snapshot, tab lifetime, Details UI and Hot Reload semantics. <!-- Non-TDD -->
- [ ] 5.2 Add checked documentation examples for a selection-aware command and a Details-hosted fixed tool tab; show durable state delegated to a user subsystem/runner. <!-- Non-TDD -->
- [ ] 5.3 Update `Plugins/Angelscript/README.md` with the concise English capability and the no-catalogue/no-arbitrary-Slate boundary. <!-- Non-TDD -->

## 6. Verification

- [ ] 6.1 Build through `Tools\RunBuild.ps1 -Label as-editor-tool-host -TimeoutMs 1800000 -NoXGE`. <!-- Non-TDD -->
- [ ] 6.2 Run `Angelscript.Editor.ToolHost` and `Angelscript.TestModule.Editor.ToolHost` through separate `Tools\RunTests.ps1` invocations. <!-- Non-TDD -->
- [ ] 6.3 Run existing `Angelscript.Editor.MenuExtensions` and `Angelscript.Editor.Module.Menu` regressions. <!-- Non-TDD -->
- [ ] 6.4 Run `Tools\RunTestSuite.ps1 -Suite Smoke -LabelPrefix as-editor-tool-host-smoke -TimeoutMs 600000`. <!-- Non-TDD -->
- [ ] 6.5 Re-run `openspec validate feature-as-editor-tool-host-extensions --type change --strict --no-interactive` and record evidence outside `tasks.md`. <!-- Non-TDD -->
