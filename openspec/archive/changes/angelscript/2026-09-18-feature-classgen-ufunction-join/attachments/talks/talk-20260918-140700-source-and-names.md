# Source shape and public names

## Context

The ClassGen materialization fixture hand-fills SuperClass and avoids `UCLASS()` / `: UObject` in source. This Change adds one method.

## Evidence

AskQuestion Q4 = A, N1 = Call, N2 = ufunction. Draft log R4. Neighbours: `ClassGenMaterialization`, `ClassGenReload`, `feature-classgen-register-join`, `feature-classgen-reload-join`.

## Options

- Q4 A: `UFUNCTION()` on the method, no `UCLASS()` / `: UObject`.
- Q4 B: bare method, no annotation.
- Q4 C: full `UCLASS() class X : UObject`.
- N1: `ClassGenCall` / `ClassGenProcessEvent` / `ClassGenUFunction`.
- N2: `feature-classgen-ufunction-join` / `call-join` / `processevent-join`.

## Settled Decision

Q4=A, N1=`ClassGenCall`, N2=`angelscript/feature-classgen-ufunction-join`. Convention names: method `InitialProcessEventReturnsValue`, type `ClassGenCallActor`.

## Consequences

Builder sees the `UFUNCTION()` annotation. SuperClass stays hand-filled. Test identity is `Angelscript.UnitTest.NativeEngine.Compile.ClassGenCall`.

## Flip Condition

Reopen Q4 if the frontend cannot parse `UFUNCTION()` without a preprocessor rewrite. Rename only if the Compile-layer neighbour convention changes.

## Sources

[glossary](../drafts/glossary.md), [design](../drafts/design.md). Provenance: draft log R4.
