# Handoff: UCLASS reload to ProcessEvent

Translated from draft `designs/uclass-reload-join/handoff.md`. Approval R15.

## OpenSpec Handoff

- Scope: uclass-reload-join
- Target Change: angelscript/feature-classgen-uclass-reload-join

## Problem

`ClassGenReload` only asserts UserData. `ClassGenCall` only asserts Initial ProcessEvent. Old HotReload gold cases embed `UCLASS`, SoftReload a method body, ProcessEvent the new value, and `CreateBlueprint`. Replacement tests do not prove that path. The Language folder corpus is not landed as execute input.

## Success

- Phase 1: after SoftReload the `UClass*` is unchanged, the old object ProcessEvents the new return, and a transient Blueprint child still calls the new body.
- Phase 2: FullReload adds a `UPROPERTY` and ProcessEvent still works; a broken reload leaves the old ProcessEvent result.
- Prefix: `Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload`.

## Evidence

- [legacy-reload-slice.md](findings/legacy-reload-slice.md): old tests call `CompileModules`, not `PerformHotReload`.
- [inline-as-not-corpus.md](findings/inline-as-not-corpus.md): do not use the Language database.
- [design.md](design.md), [glossary.md](glossary.md).

## Scope

Do: one Change, two phases, split proving commands, preprocessor-filled descriptors, new NativeEngine tests.

Do not: Language folder / `FAngelscriptTestCode`; Legacy suite restore; file watch; PIE; rename redirects; CacheV2.

## Constraints

- Entry is `CompileModules`. Source writes `UCLASS()` / `UFUNCTION()`.
- Do not revive `Legacy/HotReload/*.cpp`. Tests will be reorganized later.
- ClassGen still reads the host `ModuleDesc`.

## Approach

1. Phase 1 fixture: Soft body change + `CreateBlueprint`.
2. Phase 2 fixture: Full add-property + failed reload keeps the old value.
3. Fix only the join that blocks reload ProcessEvent.

## Alternatives and flip conditions

- Use corpus `@begin` files: flip if Language execute tests are formally landed and this Change must compile them. Rejected.
- Language before UCLASS: flip if UCLASS reload is no longer phase 1. Rejected.
- Port 32 Legacy files: flip if the isolation contract is lifted. Rejected.

## Failures

- SoftReload still returns the old value or replaces the `UClass*`.
- Blueprint child loses its parent or ProcessEvent fails.
- After a broken reload the old function is not callable.

## Verification

- `ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.ClassGenUClassReload`, `Fast=$true`.
- Phase 1 / phase 2 evidence stays per method. Do not run Language corpus or Legacy HotReload.

## Exploration Carryover

Frozen on the Harness origin marker. Local draft paths stay out of Change links.
