# P0 Diagnostic Findings — improve-as-function-table-incremental-rebuild

> Experiment date: 2026-06-25. Engine: UE 5.8. Platform: Win64. The experiment was read-only except for one controlled mtime-only `touch`, which was restored. No source content changed.

## One-Line Conclusion

**This is not a codegen bug and not intentional "full regeneration by design". The root cause is suspect B: public-header include-chain spread from shard includes.** Every `AS_FunctionTable_*` shard includes `"Core/AngelscriptEngine.h"`, a 1645-line central header referenced by 164 files. When that header, or either of the other two public headers, changes mtime, all shard translation units become stale and recompile. Codegen's own incremental guard, `CommitOutput` content-hash skipping, **works correctly**.

## Evidence Chain

### Fact 1 — Codegen Incremental Guards Work

- Recorded sha256 and mtime baselines for 29 `.gen.cpp` files in the UnrealEditor target.
- Ran one incremental editor build with `Tools\RunBuild.ps1 -NoXGE`; this build even invalidated the makefile because of `AngelscriptProjectEditor.Target.cs` and recompiled `Module.AngelscriptRuntime.12/13.cpp`.
- Re-tested after the build: **0 of 29 `.gen.cpp` files changed hash and 0 changed mtime**.
- Therefore, `CommitOutput` content-hash comparison does skip writing unchanged files. **Suspect A, codegen writes, `DeleteStaleOutputs` false deletes, or path mismatch, is ruled out.**

### Fact 2 — Touching The Central Public Header Recompiles All Shards

- Touched `AngelscriptEngine.h`, changing only mtime with byte-identical content, then restored it.
- Ran another incremental build: UBT executed **71 actions**, recompiling almost every `Module.AngelscriptRuntime.*.cpp`, where editor-target shards are inlined into unity files, plus many `Module.AngelscriptTest.*` files.
- By comparison, the no-op build in Fact 1 had only 12 actions.
- Therefore, shard recompilation is driven entirely by whether public headers included by shards are stale, not by shard content. **Suspect B is confirmed.**

### Fact 3 — Spread Radius Of Central Headers

- `AngelscriptEngine.h`: 1645 lines, referenced by **164** `.h/.cpp` files.
- `AngelscriptBinds.h`: 718 lines, referenced by **131** files.
- `FunctionCallers.h`: 393 lines.
- All three are unconditionally injected into every shard by `BuildShard()` in `AngelscriptFunctionTableCodeGenerator.cs:591-593`; disk artifacts confirmed this.
- Any gameplay edit that indirectly touches one of these highly central headers can trigger recompilation of all 36 shards.

## Attribution Calibration For The User's 36 Standalone `[x/36]` Log

- The user log shows **standalone** `Compile AS_FunctionTable_*.cpp` entries, while this editor build inlines shards into **unity** files such as `Module.AngelscriptRuntime.N.cpp`.
- Disk layout confirms that the **UnrealEditor target** puts 60 wrappers into unity, while the **UnrealGame target** also has 60 standalone wrappers under `.../UnrealGame/.../Gen/AngelscriptGeneratedFunctionTableWrappers/*.cpp`.
- The user log comes from **packaging**, via `Tools\RunPackage.ps1` -> `RunUAT BuildCookRun -build`, using a Game/Client configuration from the newly added script. That is a Game target, where shards compile as standalone files and therefore appear as `[x/36]`.
- The two target shapes differ, but the **root cause is identical**: shards include volatile central public headers. In Game builds, the non-unity form makes the cost of a single stale header more visible because 36 independent translation units recompile.

### Terminology Calibration: Editor Target vs Game/Package Target

- **Editor target**: `Tools\RunBuild.ps1` builds `AngelscriptProjectEditor` by default. The artifacts are `UnrealEditor-*.dll` files loaded by Unreal Editor. Under this target, generated function-table wrappers are folded into unity files such as `Module.AngelscriptRuntime.2.cpp`, so logs often show `Compile Module.AngelscriptRuntime.2.cpp` rather than individual `Compile AS_FunctionTable_*.cpp` lines.
- **Game/package target**: `Tools\RunPackage.ps1` uses `RunUAT BuildCookRun -build` to build a non-editor runtime game target, such as `UnrealGame` or a client configuration, for cook/package/stage/archive. This target also has wrapper files under `.../UnrealGame/.../Gen/AngelscriptGeneratedFunctionTableWrappers/*.cpp`; in non-unity or standalone compilation, logs directly show individual `Compile AS_FunctionTable_*.cpp` lines.

