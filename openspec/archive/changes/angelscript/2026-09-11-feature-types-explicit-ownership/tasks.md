---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "2.3": ["1.1"]
    "7.1": ["2.3"]
    "7.2": ["7.1"]
    "7.3": ["7.2"]
    "7.4": ["7.3"]
    "7.5": ["7.4"]
    "7.6": ["7.5"]
    "7.7": ["7.6"]
    "7.8": ["7.7"]
    "7.9": ["7.8"]
    "7.10": ["7.9"]
---

# Implementation tasks

Pending tasks 2.1, 2.2, 2.4 and 3.1-6.2 are superseded by 7.x (Image is a unique intermediate; BindInfo holds class records; Engine uniquely owns TypeInfo; no `std::shared_ptr`). Completed 1.1 and 2.3 stay checked. Read design.md and attachments/INDEX.md. Preserve unrelated workspace changes, including Bind_FName.cpp.

Use literal Automation identities under the selectors below. Keep test orchestration on the test thread; workers join on every path. After C++/header changes, freeze writers and require `ue.build` before Automation. Grouped RED then GREEN. No `std::shared_ptr` for Image, Image dependencies, publication lifetime or TypeInfo ownership.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot (Get-Location).Path
```

## Task 1.1

- [x] 1.1 Establish source consumers and reproducible ownership controls

    **Outcome**

    Produce the independent consumer/expectation ledger and baseline before SDK ownership changes. Add observation fixtures only; unchanged behavior does not require fabricated RED.

    **Context and interfaces**

    Read design sections 1-3 and the indexed source/validation evidence. Adapt actual EngineRegistrationTests, BuilderStageTests, VMObjectLifetimeTests and RuntimeBindingIsolationTests. Create TypeOwnershipTestSupport.h and test classes under the literal Baseline selector.

    **Cases**

    - Baseline.Pair: native struct Pair { int X; int Y; } with host values 20/22 and native Sum=42; record current detached/member query, registration and real VM invocation results.
    - Baseline.PrivateOwners: independently compile class ScriptThing in A/B and record pointer/key/ID relationships, ForeignEngine rejection and survivor lifetime under the current contract.
    - Baseline.ConsumerLedger: every matched active GetBoundEngine/GetEngine, ID query and metadata user-data access has an owning task and active/dormant disposition.
    - Baseline.VMExecution: capture execution samples for arithmetic, script/native calls, allocate/release, handle copy, casts and template operations across 1/2/8 Engines.
    - Baseline.Cost: 128 Pair definitions with Sum/GetX/GetY/One returning 42/20/22/1.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipTestSupport.h`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipBaselineTests.cpp`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/data/consumer-migration.csv`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/data/baseline-expectations.json`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/data/verification-baseline.md`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/INDEX.md`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    Build `cdcea3a595fa4706a935a9a366b942a4` succeeded, then proving run `72d04f2d6b524bbba54443fb365997c0` passed all five Baseline cases. See [verification-baseline.md](attachments/data/verification-baseline.md). This characterizes the old Image-owned contract.

## Task 2.3

- [x] 2.3 Provide the process ID service and bounded concurrent reservations

    **Outcome**

    Establish asCTypeIdRegistry and its single exported numeric service before any publication consumer; preserve primitive and qualifier encodings.

    **Cases**

    - Allocation.Parallel: 8 workers, 128 bundles of 2/3/1, unique 2048/3072/1024, no overlap.
    - Allocation.LastBundle: one-bundle capacity, exactly one winner, later fail.
    - Allocation.Encoding: primitives 0..11 fixed; empty/overlarge/overflow reject without advancing.
    - Allocation.Service: same Get() address; engine destroy does not reset; type/function spaces distinct.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_type_id_registry.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipAllocationTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipTestSupport.h`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Allocation'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    Build `12921bbac3934ce2be9597008efca847` succeeded. Proving run `3df18feef9154e79a831b84c6a6c16e3` passed Allocation 4/4. Follow-up TypeInfo materialization is 7.4.

