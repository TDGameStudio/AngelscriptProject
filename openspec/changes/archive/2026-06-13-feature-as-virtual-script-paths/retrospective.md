# Retrospective — feature-as-virtual-script-paths

> Development process and lessons learned. This file is archived with the change as a reference for similar future work: naming refactors, cross-submodule changes, and virtual path extensions.

## 1. What This Change Did

This change introduced a UE-style virtual source identity layer for AngelScript sources (`/Angelscript/...`), replacing the old `as://...` URI scheme. Core deliverables:

- Three canonical path families: `/Angelscript/Game/...`, `/Angelscript/Plugin/<Name>/...`, and `/Angelscript/Memory/<Provider>/...`, with `/Memory/Immediate` reserved for future live snippets.
- Value-type layer (`AngelscriptSource.h`): `FAngelscriptVirtualPath`, `FAngelscriptSource`, `FAngelscriptSourceRoot`, `EAngelscriptSourceKind`.
- Descriptor-aware entry points: `FAngelscriptPreprocessor::AddSource()` and `FAngelscriptEngine::FindAllScriptSources()`. Old `AddFile()` / `FindAllScriptFilenames()` become compatibility adapters.
- Observability: `VirtualPath` flows through file summaries and module code sections; memory sources use virtual paths as compiler section names.
- Editor hot reload queues derive virtual paths from the same valid-root descriptors, preserving plugin identity.

## 2. Key Design Decisions

- **Use a dedicated `/Angelscript` root instead of pretending to be a `/Game` package path.** This is AS source identity only. It does not register an `FPackageName` mount point, avoiding semantic conflict with UE packages.
- **Keep v1 conservative: source identity only, no snippet execution.** `/Memory/Immediate` is reserved but no execution API is exposed; that risk belongs to a separate later change.
- **Prioritize module-name compatibility.** In v1, plugin sources still use root-relative module names and do not include the plugin name in the module name, avoiding breaks in imports from already-scanned plugin `Script/` roots. Plugin-prefix migration is a separate migration-aware change.
- **Use additive changes and keep old APIs as adapters.** 62+ test call sites using `AddFile` require no change, and `FindAllScriptFilenames` automatically gains the `VirtualPath` field.

## 3. Naming Refactor Lessons

The initial type names had redundant `Script` roots. The `Angelscript` prefix already contains "script", so adding `Script` again reads as "Angel-script script source." Names were normalized:

| Old Name | New Name |
|------|------|
| `EAngelscriptScriptSourceKind` | `EAngelscriptSourceKind` |
| `FAngelscriptScriptSource` | `FAngelscriptSource` |
| `FAngelscriptVirtualScriptPath` | `FAngelscriptVirtualPath` |
| `FAngelscriptScriptRoot` | `FAngelscriptSourceRoot` |

File names and namespaces were then aligned: `AngelscriptScriptSource.{h,cpp}` → `AngelscriptSource.{h,cpp}`, and `AngelscriptScriptSource_Private` → `AngelscriptSource_Private`.

### Lessons and Method

- **Separate identifiers from natural language.** While renaming types, strings such as "Virtual script path must end with .as", test-suite topic `VirtualScriptPaths`, and feature name `feature-as-virtual-script-paths` are conceptual natural language rather than type identifiers. Keeping them preserves consistency; only identifiers should change.
- **Use whole-word boundaries (`\b`) to avoid longer-identifier damage.** `FAngelscriptScriptRoot` is a prefix in test class name `FAngelscriptScriptRootDiscoveryProjectRoot...Test`; `\bFAngelscriptScriptRoot\b` is not a boundary before `D`, so the test class name is preserved correctly. Those are independent identifiers aligned with the suite topic.
- **Dry-run hit counts and check new-name availability before renaming.** After replacement, grep for remaining old names and double-replacement mistakes such as `SourceSource` / `VirtualVirtual`, validating both directions.
- **Use `git mv` for file renames to preserve history.** Self-includes and namespaces are adjusted separately after the move.

### Deliberately Unchanged Items

- Method names `FromMemorySource` and `FindAllScriptSources`: these follow the rhythm of `FromGameFile` / `FromPluginFile`. Memory sources have no File concept, and renaming would break symmetry.

## 4. Commit Strategy Lessons

- **Commit hardening separately before rename work, keeping rename diffs clean.** The locally prepared `TryFromMemorySource` memory-root validation (task 6.2) was committed first, then the rename was performed.
- **Submodule first, parent gitlink second.** For dual-repo changes, commit `Plugins/Angelscript` first, then the parent gitlink bump.
- **Split renames into two commits: type names first, file names second.** Each commit gets independent build verification and an easy-to-review diff.
- **Commit only task-related files.** Pre-existing parent-repo changes such as `.gitignore` / `AGENTS.md` were left untouched.

Related submodule commit chain:

```text
<file-rename>  Refactor: rename AngelscriptScriptSource files to AngelscriptSource
<type-rename>  Refactor: drop redundant Script from virtual source type names
<hardening>    Test: fail closed when memory source uses non-Memory virtual path
```

## 5. Verification

- After each rename, ran `Tools\RunBuild.ps1` to fully rebuild the editor target and confirmed `Result: Succeeded` + exit code 0 (all 5 module DLLs linked).
- Focus test prefixes: `Angelscript.TestModule.{FileSystem,Preprocessor,Compiler}.VirtualScriptPaths.*` and `Angelscript.Editor.DirectoryWatcher.*`.

### Pitfall

- **Background builds fail with relative script paths.** PowerShell tool cwd may remain inside the submodule `Plugins/Angelscript`, where `-File Tools\RunBuild.ps1` cannot be found. Use the absolute path `D:\Workspace\AngelscriptProject\Tools\RunBuild.ps1`.

## 6. Known Limitations and Follow-up Work (design.md trade-off)

- Plugin module names still do not include plugin prefixes, so same-relative-path script module names can collide across plugins. This needs a separate migration-aware change.
- `/Angelscript/Memory/...` cannot yet map back to provider buffers, so memory sources cannot "jump to file."
- `/Angelscript/Memory/Immediate` live snippet execution: source identity, diagnostics, and debugger sections are prepared, making this the highest-value next step.
