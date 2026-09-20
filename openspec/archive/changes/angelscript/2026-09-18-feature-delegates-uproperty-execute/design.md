# Design

## Design for angelscript/feature-delegates-uproperty-execute

Complete `UPROPERTY` delegate execute on the CallPtr slot: Sema `IsBound`, `BindDynamic(this)`, quiet `ExecuteIfBound`, UFUNCTION return/`FName` writeback, convert-and-fire, and CallPtr-sized SoftReload copy. NativeEngine `Compile.DelegateProperty` is the proving prefix.

## Overview

Script `DECLARE_*` + `UPROPERTY` members are pointer-sized CallPtr slots (`asPWORD`, bind tag 2, listener-list tag 1). ClassGen still emits `FDelegateProperty` / `FMulticastInlineDelegateProperty` at that offset, so reflection sees a UE property while script fire stays on `asBC_CallPtr`. Native `ProcessDelegate` on those bytes trips `FMTAccessDetector` and can clobber a neighbor `int`. This Change keeps CallPtr as the source of truth and adds the missing Sema, VM, convert, and SoftReload edges.

## Context

Archived `angelscript/2026-09-19-test-delegates-uproperty-execute` landed host seeding and seven green `DelegateProperty` methods. It left `IsBound`, `this`, `ExecuteIfBound`, ReturnParm writeback, convert-and-fire, and SoftReload as later work. `Bind_Delegates` still returns on `IsHostTarget`; `SeedHostScriptDelegateTypes` stays. CacheV2 stays off. Language-folder execute, cook, and PIE are not green gates.

## Goals

- Sema `IsBound()` on a `UPROPERTY` CallPtr member.
- `BindDynamic(this, FunctionName)` / `AddDynamic(this, FunctionName)` bind the current object.
- Unbound `ExecuteIfBound` is quiet; unbound `Execute` still throws.
- `asCallBoundUFunction` writes `CPF_ReturnParm` and dword-sized values including `FName`.
- Native fire uses `FAngelscriptDelegateOperations::ProcessCallPtr`.
- SoftReload copies `AS_PTR_SIZE` for script delegate properties.
- Thicken `DelegateProperty` with a representative map. The seven landed methods stay controls.

## Non-goals

- Overlay `FScriptDelegate` / `FMulticastScriptDelegate` on `UPROPERTY` bytes.
- `ProcessDelegate` on property bytes.
- A 60-row `UPROPERTY` execute matrix.
- Language-folder / `FAngelscriptTestCode` execute as the proving surface.
- Full cook or PIE as a green gate.
- CacheV2.
- Renaming this Change to `feature-delegates-property-storage`.

## Decisions

- CallPtr remains the script source of truth. Convert-and-fire is the native path.
- Proving surface is NativeEngine only: `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty`.
- Adjacent Compile prefixes touched by Sema/VM (`DelegateBinding`, `DelegateExecute`) are observed after the owning task, not used as the green gate.
- Representative map, not every DECLARE arity.
- `ProcessCallPtr` is convention-derived from `FAngelscriptDelegateOperations`. The user did not name the convert API.
- Tasks are sequential because they share `DelegatePropertyTests.cpp`.

## Call chains

Sema member call (`as_sema_postfix.cpp` `ActOnMemberCall`):

```
Ev.IsBound()
  -> ActOnMemberCall
  -> new IsBound operation on CallPtr slot
  -> boolean from bind-tag / list-tag occupancy

Ev.AddDynamic(this, FunctionName)
  -> parser bare-target first arg
  -> this is ActOnThis, not ActOnDeclReference("this")
  -> asBC_AddPtr (multicast) / asBC_BindPtr (single-cast)

Ev.ExecuteIfBound(args)
  -> ActOnIndirectCall with quiet-unbound flag
  -> CallPtr path that returns when slot is unbound
  -> Execute stays on the throwing CallPtr path
```

VM UFUNCTION dispatch (`as_context.cpp` `asCallBoundUFunction`):

```
BindUFunction / BindDynamic slot
  -> asBC_CallPtr
  -> asCallBoundUFunction
  -> skip neither CPF_ReturnParm nor FName
  -> write dword-sized return into the script assignment
```

Native convert-and-fire (`Bind_Delegates.h`):

```
FMulticastInlineDelegateProperty* Prop
  -> read asPWORD at ScriptOffset
  -> FAngelscriptDelegateOperations::ProcessCallPtr(Slot, Signature, ParameterBuffer)
  -> temporary FMulticastScriptDelegate
  -> ProcessDelegate on the temporary
  -> never ProcessDelegate(Prop->ContainerPtrToValuePtr)
```

SoftReload (`AngelscriptClassGenerator_SoftReload.cpp` `FRawUnrealPropertyType::CopyValue`):

```
script delegate UPROPERTY
  -> copy AS_PTR_SIZE bytes
  -> neighbor int unchanged
  -> later Broadcast still uses CallPtr
```

Measured at: 38e1b7a4fe9bbc540106f28d7858ccd5d899868f (plugin d177491ad71ed4d71e13cf5f153026fb08817b08); dirty: Plugins/Angelscript (host seed + seven DelegateProperty methods). Handoff handoff-8ecfec44c2224c89.

## Risks

- SoftReload `CopyCompleteValue` on a live instance can look green if the neighbor is unused. The SoftReload case requires a neighbor `int` and a post-reload Broadcast.
- Changing `ExecuteIfBound` globally can affect local-delegate `DelegateExecute`. Observe that prefix after the Sema task.
- `this` is already `ActOnThis` in `ParsePrimaryExpression`, but bare-target argument parsing consumes `this` as a Name before that path. The fix belongs in `ParseCallArguments`, not in `ActOnDeclReference`.
- `ProcessCallPtr` must not take a property-byte pointer. Tests assert fire without `ProcessDelegate` on `Ev`.

## Open questions

None. Gate `handoff-8ecfec44c2224c89` closed Q1=B, Q2=A, Q3=C, Q4=A, Q5=A, Q6=A, N1=A.
