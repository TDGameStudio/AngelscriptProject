---
task_graph:
  version: 1
  depends_on:
    "0.1": []
    "1.1": ["0.1"]
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "2.4": ["2.3"]
    "3.1": ["2.4"]
    "3.2": ["2.4"]
    "3.3": ["3.1", "3.2"]
    "3.4": ["3.1"]
    "3.5": ["3.4"]
    "4.1": ["2.3"]
    "4.2": ["3.3", "4.1"]
    "5.1": ["3.3", "4.1"]
    "5.2": ["5.1"]
    "5.3": ["5.2"]
    "5.4": ["5.3", "3.5"]
    "5.5": ["5.4"]
    "5.6": ["5.5"]
    "6.1": ["5.6", "4.2"]
    "6.2": ["6.3"]
    "6.3": ["6.1"]
    "6.4": ["6.2"]
---

# Refactor Runtime bindings into an extensible two-stage pipeline

## Goal

Deliver a complete, extensible and measurable Runtime binding system with exactly two public stages, Record and Install, while preserving dormant legacy behavior through an incremental provider migration.

## Architecture

Record executes each eligible built-in primary provider and external extension once into independent fragments, then merges, validates and seals them into a shared const FAngelscriptBindingDatabase with separately retained HostTargets. Install prepares detached metadata once through the SDK, validates executable targets before engine allocation and creates each engine-owned FAngelscriptBindingInstance without rerunning providers or rescanning reflection. The framework splits into Registration, Recording, Metadata, Runtime, Adapters and Diagnostics, with built-in registration organized under Core, Math, Containers, Objects and Engine. See `design.md`.

## Global constraints

- Creation boundary: this Change was created as a documentation-only delivery. Every product task is intentionally unchecked; structural readiness is not permission to begin implementation in the creation session, and no product build, Automation, benchmark, trace or repair is claimed by that delivery.
- Read `design.md` and `attachments/INDEX.md` before the first ready task. All paths are relative to the selected workspace.
- Preserve unrelated changes, including the pre-existing `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp` working edit, which is not owned by this Change.
- The source inventory task column in `attachments/data/provider-migration.csv` is the migration boundary; companion-file globs (`Bind_*_Type.cpp`, `Bind_*_Functions.cpp`, `Bind_*.h`) are restricted to the listed registration owners and are never permission for unrelated edits.
- All new C++ cases live in `Plugins/Angelscript/Source/AngelscriptTest/NewVersion` and use the public `Angelscript.UnitTest.<Area>.<Scenario>` identity. Test classes must expose the literal task selectors in each card; a selector discovering zero or incomplete cases is failure.
- Mechanical moves, file moves, unchanged-behavior measurements and the final spec handoff do not require fabricated behavioral RED; missing interfaces follow the TDD skill's bounded compile-evidence rules.
- Family migration cards (5.1 through 5.6) use new test classes under their literal `Angelscript.UnitTest.RuntimeBindings.Migration.<Family>` prefix: adapt inspected inputs and oracles into those classes or shared `RuntimeBindingTestSupport.h` helpers; pointing at an existing case under another prefix does not include it in the run. Translation-unit-local fixtures are references to adapt, not public helper APIs. Existing host-only or operations-only checks remain controls and cannot substitute for required bound/VM execution.
- Task 1.1 owns the independent `baseline-expectations.json` handoff; later family cards consume its expected semantic surface and disposition rules rather than copying a migrated manifest.
- Task 0.1 verifies the `angelscript/feature-types-explicit-ownership` SDK prerequisite (UID `change_6f58d4ea-1ff3-48f6-8680-df1b32635270`) before any product node; this Change consumes the delivered SDK interfaces and never creates a binding-local allocator or duplicate registry.
- Task 6.4 is document-only and does not require a new UE build.
- Listed verification and data attachments are created only when their results exist and are indexed in the same edit; `attachments/data/planning-validation.md` is the creation report, not evidence of any task.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| SDK prerequisite verified before the binding migration baseline (proposal, SDK prerequisite) | 0.1 |
| Runtime: engine-free recording and shared database | 2.2, 4.1, 6.2 |
| Runtime: dependency-correct and callable application | 2.4, 3.2, 3.3, 4.2, 6.2 |
| Runtime: pre-installation executable-target validation | 2.4 |
| Runtime: complete primary descriptions and full migration | 1.1, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 6.1, 6.2 |
| Binding engine: explicit creation and single-use preparation | 2.4, 6.2 |
| Binding engine: adapter and resource isolation | 3.1, 6.2 |
| Binding engine: delegate host-storage lifetime | 3.4 |
| Binding engine: payload execution lifetime | 3.5 |
| Extensions: registration callbacks and conflict behavior | 2.2, 2.3; installed call proof in 2.4 |
| Extensions: provider generations | 2.3, 4.1 |
| Extensions: native enrichment, origin and dispatch | 2.3, 2.4, 6.1 |
| Extensions: supported public boundary | 2.1, 6.1 |
| Observability: phase and work attribution | 1.2, 4.1, 4.2, 6.3 |
| Observability: owned/shared memory and real trace attribution | 1.2, 6.3 |
| Observability: validated comparable performance samples | 1.1, 1.2, 6.3 |
| Class/SDK/UE/directory responsibilities and compatibility | 2.1, 2.4, 3.1, 3.2, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 6.1 |
| Final evidence and durable-spec handoff | 6.4 |

Self-review 2026-09-11: syntax migration only; coverage and symbols unchanged from the original plan. Record: `attachments/data/planning-validation.md`

## [ ] 0.1 Verify the external type SDK prerequisite

**Outcome**

Accept the verified SDK/publication/query/ownership and reusable preparation handoff before the binding migration baseline. Structural readiness of this entry task does not mean the producer is complete.

**Context and interfaces**

Consume angelscript/feature-types-explicit-ownership with immutable UID change_6f58d4ea-1ff3-48f6-8680-df1b32635270. Its task 6.2 produces sdk-handoff.json and Test-SdkHandoff.ps1 under its indexed data/scripts attachments. The verifier uses CLI-owned active task/archived closure validation and exact source hashes. Planning alone does not create this verified handoff. The SDK prerequisite now exposes asCTypeIdRegistry for checked process ID reservation and global retained host queries, plus creator-owned MetadataImage graphs. Global inspection never replaces Engine admission. Consume these delivered interfaces; do not create a binding-local allocator or duplicate registry.

**Cases**

