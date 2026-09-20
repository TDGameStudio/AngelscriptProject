# Candidate: thin-host hot reload

Translated from draft `designs/reload-classgen-join/design.md`. Approval R10.

The previous Change only joined `CompileModules(Initial)`. Hot reload still enters the dead Stage1–4 block because the live `asCModule` name and one Initial `asCDefinitions` occupy `GetModule` / `TypesByName`.

## Goals / Non-Goals

**Goals:** After a file change, a new preprocessor `ModuleDesc` gets a new shell through Builder+Register. Existing ClassGen applies Soft or Full reload. Failure keeps the last generation.

**Non-Goals:** CacheV2 function reuse; delegate/event UserData; ClassGen rewrite; full-engine retire; shadow Engine.

## Decisions

- W1=S: `FullReload` and `SoftReloadOnly` both skip the dead Stage block. Existing `Setup` → Soft / Full / PIE downgrade stays.
- R1=P: one Builder+Register per preprocessor `ModuleDesc`. Dependencies = host graph + already attached script sets. Reload retires those compile sets and dependents, then Registers in the same order.
- C1=one Change: prove per-file `asCDefinitions` first, then the reload skip.
- Names: Change `angelscript/feature-classgen-reload-join`; test class `ClassGenReload`.

## Call chains

```
PerformHotReload
→ Preprocess → GetModulesToCompile
→ CompileModules(FullReload|SoftReloadOnly)
   now: Stage1 dead
   target: retire per-file sets → Builder+Register → skip Stage1–4
        → ClassGen.Setup → SoftReload | FullReload | PIE downgrade
```

## Failures

- Widening only `if (Initial)`: second Register hits name/key conflict.
- Renaming the old shell before compile and not restoring it on failure: the editor loses the last good lookup.
- `RetireExternalDefinitions` on the live engine: host binds and unchanged files disappear.
