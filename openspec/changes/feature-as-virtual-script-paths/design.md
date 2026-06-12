## Context

UE virtual/content paths conventionally use slash-root names such as `/Game`, `/Engine`, `/Script`, and plugin roots. The old `as://project` design does not fit that convention and would make AS paths look unlike the rest of Unreal tooling.

The AS runtime currently stores only `RelativeFilename` and `AbsoluteFilename`. The compiler section name and diagnostics mostly use the absolute filename, which prevents memory-backed sources from having a stable user-visible identity.

## Decisions

### 1. Use `/Angelscript/...` paths

AS source identity uses a dedicated root instead of pretending to be UE package content:

```text
/Angelscript/Game/Gameplay/Enemy.as
/Angelscript/Plugin/Inventory/Gameplay/Item.as
/Angelscript/Memory/Immediate/Snippet_001.as
```

These paths are AS source identities only. They are not UE long package names and are not registered with `FPackageName::RegisterMountPoint()`.

### 2. Keep v1 source-focused

This change implements virtual source identity and memory-backed compile support. It does not add an API that evaluates AS snippets at runtime. `/Angelscript/Memory/Immediate/...` is reserved so that future realtime snippet execution can build on stable source names, diagnostics, and debugger section names.

### 3. Add descriptor-aware entry points

Add a small source descriptor carrying:

```text
VirtualPath
ModuleName
RelativeFilename
AbsoluteFilename optional
SourceText optional
SourceKind
```

Existing `FFilenamePair` and `FAngelscriptPreprocessor::AddFile()` remain compatibility adapters. New code can use `FAngelscriptScriptSource` and `FAngelscriptPreprocessor::AddSource()`. `FFilenamePair` carries `VirtualPath` so legacy queues, including editor hot reload, can preserve descriptor identity while keeping their old absolute/relative fields.

### 4. Preserve module compatibility

Project disk sources keep the current module rule:

```text
/Angelscript/Game/Gameplay/Enemy.as -> Gameplay.Enemy
```

Plugin disk sources also keep the existing root-relative module rule in v1 to avoid breaking imports from already-scanned plugin `Script/` roots. Memory sources are isolated:

```text
/Angelscript/Memory/Immediate/Snippet_001.as -> Angelscript.Memory.Immediate.Snippet_001
```

Any future change that prefixes plugin modules should be separate and migration-aware.

### 5. Carry virtual paths through observability

`FAngelscriptPreprocessorFileSummary` and `FAngelscriptModuleDesc::FCodeSection` gain `VirtualPath`. Disk-backed code sections keep physical `AbsoluteFilename`; memory-backed code sections use their virtual path as the compiler section name when no physical filename exists.

Editor directory watcher reload queues derive `FFilenamePair.VirtualPath` from the same effective root descriptors used by runtime discovery. This keeps plugin-root script changes on the plugin virtual path instead of falling back to `/Angelscript/Game/...`. If old test/tool code temporarily overrides only `AllRootPaths`, effective roots fall back to game roots for compatibility.

## Risks / Trade-offs

- The dedicated `/Angelscript` root avoids collision with `/Game`, but tools must learn that it is AS source identity rather than a package path.
- Keeping plugin module names compatible means `/Angelscript/Plugin/<PluginName>/...` is not fully reflected in module names yet.
- Memory source navigation cannot open a file until future tooling maps `/Angelscript/Memory/...` back to a provider buffer.

## Migration Plan

1. Add virtual path/source descriptor value types and focused tests.
2. Add descriptor-aware preprocessor entry points.
3. Add descriptor-aware source discovery while preserving existing filename discovery.
4. Add memory-source compile coverage through existing test helpers.
5. Surface virtual paths in summaries, module sections, and editor hot reload queues.
6. Keep old `AllRootPaths` override behavior compatible when `AllScriptRoots` descriptors are stale.
7. Update OpenSpec/docs references from `as://...` to `/Angelscript/...`.
