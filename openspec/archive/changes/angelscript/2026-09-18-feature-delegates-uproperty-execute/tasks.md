---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.1": ["1.1"]
    "3.1": ["2.1"]
---

# Complete UPROPERTY delegate execute on CallPtr

## Goal

Close Sema `IsBound`, `BindDynamic(this)`, quiet `ExecuteIfBound`, UFUNCTION writeback, convert-and-fire, and CallPtr-sized SoftReload copy on NativeEngine `Compile.DelegateProperty` without overlaying native storage.

## Architecture

CallPtr remains the script source of truth. Sema and the parser admit `IsBound` and `this`; `ExecuteIfBound` gets a quiet unbound CallPtr path; `asCallBoundUFunction` writes `CPF_ReturnParm` and `FName`; native fire uses `FAngelscriptDelegateOperations::ProcessCallPtr`; SoftReload copies `AS_PTR_SIZE`. See [design.md](design.md).

## Global constraints

- Prerequisite: archived `angelscript/2026-09-19-test-delegates-uproperty-execute` already owns host seeding and the seven `DelegateProperty` controls.
- Do not `ProcessDelegate` `UPROPERTY` bytes. Do not overlay `FMulticastScriptDelegate` on those bytes.
- Test identity is `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>`. Do not add Language-folder execute, cook, or PIE as a proving surface.
- CacheV2 stays off on `MakeHostEngine`. Harness `ue.*` only.
- Sequential: `1.1`, `2.1`, and `3.1` share `DelegatePropertyTests.cpp`.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp  # IsBound + ExecuteIfBound · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp  # bare-target this · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp  # IsBound + quiet ExecuteIfBound · 1.1
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp  # quiet CallPtr · 1.1; ReturnParm/FName · 2.1
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h  # ProcessCallPtr · 3.1
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp  # ProcessCallPtr body · 3.1
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_SoftReload.cpp  # CallPtr CopyValue · 3.1
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp  # representative map · 1.1, 2.1, 3.1
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Isolated host seeds adapters; multicast is `FMulticastInlineDelegateProperty` | 1.1 |
| Isolated host single-cast is `FDelegateProperty` | 1.1 |
| Script AddDynamic + Broadcast writes Current | 1.1 |
| Script BindDynamic + Execute void side-effect | 1.1 |
| Native ProcessDelegate on a local multicast | 1.1 |
| Clear / Remove / RemoveAll stop later Broadcast | 1.1 |
| IsBound false / true / false | 1.1 |
| AddDynamic(this) fires | 1.1 |
| Unbound ExecuteIfBound is quiet | 1.1 |
| Missing bind name fails compile | 1.1 |
| BindUFunction Execute writes returned int | 2.1 |
| One-param FName multicast writes owner FName | 2.1 |
| Zero-param void UFUNCTION side-effect | 2.1 |
| ProcessCallPtr fires without property-byte ProcessDelegate | 3.1 |
| SoftReload copies CallPtr slot and keeps neighbor int | 3.1 |
| No ProcessDelegate on property bytes | 1.1, 2.1, 3.1 |

Self-review 2026-09-19: coverage complete; no placeholder phrases; symbols match `design.md`. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Sema IsBound, this, and ExecuteIfBound

`asCSema::ActOnMemberCall` has no `IsBound` branch. Bare-target `ParseCallArguments` stores `this` as a Name so `ActOnDeclReference("this")` fails. `ExecuteIfBound` shares `ActOnIndirectCall` and the throwing `asBC_CallPtr` path. This task admits those three operations on a `UPROPERTY` CallPtr member. `RemoveAll` and a missing bind name are first-time characterization of already-emitted CallPtr ops.

**Outcome**

`Ev.IsBound()` is false before bind, true after `AddDynamic`, and false after `Clear`. `AddDynamic(this, FunctionName)` then `Broadcast(100, 75)` writes `Current=100`. Unbound `ExecuteIfBound(42)` leaves `Current=7` and does not throw. Unbound `Execute` still throws. Excluded: ReturnParm writeback (2.1), `ProcessCallPtr` (3.1), SoftReload copy (3.1), property-byte overlay, Language/cook/PIE.

**Interfaces**

