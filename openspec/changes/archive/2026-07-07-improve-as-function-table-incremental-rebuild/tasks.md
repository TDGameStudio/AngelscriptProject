# Tasks — improve-as-function-table-incremental-rebuild

> Changes live in the `Plugins/Angelscript` submodule: `AngelscriptUHTTool` C# codegen plus public `AngelscriptRuntime` headers. Follow `Documents/Guides/SubmoduleWorktreeWorkflow.md` for commits.
> Use only `Tools\RunBuild.ps1` / `Tools\RunTests.ps1` for verification. Do not hand-write UBT or Build.bat invocations.

## 1. P0 Diagnosis, Complete

- [x] 1.1 Re-check the artifact pipeline: `AngelscriptFunctionTableExporter.cs:22-28`, `AngelscriptFunctionTableCodeGenerator.cs:103/304/370`, and `AngelscriptRuntime.Build.cs:92-121`; confirm the 36 files consist of runtime shards plus link probes, with cross-module currently `enabled:false`.
- [x] 1.2 Record the mtime and content-hash baseline for `Intermediate/.../UHT/AS_FunctionTable_*.gen.cpp`, covering 29 editor-target shards.
- [x] 1.3 Re-test after an incremental build: no-op build has only 12 actions, and shard `.gen.cpp` files have 0 hash changes and 0 mtime changes.
- [x] 1.4 Split root cause: **files unchanged but translation units recompile -> suspect B, include-chain spread, confirmed; suspect A ruled out because codegen guards work**.
- [x] 1.5 Rule out cache artifacts: the controlled experiment, touching the central header, reproduces reliably and is not intermittent cache behavior.
- [x] 1.6 Determine wrapper inline incrementality: UBT relies on the include dependency graph plus header mtimes; unchanged shard content is insufficient when an included header is stale.
- [x] 1.7 Record the P0 conclusion in `findings.md`.
- [x] 1.8 Calibrate attribution: the user's standalone `[x/36]` log comes from packaging, the Game target through `Tools\RunPackage.ps1`; the editor target uses unity builds. Root cause is the same.
- [x] 1.9 Add the trigger matrix: host project `.cpp`, ordinary Runtime `.cpp`, `.Target.cs`, and `.uproject` do not trigger function table rebuilds; `AngelscriptBindDatabase.h` and `AngelscriptRuntime.Build.cs` trigger recompilation of the wrapper translation unit, shown as `Module.AngelscriptRuntime.2.cpp` under Editor and possibly standalone `AS_FunctionTable_*.cpp` under Game/package.

## 2. Fix Path B: Break Public-Header Include Spread

- [ ] 2.1 Analyze the three public headers injected by `BuildShard` in `AngelscriptFunctionTableCodeGenerator.cs:591-593` and determine which are actually required for shard compilation.
- [ ] 2.2 Extract a stable minimal registration-interface header, such as `AngelscriptBindsFwd.h`, and narrow shard dependency from `AngelscriptEngine.h`, currently 1645 lines, to that minimal header.
- [ ] 2.3 Update the codegen-injected include list.
- [ ] 2.4 Diff `.gen.cpp` output before and after the refactor and confirm generated artifacts are byte-equivalent except for include-line changes, with binding logic unchanged.

## 3. Fix Path A: Harden Codegen Incremental Guards, Downgraded

- [ ] 3.1 Audit `DeleteStaleOutputs` at `:1229`, including `Path.GetFullPath` and the casing comparison at `:1231`, and confirm the live set matches written paths under Windows case-insensitive behavior so files are not deleted and regenerated incorrectly.
- [ ] 3.2 Confirm whether cross-module `.cpp` shards at `:394` share the `CommitOutput` content-hash guard at `:370`; add it if missing.
- [ ] 3.3 Given the 1.6 mtime conclusion, ensure unchanged content does not rewrite timestamps; the existing `CommitOutput` write skip should satisfy this.

## 4. Verify

- [ ] 4.1 `Tools\RunBuild.ps1 -NoXGE` full build passes and artifacts are correct.
- [ ] 4.2 Re-test the 1.3 scenario, changing only an unrelated `.cpp`; after the fix, `AS_FunctionTable_*` recompilation count drops significantly, ideally to 0. Record before/after data in `findings.md`.
- [ ] 4.3 `Tools\RunTests.ps1` relevant binding tests pass and confirm no binding behavior regression.

## 5. Finish

- [ ] 5.1 Commit inside the `Plugins/Angelscript` submodule and update the parent repository gitlink.
- [ ] 5.2 Link the root-cause conclusion, design versus bug, and fix data back to GitHub Issue #1.
