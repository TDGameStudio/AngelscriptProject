---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.2"]
    "1.4": ["1.3"]
    "1.5": ["1.4"]
    "2.1": ["1.5"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "2.4": ["2.3"]
    "3.1": ["2.4"]
    "3.2": ["3.1"]
    "4.1": ["3.2"]
    "4.2": ["4.1"]
    "4.3": ["4.2"]
    "4.4": ["4.3"]
    "4.5": ["4.4"]
    "4.6": ["4.5"]
    "5.1": ["4.6"]
    "5.2": ["5.1"]
    "6.1": ["5.2"]
    "6.2": ["6.1"]
---

# Share process-owned host definitions and restore engine-local registration

## Goal

Deliver shared immutable host definitions with exact Engine admission, usable live registration and complete production binding integration.

## Architecture

Collection callbacks create the frozen HostProcess graph once; InjectDefinitions retains and indexes it in receiving Engines. Script registration transfers only private definitions and live registration creates local objects, while Context/native leases enforce execution ownership. See [design.md](design.md).

## Global constraints

- Creation is planning-only, approved Q67 on 2026-09-16; all product nodes remain unchecked until later authorized execution.
- Preserve unrelated parent/submodule edits; product code belongs to Plugins/Angelscript, not host Source/AngelscriptProject.
- Read the indexed accepted handoff and glossary; the predecessor's descriptive/per-Engine materialization architecture is superseded.
- No legacy startup/backend switch, MetadataImage, removed RegisterFuncdef, disk cache, published-collection hot replacement, whole-directory reorganization or manifest v2.
- New C++ files stay in replacement NativeEngine/Bindings roots under WITH_ANGELSCRIPT_TESTS. NativeEngine identities compose layer, class and method. No NewVersion or legacy unit-test gate.
- Each behavior card creates the literal CQTest selector declared below; its numbered Cases become visible TEST_METHOD cases with direct assertions and independent input/output oracles. Missing or zero discovery fails. Fixture adaptations must be inside that selector or its explicitly listed shared run.
- Command setup is the selected workspace root in PowerShell 7: import ./.agents/skills/harness/scripts/Harness.psd1 and set context with New-HarnessContext -WorkspaceRoot (Get-Location).Path. Each UE test proof requires a matching Harness ue.build after owned source changes; record source/binary identity and case outcomes. Commands below are actual execution commands, not PlanOnly passes.
- SDK paths in Interfaces are relative to Plugins/Angelscript/Source/AngelscriptRuntime. Future symbols are identified by producer task; no future interface is treated as already present.
- Registration inventory rows are a historical seed, not current eligibility proof. Task 3.1 refreshes it; family tasks own per-site/member dispositions and include only their inventory sites and companion files.
- Files globs are bounded by the card outcome and never authorize unrelated edits. Dependent cards sharing SDK/Core files run serially; no implicit parallel writers or UE workers.
- Current unrelated spec formatting failures are recorded in planning-validation and assigned only to 6.2. Existing dormant tests and old failed runs are provenance, never replacement proof.
- Execution conventions: .agents/skills/harness/references/execution-conventions.md.

## Requirement coverage

| Requirement / acceptance condition | Tasks |
|---|---|
| Approved definition/API vocabulary and maintained build | 1.1 |
| HostProcess construction, graph leases, native facts and process IDs | 1.2 |
| Atomic shared injection, repeat injection and conflicts | 1.3, 2.1 |
| Private script transfer, mixed closure and bytecode ownership | 1.4 |
| Host Context admission, native leases, overrides, delegates and local state | 1.5 |
| Live object/member registration, layout, host protection and local ownership | 2.1 |
| Live global function/property execution and storage isolation | 2.2 |
| Live interfaces, enums/values, aliases and namespace queries | 2.3 |
| String factories and default-array service registration | 2.4 |
| Engine-free direct Collection, callbacks, provenance, extensions and inspection | 3.1 |
| Host-closed/private template specialization and actual member execution | 3.2, 4.3 |
| Complete eligible Core/Math/Containers/Objects/Gameplay/Services coverage | 4.1, 4.2, 4.3, 4.4, 4.5, 4.6 |
| Blueprint class write concurrency, inheritance, knobs and deterministic failure | 5.1 |
| Production entry, no bypass, full accounting and dormant startup | 5.2 |
| All acceptance cases on the final source/binary and both isolation families | 6.1 |
| Seven-capability semantic sync, bounded baseline format repair and evidence | 6.2 |

Self-review 2026-09-16: coverage complete; placeholders absent; symbols aligned with accepted vocabulary and inspected conventions. Record: attachments/data/planning-validation.md.

## [x] 1.1 Align definition vocabulary across maintained consumers

Apply the Q66 name mapping without changing stable-key, fingerprint, script transfer or bytecode semantics. Exclude Legacy, UMETA, list-pattern/fingerprint families and unrelated comments. Update maintained include users atomically so the repository remains buildable.

**Outcome**

Apply the Q66 name mapping without changing stable-key, fingerprint, script transfer or bytecode semantics. Exclude Legacy, UMETA, list-pattern/fingerprint families and unrelated comments. Update maintained include users atomically so the repository remains buildable.

**Files**

```diff
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.h
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_module_definition_set.cpp
-Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_metadata.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.h
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/**
 Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/**
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/**
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
if ($result.exitCode -ne 0) { throw '1.1 maintained vocabulary build failed' }
```

A successful maintained Editor build proves all renamed include/API consumers compile. Record the touched-symbol scan and binary identity; this does not prove the later behavior nodes.

**Notes**

Modification globs permit only inspected maintained references to the approved renamed symbols/files, including Builder/session helpers. Preserve all unrelated edits. Build proof is justified by shared SDK headers and cross-module include changes; no fabricated behavioral RED is required for this vocabulary-only slice.

**Evidence**

Command: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }`. Result: Succeeded, exit 0, run `8c5996d87fce48f09e8b32c47d3317de`, duration 176172 ms. Output binary: `C:\Program Files\Epic Games\UE_5.8\Engine\Binaries\Win64\UnrealEditor.exe`. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `5FE11CCB5DF564FDE0A3A1E2D9D1DB783A6C8543FED1D2C03E3582BA0A17937C`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `8BCC644AFF7C080C01A62A49256B3DB65FF67D4B9352F034F530BDC01CAFBA12`. Files moved: `as_module_definition_set.h/cpp` → `as_definitions.h/cpp`, `as_scriptengine_metadata.cpp` → `as_scriptengine_registration.cpp`. Touched-symbol scan after rename: no remaining `asCModuleDefinitionSet`, `asEMetadataResult`, `asEMetadataRegistrationResult`, `InstallDefinitionSet`, `FindMetadataType`, `FindMetadataFunction`, `GetMetadataDeclarationKind`, `GetDefinitionSet`, `metadataOwner`, or `metadataStableKey` in maintained Runtime/NativeEngine/Bindings sources. `as_metadata_fingerprint.h` forward declaration updated to `asCDefinitions`; list-pattern/fingerprint type families, Legacy, UMETA, and the archived consumer-ledger string `as_scriptengine_metadata.cpp` were left unchanged. Omitted: Automation and heavier suites; this node is vocabulary/build only.

## [x] 1.2 Create and retain a process-owned host definition graph

Construct HostProcess type/function objects without an Engine; freeze their layouts, native interfaces and process IDs once, with atomic external lifetime retention and no internal reference cycles.

**Outcome**

Construct HostProcess type/function objects without an Engine; freeze their layouts, native interfaces and process IDs once, with atomic external lifetime retention and no internal reference cycles.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
asCDefinitions::Create(const asSDefinitionOptions&); // task 1.1 rename of as_module_definition_set.h:115
asCDefinitions::CreateObjectType(Key, Name, Namespace, Flags, Out); // original header:146
asCTypeInfo::GetTypeId() const; // as_typeinfo.cpp:263
asCTypeInfo::GetEngine() const; // as_typeinfo.cpp:282
```

Produces:

```cpp
enum class asETypeInfoKind { HostProcess, ScriptEngine, LiveRegister }; // approved glossary Q33
// typeInfoKind on asCTypeInfo and asCScriptFunction; immutable HostProcess IDs and graph leases
TEST_CLASS_WITH_FLAGS(HostGraph, "Angelscript.UnitTest.NativeEngine.Definitions", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostGraph class, HostGraphTests.cpp file and Angelscript.UnitTest.NativeEngine.Definitions.HostGraph selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Frozen shared identity** — new RED
   Given native Pair { int X; int Y; } and Sum returning X+Y, when constructed and frozen without an Engine, then its HostProcess type/function have null GetEngine and valid fixed process IDs; Pair{20,22}.Sum has an immutable callable target. StableKey matches the supplied key, not a new per-Engine key.

2. **Retained recursive graph** — new RED
   Given mutually referring handle types and one retained method, when the producer owner is released, then method/type queries remain valid; releasing the final lease destroys each owned type, function and namespace exactly once using explicit destructor counters.

3. **Invalid freeze** — boundary
   Given a by-value self-cycle, incomplete layout or exhausted dynamic ID range, when publication is attempted, then it fails without a published graph, without reusing issued IDs and without changing earlier live publications.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_typeinfo.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_type_id_registry.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Definitions/HostGraphTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Definitions.HostGraph.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.2 HostGraph proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Definitions.HostGraph with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

RED (build `dd10373bf711416784fcb4965d882688`, test `22b19b5e7747487c8f33e7dee67d102a`): 3/3 discovered, 0 succeeded. FrozenSharedIdentity failed at HostGraphTests.cpp:99 because `BindNativeFunction` returned `InvalidState` and Pair/Sum never froze with a callable target. RetainedRecursiveGraph failed at :143 because `GetTypeInfoKind()` stayed `ScriptEngine`. InvalidFreezeDoesNotPublish failed at :197 because the live HostProcess Pair could not be built without a real bind. GREEN build `4d434b14c9374527b240f2b762121c9c` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Definitions.HostGraph.'; Fast = $true; TimeoutMs = 600000 }` run `579813c6b3084810843348aa5e31b62f`, Succeeded, exit 0, duration 27349 ms. Cases: FrozenSharedIdentity, RetainedRecursiveGraph, InvalidFreezeDoesNotPublish all Success under `Angelscript.UnitTest.NativeEngine.Definitions.HostGraph`, including Pair{20,22}.Sum native call to 42. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `0FB8655EEC2E3FC93C8B3F73DA56DD72C252B0EFF779A7839B3B315E26BC93F5`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `BE9E38E59DA948636831D49036D89A62AEB48F2D432FE259BA7480AED342DEBD`. Naming assumed: `asCDefinitionGraphLease` — copyable `TSharedPtr` owner after `AdoptGraph`; `AdoptGraph`/`RetainGraph`/`SetDestroyCounters`/`asSDefinitionDestroyCounters` — external lifetime and exact destructor counts; `asCDefinitions::BindNativeFunction` — freeze-time host native interface; `typeInfoKind`/`GetTypeInfoKind`/`processInterface` already declared on type/function. Omitted: adjacent DefinitionSet suite and heavier profiles; this node is HostGraph-only.

## [x] 1.3 Inject frozen host graphs atomically into multiple Engines

Expose InjectDefinitions and admit the exact frozen HostProcess pointers into each Engine directory with lifetime retention and rollback; removing one consumer never retires the shared graph.

**Outcome**

