# Handoff: admitted Unreal root

## OpenSpec Handoff

- Scope: unreal-home
- Target Change: angelscript/feature-unreal-fixture-root

## Problem

UE-feature fixtures (UCLASS, Actor, World) are mixed into Pending/Language and Pending/World. Language must not own them. The Bindings directory name is rejected.

## Success

- Admitted `AngelscriptTestCode/Unreal/` exists and CodeGen can project it.
- 124 Language UClass files plus 124 World files are absorbed as theme pockets under the current `@begin` contract.
- The 580 Bindings leftovers remain in their holding directory.
- Admission does not prove compilation or World execution.

## Evidence

- [unreal-home.md](findings/unreal-home.md): neighbors and the rejected Bindings name.
- [unreal-all-intake.md](findings/unreal-all-intake.md): 124+124 tree.
- [unreal-intake.md](findings/unreal-intake.md): discovery of non-Pending sources.
- [two-changes.md](findings/two-changes.md): split from the Language second wave.

## Scope

Do: create the `Unreal/` root; rewrite and project the first-batch pockets; extend language-fixtures or add an Unreal inventory; teach the Skill that UE material is not Language.

Do not: the six Language themes; the 580 Bindings leftovers; Pending/Math dedup; generators; treat admission as execution.

## Constraints

- Author `.as` files in English; Change records in English.
- Pocket grammar matches Language; FileTag prefix differs.
- No task dependency on `feature-language-second-wave-fixtures`.

## Approach

Merge along the [unreal-all-intake.md](findings/unreal-all-intake.md) tree. Split the 89 EdgeCases/UClass files into Casting / GC / Input / Events / Reflection / ActorClass. Do not keep an EdgeCases pocket.

## Alternatives and flip

- ObjectCast-only pilot: rejected at Q25/Q29. Flip if rewriting 248 programs cannot be proven as one Change.
- Park under `Pending/Unreal/` first: rejected at Q23.

## Failure

- Copying old root stars fails generate.
- Writing into `Language/Casting` conflicts with Q22.
- Taking the 580 Bindings leftovers as this first batch conflicts with Q29.

## Verification

`codegen.py check`; at least `Unreal/Casting` and `Unreal/World/Actor` can be Get; the Language inventory does not list those Tags.

## Exploration Carryover

Exported from the approved draft handoff. Required copies live beside this file.
