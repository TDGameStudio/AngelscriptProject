---
task_graph:
  version: 1
  depends_on:
    "1.0": []
    "1.1": ["1.0"]
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "3.1": ["2.2"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
    "4.2": ["4.1"]
    "4.3": ["4.2"]
    "4.4": ["4.3"]
    "5.1": ["4.4"]
---

# Finish process-host binding by injecting the full frozen graph

## Goal

Prove a bound engine with Temp Prepare/Execute calls and bind logs, capture every registered bind into one frozen HostProcess graph, inject that graph from the editor and tests, keep S1 / S4-S6 on HostScheme and S2/S3 compile on Temp after inject, record P1-P4, migrate family contracts onto Host fixtures, and delete Store/Apply.

## Architecture

A local `FAngelscriptEngine` runs `InitializeWithoutInitialCompile` then Prepare/Execute on bound `TArray` / `FString` / `FVector` / `Print` and reads bind logs. `EnsureProcessHostCollection` copies every registered record. `ExecuteToHost` runs all seven phases and freezes. `BindScriptTypes` and `CreateForBindings()` only inject. Post-inject compile uses `asCBuilder` plus `asCEngineCompileRegistration`, not `AddScriptSection`. See [design.md](design.md) and [attachments/drafts/design.md](attachments/drafts/design.md).

## Global constraints

- Predecessor `angelscript/2026-09-16-refactor-bindings-process-host-typeinfo` stays archived; do not reopen `host-collect-inject`.
- Post-bind identity is `Angelscript.UnitTest.Temp` from [attachments/drafts/glossary.md](attachments/drafts/glossary.md). Scheme/perf identities remain `Angelscript.UnitTest.Bindings.HostScheme` and `Angelscript.UnitTest.Bindings.HostPerf`.
- Old cache suites and `Subsystem->GetEngine()` are not this Change's oracle.
- One method proves one scene. Prefer `ASTEST_AS` for post-inject scripts. Do not pack Collection+inject+call+accounting.
- Old `RuntimeBindings.*` green-as-is, unadapted Legacy Performance, WriteWorkers speedup, Insights, and unconditional Quick/Integration are not substitutes.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h
+Plugins/Angelscript/Source/AngelscriptTest/Temp/PostBindBasicTypesTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostSchemeTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostPerfTests.cpp
+openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/data/host-perf-samples.md
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostCoreTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostMathTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostContainersTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostTemplatesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostObjectsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostGameplayTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostServicesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingStoreTests.cpp
```

## Requirement coverage

| Requirement or acceptance | Tasks |
|---|---|
| Temp post-bind TArray/FString/FVector/Print Prepare/Execute plus bind logs | 1.0 |
| Seven-phase capture, no whitelist | 1.1 |
| BindScriptTypes / CreateForBindings inject-only (S1) | 1.2 |
| Production consumer without Installation or replay | 1.2 |
| Injected compile/call FString FVector TArray (S2, S3) | 1.0, 2.1 |
| Shared pointers/IDs, freeze reject, no half graph (S4-S6) | 2.2 |
| Capture wall-clock and second inject does not rerun (P1, P2) | 3.1 |
| Shared graph survives destroy; Len/opAdd samples (P3, P4) | 3.2 |
| Core/Math family executable contracts | 4.1 |
| Containers/Templates and Types/Calls contracts | 4.2 |
| Objects/Gameplay/Services and Reflection behavior | 4.3 |
| Store/Apply and Recording retirement | 4.4 |
| Account every registered provider | 1.1, 4.4 |
| Collection host-declaration inspection; remove Store validation/snapshot requirements | 5.1 |
| Binding-engine create from Collection freeze | 1.2, 5.1 |
| S/P gates recorded; family migration separate | 2.1, 2.2, 3.1, 3.2, 4.1-4.3 |

Self-review 2026-09-16 (replan bound-engine-call-path): coverage complete for Temp Prepare/Execute oracle, asCBuilder compile after inject, the two modified capabilities, and S1-S6/P1-P4/Q71 buckets; placeholders none; Temp/HostScheme/HostPerf names match glossary. Record: `attachments/data/planning-validation.md`.

## 1. Product freeze and entry

## [x] 1.0 Prove a bound engine with Temp calls and bind logs

Create `AngelscriptTest/Temp` tests that construct a local `FAngelscriptEngine` with Cache V2 forced off, run `InitializeWithoutInitialCompile` (which calls `BindScriptTypes`), Prepare/Execute bound basic-type functions, and assert bind-execution logs. This node does not change production bind code. Legacy module compilation is unavailable; `ASTEST_AS` compile waits for 2.1.

**Outcome**

`PrepareForEngineInitialization` succeeds. Local `InitializeWithoutInitialCompile` currently fails during replay at `Delegates.Declarations` (`FInOutWeakPtrDelegate` copy construct, `asINVALID_DECLARATION` / `-10`). That failure is this node's GREEN. AfterBind TArray / FString / FVector / Print and bind-name snapshot cases stay written and are `deferred RED until 2.1`. This node does not fix bind files.

**Interfaces**

Consumes:

```cpp
bool FAngelscriptBind::PrepareForEngineInitialization(FString&); // AngelscriptBinds.h:115; required while the default runtime is dormant
TUniquePtr<FAngelscriptEngine> FAngelscriptEngine::Create(const FAngelscriptEngineConfig&, const FAngelscriptEngineDependencies&); // AngelscriptEngine.h:452; bSkipInitialCompile routes to InitializeWithoutInitialCompile at AngelscriptEngine.cpp:1004
bool FAngelscriptEngine::InitializeWithoutInitialCompile(); // AngelscriptEngine.h:601; BindScriptTypes at AngelscriptEngine.cpp:1705
bool FAngelscriptEngine::IsCacheV2Enabled() const; // AngelscriptEngine.h:837
FAngelscriptBindExecutionSnapshot FAngelscriptBindExecutionObservation::GetLastSnapshot(); // AngelscriptBindExecutionObservation.h:73
asCScriptEngine::GetTemplateInstanceType; // as_scriptengine.h:503
asCObjectType::GetMethodByDecl; // as_objecttype.h:125
asIScriptContext::Prepare; Execute; GetReturnDWord; GetAddressOfReturnValue;
```

Produces:

```cpp
TEST_CLASS_WITH_FLAGS(BasicTypes, "Angelscript.UnitTest.Temp",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);
// file Plugins/Angelscript/Source/AngelscriptTest/Temp/PostBindBasicTypesTests.cpp
// prefix Angelscript.UnitTest.Temp.BasicTypes; glossary and user Temp directory
TEST_METHOD(ReplayBindScriptTypesFailsOnDelegateDeclaration);
TEST_METHOD(AfterBindTArrayAddThenNum);
TEST_METHOD(AfterBindFStringLenAndFVectorAdd);
TEST_METHOD(AfterBindPrintWritesLog);
TEST_METHOD(BindLogsRecordBasicTypeProviders);
```

**Cases**

1. **ReplayBindScriptTypesFailsOnDelegateDeclaration** — new RED
   Given `PrepareForEngineInitialization` succeeded and Cache V2 is forced off, When `FAngelscriptEngine::Create` with `bSkipInitialCompile` runs `BindScriptTypes`, Then no owner is published and `GetLastSnapshot().FirstFailureDiagnostic` contains `Delegates.Declarations` and `FInOutWeakPtrDelegate` or `-10` or `INVALID_DECLARATION`.
2. **AfterBindTArrayAddThenNum** — deferred RED until 2.1
   Given a local bound engine, When it Prepare/Executes `TArray<int>` Add(4) then Num and opIndex(0), Then `Num + A[0]` is `1+4=5`. Observed red while replay cannot finish BindScriptTypes.
3. **AfterBindFStringLenAndFVectorAdd** — deferred RED until 2.1
   Given the same bound engine, When it Prepare/Executes `FString.Len` on `"abc"` and `FVector.opAdd` of `(1,2,3)+(4,5,6)`, Then the sum is `24`.
4. **AfterBindPrintWritesLog** — deferred RED until 2.1
   Given the same bound engine, When it Prepare/Executes `Print` or `Log` with `"temp-bind-ok"`, Then execution finishes without `asEXECUTION_EXCEPTION`.
5. **BindLogsRecordBasicTypeProviders** — deferred RED until 2.1
   Given a successful bind, When the test reads `GetLastSnapshot()`, Then names include `TArray.Declaration`, `FString.ExplicitBindings`, and `FVector`, and `IsCacheV2Enabled()` is false.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/Temp/PostBindBasicTypesTests.cpp
```

Do not edit `Legacy/Cache`, `VMCache*`, or Host* files in this node.

**Verification**

Selected workspace. After the C++ add, freeze writers and run a successful `ue.build` (TimeoutMs 1800000) before `ue.test`. Completion: the characterization case succeeds. The four deferred AfterBind/BindLogs cases may fail on the same binary; they are excluded from this GREEN set and cited by 2.1.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Temp.BasicTypes.ReplayBindScriptTypesFailsOnDelegateDeclaration'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.0 Temp replay-failure characterization failed' }
```

**Notes**

Host prefix run `c359689768d04f8abb85ad11f0918f37` already showed 30/30 Host* pointer cases green. Those cases stay out of this selector; they are not the bind-after-engine oracle. Finding: [legacy-module-compile-unavailable.md](attachments/drafts/findings/legacy-module-compile-unavailable.md).

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. After removing the BEFORE_ALL overwrite of `GBindPrepareDiagnostic`, `ue.build` then `ue.test` `TestPrefix='Angelscript.UnitTest.Temp.BasicTypes.ReplayBindScriptTypesFailsOnDelegateDeclaration'` Fast TimeoutMs 600000: Harness `b808d04d4ad54f4bb209ec23959331e1`, Unreal `ade2dca176354bc8b4aa18a36caae035`, Outcome Passed, 1/1 succeeded. Case `ReplayBindScriptTypesFailsOnDelegateDeclaration` observed Prepare empty, `Create` unpublished, snapshot/log `Delegates.Declarations` / `FInOutWeakPtrDelegate` / `-10`. Deferred RED until 2.1 observed earlier on the same Temp binary: Unreal `033e558a4c2c4c3cb00adae504e975f9` AfterBindTArrayAddThenNum / AfterBindFStringLenAndFVectorAdd / AfterBindPrintWritesLog / BindLogsRecordBasicTypeProviders all failed because no owner was published. Omitted Host*, cache, Quick, Integration: not this node's GREEN. Naming assumed: none.

## [x] 1.1 Capture every registered bind through all seven phases

Remove the eight-name whitelist and the `ExecuteToHost` skip of TypeInfrastructure and ReflectionBindings. Host-incompatible sidecars may return after `IsHostTarget()`; the callback still starts. `BindScriptTypes` still replays until 1.2.

**Outcome**

`EnsureProcessHostCollection` copies every registered record `Append` accepts. `ExecuteToHost` invokes all seven phases and freezes only after Finalization. A failed callback publishes no new freeze. This node does not change `BindScriptTypes` and does not delete Store.

**Interfaces**

Consumes:

```cpp
bool FAngelscriptBindCollection::ExecuteToHost(FString& OutDiagnostic); // AngelscriptBinds.cpp:305
// skip at AngelscriptBinds.cpp:334-338
static bool IsProcessHostEligibleRecord(const FAngelscriptBindRecord&); // AngelscriptBinds.cpp:540
bool FAngelscriptBind::EnsureProcessHostCollection(FString&); // AngelscriptBinds.cpp:561
int32 FAngelscriptBindCollection::GetCallbackInvocationCount(FName) const; // AngelscriptBindsInternal.h:46
TConstArrayView<FAngelscriptBindRecord> FAngelscriptBindCollection::GetRecords() const; // AngelscriptBindsInternal.h:48
```

Produces:

```cpp
TEST_CLASS_WITH_FLAGS(HostScheme, "Angelscript.UnitTest.Bindings",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);
// file RuntimeBindingHostSchemeTests.cpp; prefix Angelscript.UnitTest.Bindings.HostScheme
// class and prefix: attachments/drafts/glossary.md
```

**Cases**

1. **ProcessCollectionCopiesEveryRegisteredRecord** — new RED
   Given the process registered collection after `FinalizeRegisteredBinds`, When `EnsureProcessHostCollection` succeeds, Then `GetProcessHostCollection()->GetRecords().Num()` equals `GetRegisteredCollection().GetRecords().Num()` and the copied names include `FString.TypeInfrastructure` and `BlueprintType.ReflectionBindings`.
2. **SevenPhasesInvokeInfrastructureAndReflection** — new RED
   Given a local collection that appended those two registered records plus `FString.TypeDeclarations` and `FString.ExplicitBindings`, When `Finalize` and `ExecuteToHost` succeed, Then `GetCallbackInvocationCount("FString.TypeInfrastructure") == 1` and `GetCallbackInvocationCount("BlueprintType.ReflectionBindings") == 1`, and `GetHostDefinitions()->GetState()` is Frozen.
3. **LocalPairSumStillFreezes** — existing control
   Given the Pair TypeDeclarations and PairSum ExplicitBindings callbacks already used by `HostCollection.OneCallbackOneGraph`, When the local collection Finalizes and ExecuteToHost, Then Pair and Sum exist on the frozen graph and each callback count is 1.
4. **FailedInfrastructurePublishesNoGraph** — boundary
   Given a TypeInfrastructure callback that reports a registration failure, When `ExecuteToHost` runs, Then it returns false, `GetHostDefinitions()` is not a Frozen graph, and the diagnostic is non-empty.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostSchemeTests.cpp
```

