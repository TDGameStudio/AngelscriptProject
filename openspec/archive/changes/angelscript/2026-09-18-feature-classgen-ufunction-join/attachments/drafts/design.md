# Candidate: thin-host UFUNCTION ProcessEvent

Translated from draft `designs/classgen-ufunction-join/design.md`. Approval R5.

`CompileModules(Initial)` already Builder+Registers and materializes class/struct/enum UserData. ClassGen tests have no Methods, so Analyze never binds `FunctionDesc.ScriptFunction` and ProcessEvent is unproven on the host path.

## Goals / Non-Goals

**Goals:** After Initial compile and existing ClassGen, a hand-filled BlueprintCallable `GetValue` is a live `UASFunction` whose ProcessEvent returns 7.

**Non-Goals:** Language corpus execute; real preprocessor; copying Builder CompileOutput Methods; script construct; method-body reload; ClassGen rewrite; frontend UObject; `ALWAYS_CREATE` / `Build`; CacheV2.

## Decisions

- Q1=U: prove UE reflection (`UFUNCTION` → `UASFunction` → ProcessEvent), not a bare Context.Prepare.
- Q2=P: production Methods stay preprocessor-owned; the NativeEngine test hand-fills Methods and does not copy Builder projections.
- Q3=E: Initial only. ConstructFunction and FullReload of the body are out.
- Q4=A: source writes `UFUNCTION()` on the method; no `UCLASS()` / `: UObject`. SuperClass is hand-filled.
- Names: Change `angelscript/feature-classgen-ufunction-join`; test class `ClassGenCall`; method `InitialProcessEventReturnsValue`; type `ClassGenCallActor`.

## Call chains

```
CompileModules(Initial)
→ Builder RunThrough(ByteCodeEmitted)
→ Register + asCModule shell
→ ClassGen.Analyze
   FunctionMap[ScriptFunctionName] → FunctionDesc.ScriptFunction
→ Generation → UASFunction
→ NewObject + ProcessEvent → 7
```

`ExecuteConstructFunction` returns when `ConstructFunction == nullptr`. E does not depend on script construct.

## Failures

- Empty Methods: Analyze never binds ScriptFunction.
- ScriptFunctionName mismatch: Analyze reports the method missing.
- Asserting only UserData: repeats the previous Change and does not prove a call.
