---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
---

# UPROPERTY delegate execute coverage

## Goal

Land isolated-host script-delegate TypeDatabase seeding and the four `DelegateProperty` execute cases, then thicken Clear/Remove, script `BindUFunction`, and one more dynamic multicast arity on the same prefix.

## Architecture

`SeedHostScriptDelegateTypes` installs `FScriptDelegateType` / `FMulticastScriptDelegateType` beside the existing `SeedHostScriptObjectType` calls so ClassGen can `CreateProperty` a dynamic `DECLARE_*` member. Script fire stays on the CallPtr slot; native fire uses a local `FMulticastScriptDelegate` plus the published signature. See [design.md](design.md).

## Global constraints

- Prerequisite: archived `angelscript/feature-delegates-ue-interop` already owns DECLARE admission, CallPtr, and `DelegateReflection.OrdinaryBlueprintAssignableRejected`.
- Product edits in this Change are `SeedHostScriptDelegateTypes` only. Do not overlay `FMulticastScriptDelegate` on property bytes. Do not add `Ev.IsBound()` Sema.
- Test identity is `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>`. Do not add Language-folder execute, cook, or PIE as a proving surface.
- CacheV2 stays off on `MakeHostEngine`. Harness `ue.*` only.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp  # SeedHostScriptDelegateTypes · 1.1
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp  # four controls then three thicken methods · 1.1, 1.2
 openspec/changes/angelscript/test-delegates-uproperty-execute/specs/angelscript/bindings/delegates/spec.md  # isolated-host property adapters · 1.1
 openspec/changes/angelscript/test-delegates-uproperty-execute/specs/angelscript/runtime/delegates/spec.md  # CallPtr execute and Clear/Remove · 1.1, 1.2
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Isolated host seeds `ScriptDelegateType` / `ScriptMulticastDelegateType` | 1.1 |
| Dynamic multicast `UPROPERTY` is `FMulticastInlineDelegateProperty` with `SignatureFunction` | 1.1 |
| Dynamic single-cast `UPROPERTY` is `FDelegateProperty` with `SignatureFunction` | 1.1 |
| Script AddDynamic + Broadcast(100, 75) writes listener Current/Max | 1.1 |
| Script BindDynamic + Execute(41) writes Result=42 through void `AddOne` | 1.1 |
| Native ProcessDelegate uses published signature and a local multicast | 1.1 |
| Dynamic `UPROPERTY(BlueprintAssignable)` carries CPF_BlueprintAssignable and CPF_BlueprintCallable | 1.1 |
| Clear then Remove stop later Broadcast on a `UPROPERTY` multicast | 1.2 |
| Script `BindUFunction` then Execute writes Result=42 | 1.2 |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam` `UPROPERTY` Broadcast writes Current=42 | 1.2 |
| Do not ProcessDelegate on property bytes | 1.1, 1.2 |
| Ordinary multicast BlueprintAssignable reject stays outside this prefix | 1.1 |

Self-review 2026-09-19: coverage complete; no placeholder phrases; symbols match `design.md` and `attachments/drafts/glossary.md`. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Land host delegate-type seeding and the four DelegateProperty controls

Isolated-host compile currently treats a dynamic `DECLARE_*` member as `void` unless `ScriptDelegateType` / `ScriptMulticastDelegateType` are seeded. This task installs those adapters next to `SeedHostScriptObjectType` and lands the four already-written `DelegateProperty` methods as Change-owned controls. Overlay ProcessDelegate on property bytes stays deleted.

**Outcome**

`MakeHostEngine` + `CompileModules(Initial)` materializes `UPROPERTY() FOnPropertyHealth Ev` as `FMulticastInlineDelegateProperty` and `UPROPERTY() FPropertyAdd Handler` as `FDelegateProperty`. Script Broadcast(100, 75) writes listener Current=100 and Max=75. Script BindDynamic + Execute(41) writes owner Result=42 through void `AddOne`. Native fire uses a local `FMulticastScriptDelegate` and the published `SignatureFunction`. Dynamic `UPROPERTY(BlueprintAssignable)` keeps both CPF flags. Excluded: Clear/Remove/BindUFunction thicken (1.2), property-byte overlay, Language execute, cook, PIE, retval writeback, `Ev.IsBound()` Sema.

**Interfaces**

Consumes (existing):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:1578
TUniquePtr<FAngelscriptEngine> FAngelscriptEngine::Create(const FAngelscriptEngineConfig& InConfig, const FAngelscriptEngineDependencies& InDependencies);

// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp:711
if (Binds.IsHostTarget()) return;

// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp:102
bool FScriptDelegateType::CanCreateProperty(const FAngelscriptTypeUsage& Usage) const;
// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp:107
FProperty* FScriptDelegateType::CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const;
// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp:375
bool FMulticastScriptDelegateType::CanCreateProperty(const FAngelscriptTypeUsage& Usage) const;
// Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp:380
FProperty* FMulticastScriptDelegateType::CreateProperty(const FAngelscriptTypeUsage& Usage, const FPropertyParams& Params) const;

// Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp:271
if (!PropertyType.IsValid() || !PropertyType.CanCreateProperty())
// diagnostic: "Property %s %s in class %s has a type that cannot be a UPROPERTY."
```