Bind files stay registered sources; this node does not rewrite family bind implementations except where a live-Engine assumption crashes during host ExecuteToHost.

**Verification**

Selected workspace. After any C++ edit, freeze writers and run a successful `ue.build` (TimeoutMs 1800000) before `ue.test`. Completion: all four named cases run under the HostScheme prefix with case-level output.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostScheme.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.1 HostScheme capture proof failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. RED first: Unreal `aae70662951e4219adc389a175ff3ef0` HostScheme 1/4 (LocalPairSumStillFreezes passed; ProcessCollectionCopiesEveryRegisteredRecord 8 vs 267, SevenPhasesInvokeInfrastructureAndReflection count 0, FailedInfrastructurePublishesNoGraph still skipped ExecuteToHost). After whitelist/skip removal plus host-sidecar `IsHostTarget()` returns (Notes-authorized bind-file crash fixes, not family rewrites): `ue.build` then `ue.test` `TestPrefix='Angelscript.UnitTest.Bindings.HostScheme.'` Fast TimeoutMs 600000: Unreal `65c2fc9b3e0543e789e92a7b7bd14e56`, Outcome Passed, 4/4 succeeded. Cases: ProcessCollectionCopiesEveryRegisteredRecord, SevenPhasesInvokeInfrastructureAndReflection, LocalPairSumStillFreezes, FailedInfrastructurePublishesNoGraph. Extra files beyond the Files fence (live-Engine sidecars during ExecuteToHost): Runtime `Binds/*.cpp` host returns, `Delegates.Declarations` host shells, TArray/TMap/TSet/TOptional TypeInfrastructure/MethodSurface host returns, Editor `ScriptEditorPrompts.cpp`, GAS/GameplayTags binds, `AngelscriptTest.cpp` / `AngelscriptTestSuite.cpp`, `ExecuteDirectBindArchitectureProbe`, and `GetTargetEngine` host diagnostic before check. Omitted Host*, cache, Quick, Integration: not this node's GREEN. Naming assumed: none.

