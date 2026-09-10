# Independent before-guidance consumer output

Preserved proposed cards from the isolated consumer exercise. This fenced artifact is evidence, not an active Task DAG or permission to execute its commands. Line endings are normalized for the repository; the consumer text is otherwise retained.

````markdown
# Proposed replacement cards

Planning-only proposal. Keep the existing graph unchanged: `"5.5": ["5.4"]` and `"6.4": ["6.2"]`. Both tasks remain unchecked. The shared workspace, build, evidence and exact-binary rules in the original tasks.md continue to apply. No product execution or verification result is asserted here.

## Task 5.5

- [ ] 5.5 Migrate gameplay, collision and input API providers

    **Outcome**

    Migrate exactly the EngineGameplay registrations assigned to 5.5 in provider-migration.csv into Registry/Engine, preserving their callable surface, concrete UE effects, target conditions and native value lifetimes. Each built-in type has one complete primary description; legitimate reflected/generated supplements retain separate provenance. World/collision convenience behavior belongs to the concrete provider, not the generic installation framework. This does not activate automatic runtime services or migrate the EngineServices family owned by 5.6.

    **Context and interfaces**

    The attached inventory presently contains 52 lexical source rows for 5.5. Rows identify source sites, not 52 eligible providers or types. Consume 1.1's independently authored expectations and the completed 5.4 framework handoff. Design sections 2–4 and 8 define the accepted boundary: `FAngelscriptBindingRegistration` takes a callback `void(FAngelscriptBindingContext&)`; `FAngelscriptBindingRecorder::Capture` produces a sealed `TSharedPtr<const FAngelscriptBindingDatabase>`; `FAngelscriptBindingInstaller::Prepare` creates a move-only prepared result; `FAngelscriptEngine::CreateForBindings` remains the explicitly owned engine facade. These are prerequisite-produced interfaces, not declarations claimed to exist in this planning snapshot. Use their completed signatures when implementing this task.

    The current tests provide reusable behavioral examples, not a shared gameplay fixture API. `RuntimeBindingActorsTests.cpp`, `RuntimeBindingCollisionTests.cpp` and `RuntimeBindingInputUITests.cpp` define translation-unit-local fixtures that currently call `RecordInstallableTypeDeclarations`, `RecordSelectedProviders`, `Store->Seal` and `CreateForBindings`. Their prepass setup cannot prove the replacement capture path. Add a new fixture in RuntimeBindingMigrationEngineGameplayTests.cpp that captures the new database, installs it and looks up installed functions by owner, namespace and complete declaration; use the public/prerequisite inspection interface rather than carrying the old catalog path into the new test.

    Concrete existing controls include `USceneComponent::SetRelativeLocation`, `UActorComponent::ComponentHasTag`, the global `UWorld GetCurrentWorld()`, `FCollisionShape::SetSphere/GetSphereRadius`, `FInputActionValue::GetAxis2D`, mapping `opEquals`, enhanced-input `RemoveBindingByHandle`, and `UUserWidget::SetRootWidget/GetRootWidget`. Invoke these through installed `asIScriptContext` calls. Check Prepare/argument setup and `asEXECUTION_FINISHED`, not just the returned value. Keep context, native parameter storage, world, component and widget references alive through execution; release contexts before their engine. Destroy created worlds and their world contexts; restore any temporarily replaced widget-tree state even on assertion failure.

    Existing collision world tests call `FAngelscriptTypeBindInfoInstallation::InvokeCollisionLineTraceTestByChannel(UWorld*, ...)`. Its implementation checks a recorded member and directly calls `UWorld::LineTraceTestByChannel`; it is not evidence that the recorded global is invocable. The provider already declares `System::LineTraceTestByChannel` and `System::LineTraceSingleByChannel(FHitResult& OutHit, ...)`. Exercise those installed targets with an explicit `FAngelscriptEngineScope` world context. Generic framework machinery may pass the context and arguments, but may not own a special World query implementation. Preserve the established null-world failure: no query, false hit result and a diagnostic identifying world context.

    **Cases**

    All cases below must be exposed under `Angelscript.UnitTest.RuntimeBindings.Migration.EngineGameplay`. The listed suffixes name tests to add, not tests already registered in this snapshot. Prepare the group before migrating providers. Existing behavior controls are not expected to become artificially red; the complete-primary and new-path execution assertions establish missing-behavior RED.

    | Case suffix | Concrete setup/action | Independent result and role |
    | --- | --- | --- |
    | ActorTranslation | Spawn a transient actor, attach/register a root scene component, invoke `void SetRelativeLocation(const FVector& NewLocation)` with `(11,22,33)` | Component location is exactly `(11,22,33)`, owner remains that actor, and the actor belongs to the fixture world. Existing behavior control through the new path. |
    | ActorWorldAndNoneTag | Call `UWorld GetCurrentWorld()` inside the fixture engine/world scope; call `bool ComponentHasTag(const FName& Tag) const` on an unregistered component with NAME_None | Returned world is the exact fixture pointer; tag result is false. Ambient scope ends with the fixture. Existing normal/negative controls. |
    | CollisionValueLayout | Call `SetSphere(2.0f)` and `GetSphereRadius()`; inspect bound offsets for Hit.Distance=12.5f, Hit.Item=17 and Overlap.ItemIndex=23 | VM radius is 2.0f; property reads give 12.5f, 17 and 23. Existing value/layout controls; host-only construction is not labeled VM constructor proof. |
    | CollisionQueryCopy | Copy query parameters containing ignored actor A, then add B only to the original | Original has two ignored entries, copy has one containing A. Carry the existing copy/lifetime control through the recorded lifecycle path; copied storage survives destruction of the original. |
    | CollisionWorldCalls | In an empty transient world, invoke installed System line-test and line-single targets from `(0,0,0)` to `(100,0,0)` on ECC_Visibility with default query/response parameters | Both return false; line-single writes OutHit.bBlockingHit=false and OutHit.Time=1.0. Initialize OutHit with bBlockingHit=true and Time=0.25 beforehand so unchanged out storage fails. This is a new bound-call/out-parameter proof, not a wrapper-call control. |
    | CollisionMissingWorld | Invoke the same query without a valid world scope | No UWorld query executes; hit result is false and failure identifies world context. Preserve that result through the provider call path; do not require an invented public error-code API. |
    | InputValueAndMapping | Invoke `FVector2D GetAxis2D() const` on `(1,2)`; compare a copied Jump/SpaceBar mapping with Shift=true, Ctrl=false, Alt=true, Cmd=false | Result is `(1,2)` with Axis2D identity; mapping equality is true and all four modifier values and the key remain exact. Existing controls. |
    | InputRemoval | Bind two action values A and B, invoke `bool RemoveBindingByHandle(const uint32 BindingIndex)` for A's handle | Returns true; exactly one entry remains, referring to B. Existing observable ownership control. |
    | WidgetRoot | Install a temporary widget tree, set a named Border root with Collapsed visibility through the bound setter, then call the bound getter | Getter returns that exact root and its visibility remains Collapsed. Restore the previous tree on every exit. Existing control. |
    | CompletePrimary | Capture the migrated family once, then create two engines from that database | Each primary callback runs once in capture, zero times in either install; the family uses zero declaration-prepass executions. Lifecycle, methods/properties and applicable adapter/finder/ToString records are complete before installation. Record this as new RED/GREEN behavior. |
    | CompleteInventory | Compare the 5.5 site mapping with independent expected type/member/target/effect identities and effective target policy | Every row has a final provider/contribution or evidenced compile-time/policy/test-only/no-output disposition. No eligible expected symbol is missing and no primary duplicates another. An eligible missing-member variant fails even if a replacement member keeps aggregate counts equal. An ineligible target-specific declaration is absent with its actual condition recorded. |

    Do not infer current compile-time exclusions by changing runtime flags. Use the source condition and selected build policy to establish which branch is eligible; only runtime-selectable policy exclusions can be exercised within this one binary. Retain the distinction in the migration evidence.

    **Implementation**

    1. Reconcile the 52 source rows against 1.1's expectations and the current build policy. List each old site, final provider identity, primary/extension role, expected semantic members/effects and exclusion basis. Preserve hashes/source provenance. Do not generate the expected member set from the migrated output under test.
    2. Construct the new fixture and all cases above. Reuse inspected setup patterns and literal values; extract narrowly shared support only where needed. Build and observe the complete group: identify missing complete-primary/prepass-free capture and genuine missing bound-call behavior separately from passing existing controls. Missing prerequisite APIs or a newly discovered incompatible handoff are not invented successes.
    3. Fold each type's declaration/infrastructure/member fragments into its primary callback, including lifecycle, type-specific adapter/finder and ToString work where applicable. Keep independent supplements and global services explicit. Move the providers and their actual companion files to Registry/Engine, migrate World query convenience behavior out of Framework, and update includes, generated wrapper inputs and forced links. Use immutable captured inputs for SnapshotOnly providers; live UE work remains GameThread-bound.
    4. Build the final source with writers frozen, then run the same selector for GREEN. Verify both recorded semantic coverage and installed execution. Diagnose ordinary failures here; change pending planning only if evidence invalidates the accepted interface, scope or proof.
    5. Record the case-level results, source/binary identity, inventory dispositions and retained compatibility consumers in migration-enginegameplay.md and index it. Existing actor/collision/input tests that share edited support receive adjacent regression coverage if that change can affect them; document the actual selection. Full Runtime closure remains 6.1, and performance remains 6.3.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Engine/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationEngineGameplayTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-enginegameplay.md`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md`

    Binds globs are bounded to the source owners assigned 5.5 and their actual companion headers and _Type/_Functions files; they exclude other migration families. Registry/Engine edits are likewise limited to EngineGameplay. Framework/Runtime and old Apply paths permit only migration/removal of the inspected World-specific helper and necessary call-site wiring, respecting whichever location prerequisite moves produced. Public headers permit only corresponding interface wiring. Read the existing family tests as context; this card does not authorize unrelated fixture rewrites.

    **Verification**

    From the selected workspace in PowerShell 7, use the original shared Harness import/context setup. After any C++/header/Build.cs changes, first complete the required `ue.build` against frozen sources; this selector consumes that exact binary. The following is the task's proving command:

    ```powershell
    $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.RuntimeBindings.Migration.EngineGameplay'; Fast = $true; TimeoutMs = 600000 }
    if ($result.exitCode -ne 0) { throw '5.5 proving selection failed' }
    ```

    Completion requires every named case above to be discovered, executed and passed in the enforced report, no unexplained inventory row/member, and the recorded ownership/migration checks. A zero-case report, direct host query masquerading as installed execution, counts-only reconciliation, stale binary or missing report fails acceptance. A justified shared run may provide the proof only with this task's exact case mapping and binary identity.

