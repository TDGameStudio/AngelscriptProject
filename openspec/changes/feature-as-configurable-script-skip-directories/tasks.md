# Tasks

> Plan-only deliverable. Nothing is implemented yet. Tasks are ordered by dependency and
> sized for one sitting each. TDD markers indicate whether to write the test first.

## 1. Settings surface

- [ ] 1.1 `<!-- Non-TDD -->` Add two config arrays to `UAngelscriptSettings`
  (`Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`):
  `TArray<FString> DevelopmentOnlyScriptDirectories { "Examples", "Dev" }` and
  `TArray<FString> EditorOnlyScriptDirectories { "Editor" }`, both
  `UPROPERTY(Config, EditDefaultsOnly, Category="Angelscript", Meta=(ConfigRestartRequired=true))`
  with doc comments. Verify: `Tools\RunBuild.ps1`.

## 2. Runtime config snapshot

- [ ] 2.1 `<!-- Non-TDD -->` Add matching fields to `FAngelscriptEngineConfig`
  (`AngelscriptEngine.h`): `TArray<FString> DevelopmentOnlyScriptDirectories;`
  `TArray<FString> EditorOnlyScriptDirectories;` (mark `UPROPERTY()` to match siblings).
- [ ] 2.2 `<!-- Non-TDD -->` In `FAngelscriptEngineConfig::FromCurrentProcess()`
  (`AngelscriptEngine.cpp`), copy the two lists from `GetDefault<UAngelscriptSettings>()`,
  mirroring the existing `DisabledBindNames` snapshot. Verify: `Tools\RunBuild.ps1`.

## 3. Source provider signature

- [ ] 3.1 `<!-- Non-TDD -->` Extend `IAngelscriptSourceProvider::FindSources` and
  `FAngelscriptDiskSourceProvider::FindScriptFiles`
  (`AngelscriptSourceProvider.h`) with
  `const TArray<FString>& DevelopmentOnlyDirectories, const TArray<FString>& EditorOnlyDirectories`.
- [ ] 3.2 `<!-- Non-TDD -->` Update `FAngelscriptDiskSourceProvider::FindScriptFiles`
  (`AngelscriptSourceProvider.cpp`) to replace the literal `Examples`/`Dev`/`Editor`
  comparisons with `DevelopmentOnlyDirectories.Contains(Dir)` /
  `EditorOnlyDirectories.Contains(Dir)`; propagate both lists through the recursion.
- [ ] 3.3 `<!-- Non-TDD -->` Update the caller `FAngelscriptEngine::FindAllScriptSources`
  (`AngelscriptEngine.cpp`) to pass `RuntimeConfig.DevelopmentOnlyScriptDirectories` /
  `EditorOnlyScriptDirectories` into `FindSources`. Verify: `Tools\RunBuild.ps1`.

## 4. Legacy discovery path

- [ ] 4.1 `<!-- Non-TDD -->` Decide (per design Open Question) whether to redirect the legacy
  `FAngelscriptEngine::FindScriptFiles` / `FindAllScriptFilenames` onto the provider or keep it.
  If kept, replace its hardcoded literals with the same config-sourced lists. Note remaining
  callers of `FindAllScriptFilenames` in the change notes. Verify: `Tools\RunBuild.ps1`.

## 5. Tests

- [ ] 5.1 `<!-- TDD -->` Add a runtime-integration test
  (`AngelscriptTest/<Theme>/AngelscriptScriptSkipDirectoriesTests.cpp`, `Angelscript` prefix)
  driving `FAngelscriptDiskSourceProvider::FindSources` against a temp directory tree with
  `Examples/`, `Dev/`, `Editor/`, and a custom `Sandbox/` folder:
  - default lists + skip flags skip `Examples`/`Dev`/`Editor`;
  - custom dev list including `Sandbox` skips `Sandbox`;
  - empty list skips nothing in that category;
  - include mode (`bSkip*` false) skips nothing.
  Use the existing source-provider directly (pure, no World needed). Verify:
  `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.<Theme>.*"`.
- [ ] 5.2 `<!-- TDD -->` Assert the single-source-of-truth requirement: both the provider and
  the legacy `FindAllScriptFilenames` path honor an injected/custom list (or, if 4.1 collapsed
  the legacy path, assert the provider is the only path). Verify: `Tools\RunTests.ps1`.

## 6. Docs & cleanup

- [ ] 6.1 `<!-- Non-TDD -->` Update the "hardcoded Examples/Dev/Editor" guidance (packaging /
  script-layout docs, and any ZH knowledge note) to describe the configurable lists and defaults.
- [ ] 6.2 `<!-- Non-TDD -->` Cross-link from the packaging change notes
  (`fix-cooked-packaging-bind-database-init`) that relocating `Example_Actor.as` is now optional
  given configurable skip directories.

## 7. Verification

- [ ] 7.1 `Tools\RunBuild.ps1` clean.
- [ ] 7.2 `Tools\RunTests.ps1 -TestFilter "Angelscript.TestModule.<Theme>.*"` green for the new tests.
- [ ] 7.3 (Optional, manual) Re-run `Tools\RunPackage.ps1` with `Example_Actor.as` moved back
  under `Script/Examples/` but `Examples` removed from `DevelopmentOnlyScriptDirectories`, and
  confirm the type still cooks into the package.