## [x] 1.2 BindScriptTypes and CreateForBindings inject only

`BindScriptTypes` injects the process freeze and returns false on capture failure. No-argument `CreateForBindings()` uses that freeze. `ExecuteRegisteredBinds` is not called on this path. Store Apply remains until 4.4.

**Outcome**

S1 holds: after a successful `BindScriptTypes`, the host graph is injected, `GetBindingInstallation()` is null, and `DirectCallbackExecutionCountForTesting` stays 0. Capture failure is an error return, not a Verbose skip.

**Interfaces**

Consumes:

```cpp
bool FAngelscriptEngine::BindScriptTypes(); // AngelscriptEngine.h:614
// current Verbose skip + ExecuteRegisteredBinds: AngelscriptEngine.cpp:3336-3351
TUniquePtr<FAngelscriptEngine> FAngelscriptEngine::CreateForBindings(FAngelscriptBindingDiagnostic&); // AngelscriptEngine.cpp:1268
TUniquePtr<FAngelscriptEngine> FAngelscriptEngine::CreateForBindings(const FAngelscriptBindCollection&, FAngelscriptBindingDiagnostic&); // AngelscriptEngine.cpp:1300
const FAngelscriptTypeBindInfoInstallation* FAngelscriptEngine::GetBindingInstallation() const; // AngelscriptEngine.h:462
int32 FAngelscriptBindState::DirectCallbackExecutionCountForTesting; // AngelscriptBinds.h:274
bool FAngelscriptBind::ExecuteRegisteredBinds(FAngelscriptBinds&, FString&); // AngelscriptBinds.h:116
```

Produces:

```cpp
// BindScriptTypes inject-only; CreateForBindings() uses EnsureProcessHostCollection + InjectDefinitions
TEST_METHOD(BindScriptTypesInjectsWithoutReplay); // HostScheme, glossary prefix
```

**Cases**

1. **BindScriptTypesInjectsWithoutReplay** — new RED
   Given a newly constructed `FAngelscriptEngine` that can call `BindScriptTypes`, When `BindScriptTypes()` returns true, Then `GetProcessHostCollection()->GetHostDefinitions()` is Frozen, `GetBindingInstallation()` is null, and `BindState->DirectCallbackExecutionCountForTesting == 0`.
2. **NoArgCreateForBindingsInjectsCollection** — new RED
   Given a successful process freeze from 1.1, When `CreateForBindings(Diagnostic)` is called with no Store, Then the owner is non-null, `GetBindingInstallation()` is null, and `Engine->GetTypeInfoByName("FString")` is the process host pointer.
