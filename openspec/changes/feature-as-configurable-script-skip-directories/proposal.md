## Why

The AngelScript runtime decides which `.as` directories to compile in cooked / non-editor
builds by **hardcoded directory-name matching**. Directories literally named `Examples`,
`Dev`, and `Editor` are silently skipped when development/editor scripts are excluded
(cooked games, cook commandlet, simulate-cooked). This was the direct cause of the recent
packaging issue: `Example_Actor.as` had to be physically relocated out of `Script/Examples/`
into `Script/Game/` just so its type would cook into a packaged build.

Hardcoding these names makes the convention invisible and inflexible: projects cannot keep
their own `Examples/`-style folder in cooked builds, cannot add extra development-only
folders (e.g. `Sandbox`, `Prototype`), and cannot rename the editor-only folder. Making the
skip lists configurable removes the hidden coupling and lets projects control exactly which
folders are development-only vs editor-only without moving files around.

## What Changes

- Add config-driven, project-overridable lists of **development-only** and **editor-only**
  script directory names to `UAngelscriptSettings`, defaulting to the current hardcoded values
  (`Examples`, `Dev` for development; `Editor` for editor) so existing behavior is preserved.
- Snapshot these lists into the engine runtime config (`FAngelscriptEngineConfig`), mirroring
  how `DisabledBindNames` is already captured, so the source-discovery layer stays decoupled
  from UObject settings and remains unit-testable.
- Thread the configured directory-name lists through `IAngelscriptSourceProvider::FindSources`
  (and `FAngelscriptDiskSourceProvider::FindScriptFiles`) instead of comparing against string
  literals.
- Remove the hardcoded `TEXT("Examples")` / `TEXT("Dev")` / `TEXT("Editor")` comparisons in
  both `FAngelscriptDiskSourceProvider::FindScriptFiles` (production path) and the legacy
  `FAngelscriptEngine::FindScriptFiles` (used by `FindAllScriptFilenames`).

## Capabilities

### New Capabilities
- `as-configurable-script-skip-directories`: how the runtime determines which script
  subdirectories are development-only or editor-only when discovering `.as` sources, and how
  projects override those lists via config.

### Modified Capabilities
<!-- None: source-discovery behavior is not currently captured by an existing spec. -->

## Impact

- Settings: `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`
  (new `Config` array properties).
- Runtime config: `FAngelscriptEngineConfig` in `AngelscriptEngine.h/.cpp`
  (`FromCurrentProcess()` snapshot).
- Source discovery: `IAngelscriptSourceProvider` / `FAngelscriptDiskSourceProvider`
  (`AngelscriptSourceProvider.h/.cpp`) and the legacy `FAngelscriptEngine::FindScriptFiles`
  (`AngelscriptEngine.cpp`).
- Tests: new runtime-integration coverage for the configurable skip behavior.
- Docs: the "hardcoded Examples/Dev/Editor" note becomes a "configurable skip directories"
  note; packaging guidance updated.
- Backward compatibility: defaults reproduce today's behavior exactly; no migration needed.
