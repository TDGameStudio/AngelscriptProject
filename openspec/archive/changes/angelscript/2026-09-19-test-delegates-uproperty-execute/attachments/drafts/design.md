# Accepted: UPROPERTY delegate execute coverage

Status: designed (R1). Source draft: `openspec/drafts/angelscript/delegates-property-coverage/designs/uproperty-execute/design.md` (Chinese original; approval R1).

Names: [glossary.md](glossary.md). Evidence: [current-coverage.md](findings/current-coverage.md).

## Problem

The archived delegates Change proved DECLARE macros and CallPtr. `FOnHealth Ev` was a script field, not a `UPROPERTY`. Isolated-host compile then rejected `UPROPERTY FOnHealth Ev` as `void` until `ScriptDelegateType` / `ScriptMulticastDelegateType` were seeded. Four `DelegateProperty` cases are already green and are not in a Change.

Script DECLARE fields are pointer slots. `FMulticastInlineDelegateProperty` claims `FMulticastScriptDelegate` size at the same offset. Native `ProcessDelegate` on those bytes is unsafe.

## Accepted direction

- Q1=A: this Change is `angelscript/test-delegates-uproperty-execute`. Overlay storage is a later feature Change.
- Q2=A: prove only NativeEngine `Compile.DelegateProperty`. Keep `DelegateReflection.OrdinaryBlueprintAssignableRejected` as the ordinary reject control.
- Q3=B: land the four green cases and host seeding, then add `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, and `DynamicMulticastOneParamFires`.

## Contract

```
UCLASS UPROPERTY FOnHealth Ev
  ├─ ClassGen CreateProperty → FMulticastInlineDelegateProperty + SignatureFunction
  ├─ script AddDynamic / BindUFunction / Broadcast / IsBound / Clear / Remove → CallPtr slot
  └─ native BindUFunction(SignatureFunction) + ProcessDelegate → local FMulticastScriptDelegate
```

Do not `ProcessDelegate` through `ContainerPtrToValuePtr` on the property bytes.

## Verification

`ue.test` prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty`, `Fast=true`. Observe the three new cases RED, then GREEN the whole prefix. Omit Language execute, full cook, and PIE.