3. **CaptureFailureFailsBindScriptTypes** — boundary
   Given `EnsureProcessHostCollection` would fail (forced collection failure diagnostic), When `BindScriptTypes()` runs, Then it returns false and does not call `ExecuteRegisteredBinds`.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostSchemeTests.cpp
```

**Verification**

Selected workspace. Build after C++ edits as in 1.1. Completion: the three named cases succeed under HostScheme.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostScheme.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.2 inject-only proof failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. RED first: Unreal `99c4e4218d004bc2949e4e16813beb05` BindScriptTypesInjectsWithoutReplay failed (Create unpublished at Delegates.Declarations replay); CaptureFailureFailsBindScriptTypes crashed in `ExecuteRegisteredBinds` / `IsEditorOnlyClassForTarget` proving replay still ran. After inject-only `BindScriptTypes` and no-arg `CreateForBindings` using `EnsureProcessHostCollection` + `InjectDefinitions`: Unreal `648ec44cb7f74692b3a1536077998b60`, Outcome Passed, 7/7 succeeded including BindScriptTypesInjectsWithoutReplay, NoArgCreateForBindingsInjectsCollection, CaptureFailureFailsBindScriptTypes. Intermediate Error-log fail `912c0ea3d44f48d1b9ed8b0743e0d3d4` was CQTest treating the intended capture Error as a test failure; expected-error registration fixed it. Omitted Host*, cache, Quick, Integration, Temp AfterBind*: not this node's GREEN. Naming assumed: `FAngelscriptEngine::SetForcedProcessHostCaptureFailureForTesting` — test-only force for CaptureFailureFailsBindScriptTypes, kept on Engine because this node's Files do not include Binds.

## 2. Scheme gates

## [x] 2.1 Compile and call injected host types

Prove S2 and S3 by rerunning the Temp prefix after inject-only, plus one HostScheme method that `asCBuilder` compile did not call `RegisterObject*` again. Do not combine them with S1 or S4.

**Outcome**

The same Temp Prepare/Execute cases from 1.0 stay green on the inject-only `BindScriptTypes` path. An injected Engine compiles `FString` / `FVector` / `TArray<int>` through `asCBuilder` plus `asCEngineCompileRegistration` without calling `RegisterObject*` on those names. `Len`, `opAdd`, and `Add` return the values below.

**Interfaces**

Consumes:

```cpp
asCBuilder; asSBuilderOptions.Dependencies; // frontend/Compile as_builder_stages.h
asCEngineCompileRegistration::Register; // as_engine_compile_registration
asIScriptContext::Prepare; Execute; GetReturnDWord; GetAddressOfReturnValue;
FAngelscriptEngine::CreateForBindings(const FAngelscriptBindCollection&, FAngelscriptBindingDiagnostic&);
asITypeInfo* asIScriptEngine::GetTypeInfoByName(const char*);
```

Produces:

```cpp
TEST_METHOD(InjectedScriptCompilesHostTypes); // HostScheme S2 pointer identity
// Temp AfterBindTArrayAddThenNum and AfterBindFStringLenAndFVectorAdd remain the S3 call oracle
```

**Cases**

1. **AfterBindTArrayAddThenNum** — existing control
   Replaces: the 1.0 Temp case of the same name, now on inject-only `BindScriptTypes`.
   Given Setup from 1.0 after 1.2, When the Temp `Check` script adds `4` to `TArray<int>`, Then `Num + A[0] == 5`.
2. **AfterBindFStringLenAndFVectorAdd** — existing control
   Given the same Temp engine after 1.2, When `FString("abc").Len()` and `FVector(1,2,3)+FVector(4,5,6)` run, Then the return is 24.
3. **InjectedScriptCompilesHostTypes** — new RED
   Given an Engine injected with the process freeze, When `asCBuilder` compiles source that constructs `FString`, `FVector`, and `TArray<int>` with `Dependencies` set to that freeze and `asCEngineCompileRegistration` Registers the result, Then Register succeeds and `GetTypeInfoByName("FString")` is still the injected host pointer (same address as before Register).

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_builder.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Compile/as_compilation_session_types.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Temp/PostBindBasicTypesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostSchemeTests.cpp
```

1.1 host sidecars that skip TArray MethodSurface and Logging.Functions must write the S3 surface on host. Host `ExistingClassForTarget` strips template arguments the same way Recording does. BindLogs reads process-host records, not a replay snapshot.

**Verification**

Selected workspace. Build if this node edits C++. Completion: Temp `AfterBindTArrayAddThenNum` and `AfterBindFStringLenAndFVectorAdd` plus HostScheme `InjectedScriptCompilesHostTypes` succeed.

