# UPROPERTY delegate execute coverage

Settled 2026-09-18 R1: this Change is test-only plus isolated-host TypeDatabase seeding. Overlay of `FMulticastScriptDelegate` onto `UPROPERTY` bytes is a later feature Change. Prove NativeEngine `Compile.DelegateProperty` only. Land the four green cases and seed, then thicken Clear/Remove, script `BindUFunction`, and one more dynamic multicast arity.

Names: [attachments/drafts/glossary.md](attachments/drafts/glossary.md). Accepted scope: [attachments/drafts/design.md](attachments/drafts/design.md), [attachments/drafts/handoff.md](attachments/drafts/handoff.md).

## Call chains

Isolated host must install the two script-delegate adapters that `Bind_Delegates` skips on a host target:

```
FAngelscriptEngine::Create(bSkipInitialCompile, CacheV2 off)
→ InitializeWithoutInitialCompile / inject retained HostProcess graph
→ SeedHostScriptObjectType
→ SeedHostScriptDelegateTypes(TypeDatabase, BindDatabase)
    // ScriptDelegateType = FScriptDelegateType
    // ScriptMulticastDelegateType = FMulticastScriptDelegateType
    // Bind_Delegates.cpp IsHostTarget returns without this
```

Dynamic `UPROPERTY` members then take the ClassGen property path and execute on the script pointer slot:

```
DECLARE_DYNAMIC_MULTICAST_DELEGATE_* / DECLARE_DYNAMIC_DELEGATE_*
→ FAngelscriptPreprocessor (no ProcessDelegates wrapper)
→ CompileModules(Initial)
→ ClassGen Analyze
    → FAngelscriptTypeUsage::CanCreateProperty
    → FScriptDelegateType::CreateProperty → FDelegateProperty + SignatureFunction
    → FMulticastScriptDelegateType::CreateProperty
        → FMulticastInlineDelegateProperty
        → CPF_BlueprintAssignable | CPF_BlueprintCallable
→ script AddDynamic / BindDynamic / BindUFunction
    → asCSema::ActOnMemberCall → BindPtr / AddPtr
→ script Broadcast / Execute → asBC_CallPtr
→ script Clear / Remove → asBC_ClearPtr / asBC_RemovePtr
```

Native fire used by the landed control does **not** read property bytes:

```
FMulticastInlineDelegateProperty::SignatureFunction
→ local FMulticastScriptDelegate
→ BindUFunction(Listener, OnHealth) + ProcessDelegate
```

Unsafe path, excluded:

```
ContainerPtrToValuePtr(Ev)
→ ProcessDelegate on FMulticastScriptDelegate overlay
    // FMTAccessDetector; can clobber neighbor UPROPERTY ints
```

Measured at: 38e1b7a4fe9bbc540106f28d7858ccd5d899868f (workspace) and Plugins/Angelscript d177491ad71ed4d71e13cf5f153026fb08817b08. Dirty: Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp, Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp.

## Contract

```
UCLASS UPROPERTY FOnHealth Ev
  ├─ ClassGen CreateProperty → FMulticastInlineDelegateProperty + SignatureFunction
  ├─ script AddDynamic / BindUFunction / Broadcast / Clear / Remove → CallPtr slot
  └─ native BindUFunction(SignatureFunction) + ProcessDelegate → local FMulticastScriptDelegate
```

`Ev.IsBound()` is not a Sema callable operation today. Task 1.2 observes bound state through Broadcast after Clear/Remove. Do not add `IsBound` Sema in this Change. Do not overlay property bytes.

## Follow-up

`angelscript/feature-delegates-property-storage` owns one shared blob for the script slot and `FMulticastScriptDelegate`. It is not created here.
