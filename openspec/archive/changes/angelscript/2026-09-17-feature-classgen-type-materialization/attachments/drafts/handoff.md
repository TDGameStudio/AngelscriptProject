# Handoff: connect the new AS pipeline to ClassGen materialization

## OpenSpec Handoff

- Scope: classgen-handoff
- Target Change: angelscript/feature-classgen-type-materialization

## Problem

The new frontend compiles `asCObjectType` and `Resolved` `FAngelscript*Desc` values, but asType has no UClass / UStruct / UEnum pointer. ClassGen still consumes old preprocessor `ModuleDesc` values.

## Success

- `UCLASS` / `USTRUCT` / `UENUM` go through Builder → Registration → existing ClassGenerator.
- After materialization: `asType.GetUserData()` is `UASClass*` / `UASStruct*` / `UEnum*`; `UASClass.ScriptTypePtr` and `UASStruct.ScriptType` point back at the same asType.
- `DescriptorConsumer` fills `SuperClass` / `ImplementedInterfaces` from `GetResolvedBases`.
- `RefreshCompileOutput` does not overwrite `Project` with a TypeInfo scan after DefinitionsBuilt.
- Pointers stay null after `CompileDeclarations`.
- Delegates / events are not accepted in this Change.

## Evidence

- [can-connect.md](findings/can-connect.md): two products, four gaps.
- [astype-uclass-link.md](findings/astype-uclass-link.md): existing `SetUserData` / `ScriptTypePtr`.
- [design.md](design.md): call chain.
- NativeEngine: `RegisterInstallsEngineAndTypeId`, `ResolvedDescriptorsRetainSemanticKeysAndNullMaterializationPointers`.

## Scope

Do: Resolved fields, overwrite fix, `asCEngineCompileRegistration` onto an Engine, existing ClassGenerator materialization, `ClassGenMaterialization` proof for class / struct / enum.

Do not: delegate / event materialization verification or redesign; a new publisher type; frontend UObject creation; Language `.as` generators.

## Constraints

- Frontend farthest stage is `Resolved`.
- Reuse `asCEngineCompileRegistration` and `FAngelscriptClassGenerator`.
- Resolve `CodeSuperClass` after Registration, not inside `CompileDeclarations`.

## Approach

1. `ProjectRecord` fills `SuperClass` (first non-interface base) and `ImplementedInterfaces` from resolved bases.
2. `RefreshCompileOutput` always treats `DescriptorConsumer.Project` as the authority.
3. After `TakeDefinitions` + `Register`, attach `ScriptType` onto descriptors by name.
4. `ClassGenerator.AddModule` / Setup; assert UserData and reverse pointers.
5. Delegate descriptors may still project; tests do not read their materialized fields.

## Alternatives and flip

- Separate Change for Resolved fields only: rejected at R2. Flip if Engine registration or ClassGen cannot be proven in editor tests inside one Change.
- New publisher type: rejected; reuse Registration. Flip if ScriptType attach cannot sit on the existing Engine path without polluting the frontend.
- New test layer `NativeEngine.ClassGen`: rejected at R4. Flip if later work needs a large reload / reinstance suite.

## Failure

- Overwriting projection after DefinitionsBuilt drops `UCLASS` / `bIsStruct`.
- Asserting UserData after `CompileDeclarations` breaks the existing null contract.
- Accepting delegate materialization collides with a later redesign.

## Verification

- Extend `ReflectionDescriptors`: `SuperClass` string when a base exists; `CodeSuperClass` stays null with no base.
- `CompileLifecycle`: after DefinitionsFrozen, `CompileOutput` still comes from Project (UCLASS-marked types keep `bIsStruct` / properties).
- `ClassGenMaterialization` (`Angelscript.UnitTest.NativeEngine.Compile`): one class, one struct, one enum; UserData plus reverse pointers.
- A delegate program may exist without failing; do not assert its UserData.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| ../../glossary.md | attachments/drafts/glossary.md | Confirmed public names |
| ../../findings/can-connect.md | attachments/drafts/findings/can-connect.md | Gap evidence |
| ../../findings/astype-uclass-link.md | attachments/drafts/findings/astype-uclass-link.md | asType↔UClass attach evidence |
| ../../log.md#r3 | attachments/talks/talk-20260917-195700-scope.md | Scope lock and delegate exclusion |
| ../../log.md#r4 | attachments/talks/talk-20260917-195800-names.md | Change id and test identity |
| ../../findings/astype-uclass-link.md | attachments/knowledges/astype-userdata-is-uclass.md | Reusable: asType UserData is the UClass pointer |

Provenance: local draft `angelscript/class-generation-handoff`, approval R4. Change files do not depend on `openspec/drafts/` paths.
