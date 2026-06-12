## Why

Angelscript currently identifies script sources by physical root plus root-relative filename. That works for disk-backed project scripts, but it does not give memory-backed sources a stable identity and it does not expose a UE-style source path that can survive future live snippet execution.

This change introduces a small virtual source identity layer for AS sources. The first version focuses on project/plugin disk scripts and memory-backed sources; realtime snippet execution remains a follow-up feature.

## What Changes

- Replace the old URI-style `as://...` proposal with UE-style virtual source paths under `/Angelscript/...`.
- Add canonical virtual paths for project, plugin, and memory sources:
  - `/Angelscript/Game/<Relative>.as`
  - `/Angelscript/Plugin/<PluginName>/<Relative>.as`
  - `/Angelscript/Memory/<Provider>/<Relative>.as`
- Reserve `/Angelscript/Memory/Immediate/...` for future realtime snippets, while only implementing source identity and compilation support in this change.
- Add source descriptors that carry virtual path, module name, optional physical path, optional source text, and source kind.
- Keep existing disk discovery and project module-name behavior compatible through adapter APIs.
- Surface virtual paths through preprocessing summaries and module code sections.

## Capabilities

### New Capabilities

- `as-virtual-script-paths`: Defines canonical `/Angelscript/...` source paths, source descriptor behavior, module-name compatibility, memory-backed source support, and observability requirements.

## Impact

- Runtime source identity and preprocessing: `FAngelscriptEngine::FindAllScriptFilenames`, `FAngelscriptPreprocessor::AddFile`, and module-name derivation gain descriptor-aware counterparts while retaining compatibility adapters.
- Runtime diagnostics and metadata: preprocessing summaries and module code sections carry virtual paths in addition to physical paths where available.
- Editor hot reload: directory watcher queues preserve virtual path metadata so plugin scripts keep `/Angelscript/Plugin/<PluginName>/...` identity across reload.
- Tests: focused runtime integration coverage under FileSystem, Preprocessor, and Compiler themes, plus editor directory watcher coverage for hot reload queue metadata.
- Documentation/OpenSpec: replace old `as://` and provider-registry scope with `/Angelscript/...` v1 behavior.
