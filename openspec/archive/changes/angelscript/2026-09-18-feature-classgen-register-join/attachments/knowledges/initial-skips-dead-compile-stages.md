# Initial compile must skip the whole dead Stage block

Disposition: candidate

## Reusable Insight

Reconstruction left more than `CompileModule_Types_Stage1` dead. After a successful `asCModule` shell exists, later `CompileModules` loops still assign `asNOT_SUPPORTED` and one globals loop unconditionally sets `bCompileError`. A host join that only patches Stage1 still fails. Initial source compile must run Builder+Register and skip the whole block.

## Evidence

- `CompileModule_Types_Stage1` always reports `Legacy module compilation is unavailable; use frozen Builder inputs.`
- Stage2 / Stage3 set `bCompileError` when they run.
- `AngelscriptEngine.cpp` around the class-layouting globals loop sets `bCompileError` for every non-null `ScriptModule`.
- Register shells have no `builder`, so CacheV2 function reuse cannot run on this path.

## Boundaries

Does not authorize a ClassGen rewrite or frontend UObject creation. Does not make reload skip the same block. Does not restore `ALWAYS_CREATE` / `Build`. Preprocessor `ModuleDesc` remains the ClassGen input in this Change.

## Application

Gate the Builder skip on `ECompileType::Initial` and modules without precompiled code or an existing `ScriptModule`. Prove UserData through `CompileModules(Initial)`, not a throwaway `asCreateScriptEngine()`.

## Sources

[thin-host-join](../drafts/findings/thin-host-join.md), [design](../drafts/design.md).