- Completed producer, external-types-handoff-v1 schema, shared-const-v1 preparation and matching required interface/source hashes admit the prerequisite.
- Missing handoff/verifier, incomplete producer, wrong UID or stale source hashes stop this task.
- RuntimeBindings.ExternalTypes executes on the current binary: shared graph, separate mutable installations and a callable survivor.
- Active and completed archived producer locations are supported; immutable UID is verified rather than inferred from the directory name.

**Implementation**

Run the producer verifier and the exact integration selector. Record validated UID, handoff hash, source/binary identity and report in sdk-prerequisite.md. No SDK product code is implemented here and producer tasks cannot be marked complete by this consumer. The following baseline measures binding migration after the SDK prerequisite.

**Files**

```diff
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/sdk-prerequisite.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$producerRoot = Join-Path $context.WorkspaceRoot 'openspec/changes/angelscript/feature-types-explicit-ownership'
if (-not (Test-Path -LiteralPath (Join-Path $producerRoot 'change.yaml'))) {
    $archiveRoot = Join-Path $context.WorkspaceRoot 'openspec/archive/changes/angelscript'
    $matches = @(Get-ChildItem -LiteralPath $archiveRoot -Directory | Where-Object {
        $_.Name -like '*-feature-types-explicit-ownership' -and
        (Test-Path -LiteralPath (Join-Path $_.FullName 'attachments/scripts/Test-SdkHandoff.ps1'))
    })
    if ($matches.Count -ne 1) { throw 'Expected one archived external-types prerequisite' }
    $producerRoot = $matches[0].FullName
}
$verifier = Join-Path $producerRoot 'attachments/scripts/Test-SdkHandoff.ps1'
if (-not (Test-Path -LiteralPath $verifier -PathType Leaf)) { throw 'External-types SDK prerequisite is not delivered' }
& $verifier -WorkspaceRoot $context.WorkspaceRoot -ExpectedChangeUid 'change_6f58d4ea-1ff3-48f6-8680-df1b32635270' -RequireComplete
if (-not $?) { throw 'External-types handoff verification failed' }
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.ExternalTypes'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw 'External-types SDK integration prerequisite failed' }
```

## [ ] 1.1 Establish independent coverage and a reproducible baseline

**Outcome**

Reconcile the attached 254 lexical registration sites with eligible Runtime providers and independently expected members; establish the unchanged-product baseline workload before structural edits. This task adds observation fixtures, not binding behavior.

**Context and interfaces**

Consume attachments/data/provider-migration.csv and the archived full-runtime expectation table through its INDEX. Add RuntimeBindingBaselineTests.cpp using the existing Capture, Prepare, CreateForBindings and BindingInspection boundaries. Keep source-candidate, active-provider and installed-member counts distinct.

**Cases**

- Baseline.Small: a two-int Pair with values 20 and 22 exposes Sum=42 and a global Add(20,22)=42; Capture creates no engine.
- Baseline.FullRuntime: run the existing independently expected FVector/FString/global controls and retain the full semantic manifest; note current template operations-only coverage honestly.
- Baseline.Reuse: record and prepare once through the prerequisite bridge, create two owners sharing external metadata with distinct mutable installation state, release one and invoke the survivor. Record the post-SDK binding baseline rather than inventing pre-change RED.
- Every inventory site has active, compile-time excluded, policy-excluded, test-only or no-output disposition; an unexplained site fails inventory reconciliation.

**Implementation**

Author the fixed input/expectation files and baseline fixture. The baseline-expectations.json handoff records each expected symbol's owner/namespace, kind, declaration, target condition, source-case reference, concrete input/result and proof level (host control, metadata/operations or bound invocation); keep inventory site identity separate from semantic member identity. Independently select these expectations from inspected declarations and fixture literals, then compare the implementation dump against them, never populate expectations by copying that dump. Include every six-family member/disposition required by the provider ledger. Run against the existing implementation, retain raw runs and a trimmed summary with source/binary identity. Preserve missing behaviors as known gaps for later RED tests. Instrumentation-neutral timings cover existing public boundaries; internal phase baseline follows 1.2.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingBaselineTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/baseline-expectations.json
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/verification-baseline.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Baseline'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.1 proving selection failed' }
```

## [ ] 1.2 Observe binding phases and owned memory before migration

**Outcome**

Provide fixed phase timers, work counters, scoped memory categories and one consistent read-only metrics snapshot on the current path; obtain the internal baseline before moving responsibilities.

**Context and interfaces**

Implement FAngelscriptBindingMetrics by consuming the prerequisite SDK GetMemoryStats with coverage/used/capacity semantics from design section 9; do not reimplement SDK accounting. Reuse existing AngelscriptMemoryTags and native FMemory tracing. Initially place the metrics implementation under Core; task 2.1 moves it into Diagnostics. SDK tagging must preserve an active binding attribution scope.

**Cases**

- Metrics.Ownership: a 64-byte and 128-byte counted fixture allocation reports 192 owned bytes; final release returns its owned accounting to baseline.
- Metrics.SharedDatabase: two consumers charge one database and two instance allocations; destroying one does not subtract the shared database.
- Metrics.Capacity: remove entries from a reserved fragment and prove count falls while capacity is retained; retained UObject references never add the UObject asset size.
- Metrics.Phases: capture/install/release events and counts match explicit invocation counters; worker scopes preserve capture identity; disabled facilities report unavailable rather than false zero.
- New phase/memory observations provide behavioral RED; existing call outputs remain controls. Allocator totals are not inferred solely from SDKAlloc because other allocation paths exist.

**Implementation**

Prepare arithmetic, ownership, worker and disabled-observer tests; observe missing metrics RED. Add low-overhead binding counters and UE output scopes consuming the delivered SDK-owned memory snapshot without changing collector/allocator policy. Run GREEN and repeat baseline with internal phase/coverage information. Real trace validation and overhead comparisons belong to 6.3.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindingMetrics.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptMemoryTags.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_memory.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMetricsTests.cpp
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/verification-metrics-baseline.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Metrics'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '1.2 proving selection failed' }
```

## [ ] 2.1 Establish public binding interfaces and framework ownership

**Outcome**

Introduce the named public Registration/Context/Builder/Database/Installer boundary and Framework directories with bounded old-header adapters. Preserve behavior while removing public reliance on private installation headers.

**Context and interfaces**

Use the name/directory map in design sections 3 and 8. AngelscriptRuntime remains the build module. The old FAngelscriptBinds immediate path stays dormant and is isolated from the new record facade; TypeAdapter behavioral reconstruction remains task 3.1.

**Cases**

