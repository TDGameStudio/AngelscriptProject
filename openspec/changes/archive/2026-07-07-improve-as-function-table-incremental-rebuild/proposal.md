## Why

When project gameplay code changes, the build recompiles all 36 generated `AS_FunctionTable_*` shards, such as `AS_FunctionTable_Engine_000.cpp` through `AS_FunctionTable_UMG_002.cpp`, even when the edit is unrelated to those bindings. This significantly slows iteration. The codegen path already has correct incremental guards, including `CommitOutput` content-hash comparison and deterministic sorting, so full recompilation is an optimization problem where the guard is being bypassed; it is **not intended design**. First identify the root cause, then apply a targeted fix.

## What Changes

- **Classify first (P0)**: run one incremental build after changing only an unrelated `.cpp` file and distinguish two cases:
  - (a) UHT rewrites `.gen.cpp` files, indicating a codegen-side content, path, or stale-delete issue.
  - (b) `.gen.cpp` files do not change, but their translation units recompile because public headers included by the shards, such as `AngelscriptEngine.h`, are considered stale.
- **Then apply the targeted fix**, choosing one path or running both based on the P0 result:
  - If the cause is (b), narrow the includes injected by `BuildShard` in `AngelscriptFunctionTableCodeGenerator.cs:591-593`, and extract a minimal stable header so changes to `AngelscriptEngine.h`, currently 1645 lines, do not invalidate every shard.
  - If the cause is (a), harden the codegen incremental guard: audit `DeleteStaleOutputs` at `:1229` for path normalization on Windows casing/separators, confirm the live set matches the write paths, prevent delete-and-regenerate churn, and confirm cross-module `.cpp` shards also use the `CommitOutput` guard.
- Do not assume a direction up front. The P0 experiment is the source of truth for the implementation path.

## Capabilities

### New Capabilities
None. This is a build-incremental performance improvement and does not add script-visible or tool-visible capability.

### Modified Capabilities
None at the spec level. Generated content and public API remain unchanged; only recompilation granularity improves.

## Impact

- Affected modules: `Plugins/Angelscript/Source/AngelscriptUHTTool`, the C# UBT codegen path, and public `AngelscriptRuntime` headers inside the submodule.
- Key files:
  - `AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`: `:103` Generate, `:370/:394` CommitOutput, `:581/:591` BuildShard, `:1229` DeleteStaleOutputs, and `:942` Build.cs dependency handling
  - `AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs`: `[UhtExporter]` entry point
  - `AngelscriptRuntime/AngelscriptRuntime.Build.cs:92-121`: wrapper inline and module allowlist
  - Shared shard headers: `AngelscriptRuntime/Core/AngelscriptEngine.h`, currently 1645 lines, `AngelscriptBinds.h`, and `FunctionCallers.h`
  - Reference docs: `Documents/Knowledges/ZH/Note_UBT.md`, section 7 at `:321-366`, and `Arch_UHTToolchain.md`, section 7 at `:527-533`
- Key unknowns that P0 must verify:
  1. The wrappers inline `.gen.cpp` through `UE_INLINE_GENERATED_CPP_BY_NAME`. Determine whether UBT's incremental decision for those files is based on **content hash or mtime**. If it is mtime-based, any timestamp rewrite, even with unchanged content, can trigger full recompilation.
  2. Cross-module generation is currently `enabled:false` in `cross-module-generation-modules.json`; the 36 files are mostly runtime shards plus link probes, so attribution must account for that.
- Verification: using the "change only an unrelated `.cpp`" scenario as the baseline, the number of recompiled `AS_FunctionTable_*` files should drop significantly after the fix, ideally to 0.