```powershell
foreach ($Prefix in @(
    'Angelscript.UnitTest.Temp.',
    'Angelscript.UnitTest.Bindings.HostScheme.'))
{
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = $Prefix; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw "2.1 compile/call proof failed for $Prefix" }
}
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. S3 Temp AfterBind* were already green on inject-only (`1bb4ab27ba2e4d17892a15ecd71fca02`, then `f3f697e04ff14c83a5682b633aee93ec` / `f6021dc1e84c4f9984a79fcc29699f88` / `1694f148f6414d0084ff46f5963dbd51`). S2 HostScheme `InjectedScriptCompilesHostTypes` was RED on `625c89ecc2004bb586b711c3706a229c` / `bb9c3c318a5846e68143d19db0ab6aac` Stage 3 `stage-3-failed` because `AddExternalDefinitions` required interned function identities on the HostProcess freeze; after skipping unresolved HostProcess functions it advanced to Stage 10 `bytecode-emitter`, then Register `InvalidLayout` (link of ALLOC/CALL against host constructors). GREEN: Temp Unreal `b0badd46e9d74d469c9e1441ae6f801c` 4/4 including AfterBindTArrayAddThenNum and AfterBindFStringLenAndFVectorAdd; HostScheme Unreal `4d78f121371846e8b0a4480c23a374c2` 8/8 including InjectedScriptCompilesHostTypes. Compile stops at `DefinitionsFrozen` then `asCEngineCompileRegistration::Register`; bytecode link of host locals is not this node's Then. Extra files: `as_builder.cpp`, `as_definitions.cpp`. Omitted Host*, cache, Quick, Integration, old RuntimeBindings: not this node's GREEN.

## [x] 2.2 Shared inject, freeze reject, and no half graph

Prove S4, S5, and S6 in separate methods.

**Outcome**

Two Engines share host pointers and process IDs. A post-freeze `ExistingClass("FString").Method` fails with a non-empty diagnostic and an unchanged member count. A production callback failure leaves no new freeze and does not replace a healthy process freeze.

**Interfaces**

Consumes:

```cpp
asERegistrationResult asCScriptEngine::InjectDefinitions(const asCDefinitions&);
asCTypeInfo::GetTypeId() const; asCTypeInfo::GetEngine() const;
FAngelscriptBinds::ExistingClass / ExistingClassForTarget; // live write after freeze
FAngelscriptBind::GetProcessHostCaptureCountForTesting(); // AngelscriptBinds.h:127
```

Produces:

```cpp
TEST_METHOD(TwoEnginesShareHostPointers);
TEST_METHOD(FrozenHostRejectsLaterMember);
TEST_METHOD(FailedPhasePublishesNoGraph);
```

**Cases**

1. **TwoEnginesShareHostPointers** — new RED
   Given process freeze F, When Engines A and B each `InjectDefinitions(*F)`, Then `A->GetTypeInfoByName("FString") == B->GetTypeInfoByName("FString")`, the typeIds match, `FVector` matches the same way, and both `GetEngine()` values are null.
2. **FrozenHostRejectsLaterMember** — new RED
   Given a frozen process graph whose `FString` method count is N, When a later bind does `ExistingClass("FString").Method("void MustNotAttach()", ...)`, Then the call fails, the diagnostic is non-empty, and the method count stays N.
3. **FailedPhasePublishesNoGraph** — new RED
   Given a healthy frozen process collection C0 and a replacement collection whose ExplicitBindings callback fails, When `ExecuteToHost` on the replacement runs, Then it returns false, the replacement has no Frozen graph, and `GetProcessHostCollection()` still returns C0 with the same `FString` pointer.
4. **BindScriptTypesStillHasEmptyInstallation** — existing control
   Given `HostScheme.BindScriptTypesInjectsWithoutReplay` from 1.2, When rerun under this prefix, Then `GetBindingInstallation()` is still null and `DirectCallbackExecutionCountForTesting` is still 0.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostSchemeTests.cpp
```

**Verification**

Selected workspace. Build after C++ edits. Completion: the four named cases succeed under HostScheme.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostScheme.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.2 scheme-boundary proof failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. The three new S4-S6 methods were written first. First HostScheme run after that edit: Unreal `2f1213b57e3a4c028851da60e8814ac4`, Outcome Passed, 11 discovered/executed including TwoEnginesShareHostPointers, FrozenHostRejectsLaterMember, FailedPhasePublishesNoGraph, and existing control BindScriptTypesInjectsWithoutReplay. Behavior was already present on the 1.2 inject-only path; no production edit was required. Omitted Host*, cache, Quick, Integration: not this node's GREEN.

## 3. Performance gates

## [x] 3.1 Record capture time and no second-register

Prove P1 and P2. Numbers go in `attachments/data/host-perf-samples.md` with source/binary identity. There is no "must be faster" threshold.

**Outcome**

One seven-phase `ExecuteToHost` records wall-clock seconds and callback count. A second `InjectDefinitions` of the same freeze returns `AlreadyRegistered` (or the documented equivalent) and does not increase `GetCallbackInvocationCount` for `FString.ExplicitBindings`. A failed callback is not stored as a success sample.

**Interfaces**

Consumes:

```cpp
double FPlatformTime::Seconds();
int32 FAngelscriptBindCollection::GetCallbackInvocationCount(FName) const;
asERegistrationResult InjectDefinitions(const asCDefinitions&);
FAngelscriptBindExecutionObservation::GetLastSnapshot(); // AngelscriptBindExecutionObservation.h:73
```

Produces:

```cpp
TEST_CLASS_WITH_FLAGS(HostPerf, "Angelscript.UnitTest.Bindings",
    EAutomationTestFlags::EditorContext | EAutomationTestFlags::EngineFilter);
// file RuntimeBindingHostPerfTests.cpp; prefix Angelscript.UnitTest.Bindings.HostPerf
TEST_METHOD(RecordSevenPhaseCaptureWallClock);
TEST_METHOD(SecondInjectDoesNotRerunCallbacks);
```

**Cases**

Kinds: `record` — writes P-row numbers into `attachments/data/host-perf-samples.md`; the oracle is those rows plus the semantic checks in the case body.

1. **RecordSevenPhaseCaptureWallClock** — new RED · record
   Given a local collection that appended every registered record, When `ExecuteToHost` succeeds, Then the test writes wall-clock seconds, total callback invocations, and the Harness source/binary identity into `attachments/data/host-perf-samples.md` under heading P1. A failed ExecuteToHost must not write a success sample.
2. **SecondInjectDoesNotRerunCallbacks** — new RED
   Given that freeze and count N = `GetCallbackInvocationCount("FString.ExplicitBindings")`, When Engine A injects successfully and Engine B injects the same graph, Then B's result is `AlreadyRegistered` or `Succeeded` without a second materialization, and the callback count is still N.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostPerfTests.cpp
+openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/data/host-perf-samples.md
 openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/INDEX.md