- PublicApi.ExternalLambda: a test module includes Public/Bindings only and registers a captureless lambda; its callback records one fixture type and is discoverable.
- PublicApi.PrivateBoundary: the extension fixture builds without Private/Bindings include paths or private header inclusion.
- PublicApi.Compatibility: existing Runtime registration and the dormant control remain available through bounded shims; generated aggregators and forced-link registration still compile.
- This is a structural task: build and behavior controls are proof; do not fabricate runtime RED for a mechanical move. New public API fixtures can establish missing-interface RED using the project's TDD policy.

**Implementation**

Introduce minimal public headers and forwarding bridge, move responsibility owners into Framework, update internal includes and generated-wrapper paths, and compile the independent consumer. Move metrics to Diagnostics without changing semantics. Record every retained Core include/name shim and its remaining consumer; do not move concrete providers yet.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBind*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBind*.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptPreparedBindings.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Helpers.h
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPublicApiTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/AngelscriptTest.Build.cs
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/compatibility-ledger.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.PublicApi'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.1 proving selection failed' }
```

## [ ] 2.2 Record complete primary descriptions without a declaration prepass

**Outcome**

Implement the immutable database, separate HostTargets and provider-local builders. Resolve declarations after all fragments exist so one primary callback records its entire type.

**Context and interfaces**

Consume public interfaces and the migration bridge. Context.ValueType/ReferenceType/EnumType/ExtendType produce unresolved typed records; DatabaseBuilder finalizes using SDK parser/canonical identity only, without asCMetadataImage or an engine. Snapshot required UE inputs on GameThread.

**Cases**

- Recording.CompletePrimary: one callback records Pair layout, constructor/destructor, Sum, property X, adapter/finder recipe and ToString; callback count equals one.
- Recording.ForwardReference: extension/member refers to a type whose provider executes later and resolves successfully.
- Recording.InvalidGraph: missing RequiredType and an A-by-value-B-by-value-A cycle return no database with source diagnostics; A/B handle cycles succeed.
- Recording.SealAndReuse: rejected post-seal mutation leaves semantic output unchanged; HostTargets retain their declared lifetime independently of record fragments.
- Recording.Policy: a registered eligible external module participates; explicit module/target policy exclusion is recorded. No ambient runtime-only filter silently discards every external provider.

**Implementation**

Add grouped RED cases for complete callback recording, forward references and stable ownership. Implement fragments, target IDs, in-place member modifiers and finalization without provider replay. Keep the old phased bridge only for unmigrated providers. Run GREEN and inspect that Record allocated no engine/runtime metadata object.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Recording/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Registration/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoCatalog.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingRecordingTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Recording'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.2 proving selection failed' }
```

## [ ] 2.3 Preserve external lambdas and typed native target enrichment

**Outcome**

Provide synchronized registry generations, additive type extensions and native target batch submission with explicit origin and transport at the recording boundary. Task 2.4 proves executable installation of these outputs.

**Context and interfaces**

Implement ExtendType(...).NativeTarget(Signature, TargetDesc), typed C++ wrappers and adapters over the existing native-module function-address map. Default capture admits eligible registered extension modules; explicit CaptureOptions module selection may exclude them with provenance. Live engine mutation, capturing-lambda ownership and an actual UHT generator are excluded.

**Cases**

- Extensions.Order: registering ExtraMethod before Pair's primary produces one Pair and the complete ExtraMethod signature plus the target of a real compiled function returning 42; installed invocation is owned by 2.4.
- Extensions.Generation: capture D1, register a new lambda, capture D2; D1 has no extra member and D2 has it; a registry duplicate fails without replacement.
- Extensions.Conflict: conflicting same-signature definitions fail identically in either order; Add(int) and Add(double) coexist.
- Extensions.Transport: a real compiled thunk enriches a reflected declaration and records Generated+NativeThunk; incompatible supplied signature/layout facts reject without producing a database. Executable ABI validation and calls are proved by 2.4.
- Extensions.Dispatch: a Blueprint-sensitive declaration retains reflective dispatch selection; an optional unavailable target preserves an explicit fallback and reason. Actual override invocation is proved by 2.4.

**Implementation**

Prepare extension and compiled target fixtures and observe missing merge/generation/enrichment RED. Snapshot the registry under lock, execute outside it, implement deterministic merge and target admission, and expose the public batch adapter. Prove GREEN without private-header dependencies; use fixture-generated C++ targets rather than adding UHT codegen.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Registration/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Recording/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Adapters/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptNativeModuleFunctionBinding*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingExtensionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingExtensionTestTypes.*
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Extensions'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.3 proving selection failed' }
```

## [ ] 2.4 Prepare once and validate executable targets before engine creation

**Outcome**

Unify new-record Validator target admission with the prerequisite's reusable shared const PreparedBindings, extending immutable recipe/mapping facts while preserving external/private SDK ownership and atomic native publication.

**Context and interfaces**

Consume complete records/HostTargets, delivered MetadataImage/PreparedBindings interfaces and SDK BindNativeFunction. Validator performs descriptor checks without throwaway images. Prepare produces one shared immutable publication and resolved request/adapter recipes; each Engine builds its own installation without rerunning providers or Prepare. SDK ID/query/VM ownership is a prerequisite, not reimplemented here.

**Cases**

- Preparation.Once: preparing once and creating two Engines observes one metadata preparation, two Engine allocations and separate sidecars; both installations succeed without mutating preparation.
- Preparation.RecipeOnly: a callable with only a text/JIT recipe fails before engine allocation; explicit interface/non-callable declarations remain valid controls.
- Preparation.TargetMismatch: incompatible executable signature or owner fails without publishing an engine; native request validation and connection share the same accepted facts.
- Preparation.Ownership: two Engines using one preparation resolve identical external type/function pointers and IDs, have distinct mutable adapter/native state, and survive peer destruction; private AS adoption still rejects a foreign Engine, and failure cleans only the unpublished owner.
- Preparation.Extensions: install task 2.3's external ExtraMethod and generated thunk fixtures and invoke them through the VM to obtain 42; a reflection-sensitive fixture observes its override result of 99 instead of the native candidate's 42.

**Implementation**

Observe missing new-record target-readiness and recipe behavior RED with delivered shared-preparation controls. Factor executable admission and adapt the new database to shared const preparation; use SDK validators rather than duplicating ABI or type-ownership decisions. Run GREEN including failure cleanup. Full concrete template completion is delivered by 3.2/3.3.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Metadata/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Diagnostics/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoValidation.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_native_bindings.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPreparationTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingExtensionTestTypes.*
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Preparation'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '2.4 proving selection failed' }
```