Produces (`SeedHostScriptDelegateTypes` — existing convention beside `SeedHostScriptObjectType` at AngelscriptEngine.cpp:2054; glossary Change product is host seeding):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp:2070
void SeedHostScriptDelegateTypes(FAngelscriptTypeDatabase& Database, FAngelscriptBindDatabase& BindDatabase);
// called after SeedHostScriptObjectType at AngelscriptEngine.cpp:2278 and :3955

// Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp:259
TEST_CLASS_WITH_FLAGS(DelegateProperty, "Angelscript.UnitTest.NativeEngine.Compile", ...)
// identities: Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>
// glossary Test class: DelegateProperty
```

**Cases**

Setup: `MakeHostEngine` uses `FAngelscriptEngine::Create` with `bSkipInitialCompile=true`, CacheV2 overridden off (`DelegatePropertyTests.cpp:23`). Scripts go through `WriteAndPreprocess` then `CompileModules(ECompileType::Initial)`.

1. **IsolatedHostUPropertyMaterializes** — new RED
   Given Setup and `MakeHealthScript("FOnPropertyHealth", "UDelegatePropertyHealthListener", "UDelegatePropertyHealthOwner")` When `CompileModules` finishes Then `FindFProperty<FMulticastInlineDelegateProperty>(OwnerClass, "Ev")` is non-null and `SignatureFunction` name contains `FOnPropertyHealth`. Without `SeedHostScriptDelegateTypes` the same compile reports `Property void Ev` `cannot be a UPROPERTY` (historical run `c38865f58cc2403a857814ec3b029144`). After seed, do not strip the seed to re-fail; the four controls below stay the live oracle.

2. **DynamicMulticastPropertyFires** — existing control
   Given Setup and the same `MakeHealthScript` When C++ writes `Target`/`FunctionName=OnHealth` and script `BindAndFire` runs `Ev.AddDynamic(Target, FunctionName); Ev.Broadcast(100, 75)` Then listener `Current==100` and `Max==75`. Source: `DelegatePropertyTests.cpp:262`. Historical GREEN `c74cfc56c01045c3bdb81e8eb068ecd3`.

3. **NativeProcessUsingPublishedSignature** — existing control
   Given Setup and `MakeHealthScript("FOnPropertyNativeSig", ...)` When native code reads `EvProp->SignatureFunction`, builds a local `FMulticastScriptDelegate`, `BindUFunction(Listener, OnHealth)`, and `ProcessDelegate`s `{Current=100, Max=75}` Then listener Current/Max are 100/75. The test must not call `ProcessDelegate` on `ContainerPtrToValuePtr(Owner, Ev)`. Source: `DelegatePropertyTests.cpp:311`.

4. **DynamicSingleCastPropertyExecute** — existing control
   Given Setup and `DECLARE_DYNAMIC_DELEGATE_OneParam(FPropertyAdd, int, Value)` with `UPROPERTY() FPropertyAdd Handler`, void `UFUNCTION AddOne` writing `Result = Value + 1` When C++ sets `Target=Owner`, `FunctionName=AddOne` and script `BindAndExecute` runs `Handler.BindDynamic(Target, FunctionName); Handler.Execute(41)` Then `Result==42`. Source: `DelegatePropertyTests.cpp:363`.

5. **BlueprintAssignableDynamicAccepted** — existing control
   Given Setup and `UPROPERTY(BlueprintAssignable) FOnPropertyAssignable Ev` When compile finishes Then `Ev` is `FMulticastInlineDelegateProperty` with `CPF_BlueprintAssignable` and `CPF_BlueprintCallable`. Source: `DelegatePropertyTests.cpp:427`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp
```

