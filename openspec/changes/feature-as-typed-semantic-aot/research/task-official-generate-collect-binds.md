# Official Generate skips StaticJIT compatibility-bind collection

Date: 2026-08-18. Found in the whole-change review of
`feature-as-typed-semantic-aot`. Worktree `V:\`.

## Symptom

Group 5 / AOT / NativeCall tests prove HeaderInline (`IsRunningCommandlet`)
and native forms by creating a generation Engine through
`FAngelscriptStaticJITGenerationProfile::ApplyToEngineConfig()`, which sets
`bCollectStaticJITCompatibilityBinds = true`.

Official Editor Generate / Refresh does **not** use that helper. It builds a
disposable Engine in `FAngelscriptProjectSourceGraph::Compile` by writing
`FAngelscriptEngineConfig` fields by hand. The collect flag stays at its
default `false`.

When the flag is false:

- `AddNativeForm` deletes the form immediately
  (`StaticJIT/BytecodeJIT/StaticJITBinds.cpp`)
- `FAngelscriptStaticJITNativeCallRegistry::Attach` returns false
- `Bind_CoreGlobals` / `Bind_FDateTime` reviewed descriptors return without
  attaching

`BuildProjectArtifacts` still `TryCreate(..., TypedAST())` and later generates
C++, but Bind already ran without descriptors. The generator therefore cannot
treat reviewed native calls as HeaderInline / ExportedSymbol on the product
path.

Suite All does not exercise `ProjectSourceGraph::Compile`. Official
3558/0/0 does not cover this gap.

## Expected

A `StaticJITArtifact` compile uses the same generation-Engine recipe as
`ApplyToEngineConfig()`: Purpose = `StaticJITGeneration`, collect-binds =
true, capture follows the request profile. Cache scratch /
`bDisableCacheV2Persistence` overrides stay after that apply.

`DeveloperHIRDump` remains dump-only and must not start collecting
native-call metadata.

## Fix

`FAngelscriptProjectSourceGraph::Compile` now freezes a generation profile
and calls `ApplyToEngineConfig()` for `StaticJITArtifact` only. Cache scratch
and `bDisableCacheV2Persistence` still apply afterwards.
`DeveloperHIRDump` does not collect binds.

TDD:

- RED `semantic-aot-86-collect-binds-red` **0/1**
  (`Saved/Tests/semantic-aot-86-collect-binds-red/20260818_141418_145_0cc70d11`)
  failed on `bCollectStaticJITCompatibilityBinds`.
- GREEN `semantic-aot-86-collect-binds-green` **1/1**
  (`Saved/Tests/semantic-aot-86-collect-binds-green/20260818_141553_202_3e41e48c`).