## Task 6.4

- [ ] 6.4 Reconcile completion evidence and durable specification handoff

    **Outcome**

    Produce an auditable requirement-to-proof handoff for this Change after its product tasks pass, and semantically synchronize its four delta capabilities into current specs. Leave implementation, one-off measurements and execution state in their proper owners. This task neither starts a Review nor declares neighboring Changes completed; subsequent verification and archive follow their normal lifecycle.

    **Context and interfaces**

    Dependency 6.2 transitively supplies completed product verification, functional/performance evidence, final provider dispositions and compatibility accounting. Consume proposal.md, design.md, all four concrete delta files, tasks.md and the indexed evidence. The current targets `angelscript/bindings/runtime` and `angelscript/runtime/binding-engine` exist; `angelscript/bindings/extensions` and `angelscript/bindings/observability` do not exist in this planning snapshot. Reinspect at execution time and create only still-missing capabilities with `openspec.spec create`, in the existing `angelscript/bindings` domain. Do not fabricate spec.yaml manifests.

    final-verification.md owns a table whose rows identify the proposal acceptance condition or full capability/Requirement/Scenario identity, owning task, exact executed case(s), command/report location, source and binary identity, observed result and any limitation. Include the disposition source for inventory/policy claims, the final compatibility ledger, schema-common baseline/final comparisons and final-only template workload labels. Missing or stale evidence remains a gap; documentation validation cannot turn it into executed behavior.

    **Cases and completion criteria**

    | Handoff case | Required outcome |
    | --- | --- |
    | EvidenceCoverage | Each proposal/delta acceptance condition maps to a completed task and applicable executed evidence from the final relevant source/binary. Every eligible migration member/site and remaining compatibility consumer has a final disposition. Performance rows identify actual samples, semantic checks and indexed trace evidence rather than counts copied from a prior snapshot. |
    | RuntimeMerge | Replace the three named MODIFIED requirement bodies and their same-name delta scenarios; append new scenarios and the complete ADDED migration requirement. Preserve unspecified scenarios such as `Call native members through the current VM` and `Revalidate without changing a sealed snapshot`, and the unspecified accounting/inspection requirements, including their complete clause-owned content. |
    | EngineMerge | Replace the two named MODIFIED requirement bodies and same-name scenarios; append `Consume one preparation result`, adapter restoration and the two ADDED delegate requirements. Preserve `Creation fails without a partially usable owner` under its existing requirement. |
    | NewCapabilities | Create missing extensions/observability records via the CLI and populate each with its complete ADDED requirements and scenario cards. Current specs contain no delta-operation headings. Existing capabilities are reconciled without duplicate requirements or scenarios. |
    | OwnershipAndRepeat | All imported clause-owned prose/lists/tables/examples remain beneath the exact qualifying clause; a second semantic merge would produce no change. No Files list, task checkbox, source-edit sequence, one-off proving command or benchmark transcript is promoted into durable behavior. |

    **Implementation**

    1. Audit the evidence mapping against the final relevant snapshot. Reuse valid exact proofs. For a missing/stale result, obtain only the owning task's missing proof under the existing verification policy and record its result; do not claim this card's static validator proves runtime behavior. An unfulfilled product acceptance condition prevents completion and cannot be repaired by weakening its spec.
    2. Read each full delta alongside its current target. For each MODIFIED same-name scenario use the complete delta card as replacement, retaining all clause-local content. Append new names; preserve unspecified scenarios exactly. Apply only explicitly supplied requirement-body replacements. No REMOVED/RENAMED operation is presently supplied; do not infer one.
    3. Create each still-missing spec through `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create', '<capability-id>', '--json')`, check its result, then author its current spec.md with Purpose and Requirements. The IDs are `angelscript/bindings/extensions` and `angelscript/bindings/observability`. The domain already exists; no domain mutation is needed unless the inspected state differs.
    4. Merge the four capabilities semantically. Preserve complete Markdown ownership rather than copying delta files over current specs. Review the resulting scenario inventory and unchanged cards, and repeat the merge comparison to establish idempotence. Keep permanent interface/lifetime/error guarantees in specs, construction choices in design/tasks and actual results in the attachment.
    5. Write final-verification.md and update INDEX in the same edit. Record actual commands/results, changed capabilities and intentionally omitted heavier checks with impact reasons. Run the proving command below. Mark 6.4 complete only after the substantive handoff criteria and validation succeed, then continue normal verify/closure/archive policy without introducing another task graph.

    **Files**

    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/final-verification.md`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md`
    - `openspec/specs/angelscript/bindings/runtime/spec.md`
    - `openspec/specs/angelscript/runtime/binding-engine/spec.md`
    - `openspec/specs/angelscript/bindings/extensions/spec.yaml`
    - `openspec/specs/angelscript/bindings/extensions/spec.md`
    - `openspec/specs/angelscript/bindings/observability/spec.yaml`
    - `openspec/specs/angelscript/bindings/observability/spec.md`

    Manifest files are CLI-owned outputs, not manually authored documents. Task completion remains in the existing tasks.md execution state under the shared task protocol.

    **Verification**

    From the selected workspace in PowerShell 7 after the shared Harness import/context setup, validate the Change and the current spec set as required by spec synchronization. No fresh UE build is required merely for this documentation handoff; any missing product proof follows its owning selector separately.

    ```powershell
    $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-bindings-two-stage-pipeline', '--type', 'change', '--strict', '--json')
    if ($result.exitCode -ne 0) { throw '6.4 Change validation failed' }
    $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs', '--strict', '--json')
    if ($result.exitCode -ne 0) { throw '6.4 current specification validation failed' }
    ```

    Completion requires successful validator results plus all five handoff cases, an explicit four-capability merge record and no evidence gaps. Strict validation proves structure; the semantic comparison and requirement-to-case table prove preservation and coverage. Do not rerun Quick, Integration, full Automation or performance solely because specifications changed; repeat a product proof only for stale/missing evidence or demonstrated adjacent impact.

## Rationale

The replacement preserves the incomplete IDs, dependencies and product scope while replacing generic fixture references with inspected interfaces and literal inputs/results. It distinguishes existing host/VM controls from new capture/migration proof, calls out the World helper's current direct-host behavior, bounds the provider inventory independently of aggregate counts, and makes fixture lifetime cleanup executable. The expanded handoff names concrete current-spec preservation cases, missing-capability creation, semantic merge rules, evidence fields and the distinction between static validation and product proof. The task-authoring and synchronization guidance prompted these details; no fixture API, passing run or completed task was invented.
````