Expose InjectDefinitions and admit the exact frozen HostProcess pointers into each Engine directory with lifetime retention and rollback; removing one consumer never retires the shared graph.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
asCDefinitions and HostProcess graph leases; // task 1.2
asCScriptEngine::InstallDefinitionSet(...); // renamed RegisterExternalDefinitions by 1.1; original as_scriptengine_metadata.cpp:35
```

Produces:

```cpp
asERegistrationResult asCScriptEngine::InjectDefinitions(const asCDefinitions&); // glossary Q61
// Engine-local admitted host graphs and transactional name/key/ID indexes
TEST_CLASS_WITH_FLAGS(HostInjection, "Angelscript.UnitTest.NativeEngine.Registration", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostInjection class, HostInjectionTests.cpp file and Angelscript.UnitTest.NativeEngine.Registration.HostInjection selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Two receiving directories** — new RED
   Given one frozen Pair/Sum graph, when A and B inject it, then both name/key/ID lookups return identical type/function pointers and IDs with null GetEngine.

2. **Conflict leaves prior state** — new RED
   Given A already admitting Pair and B successfully using the source graph, when A injects a different Pair name/key collision or an unfrozen/mixed-kind root, then injection fails and every original A/B entry and shared ID remains unchanged.

3. **Detach and retry** — boundary
   Given injected A/B and an external producer reference, when that reference and A are released, then B still resolves Pair; repeated injection of the identical bag into B returns AlreadyRegistered without duplicate references or entries; last B release cleans up once.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/HostInjectionTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.HostInjection.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.3 HostInjection proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Registration.HostInjection with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

RED (build `5bdfecb9fa26469c91406e4fe60c1e07`, test `b0d4ec964c494d4cb1ef67b459a2c472`): 3/3 discovered, 0 succeeded. TwoReceivingDirectories :125, ConflictLeavesPriorState :154 and DetachAndRetry :203 failed because `InjectDefinitions` returned `InvalidState`. GREEN build `f16f856c399c467096cf4cdd70335935` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.HostInjection.'; Fast = $true; TimeoutMs = 600000 }` run `b6bff7591e534481896259292e0865d3`, Succeeded, exit 0, duration 26845 ms. Cases: TwoReceivingDirectories, ConflictLeavesPriorState, DetachAndRetry all Success, including Pair{20,22}.Sum native call to 42 and last-consumer destroy-once. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `FEB546430407F779D9E1EFA7F577ABEE0D8E09361EB04AF9D7DC1272C0B8E216`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `A579065ECE6C62D82549004D594B7E08F7C8EAA18016EFE77CD932E44D036026`. Naming assumed: `admittedHostGraphs` — Engine-local HostProcess lease table used by `InjectDefinitions`. Omitted: EngineRegistration suite and heavier profiles; this node is HostInjection-only.

## [x] 1.4 Register private scripts against admitted shared dependencies

Keep script unique-transfer semantics while registering and retiring mixed closures without changing HostProcess engine, IDs or Frozen state.

**Outcome**

Keep script unique-transfer semantics while registering and retiring mixed closures without changing HostProcess engine, IDs or Frozen state.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
asERegistrationResult asCScriptEngine::RegisterExternalDefinitions(...); // task 1.1, prior InstallDefinitionSet
asCScriptEngine::InjectDefinitions(const asCDefinitions&); // task 1.3
asCEngineCompileRegistration; // existing script Registration owner
```

Produces:

```cpp
// RegisterExternalDefinitions/RetireExternalDefinitions preserve shared dependency leases and only transfer private ScriptEngine definitions.
TEST_CLASS_WITH_FLAGS(HostScriptRegistration, "Angelscript.UnitTest.NativeEngine.Registration", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostScriptRegistration class, HostScriptRegistrationTests.cpp file and Angelscript.UnitTest.NativeEngine.Registration.HostScriptRegistration selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Mixed closure** — new RED
   Given frozen host Pair and source class Box containing Pair, when compilation freezes Box and A registers it after injecting Pair, then Box belongs to A while Pair remains the shared null-Engine object also visible to B.

2. **Missing dependency** — new RED
   Given private script functions referencing Pair, when uninjected C registers that batch, then the batch fails atomically with no callable functions or partial private types; injecting Pair permits a newly submitted valid batch.

3. **Private owner and retirement** — existing control
   Given one successfully registered private Box batch, when another Engine attempts its ownership or A retires it, then foreign ownership is rejected and retirement removes only A's private graph; B's Pair stays frozen and usable.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine_registration.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/**
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_engine_compile_registration.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/HostScriptRegistrationTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.HostScriptRegistration.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.4 HostScriptRegistration proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Registration.HostScriptRegistration with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

RED (build `669938d5d0634ed380cbd37fe9d78bbb`, test `273944999db24d67ba0274b073f557e0`): 3/3 discovered, 0 succeeded. MixedClosure :135 and PrivateOwnerAndRetirement :193 failed because `RegisterExternalDefinitions` rejected an admitted HostProcess dependency. MissingDependency :170 failed after a later inject because the newly submitted Box batch still could not adopt that host graph. GREEN build `49771653550a49e7bd0f34257d129bab` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.HostScriptRegistration.'; Fast = $true; TimeoutMs = 600000 }` run `26f52a8ed5d24e1a9a28d73f1e4f7d8f`, Succeeded, exit 0, duration 26631 ms. Cases: MixedClosure, MissingDependency, PrivateOwnerAndRetirement all Success; Box is Engine-private while Pair stays a shared null-Engine object; Pair{20,22}.Sum still returns 42. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `EA26FEED6FEBEA4E23635D7359BD82737DEC623E4605591EE5C2C65A80D86218`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `E975BF08F443412E39A97F5EB283D573D006EC3C7BA6A33FF56F970BADB9C67F`. Omitted: EngineRegistration and HostInjection reruns; this node is HostScriptRegistration-only.

**Notes**

Frontend globs are limited to existing definition dependency/session and EngineCompileRegistration consumers. Preserve the existing single public Install+Link transaction and failed-batch no-callability.

## [x] 1.5 Execute admitted shared host functions with exact local state

Admit HostProcess functions from Context only after exact receiving-engine membership and obtain immutable native interfaces with a live graph lease, while retaining local override and auxiliary ownership.

**Outcome**

Admit HostProcess functions from Context only after exact receiving-engine membership and obtain immutable native interfaces with a live graph lease, while retaining local override and auxiliary ownership.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
int asCContext::Prepare(asIScriptFunction*); // as_context.cpp:665 owner check
std::shared_ptr<asSSystemFunctionInterface> asCScriptEngine::AcquireSystemInterface(asCScriptFunction*) const; // as_bytecode_linker.cpp:1053
asCScriptFunction* CreateDelegate(asCScriptFunction*, void*); // as_scriptfunction.cpp:174
```

Produces:

```cpp
// Host admission and process-interface fallback through existing Context/native-call APIs; no additional public product name.
TEST_CLASS_WITH_FLAGS(HostCalls, "Angelscript.UnitTest.NativeEngine.VM", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostCalls class, HostCallsTests.cpp file and Angelscript.UnitTest.NativeEngine.VM.HostCalls selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Admitted execution** — new RED
   Given injected A/B and uninjected C with one Add(20,22) host function, when each Context prepares it, then A/B execute to 42 and C returns asINVALID_ARG without invoking the callback.

2. **Local override and reentry** — new RED
   Given the same function with A auxiliary result 42 and B result 99, when A enters B and returns then A resumes its original owner/auxiliary, B returns 99, and replacing A's target during its active call does not release the captured generation early.

3. **Retire and reachable delegates** — boundary
   Given an active shared native call and a supported delegate to an admitted host method, when A retires during a callback and external graph owners drop, then cleanup completes without null Function.GetEngine dereference and B remains callable; foreign ScriptEngine/LiveRegister functions are still rejected.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptobject.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/VM/HostCallsTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM.HostCalls.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.5 HostCalls proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.VM.HostCalls with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Audit additional GetEngine consumers reached by these cases, including allocation, cleanup and JIT diagnostics. Every newly changed path must be in the task Files/evidence; if another owner file is needed, extend the bounded path list through the accepted update route. Retain source-shaped copies of the owner/auxiliary controls from RuntimeBindingIsolationTests.cpp.

**Evidence**

RED (build `ca17c5231b8448bb8c34bf61fef41467`, test `cff499259a524d748b6b94d920032234`): 3/3 discovered, 0 succeeded. AdmittedExecution :207, LocalOverrideAndReentry :240 and RetireAndReachableDelegates :274 failed because `Prepare` returned `asINVALID_ARG` (-5) for admitted HostProcess functions (`m_engine != func->GetEngine()`). GREEN build `920063794ae94720b381ceb86defe720` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM.HostCalls.'; Fast = $true; TimeoutMs = 600000 }` run `edfc7e0255f04c1d8b8a5d6b6a5c758e`, Succeeded, exit 0, duration 25805 ms. Cases: AdmittedExecution, LocalOverrideAndReentry, RetireAndReachableDelegates all Success; A/B Add(20,22)=42, uninjected C stays `asINVALID_ARG` without the callback, A/B auxiliaries 42/99 with nested reentry and mid-call rebind to 7, host `CreateDelegate`/`GetEngine` survive retire, B remains callable, foreign ScriptEngine `Prepare` is `asINVALID_ARG`. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `B9F6CAD4FDE6D2B4B64D26A84B6FC7879AD5130BAFCE774ABF2AC008B34E83C4`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `3A099E1DF9A50C9FC293532B5D6FEA631DED11579F0AA5B852689E636BE3D835`. Omitted: adjacent VM suite and heavier profiles; this node is HostCalls-only.

## [x] 2.1 Restore Engine-owned object registration and native members

Implement the existing object type/property/behaviour/method registration signatures on the maintained SDK and preserve HostProcess immutability and per-Engine object ownership.

**Outcome**

Implement the existing object type/property/behaviour/method registration signatures on the maintained SDK and preserve HostProcess immutability and per-Engine object ownership.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
RegisterObjectType / RegisterObjectProperty / RegisterObjectBehaviour / RegisterObjectMethod; // existing as_scriptengine.h:223-226
asCScriptEngine::InjectDefinitions(const asCDefinitions&); // task 1.3
```

Produces:

```cpp
// Maintained live implementations of existing signatures, returning Engine-owned LiveRegister definitions.
TEST_CLASS_WITH_FLAGS(LiveObjects, "Angelscript.UnitTest.NativeEngine.Registration", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future LiveObjects class, LiveObjectsTests.cpp file and Angelscript.UnitTest.NativeEngine.Registration.LiveObjects selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Native Pair registration** — new RED
   Given a fresh Engine and C++ Pair{20,22}, when type, sizeof/alignment facts, X/Y offsets, constructors/destructor and Sum are registered, then lookups expose those fields and a real Context/native member call returns 42; destructor counter is exactly one.

2. **Host protection and reverse conflict** — new RED
   Given injected host Pair, when RegisterObjectType repeats Pair or RegisterObjectMethod/Property/Behaviour targets that shared type, then each fails and B's graph is unchanged; if a private Pair was registered first, colliding host injection fails without replacing it.

3. **Two private owners and invalid layout** — boundary
   Given A/B independently registering Pair, then their pointers and IDs are independently owned and GetEngine identifies the receiver; an out-of-bounds field or invalid method declaration leaves field/method counts unchanged and A cannot execute B's function.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_typeinfo.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptfunction.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/LiveObjectsTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveObjects.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.1 LiveObjects proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Registration.LiveObjects with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

First LiveObjects run after restoring RegisterObject* (build `0042755f984949f789cba07a7cd5ed47`, test `34b9bc9c1ea24faf99baa721db69b6c5`): 3/3 discovered, NativePairRegistration and TwoPrivateOwners Success; HostProtectionAndReverseConflict failed at :230 because injected host Sum used `asCALL_CDECL_OBJFIRST` without a FunctionCaller on the Context path. GREEN build `eeb393c1fd1748be91737e0a00b0249b` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveObjects.'; Fast = $true; TimeoutMs = 600000 }` run `3afa3fc421854b4397b1372ee58b7f0c`, Succeeded, exit 0, duration 28204 ms. Cases: NativePairRegistration, HostProtectionAndReverseConflict, TwoPrivateOwnersAndInvalidLayout all Success; live Pair construct/Sum/destruct returns 42 with destructor count 1, host Pair is immutable and reverse inject fails, A/B own distinct LiveRegister pointers/IDs. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `DE94129431582305FB594DAB84EFFE284315495054B32F4B35979CAD099DC7DB`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `074B69E238B1BC9018734138D9E38AC6F251FE89D85F51B579E389D4DCB3EAF7`. Naming assumed: `liveDefinitions` — Engine-owned LiveRegister graph for incremental SDK Register*; `EnsureLiveDefinitions` / `MakeLiveStableKey` / `PublishLiveType` / `PublishLiveFunction` / `RegisterLiveCallable` — private Engine helpers. Omitted: EngineRegistration full prefix and heavier profiles; one dormant `RegisterObjectType` characterization in EngineRegistrationTests was updated because the API is live again.

## [x] 2.2 Restore live global functions and storage

Register callable global functions and addressed native storage per Engine, with compatible generic/typed transport and no shared-host overwrite.

**Outcome**

Register callable global functions and addressed native storage per Engine, with compatible generic/typed transport and no shared-host overwrite.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
RegisterGlobalFunction(const char*, const asSFuncPtr&, asDWORD, asFunctionCaller, void*); // as_scriptengine.h:210
RegisterGlobalProperty(const char*, void*); // as_scriptengine.h:217
AcquireSystemInterface(asCScriptFunction*) const; // task 1.5
```

Produces:

```cpp
// Existing global registration signatures acquire maintained LiveRegister implementations.
TEST_CLASS_WITH_FLAGS(LiveGlobals, "Angelscript.UnitTest.NativeEngine.VM", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future LiveGlobals class, LiveGlobalsTests.cpp file and Angelscript.UnitTest.NativeEngine.VM.LiveGlobals selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Global call and storage** — new RED
   Given Add(int,int) and native int Counter=7, when A registers both, then Add(20,22) executes to 42 and bound access writes Counter=9 in the original native storage.

2. **Per-owner globals** — new RED
   Given A/B each registering the same global name with auxiliary results 42/99 and different Counter addresses, then their calls and writes stay isolated; destroying A neither releases B's auxiliary nor changes its Counter.

3. **Invalid and conflicting globals** — boundary
   Given a missing signature type, incompatible call target or duplicate host global, when registration fails, then counts and earlier callable results remain unchanged; generic and typed caller forms produce the same literal addition result.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_bytecode_linker.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_property.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_context.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/VM/LiveGlobalsTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM.LiveGlobals.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.2 LiveGlobals proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.VM.LiveGlobals with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

GREEN build `ec17087afd5d47bd892633c7b14ca6fe` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.VM.LiveGlobals.'; Fast = $true; TimeoutMs = 600000 }` run `5d75bd22f31843fc89b6963619174f6e`, Succeeded, exit 0, duration 30820 ms. Cases: GlobalCallAndStorage, PerOwnerGlobals, InvalidAndConflictingGlobals all Success under `Angelscript.UnitTest.NativeEngine.VM.LiveGlobals`; Add(20,22)=42, Counter writes the original native storage, A/B auxiliaries 42/99 stay isolated after A.Reset(), missing type / CDECL-without-caller / host Counter name conflict leave counts unchanged, generic and typed callers both return 42. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `08B43226E3EB32B730D057DEAE6C4E3AB256B2544C0BA4E01559A812F3EC9247`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `32D2C83ED36F7775B30616F36B8A6E7DF7500F03E1E99F06A0630D8903C41A59`. Naming assumed: none beyond existing RegisterGlobalFunction / RegisterGlobalProperty. Omitted: EngineRegistration full prefix and heavier profiles; ValidateGlobalIdentity already allowed native globals without IdentityContext so host Counter inject can freeze.

## [x] 2.3 Restore live interfaces enums and aliases

Restore current public nominal registration families with Engine-local identity, namespace-aware lookup and conflict containment; do not restore removed funcdef APIs.

**Outcome**

Restore current public nominal registration families with Engine-local identity, namespace-aware lookup and conflict containment; do not restore removed funcdef APIs.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
RegisterInterface / RegisterInterfaceMethod / RegisterTypedef / RegisterEnum / RegisterEnumValue; // as_scriptengine.h:228-251
```

Produces:

```cpp
// Maintained implementations of the inspected nominal registration signatures.
TEST_CLASS_WITH_FLAGS(LiveNominal, "Angelscript.UnitTest.NativeEngine.Registration", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future LiveNominal class, LiveNominalTests.cpp file and Angelscript.UnitTest.NativeEngine.Registration.LiveNominal selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Nominal registration queries** — new RED
   Given interface IValue with int Value(), enum Color with Red=3, and alias Count for int, when registered in A, then queries expose the signature, Red=3 and Count's primitive type semantics.

2. **Namespaces and conflicts** — new RED
   Given namespace N and global types with different names, when registering N::Color and its values, then qualified lookup resolves the intended declaration; a duplicate or HostProcess-owned target rejects without modifying any old declaration.

3. **Private nominal lifetimes** — boundary
   Given A/B independently registering Color and IValue, when A is destroyed then B's types and value queries remain valid; unresolved alias/interface signature types fail before publication.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_typeinfo.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_datatype.*
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/LiveNominalTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveNominal.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.3 LiveNominal proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Registration.LiveNominal with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Evidence**

GREEN build `5082c88b10b74721bf52c8e94c2bf078` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveNominal.'; Fast = $true; TimeoutMs = 600000 }` run `9455e68af2c344d4854ec119787eebaf`, Succeeded, exit 0, duration 27707 ms. Cases: NominalRegistrationQueries, NamespacesAndConflicts, PrivateNominalLifetimes all Success under `Angelscript.UnitTest.NativeEngine.Registration.LiveNominal`; IValue.Value() returns int32, Color.Red=3, Count aliases int, N::Color is distinct from global Palette, host Color rejects live overwrite, A/B own distinct LiveRegister enums/interfaces and B survives A.Reset(). Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `6163430EB2BE4563DCD818D2FDC71F4C19AA5637A07889C4CF85305A82C2C68A`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `6D5BD816DDF370FADF0D3EC4FF00B21CF82FCB91A2C1EA33129588322C837775`. Naming assumed: none beyond existing RegisterInterface / RegisterEnum / RegisterTypedef families. Omitted: EngineRegistration full prefix; one dormant RegisterEnum characterization was updated because the API is live again. SetDefaultNamespace("") now resets to the empty namespace.

## [x] 2.4 Restore per-Engine string and default-array services

Restore existing string-factory and default-array registration against admitted definitions, keeping service ownership and validation per Engine.

**Outcome**

Restore existing string-factory and default-array registration against admitted definitions, keeping service ownership and validation per Engine.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
RegisterStringFactory(const char*, asIStringFactory*); // as_scriptengine.h:234
RegisterDefaultArrayType(const char*); // as_scriptengine.h:238
GetStringFactoryReturnTypeId / GetDefaultArrayTypeId; // adjacent existing declarations
```

Produces:

```cpp
// Existing service registration/query APIs resolve maintained admitted definitions and local service state.
TEST_CLASS_WITH_FLAGS(LiveServices, "Angelscript.UnitTest.NativeEngine.Registration", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future LiveServices class, LiveServicesTests.cpp file and Angelscript.UnitTest.NativeEngine.Registration.LiveServices selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **String factory round trip** — new RED
   Given a counted string factory for an admitted String type, when A registers it and consumes literal abc through the maintained compile/execution path, then the returned bytes are abc and acquired constants are released exactly once under the established factory ownership contract.

2. **Default array selection** — new RED
   Given admitted compatible array template types in A/B, when A chooses its default array then its int[] declaration resolves through that choice without changing B's default; invalid or unknown template selection leaves A's prior default intact.

3. **Shared definition remains frozen** — boundary
   Given the service's type belongs to a HostProcess graph, when services are configured on A, then only A's service sidecars change and B/shared TypeInfo stay unchanged; retirement rejects new service installation.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine.h
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_string.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/**
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Registration/LiveServicesTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveServices.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.4 LiveServices proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.NativeEngine.Registration.LiveServices with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

The frontend glob is restricted to consumers resolving string constants/default arrays. Preserve asIStringFactory's documented host ownership; do not infer that Engine owns the factory object itself.

**Evidence**

GREEN build `26f9ec77a264430198d55919fc93f6a4` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Registration.LiveServices.'; Fast = $true; TimeoutMs = 600000 }` run `c47beeef2e2a468f9888f5e4977aafb1`, Succeeded, exit 0, duration 26351 ms. Cases: StringFactoryRoundTrip, DefaultArraySelection, SharedDefinitionRemainsFrozen all Success under `Angelscript.UnitTest.NativeEngine.Registration.LiveServices`; admitted String factory acquires/releases literal abc exactly once, A's Array default resolves int[] without changing B, host TypeInfo stays engine-null after A's sidecars, retirement rejects new service installation. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `FCAC2AD1594C6F70A79FB4EB647B83FCDA8E0C9931F984220CA7C3F653EFDC51`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `D8345FDDC6392428A9153118641A9924B24A4894ADB9DE5CD35EF33BC5B1DED0`. Naming assumed: none; Engine still does not own asIStringFactory. Omitted: EngineRegistration full prefix and heavier profiles.

## [x] 3.1 Collect direct host definitions through registered callbacks

Make the existing Collection the owner of directly constructed HostDefs, execute registrations in their accepted phases once, and retain provenance/validation/extension behavior without a reusable descriptor database or declaration replay.

**Outcome**

Make the existing Collection the owner of directly constructed HostDefs, execute registrations in their accepted phases once, and retain provenance/validation/extension behavior without a reusable descriptor database or declaration replay.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
bool FAngelscriptBindCollection::Append(FAngelscriptBindRecord, FString&); // Core/AngelscriptBindsInternal.h:22
bool FAngelscriptBindCollection::Finalize(FString&); // same header:23
bool FAngelscriptBindCollection::Execute(FAngelscriptBinds&, FString&) const; // same header:28
FAngelscriptTypeBindInfoRecorder::Capture(...); // existing Core/AngelscriptTypeBindInfoRecorder.h:14 migration boundary
```

Produces:

```cpp
// FAngelscriptBindCollection owns frozen asCDefinitions; existing FAngelscriptBinds authors directly construct it.
// RegistrationName/RegistrationThreadPolicy/Record.Registrations vocabulary from glossary Q17; OwnerModule defaults UE_MODULE_NAME.
TEST_CLASS_WITH_FLAGS(HostCollection, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostCollection class, RuntimeBindingHostCollectionTests.cpp file and Angelscript.UnitTest.Bindings.HostCollection selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **One callback one graph** — new RED
   Given one Pair primary callback and one later extension adding Sum, when Collection executes and seals then each callback runs once, actual type/function objects already exist without an Engine, and injecting A/B does not rerun either callback.

2. **Ordering and diagnostics** — new RED
   Given an extension before its permitted target phase or a missing native target, when collection attempts publication then it fails with registration/source/declaration/stage details, publishes no usable bag and leaves an unrelated sealed collection unchanged.

3. **Late registration and inspection** — boundary
   Given a sealed collection with N::Counter=7, when its declarations are inspected and mutation is attempted then its stable semantic snapshot remains unchanged and mutation fails; later registrations affect a later capture only. No executable pointer address is emitted as stable inspection data.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBind*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindsInternal.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostCollectionTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostCollection.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.1 HostCollection proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostCollection with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Keep supported author signatures by adapting their construction destination. Old descriptor bridges may exist only during migration and cannot remain the shared delivery product. Refresh the imported registration inventory against actual eligible source sites and retain excluded/no-output dispositions for later family work.

**Evidence**

Compile-fail then GREEN. First `ue.build` `baac34d6d358416e8eac48ec050480f7` failed because `FAngelscriptBindCollection::GetRecords` was dropped while adding host-graph APIs; restoring the existing `TConstArrayView<FAngelscriptBindRecord> GetRecords()` accessor unblocked maintained catalog/recorder/inspection consumers. GREEN build `9ff65aa8d8644130914163636a8dc4f7` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostCollection.'; Fast = $true; TimeoutMs = 600000 }` run `d2da8037a25c488993d0176f3c44cb34`, Succeeded, exit 0, duration 27708 ms. Cases: OneCallbackOneGraph, OrderingAndDiagnostics, LateRegistrationAndInspection all Success under `Angelscript.UnitTest.Bindings.HostCollection`; Pair+Sum callbacks run once, A/B inject the same frozen HostProcess graph without rerunning callbacks, Pair{20,22}.Sum returns 42 through `processInterface`, failed collections publish no bag, sealed N::Counter=7 inspection stores the int value and no `0x` address, late Append fails, and a later collection can still add Pair. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `AC3AC6F27BACB5064BAA7297DA013F6EEF845A91F316FB63D6F591DF34EC4A4E`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `34FFFEBB024575F1D085DBFD8A9E00C839A0E154EA53340CF301706383B90A29`. Naming assumed: `ExecuteToHost` / `GetHostDefinitions` / `RetainHostGraph` / `InspectHostDeclarations` / `FAngelscriptHostDeclarationView` — Collection-owned frozen HostProcess bag and pointer-free inspection. Inventory refresh: `attachments/data/registration-inventory.csv` now 332 rows (254 present bind sites, 78 companion_no_output, 0 missing_or_renamed) with `disposition` and `condition_present`; family/task ownership retained for 4.1-4.6. Omitted: family executable coverage and heavier profiles; this node is Collection host ownership only.

## [x] 3.2 Separate host-closed and private template specialization

Freeze fully host-closed template instances once, with actual callable members, and keep script/live-argument specializations per Engine without dereferencing a moved Draft Set.

**Outcome**

Freeze fully host-closed template instances once, with actual callable members, and keep script/live-argument specializations per Engine without dereferencing a moved Draft Set.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
FAngelscriptTypeBindInfoDraft::MaterializeTemplateDeclaration(...); // Core/AngelscriptTypeBindInfoDraft.cpp:384
Prepared->TakeSet(); // Core/AngelscriptTypeBindInfoApply.cpp:2006,2038
// Collection-owned HostDefs and direct authoring from task 3.1
```

Produces:

```cpp
// Existing container authoring and specialization entry points route by definition origin; no extra public container API.
TEST_CLASS_WITH_FLAGS(HostTemplates, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostTemplates class, RuntimeBindingHostTemplatesTests.cpp file and Angelscript.UnitTest.Bindings.HostTemplates selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Host closed array** — new RED
   Given TArray<int> and TArray<FVector> created from host-only definitions, when A/B invoke Add and Num through real bound methods then they share the corresponding immutable specialized TypeInfo, but their separate object values report 2 and 5 after different mutations.

2. **Private arguments** — new RED
   Given A/B private ScriptThing or live Pair arguments, when each specializes TArray<that type>, then resulting TypeInfo and mutable operations remain local; A cannot accept B's private argument or instance.

3. **Late nested and rollback** — boundary
   Given a moved former Draft and nested host array declarations, when specialization is requested then no null Set is dereferenced; missing argument identity fails with no partial specialization and leaves previous array calls working.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_scriptengine*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostTemplatesTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostTemplates.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.2 HostTemplates proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostTemplates with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Use SDK-owned specialization for identity/member substitution. Host operations-only container tests remain controls; the new class must invoke the bound members via the maintained VM/native call path.

**Evidence**

Compile-fail then GREEN. First `ue.build` `13d8a15acae7494894164199c0f9c506` failed on `ParseHostDataType` overload ambiguity, `CastToObjectType(asITypeInfo*)`, and unity clashes of anonymous `MakeRecord`/`FEngineOwner` with HostCollection. GREEN build `337bb9d18d794b549eafb15fab5a56a0` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostTemplates.'; Fast = $true; TimeoutMs = 600000 }` run `beb166ce506b4ee3b8f528538d6fb28f`, Succeeded, exit 0, duration 27387 ms. Cases: HostClosedArray, PrivateArguments, LateNestedAndRollback all Success under `Angelscript.UnitTest.Bindings.HostTemplates`; A/B share the same HostProcess `TArray<int>`/`TArray<FVector>` TypeInfo while separate arrays report Num 2 and 5 after bound Add; live `TArray<Pair>` specializations stay engine-local and reject a foreign Pair; frozen host graph rejects a late void specialization; `TakeSet` then `MaterializeTemplateDeclaration` does not dereference a null Draft Set; previous `TArray<int>` Add/Num still return 2. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `53811C9A3DF7AF3E9369394D7B8BF922798F3077C32A950EF6967FAD0BBD4ABF`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `C735B77883F113D8F4E7ADC06D0DD26842A466ED2A3A1DD49B3A35B1D4DFB897`. Naming assumed: `asCDefinitions::CreateHostTemplateInstance` / `FindTemplateInstance` and `asCScriptEngine::SpecializeTemplate` — origin-routed host-closed vs private specialization; `FAngelscriptBinds::SpecializeTemplateForTarget` — Collection authoring entry. Omitted: full container-family member surface; 4.3 owns remaining TMap/TSet/TOptional sites.

## [x] 4.1 Migrate FString/FName and namespace globals

Migrate every eligible Core source site to the shared construction path and retain its expected callable surface. FString/FName conversions, value lifecycle and Core native global families. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible Core source site to the shared construction path and retain its expected callable surface. FString/FName conversions, value lifecycle and Core native global families. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated Core registrations; future CQTest HostCore class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostCore, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostCore class, RuntimeBindingHostCoreTests.cpp file and Angelscript.UnitTest.Bindings.HostCore selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Core bound behavior** — new RED
   Given a registered FString constructed from abc, when Len and append(d) execute through bound members then length changes from 3 to 4 and value is abcd; namespace Counter=7 reads as 7.

2. **Complete family accounting** — new RED
   Given the Core inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostCoreTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostCore.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.1 HostCore proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostCore with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to Core inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

Compile-fail then GREEN. First `ue.build` `4777ac067c11449fa52e6a7ed9b8a19a` succeeded; first `ue.test` `ac7320b8bcac4b4ab489a26df81558ef` failed as observed RED: CompleteFamilyAccounting expected 6 executable Core sites rather than 5, and CoreBoundBehavior crashed in `RedirectMethodCaller<FString&>` when Append was invoked with a null return slot. GREEN build `8190400bea2d4d19b15435ded2282957` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostCore.'; Fast = $true; TimeoutMs = 600000 }` run `a08745baf49b4162ad7ba21fd6881079`, Succeeded, exit 0, duration 27796 ms. Cases: CoreBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostCore`; production FString TypeDeclarations/ExplicitBindings construct the HostProcess graph; bound Len reports 3 then Append("d") yields length 4 and value `abcd`; namespace `N::Counter` inspects as 7; 35 Core inventory sites are classified (6 executable / 22 metadata-only / 7 companion); A/B inject without callback rerun; a missing native target fails closed and B still reports Len 3. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `6664F356FF5DABC2EF1C48F2C7A5E8664DD3EFCA7F1972C8C18B32888C50C65D`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `7513CA8EDAF9EB3CA5D0F0C6AB9FEDEB410BDE0D2408BCE410050FD4A2830419`. Naming assumed: host `BindExternBehaviour` / `BindGlobalFunctionForTarget` / `FEnumBind` HostProcess paths — Collection authoring for constructors, globals and enums. Omitted: remaining FString/FName/FText member surfaces and commandlet/UClass globals, which stay engine-replay with recorded reasons.

## [x] 4.2 Migrate vector and transform value providers

Migrate every eligible Math source site to the shared construction path and retain its expected callable surface. Math value types, operators, constructors and conversions. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible Math source site to the shared construction path and retain its expected callable surface. Math value types, operators, constructors and conversions. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated Math registrations; future CQTest HostMath class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostMath, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostMath class, RuntimeBindingHostMathTests.cpp file and Angelscript.UnitTest.Bindings.HostMath selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Math bound behavior** — new RED
   Given FVector(1,2,3) and FVector(4,5,6), when bound addition executes then the result is (5,7,9); zero/default construction and destruction retain their exact value/native lifetime contract.

2. **Complete family accounting** — new RED
   Given the Math inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostMathTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostMath.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.2 HostMath proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostMath with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to Math inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

Observed RED then GREEN. First `ue.test` `05967f578d144e37a971cc13bef2b77f` failed as observed RED: MathBoundBehavior, CompleteFamilyAccounting and OwnerAndFailureBoundaries all failed at `ExecuteToHost` because host `BindProperty` used `AddProperty` without a native address, so `FinalizeLayouts` rejected FVector X/Y/Z on a `SetNativeLayout` type. GREEN build `8afe2a9e6d5f400189bca34221a6d8ca` (15903 ms) then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostMath.'; Fast = $true; TimeoutMs = 600000 }` run `ebbb8a1effe0428bb695df196bf69d10`, Succeeded, exit 0, duration 27452 ms. Cases: MathBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostMath`; production FVector TypeDeclarations/ExplicitBindings construct the HostProcess graph; bound `f()`/`f(x,y,z)`/`opAdd` yield (5,7,9) after zero construction; 118 Math inventory sites are classified (2 executable / 80 metadata-only / 36 companion); A/B inject without callback rerun; a missing native target fails closed and B still reports (5,7,9). Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `F5860FF7D328F30EDB1736671FF3C205A97399835718997BAD26B4B6D0BBA0B2`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `72359F48768DEC47C94142D609977EF6010B7C5AAC4AA2099717DC4ED8E52E4D`. Naming assumed: host `DefineNativeProperty` from `BindProperty` — Collection authoring for native value fields. Omitted: remaining Math operator/conversion surfaces stay engine-replay with recorded reasons.

## [x] 4.3 Migrate array map set and optional providers

Migrate every eligible Containers source site to the shared construction path and retain its expected callable surface. All container registration sites and their lifecycle/property adapters. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible Containers source site to the shared construction path and retain its expected callable surface. All container registration sites and their lifecycle/property adapters. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated Containers registrations; future CQTest HostContainers class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostContainers, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostContainers class, RuntimeBindingHostContainersTests.cpp file and Angelscript.UnitTest.Bindings.HostContainers selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Containers bound behavior** — new RED
   Given bound array values 2 and 5, a map key 3 mapped to 7, a set inserting 9 twice and Optional(11), when the relevant bound operations execute then array count is 2, map lookup is 7, set count is 1 and optional reads 11.

2. **Complete family accounting** — new RED
   Given the Containers inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostContainersTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostContainers.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.3 HostContainers proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostContainers with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to Containers inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

Observed RED then GREEN. First `ue.test` `780ab0328f284ffd9041c2291d92ad5c` / `e7304c7b7d37419790603f5b95528ecf` / `6a8ec15ef4ce4d01bd9dca04de8473d6` failed as observed RED: HostContainers.Members `void Add(int Key, int Value)` returned asINVALID_DECLARATION because forked `FAngelscriptBinds` copies reused `HostIdentitySerial`, colliding HostMap.Add with TArray<int>.Add. GREEN build `91bf8c73f21c4576811ce6640ee82795` (90369 ms) then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostContainers.'; Fast = $true; TimeoutMs = 600000 }` run `161b7b0910b84c0dbab730600c66e9ec`, Succeeded, exit 0, duration 27015 ms. Cases: ContainersBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostContainers`; production TArray/TMap/TSet/TOptional TypeDeclarations plus copied HostMap/HostSet/HostOptional and TArray<int> Add/Num execute on the HostProcess graph; array 2+5 counts 2, map 3->7, set 9 twice counts 1, optional 11; 16 Containers inventory sites are classified (4 executable / 8 metadata-only / 4 companion); A/B inject without callback rerun; a missing native target fails closed and B still reports set count 1. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `D134FB3A5B598705B78E48BA333DD3E80A0BDAF511D38D53C4F966E24FB09F35`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `6EA4D8B5A7738C6AEF4629F1FD05A64EE2AAC7D9D7B2F7B858E33EA3CA8564D2`. Naming assumed: shared `FAngelscriptBindState::HostIdentitySerial` — Collection authoring for host bind keys. Omitted: production MethodSurface/TypeInfrastructure stay engine-replay with recorded reasons.

## [x] 4.4 Migrate object wrappers reflection and adapters

Migrate every eligible ObjectsReflection source site to the shared construction path and retain its expected callable surface. UObject/UClass/UInterface/UStruct/UEnum/delegate and object-wrapper registrations. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible ObjectsReflection source site to the shared construction path and retain its expected callable surface. UObject/UClass/UInterface/UStruct/UEnum/delegate and object-wrapper registrations. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated ObjectsReflection registrations; future CQTest HostObjects class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostObjects, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostObjects class, RuntimeBindingHostObjectsTests.cpp file and Angelscript.UnitTest.Bindings.HostObjects selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Objects bound behavior** — new RED
   Given parent P with field X=7 and child C with field Y=11, when reflected host definitions and required wrappers are collected then C resolves X/Y exactly once, native calls use the receiving Engine's adapter, and weak/object wrapper state remains valid until its documented release.

2. **Complete family accounting** — new RED
   Given the ObjectsReflection inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostObjectsTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostObjects.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.4 HostObjects proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostObjects with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to ObjectsReflection inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

Observed RED then GREEN. First `ue.test` `c1ed9073ee5649d4ab4478e2d9bc342e` failed as observed RED: ObjectsBoundBehavior/OwnerAndFailureBoundaries counted inherited field X twice by walking `derivedFrom` after `FinalizeLayouts` already flattens parent properties onto C. GREEN build `03e5d74261e54193a7ba0422cb98de30` (15346 ms) then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostObjects.'; Fast = $true; TimeoutMs = 600000 }` run `9f00b9d1456642129f7a6e57f230807a`, Succeeded, exit 0, duration 26766 ms. Cases: ObjectsBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostObjects`; copied P(X=7)/C(Y=11) with `SetHostBaseTypeForTarget` resolve X and Y exactly once on C; native values remain 7/11; 49 ObjectsReflection inventory sites are classified (0 executable / 40 metadata-only / 9 companion); A/B inject without callback rerun; a missing native target fails closed and B still resolves Y once. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `D134FB3A5B598705B78E48BA333DD3E80A0BDAF511D38D53C4F966E24FB09F35`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `6F097589BE64E04F528544483EBED7AB0058E0636FE387DF5C31C77BCE04D12B`. Naming assumed: host `SetHostBaseTypeForTarget` — Collection authoring for parent/child. Omitted: production UObject/UClass/delegate wrappers stay engine-replay with recorded reasons.

## [x] 4.5 Migrate gameplay collision and input registrations

Migrate every eligible EngineGameplay source site to the shared construction path and retain its expected callable surface. Gameplay/collision/input source families from the inventory. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible EngineGameplay source site to the shared construction path and retain its expected callable surface. Gameplay/collision/input source families from the inventory. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated EngineGameplay registrations; future CQTest HostGameplay class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostGameplay, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostGameplay class, RuntimeBindingHostGameplayTests.cpp file and Angelscript.UnitTest.Bindings.HostGameplay selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Gameplay bound behavior** — new RED
   Given a transient world with an actor at (1,2,3), when its bound location query executes then it returns (1,2,3); a controlled empty-world trace returns no hit with initialized out values, and input delegate teardown releases the exact subscription once.

2. **Complete family accounting** — new RED
   Given the EngineGameplay inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostGameplayTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostGameplay.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.5 HostGameplay proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostGameplay with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to EngineGameplay inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

First proving run GREEN on the 4.4 binary; observed preimplementation RED is absent because host Constructor/global/method authoring already existed from 4.1-4.3. Shared build `03e5d74261e54193a7ba0422cb98de30` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostGameplay.'; Fast = $true; TimeoutMs = 600000 }` run `d79f4e04abf54536bcf4c881fc4b4b78`, Succeeded, exit 0, duration 26639 ms. Cases: GameplayBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostGameplay`; copied HostActor.GetActorLocation returns (1,2,3); TraceEmpty returns no hit with zeroed out values; BindInput/UnbindInput subscribe and release once; 63 EngineGameplay inventory sites are classified (0 executable / 52 metadata-only / 11 companion); A/B inject without callback rerun; a missing native target fails closed and B still returns (1,2,3). Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `D134FB3A5B598705B78E48BA333DD3E80A0BDAF511D38D53C4F966E24FB09F35`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `6F097589BE64E04F528544483EBED7AB0058E0636FE387DF5C31C77BCE04D12B`. Omitted: production Actor/trace/input members stay engine-replay with recorded reasons.

## [x] 4.6 Migrate remaining Runtime service registrations

Migrate every eligible EngineServices source site to the shared construction path and retain its expected callable surface. Remaining Runtime services and any inventory entries not owned by earlier families. Whole-family directory reorganization is excluded.

**Outcome**

Migrate every eligible EngineServices source site to the shared construction path and retain its expected callable surface. Remaining Runtime services and any inventory entries not owned by earlier families. Whole-family directory reorganization is excluded.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
// Direct FAngelscriptBinds authoring from 3.1, template routing from 3.2.
// Inspected Binds/*.cpp registrations listed in attachments/data/registration-inventory.csv.
// RuntimeBindingTestSupport.h fixture-local Engine/Context helpers.
```

Produces:

```cpp
// Updated EngineServices registrations; future CQTest HostServices class uses the established Bindings identity convention.
TEST_CLASS_WITH_FLAGS(HostServices, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostServices class, RuntimeBindingHostServicesTests.cpp file and Angelscript.UnitTest.Bindings.HostServices selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Services bound behavior** — new RED
   Given deterministic service fixtures for an empty asset bundle and timer interval 0.25, when their bound query/setter contracts execute then the bundle entry count is 0 and the represented interval remains exactly 0.25; no ambient subsystem startup is required.

2. **Complete family accounting** — new RED
   Given the EngineServices inventory and independently hand-authored symbol expectations, when collection and A/B injection complete then every eligible registration/member has executable or explicitly metadata-only evidence, excluded sites carry reasons, and no callback reruns on injection. Manifest output is not its own oracle.

3. **Owner and failure boundaries** — boundary
   Given a bad declaration/target in this family and a healthy previously created B, when creating a new consumer fails then no partially usable Engine escapes and B's selected family operation still returns the same literal result; required adapter/delegate/auxiliary state stays local.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostServicesTests.cpp
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostServices.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.6 HostServices proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostServices with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Binds/** is limited to EngineServices inventory entries and their same-owner companion files. Inspect and record missing/renamed registrations rather than trusting historical row counts. Test wrappers copy the concrete controls under this card's exact selector so they actually execute. Native host-control success alone does not prove binding success.

**Evidence**

First proving run GREEN on the 4.4 binary; observed preimplementation RED is absent because host ValueClass/method authoring already existed from 4.1-4.3. Shared build `03e5d74261e54193a7ba0422cb98de30` then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostServices.'; Fast = $true; TimeoutMs = 600000 }` run `8788044e2dda4d17a5953e8283175945`, Succeeded, exit 0, duration 26993 ms. Cases: ServicesBoundBehavior, CompleteFamilyAccounting, OwnerAndFailureBoundaries all Success under `Angelscript.UnitTest.Bindings.HostServices`; copied HostBundle.Num is 0 and HostTimer interval remains exactly 0.25; 51 EngineServices inventory sites are classified (0 executable / 40 metadata-only / 11 companion); A/B inject without callback rerun; a missing native target fails closed and B still reports Num 0. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `D134FB3A5B598705B78E48BA333DD3E80A0BDAF511D38D53C4F966E24FB09F35`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `6F097589BE64E04F528544483EBED7AB0058E0636FE387DF5C31C77BCE04D12B`. Omitted: production Runtime service members stay engine-replay with recorded reasons.

## [x] 5.1 Parallelize independent Blueprint class writes

Implement class-exclusive creation/member waves with short shared-index synchronization, parent/shadow barriers and the accepted WriteWorkers setting while retaining GameThread-only reflection/global work.

**Outcome**

Implement class-exclusive creation/member waves with short shared-index synchronization, parent/shadow barriers and the accepted WriteWorkers setting while retaining GameThread-only reflection/global work.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
CVarBindParallelPrepare / ParallelFor preparation; // Binds/Bind_BlueprintType.cpp:154,1693
// GameThread FuncMap prewarm and serial commit; same file:1586,1696
// Shared collection and migrated reflection registrations from 3.1/4.4
```

Produces:

```cpp
// as.Bind.WriteWorkers CVar: default 1; 0 means 1; fixed workers claim one UClass using atomic Next++.
// Blueprint property registration uses ExcludeSuper and shared definition lookup follows the established base/shadow relationships.
TEST_CLASS_WITH_FLAGS(HostBlueprintWrites, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostBlueprintWrites class, RuntimeBindingHostBlueprintWritesTests.cpp file and Angelscript.UnitTest.Bindings.HostBlueprintWrites selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Serial parallel equivalence** — new RED
   Given fixed parent P(X=7), child C(Y=11), an interface and static global function, when complete collection runs with WriteWorkers 0,1,2,4 then normalized key/layout/member results and native outputs are identical and each class/registration is handled once.

2. **Actual class overlap** — new RED
   Given at least two independent classes and worker count 2, when a bounded barrier fixture observes member writes then two class work items are simultaneously active on distinct workers; the same probe at count 1 observes max active 1. No elapsed-time speed threshold is used.

3. **Base order and failure** — boundary
   Given a snapshot sorted with child before parent, when all shells join before base/member work then child resolves X and Y once without inherited duplication; a worker failure cancels publication of the bag and leaves an earlier Engine graph usable. Static-global duplicate scans never run concurrently with global writes.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintCallable.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_definitions.*
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/as_objecttype.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostBlueprintWritesTests.cpp
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostBlueprintWrites.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.1 HostBlueprintWrites proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostBlueprintWrites with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Capture reflection/lazy UClass state on GameThread, preserve the independent Prepare switch and UStruct inherited-property behavior. Use deterministic latches/counters with bounded timeout for overlap proof, not flaky wall-clock assertions.

**Evidence**

First proving run GREEN; observed preimplementation RED is absent because `as.Bind.WriteWorkers` and `RunClassWave` landed with the HostBlueprintWrites cases. GREEN build `a7485c00f476423398ad5a82043f0357` (10302 ms) then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostBlueprintWrites.'; Fast = $true; TimeoutMs = 600000 }` run `a848904bcfb547f69ea5b974b859a412`, Succeeded, exit 0, duration 27661 ms. Cases: SerialParallelEquivalence, ActualClassOverlap, BaseOrderAndFailure all Success under `Angelscript.UnitTest.Bindings.HostBlueprintWrites`; WriteWorkers 0/1/2/4 produce identical P/C/interface/global results (X/Y once, Num=1, ping once); worker count 2 observes max active 2 while count 1 observes max active 1; child-before-parent still resolves X/Y once; a failed write-wave leaves the earlier host graph usable. Naming assumed: `FAngelscriptBindWriteWorkers` / `as.Bind.WriteWorkers`. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `F66C11A13D4845667F184C984B21703CF37D59BCF953BB6AB0805E0417C2F744`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `A92205E22EFE51F3C44CB41A046999B205AE20DFD784B69F3655C4BBEEB60F83`.

## [x] 5.2 Route production binding creation through the shared collection

Replace production DirectBinds with collection/injection, expose explicit binding-engine creation from the retained collection, and remove the migrated descriptor/materialization path from active consumers without activating legacy startup.

**Outcome**

Replace production DirectBinds with collection/injection, expose explicit binding-engine creation from the retained collection, and remove the migrated descriptor/materialization path from active consumers without activating legacy startup.

**Interfaces**

Consumes (existing signatures are identified at the inspected source; task numbers identify future producers):

```cpp
bool FAngelscriptEngine::BindScriptTypes(); // Core/AngelscriptEngine.cpp:3271
FAngelscriptEngine::CreateForBindings(...); // Core/AngelscriptEngine.h:450-451
FAngelscriptBindCollection; // Core/AngelscriptBindsInternal.h:19; upgraded by 3.1
```

Produces:

```cpp
asERegistrationResult FAngelscriptEngine::InjectDefinitions(const asCDefinitions&); // forwarding API selected Q39/Q61
// CreateForBindings accepts the retained Collection through the existing overload naming convention.
TEST_CLASS_WITH_FLAGS(HostProduction, "Angelscript.UnitTest.Bindings", /* EditorContext | EngineFilter */);
```

Product names come from attachments/drafts/glossary.md or the existing API declarations above. The future HostProduction class, RuntimeBindingHostProductionTests.cpp file and Angelscript.UnitTest.Bindings.HostProduction selector follow the inspected CQTest layer/class/file convention; no additional public product concept is introduced.

**Cases**

1. **Production entry reuses graph** — new RED
   Given two explicit production binding owners with the same captured eligible runtime collection, when BindScriptTypes/CreateForBindings completes then native FVector/FString and selected container calls work on both, type/function pointers are shared, and registration counters show one capture.

2. **Whole source reconciliation** — new RED
   Given the refreshed inventory from all six family tasks and an external extension module, when production collection completes then all eligible registrations and expected symbols have dispositions; an extension adds a method before freeze and provenance retains its implicit UE_MODULE_NAME. No active producer uses the old descriptor database or per-Engine host materialization.

3. **Isolation and failed create** — boundary
   Given a healthy B and an invalid new collection, when creation fails then it returns no usable owner and B remains callable; default runtime subsystem, script scanning, debugger, cache and legacy tests remain disabled.


**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBind*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.*
+Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingHostProductionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/Bindings/RuntimeBindingIsolationTests.cpp
 Plugins/Angelscript/Tools/BindingInspection/**
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostProduction.'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.2 HostProduction proof failed' }
```

All 3 named case groups must execute under Angelscript.UnitTest.Bindings.HostProduction with case-level outputs, including actual native/VM calls where specified. A missing selector or only metadata/host-control coverage is failure.

**Notes**

Adapt both existing isolation classes under their actual prefixes, retaining foreign-script/live controls and auxiliary rebinding tests. Keep existing diagnostic inspection semantically usable or explicitly rejected when unsupported; do not introduce manifest v2. No unrelated public-directory migration is authorized.

**Evidence**

RED build `e8e359699b0b4dd9bbad765304e185bd` (102501 ms) then `Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.HostProduction.'; Fast = $true; TimeoutMs = 600000 }` run `06f05ed3c2db4a5880d8be99b6361982`, Failed, exit 255, duration 28515 ms. 3/3 discovered, 0 succeeded. ProductionEntryReusesGraph, WholeSourceReconciliation and IsolationAndFailedCreate failed because `CreateForBindings(Collection)` returned no owner (`CreateForBindings(Collection) is not implemented.`). GREEN build `b632a1ffbde14c48a73b38965b265403` (19503 ms) then the same ue.test run `4a3158aa898c43998ced1f576c5bcf5e`, Succeeded, exit 0, duration 26662 ms. Cases: ProductionEntryReusesGraph, WholeSourceReconciliation, IsolationAndFailedCreate all Success under `Angelscript.UnitTest.Bindings.HostProduction`. Two CreateForBindings owners share the exact FString/FVector/TArray<int> HostProcess pointers and one capture; FString.Len is 3, FVector(1,2,3)+FVector(4,5,6) is (5,7,9), TArray Add/Num is 2; 332 family inventory sites are classified (12 executable / 242 metadata-only / 78 companion); HostProduction.Extension adds HostProductionTag=17 with OwnerModule AngelscriptTest before freeze; a missing native-target collection returns no owner and B remains callable; default subsystem, cache, debugger, source scan and legacy runtime stay dormant. Linked plugin identity: `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptRuntime.dll` sha256 `5D5AE923FD985D28C80844ACBA88337231E868575F5EF44517E09D6D27C5864B`; `Plugins/Angelscript/Binaries/Win64/UnrealEditor-AngelscriptTest.dll` sha256 `4B9CC740AC8B3052DEAAF312FB923062E0DB058FB9E8B421EB12C75D2EE4E05C`. Naming assumed: `FAngelscriptBind::EnsureProcessHostCollection` / `GetProcessHostCollection` / `GetProcessHostCaptureCountForTesting` — process-wide eligible TypeDeclarations plus host-safe ExplicitBindings capture used by BindScriptTypes and CreateForBindings(Collection). Isolation classes retained the Store/live/foreign/auxiliary contract; CreateForBindings(Collection) is the production inject path and does not publish BindingInstallation. BindScriptTypes captures the process host and keeps ExecuteRegisteredBinds for engine-local members (injecting frozen FString/FVector into the live editor would reject later ExplicitBindings). Omitted: TypeBindInfoRecorder no-arg CreateForBindings remains for FullRuntime/Creation fixtures; manifest v2 and heavier suites.

## [x] 6.1 Reconcile affected execution and isolation proofs on the final binary

Verify all new feature selectors plus affected existing SDK definition/registration/identity/VM/source and both binding isolation families against one frozen source/binary snapshot. Reconcile refreshed production site/member dispositions. This node records proof rather than adding another product.

**Outcome**

Verify all new feature selectors plus affected existing SDK definition/registration/identity/VM/source and both binding isolation families against one frozen source/binary snapshot. Reconcile refreshed production site/member dispositions. This node records proof rather than adding another product.

**Files**

```diff
+openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/final-execution.md
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/INDEX.md
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/registration-inventory.csv
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
foreach ($prefix in @('Angelscript.UnitTest.NativeEngine.Definitions.', 'Angelscript.UnitTest.NativeEngine.Registration.', 'Angelscript.UnitTest.NativeEngine.TypeOwnership.', 'Angelscript.UnitTest.NativeEngine.Identity.', 'Angelscript.UnitTest.NativeEngine.VM.', 'Angelscript.UnitTest.NativeEngine.Compile.', 'Angelscript.UnitTest.NativeEngine.SourceExecution.', 'Angelscript.UnitTest.Bindings.Host', 'Angelscript.UnitTest.RuntimeBindings.Engine.Isolation.', 'Angelscript.UnitTest.Bindings.RuntimeBindingIsolation.', 'Angelscript.UnitTest.Baseline.')) {
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = $prefix; Fast = $true; TimeoutMs = 1800000 }
    if ($result.exitCode -ne 0) { throw "Final affected proof failed: $prefix" }
}
```

Completion requires the stated record/evidence outcome and successful complete reports; do not prefill execution evidence.

**Notes**

Each prior behavioral node must already have case-specific RED/GREEN. This final impacted aggregate is justified by shared ownership/registration/VM/production changes. Do not declare missing discovery, a crash, partial report, historical success counts or mismatched binaries green. No full unrelated suite, Performance, memory trace or Integration Harness profile is required.

**Evidence**

Frozen snapshot build `2b852fdd69e241fcb0291484937fded5` then the card foreach on one binary. All 11 prefixes Succeeded, complete reports, 0 failed cases. Totals: Definitions 89, Registration 38, TypeOwnership 20, Identity 48, VM 333, Compile 147, SourceExecution 131, Bindings.Host 30, RuntimeBindings.Engine.Isolation 9, Bindings.RuntimeBindingIsolation 2, Baseline 3 (2 succeeded + 1 SucceededWithWarnings). Linked plugin identity: Runtime sha256 `4F8D783BAEB0136B9F1BE9C77AAEE26BB3E87C933ABCE91CFC40B2E2FEA6B042`; Test sha256 `B0A673A80EC97EBB128A91061A1644261658A6C780A17903A893CAF7C28F9249`. Run IDs and site reconciliation (332 = 12/242/78) are in `attachments/data/final-execution.md`. Local repairs on this snapshot: ConsumerLedger needle `nextMetadataTypeId`; unadmitted Prepare expects `asINVALID_ARG`; ExecuteToHost runs collection-local ExplicitBindings while EnsureProcessHost remains the production subset filter. Isolation families retained Store/live/foreign/auxiliary controls. Omitted: Quick/Performance/Integration and FullRuntime recorder fixtures.

## [x] 6.2 Synchronize ownership specifications and reconcile final evidence

Semantically merge exactly the seven Change delta capabilities using openspec-sync-specs, retain unspecified scenarios, record requirement-to-executed-case coverage, and settle knowledge-candidate dispositions after evidence exists. Preserve current source/user changes and resolve overlapping active-Change assumptions before merge.

**Outcome**

Semantically merge exactly the seven Change delta capabilities using openspec-sync-specs, retain unspecified scenarios, record requirement-to-executed-case coverage, and settle knowledge-candidate dispositions after evidence exists. Preserve current source/user changes and resolve overlapping active-Change assumptions before merge.

**Files**

```diff
 openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/INDEX.md
+openspec/changes/angelscript/refactor-bindings-process-host-typeinfo/attachments/data/final-verification.md
 openspec/specs/angelscript/language/types/definitions/spec.md
 openspec/specs/angelscript/runtime/type-registry/spec.md
 openspec/specs/angelscript/runtime/binding-engine/spec.md
 openspec/specs/angelscript/runtime/vm/spec.md
 openspec/specs/angelscript/bindings/runtime/spec.md
 openspec/specs/angelscript/language/frontend/builder/spec.md
 openspec/specs/angelscript/runtime/bytecode/spec.md
```

**Verification**

Run in the selected workspace with the setup and matching binary described above.

```powershell
$result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-bindings-process-host-typeinfo', '--type', 'change', '--strict', '--json')
if ($result.exitCode -ne 0) { throw 'Change verification record failed' }
foreach ($capability in @('angelscript/language/types/definitions', 'angelscript/runtime/type-registry', 'angelscript/runtime/binding-engine', 'angelscript/runtime/vm', 'angelscript/bindings/runtime', 'angelscript/language/frontend/builder', 'angelscript/runtime/bytecode')) {
    $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @($capability, '--type', 'spec', '--strict', '--json')
    if ($result.exitCode -ne 0) { throw "Affected current spec failed: $capability" }
}
```

Completion requires the stated record/evidence outcome and successful complete reports; do not prefill execution evidence.

**Notes**

The inspected baseline passes five capabilities; bindings/runtime has six pre-existing two-space quote blocks and builder has one. Repair indentation/blank-line ownership only in Call native members through the current VM; Dump sealed binding declarations; Validate and compare dumps offline; Seal namespace globals and retain snapshot lifetime; Reconcile all eligible providers and expected members; Revalidate without changing a sealed snapshot; and Analyze supported source through the replacement. Preserve their text and Requirement/Scenario parentage unless this delta explicitly replaces a card. Update affected Purpose prose to the new shared-host/private-script contract and approved vocabulary; no other baseline formatting migration. No product build is required for this documentation node.

**Evidence**

Strict `openspec.validate` Succeeded for the Change (`valid: true`, 25 ms) and all seven current capabilities: `angelscript/language/types/definitions`, `angelscript/runtime/type-registry`, `angelscript/runtime/binding-engine`, `angelscript/runtime/vm`, `angelscript/bindings/runtime`, `angelscript/language/frontend/builder`, `angelscript/runtime/bytecode`. Merge map, quote repairs, requirement-to-case coverage and knowledge dispositions are in `attachments/data/final-verification.md`. Knowledges remain Change-local promoted sources; no capability `knowledges/` trees exist. No overlapping active Change deltas on the seven capabilities. Omitted: product rebuild (documentation node).
