# Handoff: host API leftovers plus Pending containers

## OpenSpec Handoff

- Scope: container-home
- Target Change: angelscript/feature-host-api-fixtures

## Problem

The Bindings holding directory still has 580 host types (~2420 `Observe_*`) on old `root` stars. `Pending/Containers` (240) is a second pile with Fail, thicken, and pointer types. Taking one pile drops cases. The directory name `Bindings` is rejected. The created Unreal Change first batch does not include these 580 files.

## Success

- Admitted `AngelscriptTestCode/Containers/` holds TArray, TMap, TSet, TOptional, TSoftObjectPtr, TWeakObjectPtr, TSubclassOf, TObjectPtr, and SoftObjectPath as current `@begin` pockets plus Fail siblings.
- Remaining Bindings type folders become `Unreal/<Type>` pockets and are deduped against `feature-unreal-fixture-root` Strings / Input / World/Actor.
- `Pending/Containers` Reject / Negative / Exception / thicken merge into those pockets. Misfiled TSet gameplay is moved out of the container home, not deleted.
- `Pending/Math` (111) merges into `Unreal/` math pockets.
- CodeGen generate/check can project the new FileTags. Admission does not prove compilation or execution.

## Evidence

- [bindings-intake.md](findings/bindings-intake.md): 580 / 126 folders / two container contracts.
- [host-destinations.md](findings/host-destinations.md): Q35 split roots.
- [two-changes.md](findings/two-changes.md): boundary against the two sibling Changes.

## Scope

Do: rewrite the 580 Bindings leftovers plus `Pending/Containers` plus overlapping `Pending/Math`; admit `Containers/`; add type pockets under existing `Unreal/`; sync Skill, spec inventory, and projections.

Do not: the six Language themes; the Unreal first-batch UClass+World sources (owned by the other Change); GAS `Pending/Optional`; TestFramework Usage; Definitions / Feature / Gameplay / HotReload; generator 122; reopen the parser; treat admission as execution.

## Constraints

- Author `.as` files in English; Change records in English.
- Parentless cases, Fail siblings, and `@function` follow `theme-case-containers`.
- Do not revive a `Bindings/` admitted root.
- Do not rewrite the Unreal first-batch source list of 248 files; merge only when FileTags collide.

## Approach

Split Bindings axis mashups into `@begin` cases. Fill holes from Pending one-concern and Fail files. About one positive pocket plus CompileFail and optional RuntimeFail per type. Pointer types follow T* into `Containers/`.

## Alternatives and flip

- All 580 under `Containers/<Type>`: rejected at Q35. Flip if non-T* cannot merge with Unreal first-batch themes.
- A new `Library/` root: rejected at Q35. Flip if `Unreal/` math pockets cannot coexist with FVector.
- Fold into the Unreal Change: rejected at Q34.

## Failure

- Copying `@version root` or `Behavior_01` mashups fails the current parser or recreates privileged root.
- Writing AActor as `Containers/AActor` conflicts with Q32/Q35.
- Deleting TSet files marked “Not TSet API” drops cases.

## Verification

`codegen.py check`; `Containers/TArray` and at least one CompileFail / RuntimeFail can be Get; `Unreal/FMath` (or the merged math pocket) registers; the Language corpus does not treat these as core language. This Change does not prove container execution.

## Exploration Carryover

Exported from the approved draft handoff. Required copies live beside this file.
