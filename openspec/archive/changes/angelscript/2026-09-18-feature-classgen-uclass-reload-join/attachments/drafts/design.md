# Candidate: UCLASS reload ProcessEvent

Translated from draft `designs/uclass-reload-join/design.md`. Approval R15.

`ClassGenReload` proves UserData only. `ClassGenCall` proves Initial ProcessEvent only. The old HotReload gold cases embed `UCLASS` source, SoftReload a method body, keep the same `UClass*`, ProcessEvent the new value on the live object, and may `CreateBlueprint` a transient child. That host path is unproven in replacement tests. The Language folder corpus is not an input.

## Goals / Non-Goals

**Goals:** Phase 1 SoftReload updates a `UFUNCTION` body and a transient Blueprint child still ProcessEvents the new value. Phase 2 FullReload adds a property and a failed reload keeps the old ProcessEvent result.

**Non-Goals:** `AngelscriptTestCode/Language/**`; `FAngelscriptTestCode`; restoring `Legacy/HotReload/*`; `PerformHotReload` file watch; PIE; rename redirects; copying Builder Methods; ClassGen rewrite; CacheV2.

## Decisions

- Q1=O: one Change; proving commands stay split by phase.
- R8: first prove UCLASS SoftReload plus transient Blueprint create; do not port the Legacy suite.
- Q5: finish the UCLASS seam (Full add-property + failed keep) before any Language work.
- R13: embed old-style `UCLASS()` / `UFUNCTION()` strings in NativeEngine tests. Do not read the Language database.
- N1/N2: test class `ClassGenUClassReload`; Change `angelscript/feature-classgen-uclass-reload-join`.
- Production descriptors come from the preprocessor when the source has `UCLASS(`.

## Call chains

```
Inline ScriptV1 / ScriptV2
→ Preprocessor (UCLASS present) → ModuleDesc.Classes / Methods
→ CompileModules(Initial | SoftReloadOnly | FullReload)
→ ClassGen Analyze + Generation
→ NewObject or FKismetEditorUtilities::CreateBlueprint
→ ProcessEvent GetVersion
```

Entry remains host `CompileModules`, not `PerformHotReload`.

## Verification

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload`, `Fast=$true`. Phase evidence is per method. Do not run the Language corpus or Legacy HotReload.