## 2026-06-26 Additional Trigger Matrix

Before the experiment, confirmed the editor build baseline: `Tools\RunBuild.ps1 -NoXGE` reported `Target is up to date` with 0 actions. All touches changed only mtime and were restored afterward.

| Trigger source | Editor target result | Triggers function table |
| --- | --- | --- |
| temporary comment in `Source/AngelscriptProject/AngelscriptProject.cpp` | 4 actions, only host project module compile/link | No |
| touch `Plugins/Angelscript/.../AngelscriptBindDatabase.cpp` | 4 actions, only `Module.AngelscriptRuntime.13.cpp` plus Runtime link | No |
| touch `Plugins/Angelscript/.../AngelscriptBindDatabase.h` | 44 actions, Runtime/Test/Editor/GAS multi-module recompilation | Yes, shown in editor logs as unity TUs such as `Module.AngelscriptRuntime.2.cpp` |
| touch `Source/AngelscriptProjectEditor.Target.cs` | makefile invalidated, 0 actions | No |
| touch `AngelscriptProject.uproject` | makefile recreated, 0 actions | No |
| touch `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` | UHT reran `AngelscriptFunctionTable`, 6 actions, compiling `Module.AngelscriptRuntime.2/3/4.cpp` | Yes, `Module.AngelscriptRuntime.2.cpp` contains all function-table wrappers |

Additional confirmation:

- `Module.AngelscriptRuntime.2.cpp` directly includes `Gen/AngelscriptGeneratedFunctionTableWrappers/AS_FunctionTable_*.cpp`, so `Compile Module.AngelscriptRuntime.2.cpp` in editor build logs is equivalent to recompiling the translation unit that contains function-table wrappers.
- Changing only a host project `.cpp` or ordinary plugin `.cpp` does not trigger function-table work. The edit must hit a public header included by shards, or a rule file such as `AngelscriptRuntime.Build.cs` that causes UHT/exporter and wrapper compile graph participation.

## Answers To Key Unknowns

- **Whether wrapper inline incremental decisions use hash or mtime**: Fact 1 proves UBT does not recompile the corresponding unity file when `.gen.cpp` content is unchanged; the no-op build did not touch shard unity. Fact 2 proves that header mtime changes do trigger recompilation. UBT relies on the include dependency graph plus file mtimes/timestamps to decide whether a translation unit is stale. Identical shard content is insufficient when an included header is stale; that is exactly include-chain spread.
- **Cross-module `enabled:false`**: confirmed currently disabled. The 36 files are per-module runtime shards plus link probes, matching the attribution.

## Recommended Fix Direction: Primary Path B

Narrow the includes injected by `BuildShard()` in `AngelscriptFunctionTableCodeGenerator.cs:591-593`:

1. A shard's real compile requirement is only the minimal interface for registering binds plus the target type headers referenced by each entry. Injecting the full 1645-line `AngelscriptEngine.h` is likely far beyond what is needed.
2. Extract a **stable, rarely changed** minimal registration-interface forward header, such as `AngelscriptBindsFwd.h` or a slim binds registration header, so the 36 shards depend only on it plus their target type headers instead of the full `AngelscriptEngine.h`.
3. Then gameplay edits to `AngelscriptEngine.h` no longer invalidate shard translation units, and package/incremental builds avoid needless recompilation of every function table.
4. Acceptance: after refactor, diff `.gen.cpp` output and confirm binding logic is byte-equivalent, with only include-line changes. Then touch `AngelscriptEngine.h` again and confirm shards are no longer pulled into recompilation.

Suspect A hardening tasks, group 3 in `tasks.md`, can be downgraded to opportunistic checks rather than the main fix because the guards have been proven effective.

## Follow-Up

- Task group 1, P0, is complete; this file is the deliverable.
- Primary work is task group 2: path B, breaking include spread.
- Task group 3, path A, is downgraded.