## [ ] 3.1 Restore owner-local adapters and property finders from records

**Outcome**

Replace recorded adapter names alone with usable factories/operation descriptors and reconstruct each owner's TypeAdapterRegistry automatically.

**Context and interfaces**

Use Adapter/TypeFinder builder methods and HostTargets, creating adapters only for the unpublished BindingInstance. Introduce the new adapter names with old-source shims; migrate all explicit database lookups used by the new path to an exact owner. Do not revive a global default engine.

**Cases**

- Adapters.Automatic: a real FVector/FName primary registers its adapter/finder; immediately after CreateForBindings the engine resolves the adapter and a compatible FProperty without manual Register calls.
- Adapters.Owners: a stateful Pair adapter in A and B has distinct storage; modifying A's state does not affect B and B survives A destruction.
- Adapters.Conversion: copying a counted nontrivial value and converting its property preserve value 42 and destroy exactly once.
- Adapters.MissingFactory: a required adapter descriptor with no factory fails before publication; no leaked temporary adapter remains.

**Implementation**

Prepare automatic reconstruction tests using real providers plus a counted fixture and observe RED; the existing isolation test's manual post-registration is only a control. Implement explicit factory invocation, ordered property finders and owner lookup, then run GREEN and destruction checks.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Adapters/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_*.h
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingAdapterTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingAdapterTestTypes.*
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Adapters'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.1 proving selection failed' }
```

## [ ] 3.2 Specialize complete template member metadata in the SDK

**Outcome**

Provide generic type-use substitution and complete concrete member/behavior metadata through SDK-owned semantics, independent of UE container operations.

**Context and interfaces**

Add an asCBindingTemplateSubstitution helper in the existing frontend binding-declaration owner and metadata APIs as needed. It accepts generic member facts plus canonical argument type uses, preserves qualifiers/defaults and produces concrete function identities before Freeze. It does not discover UObjects or implement TArray.

**Cases**

- BindingTemplates.Types: substitute T=string-like nominal in T&, const T& and nested Container<T>; concrete signatures retain qualifiers and distinct canonical identities.
- BindingTemplates.Members: a generic Add(const T&) and Num() const produce concrete function metadata and constructor/destructor behaviors owned by the instance.
- BindingTemplates.Failure: wrong arity, unresolved type parameter and illegal by-value recursion fail without frozen graph mutation.
- BindingTemplates.Identity: repeated concrete request reuses identity; differing argument types produce distinct members; cross-owner references are validated.

**Implementation**

Prepare SDK-only tests and observe missing specialization RED. Implement canonical substitution and complete member creation through protected metadata APIs; retain generic definitions as immutable recipes. Prove GREEN with actual metadata queries, frozen-definition validation and rejection atomicity.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_template_substitution.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_fingerprint.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/BindingTemplateTests.cpp
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.BindingTemplates'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.2 proving selection failed' }
```

## [ ] 3.3 Install and execute concrete UE container members

**Outcome**

Complete TArray/TMap/TSet/TOptional and supported object-wrapper member metadata and executable targets for initial and later requested instances.

**Context and interfaces**

Consume SDK specialization and owner-local adapters. TemplateInstance component builds concrete call state/native thunks before image Freeze and caches only successfully linked instances. Template operations remain implementation helpers, not the acceptance surface.

**Cases**

- TemplateCalls.Array: VM constructs TArray<FString>, adds 'hello' and 'world', observes Num=2 and index 1='world', then destroys values exactly once.
- TemplateCalls.Containers: map key 7 maps to 42; set adding 7 twice has one member; optional Set(42)/Reset toggles presence, all through VM-callable members.
- TemplateCalls.Nested: nested arrays preserve inner values and lifetimes; repeated same-owner requests reuse the type, two owners do not share mutable call state.
- TemplateCalls.Failure: unsupported element lifetime or missing concrete target publishes neither partial image nor cache entry; an already installed array remains callable.

**Implementation**

Add actual installed-function/context or source-execution fixtures and observe the missing-callable-member RED. Wire generic metadata to UE container operation state and native thunks; complete additional images before publication. Run GREEN; direct Operations calls may remain narrow controls only.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/Templates/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Metadata/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTemplateCallTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTemplateTestTypes.*
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingFullRuntimeTests.cpp
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.TemplateCalls'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.3 proving selection failed' }
```

## [ ] 3.4 Bind delegate subscriptions to explicit host storage lifetimes

**Outcome**

Replace ungoverned raw delegate addresses with storage scopes and subscription tokens, including generation-safe single delegate replacement and exact multicast cleanup.

**Context and interfaces**

Implement FAngelscriptDelegateStorageScope and FAngelscriptDelegateSubscriptionToken as defined in design section 7. Native scopes expire before storage; UObject-property scopes use weak valid locators. Existing raw-reference runtime APIs are migrated, not kept as unsafe permanent overloads.

**Cases**

- DelegateStorage.StackFirst: native delegate and storage scope expire before engine destruction; no later storage access occurs.
- DelegateStorage.Rebind: B replaces A in one storage scope, including same receiver/function names; destroying A/token cannot clear B's callable binding.
- DelegateStorage.Multicast: remove only the owned listener while a host listener still fires; indistinguishable duplicate owned entries reject.
- DelegateStorage.HostDeath: invalid UObject property storage is not dereferenced; repeated unsubscribe is idempotent and releases target ownership once.

**Implementation**

Create real native storage/UObject fixtures and observe missing scope/token/generation RED using lifecycle counters and explicit access probes. Implement scoped validity and exact subscription cleanup, migrate current delegate tests/callers, and run GREEN. Do not add delegate language syntax or broader Blueprint publication.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/Delegates/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates*
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDelegateStorageTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDelegateTestTypes.*
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDelegatesTests.cpp
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.DelegateStorage'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.4 proving selection failed' }
```

## [ ] 3.5 Retain payload execution state across reentrant callbacks

**Outcome**

Keep admitted payload calls valid through self-unbind, container relocation and nested calls; unregister visibility without destroying an active call's payload/frame.

**Context and interfaces**

Use a copied strong execution lease and an RAII parameter frame. Unbind removes lookup membership instead of resetting payload storage retained by an active lease. Keep the surrounding exact-engine execution lifetime contract.

**Cases**

- PayloadReentry.SelfRemove: callback observes payload 7, unregisters itself and returns; a later call is unbound and counters show one final payload release.
- PayloadReentry.Grow: callback adds enough entries to relocate storage; return cleanup still destroys the correct parameter once.
- PayloadReentry.RemoveEarlier: remove an earlier entry then invoke another payload recursively; outer/inner values remain 7/42 with independent cleanup.
- PayloadReentry.Fault: invalid handle and rejected target do not initialize leaked frames; supported callback failure cleans admitted frame state.