Consumes (existing):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:499
asCExpr* asCSema::ActOnMemberCall(...)
// :503 Execute/Broadcast/ExecuteIfBound -> ActOnIndirectCall
// :505 BindDynamic/AddDynamic/BindUFunction; :527 ActOnDeclReference(Arguments[0].Name)
// :624 Clear/RemoveAll already emit CallPtr list ops

// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp:1117
// bBareIdentifierTarget consumes Identifier this as Name before ParsePrimaryExpression:1158 ActOnThis

// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp:392
// callable invoke emits asBC_CallPtr for Execute/Broadcast/ExecuteIfBound

// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp:4367
// asBC_CallPtr; :4387 SetInternalException(TXT_UNBOUND_FUNCTION)

// Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:2070
void SeedHostScriptDelegateTypes(...)

// Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp:23
TUniquePtr<FAngelscriptEngine> MakeHostEngine(FString& OutDiagnostic);
```

Produces (convention from existing `DelegateProperty` `TEST_METHOD` names and Clear/RemoveAll emitter ops):

```cpp
TEST_METHOD(PropertyIsBoundReports)
TEST_METHOD(AddDynamicThisFires)
TEST_METHOD(ExecuteIfBoundUnboundQuiet)
TEST_METHOD(RemoveAllStopsBroadcast)
TEST_METHOD(BindMissingUFunctionRejected)
// Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>
```

**Cases**

Setup: `MakeHostEngine` uses `FAngelscriptEngine::Create` with `bSkipInitialCompile=true`, CacheV2 off (`DelegatePropertyTests.cpp:23`). Scripts go through `WriteAndPreprocess` then `CompileModules(ECompileType::Initial)`.

1. **PropertyIsBoundReports** — new RED · sequence
   Given Setup and `UPROPERTY() FOnPropertyHealth Ev` on a `UCLASS` with a `UFUNCTION` listener.
   1. script `bool A = Ev.IsBound()` → `A` is false.
   2. script `Ev.AddDynamic(Target, FunctionName)` → `Ev.IsBound()` is true.
   3. script `Ev.Clear()` → `Ev.IsBound()` is false.
   Oracle: the three booleans are false, true, false. Do not `ProcessDelegate` `Ev` bytes.

2. **AddDynamicThisFires** — new RED
   Given Setup and owner `UPROPERTY() FOnPropertyHealth Ev` plus void `UFUNCTION OnHealth` writing `Current` When script runs `Ev.AddDynamic(this, FunctionName)` with `FunctionName=OnHealth` then `Ev.Broadcast(100, 75)` Then owner `Current==100`. Compile must not report `unresolved-reference:this`.

3. **ExecuteIfBoundUnboundQuiet** — new RED
   Given Setup and unbound `UPROPERTY() FPropertyAdd Handler` plus `UPROPERTY() int Current = 7` When script calls `Handler.ExecuteIfBound(42)` Then `Current` stays 7 and `CallScriptMethod` returns success. Unbound `Execute` remains the throwing path used by existing `DelegateExecute` controls.

4. **RemoveAllStopsBroadcast** — existing control
   Given Setup and a bound `Ev` When script `RemoveAll(Target)` then `Broadcast(100, 75)` Then `Current` stays 0. First-time characterization of already-emitted `RemoveAll` on a `UPROPERTY` slot.

5. **BindMissingUFunctionRejected** — existing control
   Given Setup and `Ev.AddDynamic(this, FunctionName)` with `FunctionName` naming no `UFUNCTION` When `CompileModules` finishes Then the module has a compile error (`bind-requires-ufunction` or unresolved bind). First-time characterization of the existing bind-name check.

6. **DynamicMulticastPropertyFires** — existing control
   The landed TwoParams Broadcast(100, 75) case stays green. Source: `DelegatePropertyTests.cpp:280`.

7. **NativeProcessUsingPublishedSignature** — existing control
   Local-multicast `ProcessDelegate` stays green. Source: `DelegatePropertyTests.cpp:329`.

8. **DynamicSingleCastPropertyExecute** — existing control
   Void `BindDynamic` + `Execute(41)` writes `Result==42`. Source: `DelegatePropertyTests.cpp:381`.

9. **BlueprintAssignableDynamicAccepted** — existing control
   Dynamic `UPROPERTY(BlueprintAssignable)` keeps both CPF flags. Source: `DelegatePropertyTests.cpp:445`.

10. **PropertyIsBoundClearRemove** — existing control
    Clear then handle Remove stop later Broadcast. Source: `DelegatePropertyTests.cpp` method `PropertyIsBoundClearRemove`.

11. **ScriptBindUFunctionFires** — existing control
    Script `BindUFunction` then void Execute writes `Result==42`.

12. **DynamicMulticastOneParamFires** — existing control
    OneParam Broadcast(42) writes `Current==42`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Parser/as_parser.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp
```

