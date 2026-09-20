# Hot-reload join: not a wider Initial skip

Date: 2026-09-18. Workspace: `git_3b46972bbc7ef05a4244fd2890d18183`.
Prior Change: `angelscript/2026-09-18-feature-classgen-register-join` (Q2=I, reload stayed on the dead Stage path).

Translated from draft `findings/reload-join.md`. Approval R10.

## Current path

```
file change
  └─ PerformHotReload(FullReload | SoftReloadOnly)
       ├─ preprocessor AddSource / Preprocess
       ├─ GetModulesToCompile()          // new ModuleDesc, ScriptModule null
       └─ CompileModules(CompileType)
            ├─ Initial ── already skips Stage1–4
            └─ Full / Soft ── still enters the dead block
                 └─ Stage1: Legacy module compilation is unavailable
                      └─ bHadCompileErrors
                           └─ no SwapIn, keep last-good code
```

ClassGen Soft/Full is decided after a successful compile. That compile never arrives. `PerformHotReload` already uses `ForceClean`, so CacheV2 reuse is not the gate.

## Why the Initial helper cannot be reused as-is

`CompileInitialModulesThroughBuilder` skips a module when `ScriptModule != nullptr`. Reloaded preprocessor modules are usually empty shells, so that check passes.

The live previous generation is the block:

1. **Module name**  
   `Register(Sets, Output)` returns `NameConflict` when `Engine.GetModule(name)` still finds the old shell.  
   Today's `SwapIn` renames the old shell to `Name_OLD_N` only after a successful compile.

2. **Type names / stable keys**  
   Initial does one `TakeDefinitions` + one `Register`, so **every `.as` type lives in one `asCDefinitions`**.  
   Engine `TypesByName` already holds `ClassGenJoinActor`. A second Register of the same names is `NameConflict` / `IdentityConflict`.  
   `RetireExternalDefinitions` tears down **all** compile sets (and admitted hosts). It cannot run on a live reload.

3. **Failure rollback**  
   If the old shell is renamed before compile, failure must restore the name. Today's failure path leaves `ActiveModules` untouched.

## Two generations

```
ActiveModules["Game.Player"] ── ModuleDesc (old)
  └─ ScriptModule "Game.Player"     // asCScriptEngine::GetModule hit
       └─ type pointers ∈ the single Initial definitionSet

preprocessor new ModuleDesc("Game.Player")
  └─ ScriptModule = null
       └─ Builder will allocate new asTypes (new objects, same names)
```

ClassGen `AddModule` uses host `GetModule(ModuleName)` for the **old** `ModuleDesc` (`ActiveModules`) and the new `ScriptModule` for new asTypes. That split can stay. What is missing is a way to publish new asTypes without colliding with the old index.

## Options (settled: P)

| Option | Approach | Cost |
| --- | --- | --- |
| P per-file sets | Initial and reload `Register` one `asCDefinitions` per `.as`. Reload retires that file and dependents, then Registers. | Changes archived Initial ownership; matches per-file `asCModule`. **Selected.** |
| K live-set replace | Keep one graph. A new Register API replaces types/functions by StableKey; old objects live until SwapIn/Discard. | New engine protocol; leaves Initial as one set. **Rejected.** |
| X shadow engine | Compile on a new engine and switch. | Beyond thin host; ClassGen binds the host singleton. |

Do not: only widen `if (Initial)`; restore `ALWAYS_CREATE` / `Build`; rewrite ClassGen.

## Soft vs Full

`ECompileType` chooses **after** compile whether ClassGen runs `PerformSoftReload` or `PerformFullReload`, and whether PIE structural changes downgrade. The dead compile is the same for both. This Change skips the dead block for both compile types.