**Implementation**

Prepare real ProcessEvent reentry fixtures and observe the current invalidation/lifetime RED. Copy stable state before host entry, move parameter cleanup into the owned frame and defer active payload destruction. Run GREEN with exact values and release counts, not an array-capacity assertion.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/Delegates/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPayloadReentryTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingDelegateTestTypes.*
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.PayloadReentry'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '3.5 proving selection failed' }
```

## [ ] 4.1 Record eligible providers in isolated parallel fragments

**Outcome**

Implement usable Serial/Parallel capture with immutable UE inputs, task-local record ownership and deterministic joins; initial default stays Serial.

**Context and interfaces**

SnapshotOnly callbacks use only the prepared context. GameThread callbacks remain pinned. Registry snapshots and per-provider fragments are owned until join; diagnostics and targets merge using stable identities, never completion order.

**Cases**

- ParallelRecording.Match: shuffle 64 independent providers and compare canonical database/dump with Serial; each callback runs exactly once.
- ParallelRecording.Threads: SnapshotOnly callbacks execute through workers when capacity exists; a UE-dependent callback always observes IsInGameThread=true.
- ParallelRecording.Failures: two independent bad providers report the same source-sorted diagnostics in repeated runs; no partial database is returned.
- ParallelRecording.Registration: adding a lambda during capture affects the next generation only; worker outputs cannot mutate sealed prior data.

**Implementation**

Prepare deterministic output and actual thread/ownership probes and observe RED for the missing parallel mode. Dispatch bounded task-local jobs, propagate metrics scopes and join before merge/retained-input release. Run GREEN under 1/2/4 workers where available; performance benefit is measured by 6.3.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Recording/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Registration/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Diagnostics/**
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingParallelRecordingTests.cpp
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.ParallelRecording'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.1 proving selection failed' }
```

## [ ] 4.2 Prepare detached metadata with explicit parallel barriers

**Outcome**

Implement optional concurrent type/member preparation while retaining SDK ownership locks and final transaction boundaries.

**Context and interfaces**

Use the SDK factories and thread-safe canonical context. Publish immutable nominal lookup at a barrier, give one task each type's ordered members, avoid reading mutable draft views, and join before layout finalization/Freeze. Do not split mutually dependent graphs into unsupported frozen per-type images.

**Cases**

- ParallelMetadata.Match: shuffled independent types and signatures produce equal semantic identities/layouts/calls in both modes.
- ParallelMetadata.Graph: mutually referring handles succeed; by-value cycles fail identically; templates and global namespaces retain valid ownership.
- ParallelMetadata.Publish: no engine sees incomplete worker output and a failed worker prevents publication.
- ParallelMetadata.Contention: report worker/preparation/wait measurements; correctness does not imply lock-free insertion or guaranteed speedup.

**Implementation**