No SoftReload, `ProcessCallPtr`, or Language-folder files. `as_context.cpp` edits in this task are the quiet unbound CallPtr path only.

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace root. After any C++ edit, run `ue.build` with `TimeoutMs=1800000` first. Grouped RED: write `PropertyIsBoundReports`, `AddDynamicThisFires`, and `ExecuteIfBoundUnboundQuiet` first and observe them fail together. GREEN: the report discovers and succeeds those three plus the seven landed controls. `RemoveAllStopsBroadcast` and `BindMissingUFunctionRejected` are existing-control characterization and never count as RED. After GREEN, observe `Angelscript.UnitTest.NativeEngine.Compile.DelegateBinding` and `Angelscript.UnitTest.NativeEngine.Compile.DelegateExecute` because Sema postfix and CallPtr are shared; those prefixes are not this card's green gate. Omit Language, cook, PIE, and CacheV2.

**Notes**

Bare-target `this` is fixed in `ParseCallArguments` by routing the identifier `this` through `ActOnThis`, not by making `ActOnDeclReference` special-case the string. `ExecuteIfBound` must not share the throwing unbound `CallPtr` path. Do not `ProcessDelegate` property bytes.

**Evidence**

RED run `618d2637798c43d590af2b90a0995a4a` after `ue.build` `2087a2f98ea544bb9bd14637f9e06a1f`: prefix discovered 12, failed the three new RED methods (`PropertyIsBoundReports` / `AddDynamicThisFires` compile `body-analysis-failed`; `ExecuteIfBoundUnboundQuiet` runtime unbound throw). Seven landed controls plus `RemoveAllStopsBroadcast` and `BindMissingUFunctionRejected` stayed green.

GREEN run `ba7d3dfc4abc4beb834647dd0a5cfa75` (binary after the Sema/parser/emitter/CallPtr edits): 12/12 Success. Adjacent `DelegateExecute` `123e9a5fdcf94828babdad196060b13d` 5/5 Success. `Compile.DelegateBinding` is not a registered prefix (run `3894c71299f143959d9c41c1b090e65e`); observed `DelegateDynamicInterop` `0c32bc7c67464a12a683bf48735332cc` 3/3 and `DelegateMulticast` `07955e3450ad47f6a3751f052a2597c1` 4/4 instead. Omitted Language/cook/PIE/CacheV2.

## [x] 2.1 asCallBoundUFunction ReturnParm and FName

`asCallBoundUFunction` skips `CPF_ReturnParm` and copies only `FIntProperty` args, so `int Result = Handler.Execute()` stays 0 and an `FName` parameter is dropped. This task writes ReturnParm and dword-sized `FName` through the same CallPtr UFUNCTION dispatch. Zero-param void fire is first-time characterization.

**Outcome**

`BindUFunction` then `int Result = Handler.Execute()` assigns 42. A one-param `FName` multicast `Broadcast` copies `Health` onto the owner `FName` field. Excluded: `ProcessCallPtr` (3.1), SoftReload copy (3.1), property-byte overlay, Language/cook/PIE.

**Interfaces**

