# Design — improve-as-function-table-incremental-rebuild

## Artifact Pipeline Facts

`AS_FunctionTable_*` files are generated at build time by the C# UBT plugin **`AngelscriptUHTTool`**, which hooks into the UHT pipeline. It does not run inside the UE process.

- Registration entry point: `AngelscriptFunctionTableExporter.cs:22-28` with `[UhtExporter(Name="AngelscriptFunctionTable", CppFilters=["AS_FunctionTable_*.gen.cpp","AS_FunctionTable_*.cpp"], ModuleName="AngelscriptRuntime")]`.
- Main generation path: `AngelscriptFunctionTableCodeGenerator.cs:103 Generate` -> `:304 GenerateModule` -> `:1258 CollectEntries`, which collects `BlueprintCallable/Pure` functions and filters through `:1806 ShouldGenerate`, then `:370 CommitOutput`.
- Sharding rule: `MaxEntriesPerShard=256` at `:99`, rounded up per module. Engine has 4054 entries -> 16 shards. The 36 logged files are runtime shards, cross-module shards, and link probes across modules.
- Output directory: `Plugins/Angelscript/Intermediate/Build/<Platform>/<Target>/Inc/AngelscriptRuntime/UHT/AS_FunctionTable_*.gen.cpp`.
- Compile-graph inclusion: `AddGeneratedFunctionTableWrappers()` in `AngelscriptRuntime.Build.cs:92-121` predeclares a fixed number of wrapper `.cpp` files per module, for example Engine=32 and UMG=8. Each wrapper uses `#if __has_include(...) #include UE_INLINE_GENERATED_CPP_BY_NAME(...)` to inline the `.gen.cpp` into compilation.

## Incremental Guards

`AngelscriptUHTTool` does not implement its own hash/mtime incremental system; it relies on standard UBT mechanisms:

- `AddExternalDependency(headerPath)` at `:1269` and `AddExternalDependency(buildCsPath)` at `:942` mark inputs.
- `CommitOutput(path, contents)` at `:370` uses UBT content-hash comparison, so **unchanged content is not written**, which should avoid downstream recompilation.
- Output is deterministic: `entries.Sort` at `:316/:330` provides stable sorting, and includes use `SortedSet` at `:306`. Identical reflection input should produce byte-identical output.

Therefore, "changing only an unrelated `.cpp` still triggers full recompilation" means one of these guards is being bypassed somewhere.

## Two Main Suspects

**Suspect B, highest probability: public-header include spread.** Each shard includes `"Core/AngelscriptBinds.h"`, `"AngelscriptEngine.h"`, and `"FunctionCallers.h"` in `BuildShard:591-593`. Together these headers are 2756 lines, with `AngelscriptEngine.h` alone at 1645 lines. If any shared header is touched directly or indirectly by gameplay work, all 36 shard translation units become stale through the include graph. This matches `Note_UBT.md:332`, which describes public header edits spreading across Runtime through public include chains. In this case, `.gen.cpp` content does not change; the included headers do.

**Suspect A: codegen write or stale-delete churn.**
- `DeleteStaleOutputs(:1229)` enumerates by glob and deletes files outside the live set on each run. If the live-set comparison does not match `MakePath` output because of casing or path-separator differences, files may be deleted and regenerated, changing timestamps and triggering full recompilation.
- Cross-module shards use `Path.Combine(module.OutputDirectory, ...)` at `:394` and are `.cpp` rather than `.gen.cpp`; confirm whether they share the `CommitOutput` guard.

## Key Unknowns For P0

1. **Whether wrapper inline incremental decisions use content hash or mtime**: wrappers inline `.gen.cpp` files through `UE_INLINE_GENERATED_CPP_BY_NAME`. If UBT uses mtime, any timestamp rewrite, even with identical content, triggers full wrapper recompilation. That would make suspect A's delete-and-regenerate churn severe even when content is unchanged.
2. **Cross-module generation is `enabled:false`**: `cross-module-generation-modules.json` currently disables cross-module generation, so the 36 files are mostly runtime shards plus link probes. Attribution must account for that.

## P0 Diagnostic Experiment

During one incremental build after changing only an unrelated `.cpp`, with no reflected `UFUNCTION` changes, collect:

- Whether `AS_FunctionTable_*.gen.cpp` mtime and content hash change before/after the build.
- The recompile reason for these translation units in UBT `-verbose` logs: stale include versus the file itself changing.
- Whether UHT is invoked again. In theory, a `.cpp`-only change should not trigger UHT because UHT reads headers.

Route based on the evidence:
- Files are rewritten -> pursue suspect A on the codegen side.
- Files are unchanged but translation units recompile -> pursue suspect B on the include chain.

## Fix Direction

**If B, include spread:** narrow the includes injected by `BuildShard`. Extract a stable, rarely changed minimal registration interface header, such as `AngelscriptBindsFwd.h`, so the 36 shards depend only on that surface and do not all become stale when `AngelscriptEngine.h` changes. Modify `AngelscriptFunctionTableCodeGenerator.cs:591-593` and the relevant headers.

**If A, write/delete churn:** audit `Path.GetFullPath` and casing comparison in `DeleteStaleOutputs:1229`/`:1231` so the live set and write paths match under Windows case-insensitive behavior; confirm cross-module shards share the `CommitOutput` guard.

Both directions can be checked in parallel, but the P0 result decides the primary implementation.

## Risks

- This change touches UHT codegen. The regression surface is that generated artifact content must remain byte-identical and only recompilation granularity should improve. After any header split, compare generated `.gen.cpp` output against the pre-refactor output.
- The root cause might be an IDE/UBT `Intermediate/Build` cache issue rather than code, as noted in existing docs. P0 must rule that out.