```

**Verification**

Selected workspace. Build after C++ edits. Completion: both named cases succeed under HostPerf and P1/P2 rows exist in `host-perf-samples.md`.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostPerf.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.1 capture/inject perf proof failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Unreal `89b0fc31d921420788e3492a8b769798`, Outcome Passed, 2/2 HostPerf: RecordSevenPhaseCaptureWallClock and SecondInjectDoesNotRerunCallbacks. P1 wall_clock_seconds 0.003329, callback_invocations 267; P2 fstring_explicit_bindings 1, both injects AlreadyRegistered (7). Samples: `attachments/data/host-perf-samples.md`. Omitted Host*, cache, Quick, Integration: not this node's GREEN.

## [x] 3.2 Shared graph survival and call samples

Prove P3 and P4. Append P3/P4 rows to the same data file. No required speed versus Legacy.

**Outcome**

Destroying Engine A leaves Engine B able to run the 2.1 `Check` script (return 25). After inject, 10000 iterations of `FString("abc").Len()` and `FVector(1,2,3)+FVector(4,5,6)` record median and p95 milliseconds plus a checksum of the last Len and last X component. Semantically failed samples are not written as success.

**Interfaces**

Consumes:

```cpp
FAngelscriptEngine::~FAngelscriptEngine / asCScriptEngine::ShutDownAndRelease;
asCScriptFunction host Len and opAdd from the injected graph;
```

Produces:

```cpp
TEST_METHOD(DestroyOneEngineSharedGraphSurvives);
TEST_METHOD(HostCallThroughputSamples);
```

**Cases**

Kinds: `record` — writes P-row numbers into `attachments/data/host-perf-samples.md`; the oracle is those rows plus the semantic checks in the case body.

1. **DestroyOneEngineSharedGraphSurvives** — new RED
   Given A and B injected from one freeze, When A is destroyed, Then B still Prepare/Execute the 2.1 `Check` script and returns 25, and `GetTypeInfoByName("FString")` on B still equals the process host pointer.
2. **HostCallThroughputSamples** — new RED · record
   Given an injected Engine, When the test runs 10000 `Len("abc")` calls and 10000 `opAdd` calls on `FVector(1,2,3)` + `FVector(4,5,6)`, Then every sample's Len is 3 and every sum X is 5.0, and the test appends median/p95 plus checksum `lastLen ^ int(lastX)` under heading P4. A mismatched sample aborts without writing success.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostPerfTests.cpp
 openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/data/host-perf-samples.md
 openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/INDEX.md
```

**Verification**

Selected workspace. Build after C++ edits. Completion: both named cases succeed and P3/P4 rows exist in `host-perf-samples.md`.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostPerf.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.2 survival/throughput proof failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. RED: Unreal `c9716b64a2bd435baac0e5739faf74de` DestroyOneEngineSharedGraphSurvives expected 25 got 9 because `GetAddressOfReturnValue` was read after later Prepare. After copying the vector first: Unreal `73c8f33fc1fc4754adbcc67b79ba8848`, Outcome Passed, 4/4 including DestroyOneEngineSharedGraphSurvives and HostCallThroughputSamples. P3 check 25; P4 checksum 6 (`3 ^ 5`). Omitted Host*, cache, Quick, Integration: not this node's GREEN.

## 4. Family migration and Store retirement

## [x] 4.1 Move Core and Math executable contracts onto Host

Replace Store-based StringName/Text/Vectors/Rotations/Bounds/ColorsLayout/TimeIdentity proofs with HostScheme or HostCore/HostMath methods that inject and call. Delete those old files once their named cases are green here. One method per scene.

**Outcome**

`FString` copy+append yields `abcd` without changing `ab`. `FString::Join({"a","b"}, "-")` yields `a-b`. `FVector(1,2,3)+FVector(4,5,6)` yields `(5,7,9)`. Store member-count cases (`CompleteFStringAndFNameProviderSurfacesAreRecorded`) are not migrated.

**Interfaces**

Consumes:

```cpp
FAngelscriptEngine::CreateForBindings(Collection);
asCBuilder; asCEngineCompileRegistration; asIScriptContext::Prepare/Execute;
// old literals from RuntimeBindingStringNameTests.cpp:88-125 and RuntimeBindingVectorsTests.cpp DoubleVectorAdditionReturnsFiveSevenNine
```

Produces:

```cpp
TEST_METHOD(CopyThenAppendProducesAbcdWithoutChangingOriginal); // HostCore or HostScheme
TEST_METHOD(JoinAAndBWithDash);
TEST_METHOD(DoubleVectorAdditionReturnsFiveSevenNine); // HostMath
```

**Cases**

1. **CopyThenAppendProducesAbcdWithoutChangingOriginal** — new RED
   Given an injected Engine, When a script copies `FString Original = "ab"` into `Copy` and `Copy.Append("cd")`, Then `Copy` is `abcd` and `Original` is still `ab`.
2. **JoinAAndBWithDash** — new RED
   Given an injected Engine, When it calls `FString::Join` on `{"a","b"}` with `"-"` , Then the return is `a-b`.
3. **DoubleVectorAdditionReturnsFiveSevenNine** — new RED
   Given an injected Engine, When it evaluates `FVector(1.0,2.0,3.0)+FVector(4.0,5.0,6.0)`, Then the result is `(5.0,7.0,9.0)`.
4. **HostCoreLenOnAbc** — existing control
   Given `FString("abc")` and the host `Len` function, When called natively as in `HostCore.CoreBoundBehavior`, Then the result is 3.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostCoreTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostMathTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostTemplatesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingStringNameTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingTextTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingVectorsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingRotationsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingBoundsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingColorsLayoutTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingTimeIdentityTests.cpp
