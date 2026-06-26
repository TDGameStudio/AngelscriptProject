## Context

Script source discovery walks the configured script roots recursively for `.as` files.
During the walk, directories are skipped based on whether development/editor scripts are
included for the current run. The include decision already exists and is correct:

```
FindAllScriptSources():
  bSkipDevelopmentScripts = !ShouldUseEditorScripts();
  bSkipEditorScripts      = bSkipDevelopmentScripts;
  Dependencies.SourceProvider->FindSources(roots, bSkipDevelopmentScripts, bSkipEditorScripts, out);

ShouldUseEditorScripts() == bUseEditorScripts ==
  WITH_EDITOR && ((bIsEditor && !bRunningCommandlet) || bForcePreprocessEditorCode) && !bSimulateCooked
```

What is hardcoded is only the **set of directory names** treated as development-only / editor-only.
There are two copies of the literal comparison:

1. `FAngelscriptDiskSourceProvider::FindScriptFiles` — production path (via `FindSources`),
   in `AngelscriptSourceProvider.cpp`.
2. `FAngelscriptEngine::FindScriptFiles` — legacy path used by `FindAllScriptFilenames`,
   in `AngelscriptEngine.cpp`.

Both contain:

```cpp
if (bSkipDevelopmentScripts) { if (Dir == TEXT("Examples")) continue; if (Dir == TEXT("Dev")) continue; }
if (bSkipEditorScripts)      { if (Dir == TEXT("Editor"))   continue; }
```

`UAngelscriptSettings` is `UCLASS(Config=Engine, DefaultConfig)` and already carries
config arrays like `DisabledBindNames` and `AdditionalEditorOnlyScriptPackageNames`. The
engine snapshots settings into `FAngelscriptEngineConfig` (`DisabledBindNames` is copied in
`FromCurrentProcess()`), keeping the discovery layer free of UObject access.

## Goals / Non-Goals

**Goals:**
- Make the development-only and editor-only directory-name lists project-configurable.
- Preserve current behavior by default (`Examples`, `Dev`; `Editor`).
- Keep the source provider decoupled from `UObject`/settings (pass data in, no `GetDefault`).
- Single source of truth: both discovery paths consume the same lists.

**Non-Goals:**
- Changing *when* development/editor scripts are included (the `ShouldUseEditorScripts`
  decision is unchanged).
- Path/glob matching or nested-path rules — this stays a per-segment directory-**name** match,
  same semantics as today.
- Per-root or per-plugin overrides (single project-wide list for each category for now).
- Case-sensitivity changes — preserve the current exact `==` comparison semantics.

## Decisions

### 1. Config lives on `UAngelscriptSettings`, snapshotted into `FAngelscriptEngineConfig`
Add two `UPROPERTY(Config, EditDefaultsOnly, Meta=(ConfigRestartRequired=true))` arrays:

```cpp
TArray<FString> DevelopmentOnlyScriptDirectories { TEXT("Examples"), TEXT("Dev") };
TArray<FString> EditorOnlyScriptDirectories      { TEXT("Editor") };
```

`FAngelscriptEngineConfig::FromCurrentProcess()` copies them into new config fields
(`DevelopmentOnlyScriptDirectories`, `EditorOnlyScriptDirectories`). The engine then passes
these to `FindSources`.

Rationale: mirrors the proven `DisabledBindNames` pattern; the provider already receives
booleans from the engine, so adding the name lists is a natural extension and keeps the
provider testable without a live `UAngelscriptSettings`.

Alternative considered: read `GetDefault<UAngelscriptSettings>()` directly inside
`FAngelscriptDiskSourceProvider`. Rejected — it couples the pure disk provider to the UObject
settings system and breaks the dependency-injection seam used by tests.

### 2. Extend `FindSources` / `FindScriptFiles` signatures with the name lists
`IAngelscriptSourceProvider::FindSources` and `FAngelscriptDiskSourceProvider::FindScriptFiles`
gain two `const TArray<FString>&` parameters for the development-only and editor-only names.
The skip check becomes `if (bSkipDevelopmentScripts && DevDirs.Contains(Dir)) continue;` etc.

Rationale: keeps the include decision (booleans) and the name lists as explicit inputs;
no hidden globals. The legacy `FAngelscriptEngine::FindScriptFiles` is updated the same way
(or made to delegate to the provider) so both paths share semantics.

### 3. Defaults preserve behavior; empty list means "skip nothing in that category"
If a project sets an empty `DevelopmentOnlyScriptDirectories`, no directory is treated as
development-only (everything cooks). Defaults reproduce today's `Examples`/`Dev`/`Editor`.

## Risks / Trade-offs

- [Signature change ripples to all `IAngelscriptSourceProvider` implementers/tests] → There is
  one production implementer (`FAngelscriptDiskSourceProvider`); update it and any test doubles
  in the same change. Keep the parameter order stable and documented.
- [Two discovery code paths can drift] → Have both consume the same config-sourced lists; add a
  test asserting both honor an injected custom list (or collapse the legacy path onto the
  provider if low-risk).
- [Misconfiguration cooks editor-only scripts] → Document clearly that emptying
  `EditorOnlyScriptDirectories` may pull editor-only code into cooked builds; defaults are safe.
- [`ConfigRestartRequired`] → Lists are read at engine init snapshot time; changing them needs a
  restart, consistent with sibling settings.

## Migration Plan

No data migration. Projects that previously relocated files out of `Examples/` purely to cook
them (e.g. the recent `Example_Actor.as` move) can optionally either keep the relocation or add
their folder to (or remove it from) the configured lists. Defaults mean no action is required.

## Open Questions

- Should the legacy `FAngelscriptEngine::FindScriptFiles` be deleted/redirected to the provider
  rather than maintained in parallel? (Decide during implementation based on remaining callers
  of `FindAllScriptFilenames`.)
- Do we want a project-relative-path form (e.g. `Examples/Internal`) later, or is per-segment
  name matching sufficient? (Out of scope now; note as possible follow-up.)