No other Runtime, ClassGen, Sema, or Language-folder files.

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace root. After any C++ edit, run `ue.build` with `TimeoutMs=1800000` first. Pass when the report discovers and succeeds the four control methods. `IsolatedHostUPropertyMaterializes` is the seed invariant those four already assert; it has no fifth `TEST_METHOD`. Omit Language, cook, PIE, and `DelegateReflection` because R1 Q2 limits proof to this prefix. Adjacent reject `Angelscript.UnitTest.NativeEngine.Compile.DelegateReflection.OrdinaryBlueprintAssignableRejected` stays archived and is not this card's selector.

**Notes**

The seed and four methods are already in the dirty plugin tree. If the prefix is already green, record historical RED `c38865f58cc2403a857814ec3b029144` and GREEN `c74cfc56c01045c3bdb81e8eb068ecd3` in Evidence and keep the prefix green. Do not reintroduce property-byte `ProcessDelegate`.

**Evidence**

Shared run `fe5caa13d1144ead819f994495e42d04` after `ue.build` `54775a67a8c5402bbb016d28d21eec4d`. Prefix `Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty` discovered 7/7 Success, including the four 1.1 controls: `DynamicMulticastPropertyFires`, `NativeProcessUsingPublishedSignature`, `DynamicSingleCastPropertyExecute`, `BlueprintAssignableDynamicAccepted`. Historical RED without seed: `c38865f58cc2403a857814ec3b029144`. Historical GREEN of the four controls: `c74cfc56c01045c3bdb81e8eb068ecd3`. Seed and four methods were already in the dirty tree; this run keeps them green. Omitted Language/cook/PIE and `DelegateReflection` per R1 Q2.

## [x] 1.2 Thicken IsBound/Clear/Remove, BindUFunction, and OneParam

The four landed controls bind and fire once. This task adds the three glossary methods on the same `TEST_CLASS DelegateProperty`. Bound state is observed through Broadcast after Clear/Remove because `asCSema::ActOnMemberCall` has no `IsBound` branch (`as_sema_postfix.cpp:499`).

**Outcome**

`PropertyIsBoundClearRemove` proves Clear and handle Remove stop later Broadcast. `ScriptBindUFunctionFires` proves script `BindUFunction(Target, FunctionName)` then Execute(41) writes Result=42. `DynamicMulticastOneParamFires` proves `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam` `UPROPERTY` Broadcast(42) writes Current=42. Excluded: overlay storage, `Ev.IsBound()` Sema, 60-row matrix, retval writeback, Language/cook/PIE.

**Interfaces**

Consumes (existing, after 1.1):

```cpp
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:505
if (Name == TEXT("BindDynamic") || Name == TEXT("AddDynamic") || Name == TEXT("BindUFunction"))
// two-arg object+FName path sets callable operation BindUFunction or AddDynamic

// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:602
if (Name == TEXT("Remove")) // uint64 handle
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Sema/as_sema_postfix.cpp:624
if (Name == TEXT("Clear") || Name == TEXT("RemoveAll"))

// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp:250
if (Operation == TEXT("BindUFunction") || Operation == TEXT("AddDynamic")) // asBC_BindPtr / asBC_AddPtr
// Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_emitter_calls.cpp:290
if (Operation == TEXT("Remove") || Operation == TEXT("Clear") || Operation == TEXT("RemoveAll"))

// Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp:23
TUniquePtr<FAngelscriptEngine> MakeHostEngine(FString& OutDiagnostic);
// :36 Compile, :63 WriteAndPreprocess, :131 CallScriptMethod, :173 ReadIntProperty, :186 WriteListenerTarget
```