Consumes (existing, after 1.1):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp:115
bool asCallBoundUFunction(asCContext& Context, asSCallableBinding& Binding, asDWORD* ArgBase, int ArgDwords)
// :131 ParmCount skips CPF_ReturnParm
// :165 nested script path continues on ReturnParm or non-FIntProperty
// :189 native path continues on ReturnParm
// :194 only FIntProperty is copied
```

Produces (convention from existing `DelegateProperty` method names):

```cpp
TEST_METHOD(RetValWriteback)
TEST_METHOD(FNameParamFires)
TEST_METHOD(ZeroParamFires)
// Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>
```

**Cases**

Setup: same isolated host as 1.1.

1. **RetValWriteback** — new RED
   Given Setup, `DECLARE_DYNAMIC_DELEGATE_RetVal(int, FPropertyGet)`, `UPROPERTY() FPropertyGet Handler`, and `UFUNCTION int GetValue() { return 42; }` When script runs `Handler.BindUFunction(Target, FunctionName)` with `FunctionName=GetValue` then `int Result = Handler.Execute()` Then `Result==42`.

2. **FNameParamFires** — new RED
   Given Setup, `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPropertyName, FName, Label)`, owner `UPROPERTY() FName LastLabel`, and `UFUNCTION void OnName(FName Label) { LastLabel = Label; }` When script `AddDynamic` binds `OnName` and `Broadcast`s `FName("Health")` Then owner `LastLabel` equals `Health`.

3. **ZeroParamFires** — existing control
   Given Setup, `DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnPropertyZero)`, and void `UFUNCTION OnZero` writing `Current=1` When script `AddDynamic` then `Broadcast()` Then `Current==1`. First-time characterization of already-working zero-param CallPtr fire.

4. **PropertyIsBoundReports** — existing control
   The 1.1 `IsBound` sequence stays green.

5. **AddDynamicThisFires** — existing control
   The 1.1 `this` Broadcast stays green.

6. **ExecuteIfBoundUnboundQuiet** — existing control
   The 1.1 quiet unbound path stays green.

7. **DynamicMulticastPropertyFires** — existing control
   TwoParams Broadcast(100, 75) stays green.

8. **ScriptBindUFunctionFires** — existing control
   Void `BindUFunction` + Execute stays green.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp
```

No Sema, parser, SoftReload, or Language-folder files. `as_context.cpp` edits in this task are `asCallBoundUFunction` writeback only.

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace root. After any C++ edit, run `ue.build` with `TimeoutMs=1800000` first. Grouped RED: write `RetValWriteback` and `FNameParamFires` first and observe them fail together. GREEN: the report discovers and succeeds those two plus the 1.1 methods and landed controls. `ZeroParamFires` is existing-control characterization and never counts as RED. Omit Language, cook, PIE, and CacheV2.

**Notes**

Do not change CallPtr slot size. Do not `ProcessDelegate` property bytes.

**Evidence**

Grouped RED `36b824dcaf3d473c9237b5512b0f14c7`: `RetValWriteback` Result stayed 0; `FNameParamFires` Register failed: 4. GREEN run `12ef2f123f984cb0a21a1961e272ffa1`: prefix discovered 15/15 Success (`RetValWriteback`, `FNameParamFires`, `ZeroParamFires`, plus the 1.1 methods and landed controls). Isolated-host FName CallPtr args are Address (`GetSizeOnStackDWords` / `asByteCodeStorageKind`); emitter PSF/PshVPtr those args and `asCallBoundUFunction` dereferences the pointer. Member assign of FName uses `WRTV8`. Omitted Language/cook/PIE/CacheV2.

## [x] 3.1 ProcessCallPtr and CallPtr SoftReload copy

Native fire still has no convert-from-CallPtr helper, and SoftReload `FRawUnrealPropertyType::CopyValue` uses `CopyCompleteValue`, which can memcpy a native multicast blob over an 8-byte CallPtr slot. This task adds the convert helper and copies `AS_PTR_SIZE` for script delegate properties.

**Outcome**

After script `AddDynamic`, `FAngelscriptDelegateOperations::ProcessCallPtr` with `(100, 75)` writes `Current=100` without `ProcessDelegate` on `Ev` bytes. After bind and `Current=7`, `CompileModules(SoftReloadOnly)` keeps `Current=7`, `Ev.IsBound()` true, and `Broadcast(100, 75)` writes 100. Excluded: property-byte overlay, Language/cook/PIE.

**Interfaces**

Consumes (existing, after 2.1):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h:21
struct ANGELSCRIPTRUNTIME_API FAngelscriptDelegateOperations
// :44 IsBound(FScriptDelegate*)

// Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_SoftReload.cpp:337
virtual void CopyValue(...) const
// :339 Usage.UnrealProperty->CopyCompleteValue(DestinationPtr, SourcePtr)

// Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/ClassGenUClassReloadTests.cpp:257
Engine->CompileModules(ECompileType::SoftReloadOnly, ...)
```

Produces (`ProcessCallPtr` — convention from `FAngelscriptDelegateOperations` statics; user did not name the convert API. Test names follow `DelegateProperty`):

```cpp
static void ProcessCallPtr(asPWORD Slot, UDelegateFunction* Signature, void* ParameterBuffer);
TEST_METHOD(ConvertCallPtrFires)
TEST_METHOD(SoftReloadCopiesCallPtrSlot)
// Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>
```

**Cases**

Setup: same isolated host as 1.1. SoftReload uses `ECompileType::SoftReloadOnly` on the same class layout, matching `ClassGenUClassReloadTests.cpp`.

1. **ConvertCallPtrFires** — new RED
   Given Setup and script `AddDynamic` on `UPROPERTY() FOnPropertyHealth Ev` When native code reads the `asPWORD` at the script offset and calls `FAngelscriptDelegateOperations::ProcessCallPtr(Slot, EvProp->SignatureFunction, {100, 75})` Then listener `Current==100`. The test must not call `ProcessDelegate` on `ContainerPtrToValuePtr(Owner, Ev)`.

2. **SoftReloadCopiesCallPtrSlot** — new RED · sequence
   Given Setup, owner `UPROPERTY() int Current` beside `UPROPERTY() FOnPropertyHealth Ev`, after script `AddDynamic` and `Current=7`.
   1. `CompileModules(SoftReloadOnly)` with the same class layout → compile succeeds and the `UClass*` is unchanged.
   2. Read `Current` → 7.
   3. script `Ev.IsBound()` → true.
   4. script `Ev.Broadcast(100, 75)` → `Current==100`.
   Oracle: neighbor int and CallPtr fire both survive SoftReload. Do not `ProcessDelegate` `Ev` bytes.

3. **RetValWriteback** — existing control
   The 2.1 returned-int assignment stays green.

4. **PropertyIsBoundReports** — existing control
   The 1.1 `IsBound` sequence stays green.

5. **DynamicMulticastPropertyFires** — existing control
   TwoParams Broadcast stays green.

6. **NativeProcessUsingPublishedSignature** — existing control
   Local-multicast `ProcessDelegate` stays green.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_SoftReload.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp
```

No Sema, parser, or Language-folder files.

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace root. After any C++ edit, run `ue.build` with `TimeoutMs=1800000` first. Grouped RED: write `ConvertCallPtrFires` and `SoftReloadCopiesCallPtrSlot` first and observe them fail together. GREEN: the report discovers and succeeds those two plus the earlier methods. Record `Naming assumed: FAngelscriptDelegateOperations::ProcessCallPtr — convention from FAngelscriptDelegateOperations; the user did not name the convert API` in Evidence. Omit Language, cook, PIE, and CacheV2.

**Notes**

`ProcessCallPtr` reads the pointer-sized slot and builds a temporary native multicast. It never takes a property-byte pointer as the fire target.

**Evidence**

Grouped RED: `ConvertCallPtrFires` `28a5928c5974488e938a64d64b24b676` (`ProcessCallPtr Current` stayed 0; helper was a no-op). `SoftReloadCopiesCallPtrSlot` `b1de41e6b35647aca10fe4f184aed910` crashed in `DoSoftReload` at `AngelscriptClassGenerator_SoftReload.cpp:637` (`CopyCompleteValue` / `FMTAccessDetector`). Intermediate SoftReload still crashed after convert (`686777ce712549ad8276bf998ecd2c8d`); after CallPtr-sized remap, Fire failed `a5c24c8e9c1346bcb37f9da8a0e32caf` (`Execute=3` `Indirect call signature mismatch` because post-reload CallPtr had no Expected and ArgDwords stayed 0).

GREEN run `c01796b177fd4b2fbb6b473d8daaed42` (inner `ca9fbbb10799451280a0bb60503b786e`): prefix discovered 17/17 Success, including `ConvertCallPtrFires` and `SoftReloadCopiesCallPtrSlot` plus the 1.1/2.1 methods and landed controls. SoftReload Fire uses only `ReloadModules[0]->ScriptModule` (the pre-reload `InModules` module is dangling). When Expected is null, CallPtr ArgDwords come from the bound `UFUNCTION` (`asBoundUFunctionArgDwords`). Naming assumed: `FAngelscriptDelegateOperations::ProcessCallPtr` — convention from `FAngelscriptDelegateOperations`; the user did not name the convert API. Omitted Language/cook/PIE/CacheV2.