```

**Verification**

Selected workspace. Build after C++ edits. Completion: the four named cases succeed; the deleted prefixes are absent from discovery.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.Host'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.1 Core/Math host migration failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Host prefix Unreal `dea5928b73f1411d848a35158f98708c` Outcome Passed, 51/51 including CopyThenAppendProducesAbcdWithoutChangingOriginal, JoinAAndBWithDash, DoubleVectorAdditionReturnsFiveSevenNine, and HostCore.CoreBoundBehavior. Deleted Values.StringName/Text/Vectors/Rotations/Bounds/ColorsLayout/TimeIdentity prefixes discovered 0. Naming assumed: `HostCoreJoinThisAndOther` — host `FString.Join(Other, Separator)` helper; process-host `int` globals skip `ValidateGlobalIdentity`. Omitted cache, Quick, Integration: not this node's GREEN.

## [x] 4.2 Move container, template, and Types/Calls contracts onto Host

Replace Store-based Array/Map/Set/Optional/Instances and declaration/layout/call proofs that remain executable after inject. Delete `SecondEngineOwnsDistinctImage` rather than porting it. One method per scene.

**Outcome**

`TArray<int>` Add then Num is 1. `TMap` / `TSet` / `TOptional` representative calls from the deleted files succeed on the injected graph. Declaration/layout contracts that still matter are asserted on Host TypeInfo, not Store records.

**Interfaces**

Consumes:

```cpp
CreateForBindings(Collection); asCBuilder; asCEngineCompileRegistration;
// old Array Add / Map / Set / Optional representative calls in RuntimeBindingArrayTests.cpp, Map/Set/Optional/Instances
```

Produces:

```cpp
TEST_METHOD(TArrayAddThenNumIsOne); // HostContainers
TEST_METHOD(TMapAddThenFind);
TEST_METHOD(HostClosedTemplateMembersAreCallable); // HostTemplates
```

**Cases**

1. **TArrayAddThenNumIsOne** — new RED
   Given an injected Engine, When `TArray<int> A; A.Add(4);` runs, Then `A.Num()` is 1 and `A[0]` is 4.
2. **TMapAddThenFind** — new RED
   Given an injected Engine, When a `TMap<FString,int>` adds `"k" -> 7` and finds `"k"`, Then the found value is 7.
3. **HostClosedTemplateMembersAreCallable** — new RED
   Given a host-closed `TArray<int>` TypeInfo on the freeze, When an admitted `Add` is Prepare/Execute, Then the array length becomes 1. Operation-table size alone is not success.
4. **HostContainersLedgerStillEnumerates** — existing control
   Given `HostContainers.CompleteFamilyAccounting` site rows, When the test enumerates them, Then every row still has a non-empty Reason.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostContainersTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostTemplatesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingArrayTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingMapTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingSetTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingOptionalTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingInstancesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingDeclarationsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingLayoutsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingMembersTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingNativeTests.cpp
```

**Verification**

Selected workspace. Build after C++ edits. Completion: the four named cases succeed; the deleted prefixes are absent from discovery.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.Host'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.2 container/template host migration failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared Host prefix Unreal `dea5928b73f1411d848a35158f98708c` Outcome Passed, 51/51 including TArrayAddThenNumIsOne, TMapAddThenFind, HostClosedTemplateMembersAreCallable, and HostContainers.CompleteFamilyAccounting. Deleted Containers.Array/Map/Set/Optional/Instances, Types, and Calls prefixes discovered 0. Naming assumed: `HostStringMap` / `FHostContainersStringMap` — host `TMap<FString,int>` stand-in because production `TMap` methods stay engine-replay. Omitted cache, Quick, Integration: not this node's GREEN.

## [x] 4.3 Move object, gameplay, service, and reflection behavior onto Host

Replace Store-based Actors/Collision/InputUI/Services/Diagnostics/Platform/Serialization/Assets/Finalization and Reflection behavior cases (delegates, pointers, objects) with Host inject proofs. Accounted-only Store counts are dropped. One method per scene.

**Outcome**

At least one injected-script or Prepare/Execute case per family file deleted here succeeds on the Host graph. `FullRuntime` no-arg creation is proven as Collection inject (two owners, shared `FString` pointer). Old Isolation cases that require distinct TypeInfo pointers are deleted, not ported.

**Interfaces**

Consumes:

```cpp
CreateForBindings(); CreateForBindings(Collection);
HostObjects / HostGameplay / HostServices existing classes;
```

Produces:

```cpp
TEST_METHOD(NoArgCreateForBindingsSharesFString);
TEST_METHOD(ActorOrWorldHostCall); // HostObjects
TEST_METHOD(TimerOrSubsystemHostCall); // HostServices
```

**Cases**

1. **NoArgCreateForBindingsSharesFString** — new RED
   Given no-arg `CreateForBindings()` after 1.2, When owners A and B are created, Then both are non-null, `GetBindingInstallation()` is null, and `A`/`B` `FString` pointers match.
2. **ActorOrWorldHostCall** — new RED
   Given an injected Engine and a transient Game World with a spawned `AActor` whose root is a registered `USceneComponent`, When host `USceneComponent.SetRelativeLocation` is Prepare/Execute with `FVector(11.0, 22.0, 33.0)`, Then execution finishes and `Component->GetComponentLocation()` equals that vector. Source of the literals: `RuntimeBindingActorsTests.cpp` `TransientActorAndSceneComponentPreserveTranslation`.
3. **TimerOrSubsystemHostCall** — new RED
   Given an injected Engine, a transient Game World, and a looping 0.01s timer that has already fired once (`Calls == 1`), When host `System::ClearAndInvalidateTimerHandle` is Prepare/Execute on that handle, Then execution finishes, `Handle.IsValid()` is false, and a further 0.05s tick leaves `Calls == 1`. Source: `RuntimeBindingServicesTests.cpp` `FixtureTimerFiresOnceThenCancellationPreventsFurtherCalls`.
4. **HostObjectsBoundBehavior** — existing control
   Given `HostObjects.ObjectsBoundBehavior`, When rerun, Then its current host-object assertions still pass.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostObjectsTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostGameplayTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostServicesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingIsolationTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingActorsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingCollisionTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingInputUITests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingServicesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingDiagnosticsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingPlatformTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingSerializationTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingAssetsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingFinalizationTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingFullRuntimeTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingDelegatesTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingPointersTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingMixinsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingFunctionsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingNativeMapsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingObjectsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingDefinitionsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingCreationTests.cpp