Produces (glossary: `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, `DynamicMulticastOneParamFires`):

```cpp
TEST_METHOD(PropertyIsBoundClearRemove)
TEST_METHOD(ScriptBindUFunctionFires)
TEST_METHOD(DynamicMulticastOneParamFires)
// Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty.<Method>
```

**Cases**

Setup: same `MakeHostEngine` / preprocess / `CompileModules` host as 1.1. New methods live in `DelegatePropertyTests.cpp`.

1. **PropertyIsBoundClearRemove** — new RED · sequence
   Script sketch (listener `OnHealth` writes Current/Max; owner `UPROPERTY FOnBoundHealth Ev`, Target, FunctionName):
   1. C++ writes Target and `FunctionName=OnHealth` → Current is 0.
   2. script `uint64 Handle = Ev.AddDynamic(Target, FunctionName); Ev.Broadcast(100, 75)` → Current==100, Max==75.
   3. script `Ev.Clear()`; C++ or script sets Current=0, Max=0; script `Ev.Broadcast(1, 1)` → Current stays 0.
   4. script `Handle = Ev.AddDynamic(Target, FunctionName); Ev.Remove(Handle)` then Current=0 and `Ev.Broadcast(2, 2)` → Current stays 0.
   Oracle: listener Current after steps 3 and 4 is 0. Do not call `Ev.IsBound()`. Do not ProcessDelegate on Ev bytes.

2. **ScriptBindUFunctionFires** — new RED
   Given `DECLARE_DYNAMIC_DELEGATE_OneParam(FPropertyBindFn, int, Value)` with `UPROPERTY() FPropertyBindFn Handler`, void `UFUNCTION AddOne` writing `Result = Value + 1`, `Target=Owner`, `FunctionName=AddOne` When script runs `Handler.BindUFunction(Target, FunctionName); Handler.Execute(41)` Then `Result==42`.

3. **DynamicMulticastOneParamFires** — new RED
   Given `DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnPropertyOne, int, NewHealth)`, listener `UFUNCTION void OnHealth(int NewHealth) { Current = NewHealth; }`, owner `UPROPERTY() FOnPropertyOne Ev` When C++ writes Target/`FunctionName=OnHealth` and script `Ev.AddDynamic(Target, FunctionName); Ev.Broadcast(42)` Then listener `Current==42`.

4. **DynamicMulticastPropertyFires** — existing control
   The 1.1 TwoParams Broadcast(100, 75) case remains green on the same prefix.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Compile/DelegatePropertyTests.cpp
```

No Runtime, Sema, or emitter edits. No new test class.

**Verification**

```
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Compile.DelegateProperty'; Fast = $true; TimeoutMs = 600000 }
```

Working directory is the selected workspace root. Build with `ue.build` `TimeoutMs=1800000` after C++ edits. Grouped RED: the three new methods are written first and fail together (missing method or failing assert). GREEN: the report discovers and succeeds all seven methods — the four 1.1 controls plus the three new names. Omit Language, cook, PIE, and the 60-row DECLARE matrix.

**Notes**

If `Ev.IsBound()` is written and Sema reports an unresolved member, delete that call and keep the Broadcast oracle. Do not add an `IsBound` Sema branch in this task. Overlay follow-up stays `angelscript/feature-delegates-property-storage`.

**Evidence**

Same shared run `fe5caa13d1144ead819f994495e42d04` (binary from `ue.build` `54775a67a8c5402bbb016d28d21eec4d`). The three new methods were written first; the first Automation run after they existed succeeded together with the 1.1 controls: `PropertyIsBoundClearRemove`, `ScriptBindUFunctionFires`, `DynamicMulticastOneParamFires`, plus control `DynamicMulticastPropertyFires` (7/7 Success). Product Clear/Remove/BindUFunction/OneParam on the CallPtr slot already existed; no Sema or overlay edit. No `Ev.IsBound()` call. Omitted Language/cook/PIE and the 60-row matrix.