## Task 7.1

- [x] 7.1 Make asCMetadataImage a unique intermediate helper

    **Outcome**

    Refactor asCMetadataImage so it is a unique, discardable helper: `TUniquePtr` creation, no `std::shared_ptr` / `enable_shared_from_this`, no shared Image graph. After Engine adopt, TypeInfo lives with the Engine; destroying Image must not delete those objects. Revert abandoned 2.1 `Register(std::shared_ptr)` APIs.

    **Context and interfaces**

    Current `Create()` returns `std::shared_ptr`, destructor deletes Types/Functions, Engine `RegisterMetadataImage(const std::shared_ptr<asCMetadataImage>&)` retains the Image, and TypeInfo `GetEngine()` goes through BoundEngine. Target:

    ```cpp
    static TUniquePtr<asCMetadataImage> asCMetadataImage::Create(const asSMetadataOptions& Options = {});
    asEMetadataRegistrationResult asCScriptEngine::RegisterMetadataImage(TUniquePtr<asCMetadataImage> Image);
    ```

    Dependencies are non-owning `asCMetadataImage*` or uniquely owned children, never `std::shared_ptr`. Builder `GetDefinitions()` returns `TUniquePtr` or a non-owning view plus an explicit take-ownership method. `FAngelscriptTypeBindInfoDraft` stores `TUniquePtr<asCMetadataImage>`.

    **Cases**

    - Image.UniqueCreate: `Create()` yields a non-null unique pointer; copying the Image type does not compile.
    - Image.DiscardAfterAdopt: define Pair, adopt into Engine, reset the unique Image; TypeInfo remains alive, `GetEngine()` is the Engine, Sum still executes as 42.
    - Image.NoSharedPtr: Image headers and the Register/Create/AddDependency/GetDefinitions signatures contain no `std::shared_ptr`.
    - Image.TwoUniqueHelpers: two unique Pair helpers adopted by A and B produce distinct TypeInfo pointers; destroying one helper does not affect the other Engine.

    **Implementation**

    1. Add Image.* cases; they fail to compile or fail assertions while Create still returns shared_ptr and destructor deletes adopted Types.
    2. Switch Create to TUniquePtr, remove enable_shared_from_this, transfer TypeInfo/function/global ownership on Engine adopt, make destructor skip transferred objects.
    3. Update every maintained caller (NativeEngine fixtures, Builder, Draft/Apply, TypeOwnership). Leave Legacy ignored sources untouched.
    4. GREEN the Image selector plus Allocation (2.3 must stay green). Baseline may need fixture pointer-type updates in this same task.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_type_id_registry.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.*`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/NativeDetachedDefinitionTestSupport.h`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/**`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**/*.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Image'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    $alloc = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Allocation'; Fast = $true; TimeoutMs = 600000 }
    if ($alloc.exitCode -ne 0) { throw 'Allocation regression failed' }
    ```

    **Evidence**

    Build `a6147bf1fdcf480e975bbadcfd878733` succeeded (`NoXge`, serialized). Image proving run `b96feb31c15a4476a3b5899effdeeece` passed UniqueCreate, DiscardAfterAdopt, NoSharedPtr, TwoUniqueHelpers (4/4). Allocation regression run `2d26bc875e0c47e1b0b96abf77834ee5` passed Parallel, LastBundle, Encoding, Service (4/4). Create returns `TUniquePtr`; Register takes unique by value; Builder `GetDefinitions()` is a raw view and `TakeDefinitions()` transfers ownership; dependencies are non-owning `asCMetadataImage*`. Omitted Baseline, full NativeEngine, Integration, and Unreal suites: 7.1 proving selection is Image plus Allocation only.

## Task 7.2

- [x] 7.2 Publish BindInfo class records with process IDs before TypeInfo exists

    **Outcome**

    Assign TypeId/FunctionId to BindInfo publications using the 2.3 allocator without creating Engine TypeInfo.

    **Cases**

    - Publish.PairId: BindInfo Pair receives a TypeId > last primitive; `GetTypeInfoById` is null until 7.4.
    - Publish.Invalid: incomplete layout fails with no ID consumed into a visible TypeInfo.
    - Publish.NoReuse: a second independent Pair record gets a different ID.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_type_id_registry.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.*`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipPublicationTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Publish'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED compile `c1f3343ad48f439c9ac497c2ee609cd5` failed on missing `PublishProcessIds` / `GetPublishedTypeId` / `GetPublishedFunctionId`. Build `365d9ba89afd4c46993e9e54df0f12c5` succeeded. Proving run `a8f16fbae2104bcebc5fe4be46121fc8` passed PairId, Invalid, NoReuse (3/3). Sealed BindInfo stores reserve TypeId/FunctionId through the 2.3 allocator; Engine `GetTypeInfoById` stays null. Invalid alignment does not consume sequences. Omitted Image, Allocation, Baseline, and Unreal suites: 7.2 proving selection is Publish only.