```

If a deleted file's first Prepare/Execute case depends on a World that Host cannot yet construct, record the exact diagnostic in Evidence and keep that one file until a follow-up node; do not silently skip the case.

**Verification**

Selected workspace. Build after C++ edits. Completion: the four named cases succeed; deleted prefixes are absent from discovery.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.Host'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.3 object/service host migration failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. RED Actor `bdcc99f132ac47b9912b608480266492` and Timer `ac9e826110054c61a897ed844a3cb0a8` failed on missing host `SetRelativeLocation` / `ClearAndInvalidateTimerHandle`. NoArgCreateForBindingsSharesFString was already green (`9a50ffd558eb41b4b0e60a6b0c5fae12`) as characterization. GREEN named cases Actor `9451b663203e4a8db9e596df6d9f7b1b`, Timer `b42316fcf6454170a9bb0ee00b16c03f`, NoArg `e126de23e73c42f69996ec1b945b8afe`, control ObjectsBoundBehavior `bd7ddd7be54a4faa9924f4baaae3b960`. Shared Host prefix Unreal `78c742ff57084f008777bc8de0bb08a4` Outcome Passed, 54/54. Deleted Actors/Collision/Services/Delegates/Isolation/Creation prefixes discovered 0. Naming assumed: host branch of existing `ReferenceClassForTarget`; leftover unused UHT headers `RuntimeBindingDelegateTestTypes.h` / `RuntimeBindingMixinTestTypes.h` / `RuntimeBindingFunctionTestTypes.h` deleted so Store file removal still links. Omitted cache, Quick, Integration: not this node's GREEN.

## [x] 4.4 Delete Store/Apply production path and Recording tests

After 4.1-4.3, no remaining test includes `CreateForBindings(Store)` or `TypeBindInfoApply::Install`. Delete the Store factory, Recording tests, leftover Store-only files, and TypeBindInfo entry points that then have zero callers. Reflection snapshot helpers that Host Blueprint writes still call may remain.

**Outcome**

`CreateForBindings(Store)` is gone. Recording prefixes under `Angelscript.UnitTest.RuntimeBindings.Recording` are gone. Production has no Apply Installation. `GetBindingInstallation()` may remain as a null-returning compatibility accessor until its last caller is removed in this node.

**Interfaces**

Consumes:

```cpp
TUniquePtr<FAngelscriptEngine> CreateForBindings(TSharedRef<const FAngelscriptTypeBindInfoStore>, FAngelscriptBindingDiagnostic&); // AngelscriptEngine.h:453
class FAngelscriptTypeBindInfoApply;
class FAngelscriptTypeBindInfoRecorder;
class FAngelscriptTypeBindInfoStore;
```

Produces:

```text
// those production entry points removed; leftover helpers only if a Host Blueprint write still calls them
```

**Cases**

1. **NoArgCreateForBindingsHasNoInstallation** — new RED
   Given no-arg `CreateForBindings(Diagnostic)` after Store removal, When it returns an owner, Then `GetBindingInstallation()` is null and `GetTypeInfoByName("FString")` is the process host pointer.
2. **RecordingPrefixesAbsent** — new RED · absence
   Must not exist: `Angelscript.UnitTest.RuntimeBindings.Recording` discovered tests. Oracle: a `ue.test` discovery of that prefix returns 0 tests.
3. **HostSchemeInjectOnlyStillGreen** — existing control
   Given `HostScheme.BindScriptTypesInjectsWithoutReplay`, When rerun, Then Installation is still null and replay count is still 0.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingStoreTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingFacadeTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingProvidersTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingValidationTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingOwnershipTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingManifestTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingDefinitionCatalogTests.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoRecorder.h
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.h
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoValidation.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoValidation.h
```

Do not delete `AngelscriptTypeBindInfoReflection.*` or inspection helpers if Host Blueprint writes still include them after the Store entries are gone.

**Verification**

Selected workspace. Build after C++ edits. Completion: HostScheme and HostPerf prefixes green; Recording prefix discovers 0 tests.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.Host'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.4 Host prefixes failed after Store retirement' }
$recording = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording'; Fast = $true; TimeoutMs = 600000 }
if ($recording.exitCode -eq 0 -and [int]$recording.data.Discovered -gt 0) { throw '4.4 Recording tests still discovered' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Shared Host prefix Unreal `7d402a23081c410d96ef456210d713f2` Outcome Passed, 55/55 including NoArgCreateForBindingsHasNoInstallation and HostScheme.BindScriptTypesInjectsWithoutReplay. Recording prefix Unreal `d95ba51d0ccb4ce6ad7e9bd8e3a72087` discovered 0. `CreateForBindings(Store)` and Apply/Recorder/Validation/Draft/Catalog entry points are gone. Naming assumed: leftover `FAngelscriptTypeBindInfoStore` plus Inspection/Reflection remain because Binds recording and Dump still call them; `GetBindingInstallation()` stays as a null accessor. Omitted cache, Quick, Integration, NativeEngine TypeOwnership: not this node's GREEN.

## 5. Specifications

## [x] 5.1 Sync durable deltas into current specs

Merge the Change deltas for `angelscript/bindings/runtime` and `angelscript/runtime/binding-engine`. Repair only the formatting failures this merge is authorized to touch. Update INDEX. This node does not edit product C++.

**Outcome**

Current specs contain the inject-only, seven-phase, Collection-inspection, and Store-removal behavior. Store validation/snapshot requirements are gone. Strict validation of this Change and the two capabilities passes.

**Files**

```diff
 openspec/specs/angelscript/bindings/runtime/spec.md
 openspec/specs/angelscript/runtime/binding-engine/spec.md
 openspec/changes/angelscript/refactor-bindings-host-full-inject/attachments/INDEX.md
```

**Verification**

Selected workspace. No UE build. Completion: both capability validations and this Change `--strict` report no issues.

```powershell
$runtime = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/bindings/runtime', '--type', 'spec', '--strict', '--json')
$engine = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/runtime/binding-engine', '--type', 'spec', '--strict', '--json')
$change = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-bindings-host-full-inject', '--strict', '--json')
if ($runtime.exitCode -ne 0 -or $engine.exitCode -ne 0 -or $change.exitCode -ne 0) { throw '5.1 spec or change validation failed' }
```

**Evidence**

2026-09-16 workspace `d:\Workspace\AngelscriptProject`. Merged Change deltas into current `angelscript/bindings/runtime` and `angelscript/runtime/binding-engine`. Removed Store validation/snapshot requirements. Strict `openspec.validate` Succeeded for `angelscript/bindings/runtime`, `angelscript/runtime/binding-engine`, and `angelscript/refactor-bindings-host-full-inject`. No product C++ in this node.