Observe missing parallel preparation RED through actual worker activity and deterministic metadata oracles. Add task-local parsing/preparation and protected insertion barriers, then run GREEN including failure/cancellation cleanup of owned jobs. Keep Serial default and leave lock redesign outside scope absent invalidating evidence.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Metadata/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/Templates/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Diagnostics/**
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.*
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.*
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingParallelMetadataTests.cpp
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.ParallelMetadata'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '4.2 proving selection failed' }
```

## [ ] 5.1 Migrate complete Core value and global providers

**Outcome**

Migrate the Core slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- CoreMigration.NameString: adapt RuntimeBindingStringNameTests.cpp / CopyThenAppendProducesAbcdWithoutChangingOriginal and FNameEqualityAndStringRoundTrip. Invoke the installed FString copy/Append path with original 'ab' and suffix 'cd': copy is 'abcd', original remains 'ab'; construct FName('RuntimeBindingName'), equality with the same name is true and GetPlainNameString returns that exact string. Automatic adapter and ToString acceptance from 3.1 remains required.
- CoreMigration.TextTime: retain text/format-argument signatures from the 1.1 oracle. Adapt RuntimeBindingTimeIdentityTests.cpp / OneSecondTimespanUsesExactTicks, DateComponentsRoundTrip and GuidValidityAndFixedParseRoundTrip: one second is 10,000,000 ticks; (2024,2,29,12,34,56,789) preserves each date/time component; GUID '00112233-4455-6677-8899-AABBCCDDEEFF' roundtrips ignoring letter case, while the default GUID is invalid. These existing time/identity assertions are native-host controls; add installed calls for eligible recorded members to the new migration class rather than claiming the old controls prove VM execution.
- CoreMigration.Complete: one primary per migrated type records lifecycle/members/effects; all Core inventory sites map to a primary/supplement/exclusion with no phase prepass for these types.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ConfigEnums.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CoreGlobals.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FDateTime.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFormatArgumentValue.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFrameTime.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGuid.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FName.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FNumberFormattingOptions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FString.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FStringTableRegistry.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FText.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTimespan.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Hash.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Core/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationCoreTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-core.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.Core'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.1 proving selection failed' }
```

## [ ] 5.2 Migrate complete Math providers

**Outcome**

Migrate the Math slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- MathMigration.Vector: adapt RuntimeBindingVectorsTests.cpp / DoubleVectorSizeSquaredUsesLiteralComponents and DoubleVectorAdditionReturnsFiveSevenNine. Installed calls on FVector(3,4,0) give SizeSquared=25 (length=5), and (1,2,3)+(4,5,6) gives (5,7,9); a property/method roundtrip preserves all components. Preserve the float/double width/layout expectations in FloatAndDoubleVariantsRetainWidthLayoutAndProperties.
- MathMigration.Transform: use RuntimeBindingRotationsTests.cpp / IdentityTransformPreservesLiteralPosition as an inspected host-control oracle: identity transform leaves (1,2,3) unchanged. Exercise the eligible installed transform/quaternion members in the new migration fixture; keep box/sphere expectations from the 1.1 oracle, not aggregate counts.
- MathMigration.Complete: all Math inventory sites and independent expected members are accounted for; primary callback count per type is one.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAnchors.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox2D.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBox3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBoxSphereBounds3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FColor.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGeometry.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntPoint.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector2.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FIntVector4.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLinearColor.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMargin.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMatrix.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlane4f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FQuat4f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRandomStream.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRange.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FRotator3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FSphere3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FTransform3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector3f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector4f.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Math/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationMathTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-math.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.Math'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.2 proving selection failed' }
```

## [ ] 5.3 Migrate complete container providers

**Outcome**

Migrate the Containers slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- ContainerMigration.Array: replay 3.3's installed TArray<FString> construction/Add/Num/index case with 'hello' and 'world': Num=2, index 1='world', and exactly-once element destruction. RuntimeBindingArrayTests.cpp / StringCopyIsIndependent supplies an operations-control pattern, not VM proof.
- ContainerMigration.Other: replay 3.3 through installed members: map key 7 has value 42; inserting set value 7 twice leaves Num=1; optional Set(42) is engaged and Reset clears it. A copied nested array retains its inner 'hello' value after the source is cleared. Adapt RuntimeBindingMapTests.cpp / MissingKeyLeavesOutputUnchanged as a negative-control oracle and RuntimeBindingOptionalTests.cpp / ResetDestroysOneCountedElement for exact lifetime accounting; preserve the 1.1 oracle's eligible iterator signatures and add VM iteration yielding each inserted element once.
- ContainerMigration.Complete: template lifecycle, adapters, finders and native members come from one primary per template; all inventory phase fragments have dispositions.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TArray.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TMap.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TOptional.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSet.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Containers/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationContainersTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-containers.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.Containers'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.3 proving selection failed' }
```

## [ ] 5.4 Migrate object wrappers and reflection generators

**Outcome**

Migrate the ObjectsReflection slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- ObjectMigration.Reflection: adapt RuntimeBindingObjectsTests.cpp / ParentAndChildPropertiesAccessOnlyTheirObject, EnumPropertyRoundTripsUnderlyingValue and TypeFromDifferentOwnerIsRejected. ParentValue=11 and ChildValue=13 roundtrip independently, enum Mode=1 returns 1, and a foreign owner's type fails with a different-binding-owner diagnostic. Retain the planned reflected return/out-parameter fixture returning 42; its call must execute through the installed bridge, not a declaration count.
- ObjectMigration.Wrappers: use RuntimeBindingObjectsTests.cpp / NativeStructCopyOwnsIndependentStringStorage: copy 'initial', change the source to 'changed', and retain 'initial' in the copy with both values destroyed once. Adapt RuntimeBindingPointersTests.cpp / CorrectSubclassAssignmentSucceedsAndUnrelatedClassIsRejected: URuntimeBindingMixinTarget succeeds, URuntimeBindingStaticPublication fails with a subclass diagnostic and leaves the prior value unchanged. Pointer Operations are controls; preserve eligible installed weak/soft/subclass behavior from 3.3 and the 1.1 oracle.
- ObjectMigration.Generators: loaded-reflection snapshot is captured once; explicit primary beats fallback reflection and supplements retain provenance.
- ObjectMigration.Complete: delegate storage/payload repairs survive provider migration; all ObjectsReflection inventory sites are covered.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintEvent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptDelegateWithPayload.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FAngelscriptGameThreadScopeWorldContext.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInstancedStruct.cpp
+Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionPublicationMixins.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SoftObjectPath.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_TSoftObjectPtr.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnum.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UObject.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPackage.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Objects/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Core/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationObjectsReflectionTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-objectsreflection.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.ObjectsReflection'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.4 proving selection failed' }
```

## [ ] 5.5 Migrate gameplay, collision and input API providers

**Outcome**

Migrate the EngineGameplay slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- GameplayMigration.Actor: adapt RuntimeBindingActorsTests.cpp / TransientActorAndSceneComponentPreserveTranslation and CurrentWorldUsesExplicitAmbientFixture. Spawn a transient actor with a registered root scene component; the installed SetRelativeLocation call with (11,22,33) finishes successfully and yields exactly that location. Within FAngelscriptEngineScope for the fixture world, installed GetCurrentWorld returns that same world. ComponentHasTag(NAME_None) on the unregistered component remains false.
- GameplayMigration.Collision: adapt RuntimeBindingCollisionTests.cpp / SphereShapeRadiusTwoRoundTrips, HitAndOverlapPropertiesMatchFixtureValues, EmptyTransientWorldQueryReturnsNoHit and NullWorldContextProducesExplicitDiagnostic. VM SetSphere(2)/GetSphereRadius returns 2; recorded offsets read Hit.Distance=12.5, Hit.Item=17 and Overlap.ItemIndex=23. A visibility query in the empty transient world from (0,0,0) to (100,0,0) returns no hit; null world fails with a world diagnostic and Hit=false. The current query helper calls UWorld through the installation and is a bridge control, not VM evidence. Move the specific convenience path to Registry/Engine and exercise the recorded callable/ref-out boundary in the new fixture while preserving those literal outcomes.
- GameplayMigration.Input: adapt RuntimeBindingInputUITests.cpp / AxisTwoValuePreservesComponentsAndType, ActionMappingCopyPreservesKeyAndModifiers, RemoveBindingByHandleAffectsExactlyOneBinding and TransientWidgetRootLookupPreservesVisibility. Installed calls return Axis2D=(1,2); copied Jump/SpaceBar mapping compares equal with Shift/Alt=true and Ctrl/Cmd=false; removing A from two action bindings leaves only B; setting/getting the transient widget root returns the identical root with Collapsed visibility. Restore modified CDO widget state in fixture cleanup and retain target exclusions from the independent oracle.
- GameplayMigration.Complete: every EngineGameplay source site maps to a complete migrated contribution, independent member expectations and explicit policy dispositions.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Engine/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCollisionTests.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationEngineGameplayTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-enginegameplay.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

The additional Runtime.Collision selector below is adjacent regression proof for the changed existing control callers; both selections use the same frozen source/binary.

Core/AngelscriptTypeBindInfoApply and Framework/Runtime edits are limited to removing/moving InvokeCollisionLineTraceTestByChannel and its necessary call wiring, using the location produced by prerequisite moves. RuntimeBindingCollisionTests.cpp is owned only for adapting its existing bridge-control callers to that move. Do not rewrite unrelated framework or legacy fixture behavior. The installed query proof uses the recorded System::LineTraceTestByChannel / LineTraceSingleByChannel targets, not a direct UWorld call relabeled as VM coverage.

**Verification**

```powershell
foreach ($prefix in @('Angelscript.UnitTest.RuntimeBindings.Migration.EngineGameplay', 'Angelscript.UnitTest.RuntimeBindings.Runtime.Collision')) {
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = $prefix; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw "5.5 proving selection failed: $prefix" }
}
```

## [ ] 5.6 Migrate remaining Runtime service providers

**Outcome**

Migrate the EngineServices slice in provider-migration.csv completely, including companion headers and _Type/_Functions files, while preserving its independently expected binding surface.

**Context and interfaces**

Consume the new framework, complete container/native/adapter paths and prior family proof. Fold phase fragments into one primary per type and keep intentional cross-type/module supplements explicit. The attached task column is the exact source ownership boundary; source lists below include the registration owners and companion globs are limited to those owners. Reflection generators finish in Registry/Core; non-provider code in Core/Testing remains in its original owning subsystem.

**Cases**

- ServiceMigration.Serialization: retain the planned JSON value-42 roundtrip and adapt RuntimeBindingSerializationTests.cpp / JsonLiteralParsesAndExposesFields and MemoryReaderReadsKnownSequenceAndRejectsOverrun. Installed JSON parsing of {"Count":7,"Name":"a"} exposes 7 and 'a'; bytes [0x2a,0x78,0x56,0x34,0x12] read as 42 then 0x12345678, and Skip(1) at the end raises the execution exception with position still 5. Keep malformed JSON rejection as a control.
- ServiceMigration.Platform: adapt RuntimeBindingPlatformTests.cpp / ParseFindsKnownInteger and PathsCombineAndNormalizeKnownComponents. Installed FParse.Value on 'Name=fixture Count=7' with 'Count=' succeeds and writes 7; combining 'alpha/beta' and '../gamma/file.txt', then collapsing, produces the normalized suffix 'alpha/gamma/file.txt'. Keep diagnostic/configured-native-map controls from the 1.1 oracle; do not spawn processes or mutate global command-line/platform state to measure migration.
- ServiceMigration.Finalization: adapt RuntimeBindingFinalizationTests.cpp / EveryToStringContributionIsRecordedAndOwnerLocal and FinalizationFailureNamesProviderAndPublishesNoOwner, preserving their exact owner isolation and failure oracles. Logging/console/stat/test-helper skip and ToString effects must match the captured target policy; a rejected required effect names its provider and publishes no owner.
- ServiceMigration.Complete: all EngineServices sites including Core/Testing-owned registrations are accounted for; no unexplained Runtime registration remains.

**Implementation**

Prepare the family migration cases and independent symbol expectations before folding callbacks; observe missing single-primary/complete-record behavior RED while existing call outputs serve as controls. Move providers and adjacent type-specific adapters, update includes/forced links and generated wrappers, and run the family GREEN. Record site-to-final-provider mapping, explicit exclusions and any retained legacy-only shim.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetBundleData.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetManagerScriptMixins.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AssetRegistry.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Debugging.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Deprecations.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FApp.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCommandLine.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCpuProfilerTraceScoped.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FFileHelper.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FGenericPlatformMisc.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMemoryReader.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMessageDialog.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FParse.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPaths.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformApplicationMisc.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformMisc.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FPlatformProcess.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Json.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_JsonObjectConverter.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Logging.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_NativeModuleFunctionBinding.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Stats.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Subsystems.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_SystemTimers.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UAssetManager.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UDataTable.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSkipBinds.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTest.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Testing/AngelscriptTestSuite.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Engine/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationEngineServicesTests.cpp
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-engineservices.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.EngineServices'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '5.6 proving selection failed' }
```

## [ ] 6.1 Remove new-path phase bridges and complete inspection compatibility

**Outcome**

Finish the new path's ownership/name migration, retire declaration-prepass and phase-execution bridges, and expose complete transport/adapter/metrics classifications in inspection.

**Context and interfaces**

Consume the complete provider ledger and framework. Retain only documented dormant compatibility headers/APIs; public callers use Public/Bindings. Upgrade the diagnostic manifest to schema version 2 with explicit reader rejection for unsupported versions; do not treat an old manifest as an executable database or silently ignore changed fields.

**Cases**

- MigrationFinal.NoReplay: full capture invokes one primary per type with zero declaration-prepass or installation provider callbacks.
- MigrationFinal.Public: an external module extension compiles against supported headers; no active new-path include points into Private/Bindings.
- InspectionV2.Transport: dump distinguishes NativeDirect/NativeThunk/UFunction/MetadataOnly and origin/selected-reason fields without pointers.
- InspectionV2.Determinism: equivalent parallel/serial dumps compare equal; incompatible schema fails explicitly; expected missing symbol fails even if counts match.

**Implementation**

Add final contract and manifest fixture RED, remove now-unused new-path bridges, complete responsibility moves and update the Python validator/diff fixtures for schema 2. Prove GREEN and independently run the stdlib inspection suite. Update compatibility ledger with final consumers and no supported old-runtime fallback.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/**
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBind*
 Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfo*
 Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationFinalTests.cpp
 Plugins/Angelscript/Tools/BindingInspection/**
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/compatibility-ledger.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
$result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.MigrationFinal'; Fast = $true; TimeoutMs = 600000 }
if ($result.exitCode -ne 0) { throw '6.1 proving selection failed' }
python -m unittest discover -s Plugins/Angelscript/Tools/BindingInspection/tests -p "test_*.py"
if ($LASTEXITCODE -ne 0) { throw 'Inspection fixture verification failed' }
```

## [ ] 6.2 Prove full Runtime execution and affected SDK regressions

**Outcome**

Establish final functional proof for every migrated Runtime family, new repair and affected SDK ownership/metadata contract on one frozen source/binary snapshot.

**Context and interfaces**

Use all task-specific case identities and independent expected surface. Full RuntimeBindings and NativeEngine coverage is justified by changes to shared record, parser/template, metadata and native publication contracts. Do not substitute archived counts or a build-only success.

**Cases**

- FullRuntime: provider/source/member reconciliation passes with actual VM value/container/global/adapter calls, including external target selection.
- OwnersAndFailure: reuse one database for two engines, destroy either owner, reject invalid targets/templates/graphs without partial publication and retain deterministic diagnostics.
- Lifetime: native storage-before-engine, rebind, multicast preservation and payload reentry all execute with exact release counters.
- SDK: complete NativeEngine suite retains detached metadata, frozen image ownership, template identity, native ABI/publication and existing VM behavior; dormant startup stays disabled.

**Implementation**

Build from frozen source after 6.3, execute the exact task selectors through the full RuntimeBindings run, affected SDK aggregate and existing Angelscript.UnitTest.Baseline controls, and reconcile discovered/executed case identities. The benchmark prefix is separate, so this functional aggregate needs no tracing options. Diagnose adjacent failures inside the affected owner; retain final source/binary and report hashes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/**
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/**
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/verification-functional.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
foreach ($prefix in @('Angelscript.UnitTest.RuntimeBindings.', 'Angelscript.UnitTest.NativeEngine.', 'Angelscript.UnitTest.Baseline.')) {
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = $prefix; Fast = $true; TimeoutMs = 1800000 }
    if ($result.exitCode -ne 0) { throw "Functional verification failed: $prefix" }
}
```

## [ ] 6.3 Capture validated performance and memory comparisons

**Outcome**

Produce a final baseline/final and Serial/Parallel comparison with actual CPU/counter and Memory Insights evidence. Observation itself must not change ownership or functional outcomes.

**Context and interfaces**

Consume metrics contract and task 1.1/1.2 baseline. RuntimeBindingPerformanceTests.cpp implements design section 9: small/full/reuse/template workloads, three warmups, ten measured iterations, both mode orders and supported 1/2/4 worker limits. The separate Angelscript.UnitTest.BindingPerformance selection runs all matrix scenarios; labeled fresh invocations provide the two process orders. Implement ASBindingBenchmarkOrder parsing in the test fixture, defaulting to SerialFirst, and reject unknown values. Baseline/final common-work projections are independent of manifest version; newly executable template cases are labeled final-only. Task 6.2 runs final functional/SDK verification after this task's last source changes.

**Cases**

- Performance.Equivalence: each timed sample validates semantic digest, expected native outputs and exact work counts; incorrect/missing samples fail the report.
- Performance.Memory: shared database counts once, per-engine deltas are separate and release returns measured owned resources to baseline; capacity/coverage are explicit.
- Performance.Trace: a real .utrace contains binding phase/counters and a distinctive worker allocation/free with correct tag and no duplicate allocation events.
- Performance.Overhead: disabled/basic/detailed observation runs are compared independently; report contention and regressions without an invented speed target or automatic default change.

**Implementation**

Add measurement/report validation cases, observe RED for missing required output/coverage, then implement bounded benchmark orchestration and output checks. Capture both mode orders in fresh Harness-managed runs. Inspect each completed trace in Unreal Insights: filter Timing by the fixed Record/Install scope names and capture identity, inspect its worker span and counters, then query the corresponding Memory interval for the distinctive allocation's tag, allocation/free pair and live-byte delta. Retain the query interval, event/category names and observed results in the comparison; file existence or process success alone does not prove trace contents. Run GREEN, retain raw ignored CSV/JSON/trace paths and hashes, and publish omitted/unavailable metrics explicitly.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Diagnostics/**
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingPerformanceTests.cpp
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/performance-comparison.md
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/performance-summary.json
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
```

**Verification**

```powershell
foreach ($order in @('SerialFirst', 'ParallelFirst')) {
    $tracePath = Join-Path $context.WorkspaceRoot ("Saved/BindingPerformance-{0}-{1}.utrace" -f $order, [guid]::NewGuid().ToString('N'))
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.BindingPerformance'; Fast = $true; TimeoutMs = 1800000; Label = $order; ExtraArguments = @("-ASBindingBenchmarkOrder=$order", '-trace=default,cpu,counters,memory', "-tracefile=$tracePath") }
    if ($result.exitCode -ne 0) { throw "Performance verification failed: $order" }
}
```

## [ ] 6.4 Reconcile completion evidence and durable specification handoff

**Outcome**

Complete the requirement-to-case/source mapping and final verification record after all product tasks pass; synchronize durable specs through the proper lifecycle before later archive.

**Context and interfaces**

Consume functional/performance evidence, provider migration dispositions, final compatibility ledger and all delta specs. Use openspec-sync-specs for the semantic merge and CLI-owned creation of missing extensions/observability spec manifests. This task does not start a Review, activate legacy services or claim another Change's work is complete.

The inspected current angelscript/bindings/runtime spec has six preserved Scenario Cards with two-space quote blocks: Call native members through the current VM; Dump sealed binding declarations; Validate and compare dumps offline; Seal namespace globals and retain snapshot lifetime; Reconcile all eligible providers and expected members; Revalidate without changing a sealed snapshot. The current strict validator rejects these blocks, and this delta does not replace them. The accepted planning correction explicitly scopes a formatting-only repair of these six blocks during this task: use four-space clause ownership and blank-line separation, retaining every word and the existing Requirement/Scenario parentage. Revalidate the actual baseline before merging; additional failures require classification and matching scope, not silent all-record migration.

**Cases**

- Every proposal/spec acceptance condition has executed evidence from a current binary; all source sites and retained compatibility consumers have final dispositions.
- Current specs preserve every unchanged Scenario Card while merging these deltas, except the six explicitly listed ownership-format corrections whose text and parentage remain unchanged. No temporary Task state or benchmark transcript becomes durable behavior.
- Strict validation passes for the Change and exactly four affected current capabilities: bindings/runtime, runtime/binding-engine, bindings/extensions and bindings/observability under angelscript. A passing delta or an unrelated baseline failure does not excuse a failing affected target.
- Future closure remains explicit: all tasks checked only with evidence, any actually requested Review handled under its own lifecycle, and archive performed only after completion verification.

**Implementation**

1. Reconcile the existing exact functional/performance proofs and retain their task/case and source/binary mapping without unnecessary reruns. Record omitted heavier checks with reasons.
2. Validate the existing affected current targets, record baseline diagnostics, and apply only the named formatting corrections while preserving text/parentage. Create missing capability manifests through Harness OpenSpec routes, then merge the complete delta cards without overwriting unspecified scenarios.
3. Run the exact Change and four-capability validation below and verify retained-card preservation separately. Record the actual results in final-verification.md and INDEX. No UE build or Automation is required for this document-only step. Only then complete this node; use normal verify/archive skills for later closure.

**Files**

```diff
+openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/final-verification.md
 openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md
 openspec/specs/angelscript/bindings/runtime/spec.md
 openspec/specs/angelscript/runtime/binding-engine/spec.md
 openspec/specs/angelscript/bindings/extensions/**
 openspec/specs/angelscript/bindings/observability/**
```

**Verification**

```powershell
foreach ($record in @(@('angelscript/refactor-bindings-two-stage-pipeline','change'), @('angelscript/bindings/runtime','spec'), @('angelscript/runtime/binding-engine','spec'), @('angelscript/bindings/extensions','spec'), @('angelscript/bindings/observability','spec'))) {
    $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @($record[0], '--type', $record[1], '--strict', '--json')
    if ($result.exitCode -ne 0) { throw "Record validation failed: $($record[0])" }
}
```