## Task 7.3

- [x] 7.3 Return UE class information from BindInfo without Engine TypeInfo

    **Outcome**

    Host queries name, members, signatures and IDs from BindInfo/Registry after the unique Image helper is destroyed.

    **Cases**

    - ClassInfo.PairMembers: X/Y offsets and int32 type facts, Sum signature, after Image reset.
    - ClassInfo.NoTypeInfoPointer: query APIs do not return asCTypeInfo* before materialize.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoStore.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_type_id_registry.*`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipClassInfoTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.ClassInfo'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED compile `ba88ea36dee44ea7b45cfa8a9b84e816` failed on missing `GetPublishedClassInfo`. Build `90e485c455fc4f958d7b2ee4b58cf0d7` succeeded. Proving run `dd01adb5032141e1b275c97244970486` passed PairMembers and NoTypeInfoPointer (2/2). After Image reset, BindInfo still returns Pair name, X/Y offsets, int type facts, Sum signature and FunctionId; Engine `GetTypeInfoById` stays null. Omitted Publish, Image, Allocation, Baseline, and Unreal suites: 7.3 proving selection is ClassInfo only.

## Task 7.4

- [x] 7.4 Materialize Engine-owned TypeInfo from a publication

    **Outcome**

    An Engine constructs unique TypeInfo from BindInfo, reports the publication IDs, and does not need the Image afterward.

    **Cases**

    - Materialize.Pair: Engine GetTypeInfoById returns that Engine's pointer; Sum executes 42.
    - Materialize.DiscardImage: Image unique_ptr reset before Execute still works.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.*`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipMaterializeTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Materialize'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED compile `77914d7c6502474c916a78e0ca6677ae` failed on missing `MaterializePublishedTypes`. Proving run `f1eacd9e2c0a4eeca88b80ce41369c2a` passed Pair and DiscardImage (2/2). Engine TypeInfo reports BindInfo publication IDs; Sum executes 42; caller Image unique can be reset first. Unpublished helper images skip already published process IDs. Omitted ClassInfo, Publish, Baseline, and Unreal suites: 7.4 proving selection is Materialize only.

## Task 7.5

- [x] 7.5 Give two Engines distinct TypeInfo for one publication ID

    **Outcome**

    A and B materialize Pair independently: same ID, different pointers, independent native state 42 vs 99.

    **Cases**

    - Shared.DistinctPointers
    - Shared.IndependentAuxiliary
    - Shared.DestroyALeavesB

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipSharedPublicationTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Shared'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    Proving run `0c34a3a4a9c8433eba0bfdf0ef1153a9` passed DistinctPointers, IndependentAuxiliary, DestroyALeavesB (3/3). Two Engines materializing one BindInfo publication share TypeId/FunctionId and keep distinct TypeInfo/Function pointers; A=42 and B=99; destroying A leaves B executable. Enabled by 7.4 unique materialize. Omitted Materialize, Baseline, and Unreal suites: 7.5 proving selection is Shared only.

## Task 7.6

- [x] 7.6 Keep private AS TypeInfo exclusive to the receiving Engine

    **Outcome**

    Independently compiled ScriptThing objects differ; B rejects A's TypeInfo; source specializations stay with the receiver.

    **Cases**

    - Private.ScriptThingIsolation
    - Private.SpecializationStaysWithEngine

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.*`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipPrivateTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Private'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED run `a44908e0068345319318d5ef71180544` failed ScriptThingIsolation (same numeric TypeId on A and B) and SpecializationStaysWithEngine (B resolved A's ID). Unpublished Image registration now reserves process IDs. Proving run `d7b3853f712f470d8a14334fa730c2ea` passed ScriptThingIsolation and SpecializationStaysWithEngine (2/2). Adjacent Materialize `a0c97633921e47bb8486f04312f55b38` and Shared `abe3db1832df4e5e93be5ba6dfca28eb` stayed green. Omitted Baseline and Unreal suites: 7.6 proving selection is Private, with adjacent Materialize/Shared because Register unpublished IDs changed.

## Task 7.7

- [x] 7.7 Admit and execute only the receiving Engine's TypeInfo

    **Outcome**

    Context/linker/VM use Engine TypeInfo. No BoundEngine on Image. Foreign TypeInfo pointers reject even with a matching publication ID.

    **Cases**

    - Admission.ForeignTypeInfoRejected
    - Admission.NoImageBoundEngine

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_linker.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_vm_object.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipAdmissionTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Admission'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED run `edf932c3bbb6481eb29c6281831e4d59` failed NoImageBoundEngine (`GetBoundEngine` still set). Proving run `7a47cded3fcc461fa36ac4cd5d9120b2` passed ForeignTypeInfoRejected and NoImageBoundEngine (2/2). TypeInfo/Function `engine` is the admission authority; Image BoundEngine stays null. Adjacent Materialize `ce979b122d6d4ee9ba383f677d391a5b`, Shared `0b815d0c07e0418abc0eac0efcdb45d7`, Private `ac8c0ab0641149afad43fdc84d1541e4` stayed green. Omitted Baseline and Unreal suites: 7.7 proving selection is Admission, with adjacent TypeOwnership groups because Register/GetEngine/linker changed.

## Task 7.8

- [x] 7.8 Install bindings from BindInfoStore with a unique Image helper

    **Outcome**

    CreateForBindings consumes BindInfoStore, uses a unique Image only during materialize, and isolates per-Engine installation.

    **Cases**

    - Bindings.PrepareOnceTwoEngines
    - Bindings.DestroyOne

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.*`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoDraft.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingIsolationTests.cpp`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Bindings.RuntimeBindingIsolation'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    RED run `82baa051fd0149419b09d6c5eb3fc889` failed both cases at CreateForBindings (`ConnectNative` still required Image BoundEngine). After BoundEngine admission, run `5aebb493e362453e94651906e1517794` failed FindType(Pair) because Draft lookup ignored ImageView after TakeImage. Proving run `421dbe2c93ee4dbb91e445948b0621bf` passed PrepareOnceTwoEngines and DestroyOne (2/2). CreateForBindings publishes BindInfo once, Install materializes unique TypeInfo with those IDs, ConnectNative admits by TypeInfo engine, and Draft FindType uses the non-owning Image view. Adjacent Isolation `df9036f7f09f42e6b546cda6e173649e` (9/9), Materialize `3e5a342a2fa147b394484fb1f5a63d25` (2/2), Shared `450fe1a615314c569ca3d495d1fe4464` (3/3) stayed green. Omitted Baseline and Unreal suites: 7.8 proving selection is RuntimeBindingIsolation; Isolation/Materialize/Shared cover ConnectNative, published-ID maps, and FindType.

## Task 7.9

- [x] 7.9 Preserve VM execution performance versus the 1.1 baseline

    **Outcome**

    Repeat 1.1 VMExecution/Cost semantic fixtures on the unique-TypeInfo path. A repeatable regression attributable to this Change blocks completion.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/TypeOwnership/TypeOwnershipBaselineTests.cpp`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/data/verification-final.md`

    **Verification**

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.TypeOwnership.Baseline'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw 'Owned proving selection failed' }
    ```

    **Evidence**

    Pre-oracle RED `3382d71bcca549feb277c88431f4c378` failed Pair only: detached int members report `asTYPEID_INT32`, not `-1`. After that oracle, proving run `e1fca0fe764f4024a329c4d94cf7601c` passed all five Baseline cases (5/5). Repeatability sample `374941a23bb342639868fa61deec4dc5` also 5/5. Semantic VM results match 1.1 (20+22=42, CALLSYS, ALLOC/FREE, Cast, concurrent 1/2/8). Setup attach_ns is higher because unpublished Register now reserves process IDs; that is outside VM dispatch. See [verification-final.md](attachments/data/verification-final.md). Omitted Quick, Performance, Integration and Unreal suites: 7.9 reuses the 1.1 Baseline selector.

## Task 7.10

- [x] 7.10 Synchronize specs and produce the SDK handoff

    **Outcome**

    Merge durable deltas, apply only named formatting repairs from validation-baseline.json, and write sdk-handoff.json for the binding Change.

    **Files**

    - `openspec/specs/angelscript/runtime/type-registry/**`
    - `openspec/specs/angelscript/language/types/definitions/spec.md`
    - `openspec/specs/angelscript/runtime/vm/spec.md`
    - `openspec/specs/angelscript/runtime/bytecode/spec.md`
    - `openspec/specs/angelscript/runtime/binding-engine/spec.md`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/data/sdk-handoff.json`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/scripts/Test-SdkHandoff.ps1`
    - `openspec/changes/angelscript/feature-types-explicit-ownership/attachments/INDEX.md`

    **Verification**

    ```powershell
    foreach ($record in @(@('angelscript/feature-types-explicit-ownership','change'), @('angelscript/refactor-bindings-two-stage-pipeline','change'), @('angelscript/runtime/type-registry','spec'), @('angelscript/language/types/definitions','spec'), @('angelscript/runtime/vm','spec'), @('angelscript/runtime/bytecode','spec'), @('angelscript/runtime/binding-engine','spec'))) {
        $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @($record[0], '--type', $record[1], '--strict', '--json')
        if ($result.exitCode -ne 0) { throw "Record validation failed: $($record[0])" }
    }
    ```

    **Evidence**

    Created current `angelscript/runtime/type-registry` and merged ADDED/MODIFIED deltas into definitions, vm, bytecode and binding-engine. Applied named four-space clause-ownership repairs from [validation-baseline.json](attachments/data/validation-baseline.json). Strict validation: producer `73147522eaf147cba14a7a95fbfec2ae`, binding Change `96f6a8d7d0e64022b41f09efdd15aaa3`, type-registry `48255b37574b4d01bc536e58147d50c9`, definitions `096372cc753840528070694676444f78`, vm `e2d03f4534e14597b748c8dbf80c36bb`, bytecode `6213d9eb291c40c4a30fb1b8e6b8c910`, binding-engine `05c1cc50f08b4db08fb31bac6ab6165c`. Wrote [sdk-handoff.json](attachments/data/sdk-handoff.json) schema `external-types-handoff-v1` and [Test-SdkHandoff.ps1](attachments/scripts/Test-SdkHandoff.ps1) for UID `change_6f58d4ea-1ff3-48f6-8680-df1b32635270`; verifier passed `-RequireComplete`. Omitted Unreal suites: 7.10 is specification and handoff only.
