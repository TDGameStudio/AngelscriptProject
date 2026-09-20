# Independent after-guidance consumer output

Preserved proposed cards from the isolated consumer exercise. This fenced artifact is evidence, not an active Task DAG or permission to execute its commands. Line endings are normalized for the repository; the consumer text is otherwise retained.

````markdown
# Proposed replacement cards

These are planning-only replacements for the existing unchecked 5.5 and 6.4. Preserve the frontmatter dependencies `"5.5": ["5.4"]` and `"6.4": ["6.2"]`, every other ID and completion state, and the shared setup before the first task. No product implementation or successful product verification is asserted here.

## Task 5.5

- [ ] 5.5 Migrate gameplay, collision and input API providers

    **Outcome**

    Migrate exactly the EngineGameplay source sites assigned to task 5.5 in `attachments/data/provider-migration.csv`, including their companion headers and `_Type`/`_Functions` files. Each built-in type has one complete primary description; intentional supplements keep their own provenance. Preserve independently expected declarations, qualifiers, native transports, effects and target exclusions. Move concrete World/collision behavior into Registry/Engine. This task does not activate the dormant runtime, create a UHT generator, migrate another inventory family, or move reflection generators out of their Registry/Core owner.

    **Context and interfaces**

    Task 5.4 supplies the migrated object/reflection path; its transitive prerequisites supply the public recording API, installed native/container calls and owner-local adapters. The accepted target signatures in design section 3 are `FAngelscriptBindingRecorder::Capture(const FAngelscriptBindingRegistry&, const FAngelscriptBindingCaptureOptions&, TSharedPtr<const FAngelscriptBindingDatabase>&, FAngelscriptBindingDiagnostic&)` and `FAngelscriptBindingInstaller::Prepare(TSharedRef<const FAngelscriptBindingDatabase>, const FAngelscriptBindingInstallOptions&, TUniquePtr<FAngelscriptPreparedBindings>&, FAngelscriptBindingDiagnostic&)`. `FAngelscriptEngine::CreateForBindings` remains the owning facade. These are prerequisite outputs, not APIs verified to exist in the planning snapshot. Consume their completed declarations when implementation resumes; do not reconstruct the old declaration prepass in a new fixture.

    Existing controls are in `RuntimeBindingActorsTests.cpp`, `RuntimeBindingCollisionTests.cpp` and `RuntimeBindingInputUITests.cpp`. Their local `FActorsFixture`, `FCollisionFixture` and `FInputUIFixture` each implement `Create(bool)` and `Function(const TCHAR* OwnerName, const TCHAR* Declaration) const`. Today they record through `FinalizeRegisteredBinds`, `RecordInstallableTypeDeclarations` and `RecordSelectedProviders`, then seal and call `CreateForBindings`. Their old provider-name arrays and contribution counts describe the old phase fragments; they are not the migrated coverage oracle.

    Replace only those fixtures' setup/accounting with the completed Capture/CreateForBindings path while preserving the literal regression assertions below. Installed-call assertions use the exact owner, namespace and declaration to find the installed function, then `asIScriptContext::Prepare`, argument setters and `Execute`; require zero setup return codes and `asEXECUTION_FINISHED`. `RuntimeBindingTestSupport.h` currently has a declaration-only `Function` lookup and Pair helpers, not a complete gameplay fixture. Add an owner/namespace-aware lookup and family capture wrapper here or in the new migration test file as explicit construction work; do not assume those helpers already exist.

    Keep the database alive while its engines exist, create separate prepared/installed state for each owner, and release script contexts before their owners. World, actors, components and argument storage must outlive admitted calls. Use the existing transient-world RAII pattern, retain objects through each case, destroy actors/components before the world, and restore the UUserWidget default object's previous WidgetTree on every exit as the existing scope guard does. SnapshotOnly recording must consume captured immutable UE inputs; live UObject/metadata work stays on GameThread.

    **Cases**

    The following existing methods remain regression controls in their original files and original `Angelscript.UnitTest.RuntimeBindings.Runtime.Actors`, `.Runtime.Collision` and `.Runtime.InputUI` selections. The single proving command below executes all three selections as well as the new migration selection. Each row names actual inspected inputs and outputs; the coverage column limits what may be claimed from it.

    | Existing file and method | Input and literal expected result | Coverage |
    | --- | --- | --- |
    | Actors: `TransientActorAndSceneComponentPreserveTranslation` | Spawn an actor, register its root scene component, invoke `void SetRelativeLocation(const FVector& NewLocation)` with `(11,22,33)`; component world location equals `(11,22,33)` | Installed VM method |
    | Actors: `CurrentWorldUsesExplicitAmbientFixture` | Enter `FAngelscriptEngineScope(*Owner, World)`, invoke `UWorld GetCurrentWorld()`; returned object is exactly that World | Installed VM global plus native context checks |
    | Actors: `UnregisteredComponentNoneTagUsesExistingFalseContract` | Unregistered scene component, `FName()` and `bool ComponentHasTag(const FName& Tag) const`; return `false` | Installed VM negative control |
    | Actors: `SpawnParameterFieldsAndFlagsRoundTrip` | `Name="FixtureActor"`, `bNoFail=true`, `bDeferConstruction=true`; all three native fields retain those values and `FName Name` is recorded | Native fields and metadata; not a script property write |
    | Collision: `SphereShapeRadiusTwoRoundTrips` | VM calls `void SetSphere(const float32 Radius)` with `2.0f`, then `float32 GetSphereRadius() const`; return `2.0f` | Installed VM methods |
    | Collision: `QueryIgnoredActorCollectionCopiesIndependently` | Ignore A, copy query params, then add B only to original; original count `2`, copy count `1`, first identity equal | Native copy/lifetime control; not VM copy proof |
    | Collision: `HitAndOverlapPropertiesMatchFixtureValues` | Native Hit has Distance `12.5f`, Item `17`; Overlap has ItemIndex `23`; recorded offsets read exactly `12.5f`, `17`, `23` | Metadata layout and native values; not ref/out execution |
    | Collision: `EmptyTransientWorldQueryReturnsNoHit` | Empty world, Start `(0,0,0)`, End `(100,0,0)`, `ECC_Visibility`, default query/response params, initial OutHit `true`; helper succeeds and OutHit becomes `false` | Existing helper calls UWorld directly; not VM trace proof |
    | Collision: `NullWorldContextProducesExplicitDiagnostic` | Null World, `(0,0,0)` to `(1,1,1)`, initial OutHit `true`; helper returns `false`, OutHit becomes `false`, diagnostic contains `world` | Existing host-helper rejection control |
    | InputUI: `AxisTwoValuePreservesComponentsAndType` | FInputActionValue from `(1,2)`; VM `FVector2D GetAxis2D() const` returns `(1,2)` and native value type is Axis2D | VM return plus native type check |
    | InputUI: `ActionMappingCopyPreservesKeyAndModifiers` | Copy `Jump`, SpaceBar, Shift=true, Ctrl=false, Alt=true, Cmd=false; VM `opEquals` returns `true`, native copy retains those key/modifiers | VM equality; construction/copy are native |
    | InputUI: `RemoveBindingByHandleAffectsExactlyOneBinding` | Bind actions A and B, VM-remove A's handle; return `true`, count `2 -> 1`, survivor is exactly B | Installed VM mutation |
    | InputUI: `InputChordConstructorPreservesModifierFlags` | VM constructor gets K, true, false, true, false; native result has exactly K and those four flags | Installed VM constructor |
    | InputUI: `TransientWidgetRootLookupPreservesVisibility` | Construct Border named FixtureRoot, set Collapsed, VM SetRootWidget/GetRootWidget; return exact root and visibility remains Collapsed | Installed VM object calls with restored fixture state |

    Retain the existing actor/component destruction and input-resource weak-pointer controls as native lifetime controls. Replace old phase-name/count accounting assertions with the independent inventory mapping described below; counts such as InputUI's 427 contributions/63 recipes cannot serve as fixed post-folding provider expectations.

    Add these planned methods in `RuntimeBindingMigrationEngineGameplayTests.cpp`, under exactly `Angelscript.UnitTest.RuntimeBindings.Migration.EngineGameplay`. The names are future tests, not discovery evidence:

    | Planned method | Construction and observable acceptance | RED/control distinction |
    | --- | --- | --- |
    | `CompletePrimaryRecordWithoutReplay` | Capture the family with required prerequisite types. For each expected primary, callback count is `1`, declaration-prepass count is `0`, and lifecycle/member/adapter/ToString facts present in the independent oracle are all recorded. Prepare/create two engines from that same database; provider counts remain unchanged. Destroy either owner, then run the sphere `2.0f` and input `(1,2)` calls on the survivor. Compare canonical family projection between Serial and Parallel, excluding transient IDs/addresses | New missing complete-primary/replay behavior; literal calls are controls |
    | `CollisionInstalledCallsAndRefOutput` | Build the existing empty transient world and explicit engine/world scope. Execute installed `System::LineTraceTestByChannel` using `(0,0,0)` to `(100,0,0)`, `ECC_Visibility` and default query/response objects; return `false`. Also execute installed `System::LineTraceSingleByChannel(FHitResult& OutHit, const FVector& Start, const FVector& End, ECollisionChannel TraceChannel, const FCollisionQueryParams& Params, const FCollisionResponseParams& ResponseParam)` with the same inputs and host-owned initialized FHitResult; return `false`, OutHit.bBlockingHit is `false`, and the output remains valid until its one normal destruction after context release. Resolve the full recorded declaration, including existing default arguments, from the independently captured declaration oracle | New VM-boundary coverage. Existing helper/native offset tests cannot satisfy this case. If this VM behavior already passes before folding, retain it as an observed control rather than inventing RED |
    | `CollisionHostGuardRemainsExplicit` | Preserve the existing helper signature's World/query/response/OutHit/Diagnostic inputs at its relocated Registry/Engine owner. For null World: return `false`, OutHit=`false`, diagnostic exactly `collision query requires a valid world context`. For an owner without the required collision declaration: return `false`, OutHit=`false`, diagnostic exactly `collision query surface is not installed in this binding owner` | Existing concrete diagnostics inspected in `AngelscriptTypeBindInfoApply.cpp`; the relocated helper is construction work, not an existing fixture API |
    | `IndependentSurfaceAndPolicy` | Compare every task-5.5 inventory row with independently expected member identities, qualifiers, transports/effects and target conditions. Delete the expectation's `FCollisionShape` sphere getter from a test copy of the actual projection: the comparator must fail and identify that exact missing owner/declaration even if another entry keeps the count unchanged. A duplicate primary must fail and identify both sources; no database is published | New accounting assertions; rejection reasons use completed framework diagnostic fields, not an invented error enum |

    `IndependentSurfaceAndPolicy` owns the family-wide oracle beyond these representative calls. Task 1.1 produces `baseline-expectations.json` from pre-migration source and independent expectations. Before changing any task-5.5 provider, join that input to all CSV rows with `task=5.5` and `family=EngineGameplay`, reconcile source hashes against the selected snapshot, and encode the immutable family expectation table in the migration fixture. The current CSV has 52 lexical sites, not 52 active providers. Record each `(source,line,symbol,file_sha256)` with its final stable module/provider identity, contribution role, expected symbols/effects, actual policy and installed/excluded/no-output disposition in `migration-enginegameplay.md`. Do not regenerate expected symbols from migrated output. An incomplete prerequisite oracle must be filled from the preserved pre-migration source before proceeding, never accepted as missing coverage.

    For target conditions, preserve the inspected UUserWidget `WITH_EDITOR` exclusion effect for `/Script/UMG.UserWidget:GetIsVisible` (`NotInAngelscript=true` to avoid the visibility accessor conflict). Test effective policy with captured fixture inputs through the prerequisite recording policy support; identify physically compiled-out sites from preprocessor/source evidence when that build cannot execute them. Do not claim a non-editor binary was exercised by an editor-only run. Every other condition comes from its source row and task-1.1 oracle, not a blanket exclusion for an unsupported eligible provider.

    **Implementation**

    1. Freeze the independent family expectations and final case-to-selection mapping before folding registrations. Port the three existing local fixture setup paths to the prerequisite recording facade. Add the new migration fixture, owner/namespace lookup, counters and projection comparator as needed. Keep all literal regression values visible.
    2. Build and execute the single proving command for grouped RED. Record which new complete-primary/replay/accounting cases fail for missing behavior and which existing VM/native controls pass. If an interface is still missing, follow bounded compile-evidence rules; do not call a failed unrelated build behavioral RED.
    3. Fold each family type's old phase fragments into one primary callback with its lifecycle, methods, adaptation and ToString contribution. Keep supplement ownership explicit, preserve generated/manual/reflection precedence, and relocate family providers/type-specific helpers into Registry/Engine. The World helper currently declared/defined on `FAngelscriptTypeBindInfoInstallation` must leave generic installation ownership; update its two old control callers to the new concrete owner. Any dormant forwarding shim stays indexed and unselectable as an old runtime.
    4. Update owned companion includes, forced links, Build.cs generation/aggregation references and the three control fixtures' accounting. Check that captured World/input effects use the correct thread policy. Run the same command for grouped GREEN in both supported execution modes inside the migration cases; preserve the selected build's policy evidence. Refactor shared fixture code only with a rerun of affected cases.
    5. Retain actual discovered/executed case names, RED/GREEN results, source/binary identities, independent family projection and every source-site disposition in `migration-enginegameplay.md`, indexed when evidence exists. Completion requires zero unexplained eligible sites, zero new-path declaration prepass for the family and no callback replay at installation. Mechanical file moves need no fabricated RED.

    **Files**

    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_APlayerController.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AVolume.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_CollisionProfile.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FActorSpawnParameters.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FBodyInstance.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionQueryParams.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FCollisionShape.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FHitResult.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionKeyMapping.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputActionValue.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FInputBindingHandle.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FLatentActionInfo.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FOverlapResult.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputComponentScriptMixins.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_LandscapeProxy.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UActorComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UCollisionProfile.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UEnhancedInputComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UFXSystemComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UGameInstance.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputMappingContext.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UInputSettings.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_ULocalPlayer.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPoseableMeshComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UPrimitiveComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UProjectileMovementComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USceneComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkeletalMeshComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_USkinnedMeshComponent.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UUserWidget.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UWorld.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_WorldCollision.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Type.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*_Functions.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Registry/Engine/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Public/Bindings/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.h`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/Private/Bindings/Framework/Runtime/**`
    - `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingActorsTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingCollisionTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingInputUITests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingMigrationEngineGameplayTests.cpp`
    - `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingTestSupport.h`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/provider-migration.csv`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/migration-enginegameplay.md`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md`

    Companion globs cover only the named 5.5 source owners. Core/Apply and Framework/Runtime edits are limited to relocating/removing the World-specific helper at its prerequisite-moved location; they do not authorize general installer changes. Public header changes cover the relocated family boundary and its consumers only. The task-1.1 baseline expectation file is a read-only input here.

    **Verification**

    Run from the selected workspace in the shared PowerShell 7 Harness context, after the shared fresh-build requirement for changed C++/headers/Build.cs. The four exact selections are one bounded family proving command: the first discovers all four new methods, and the other three execute the unchanged literal regression cases in the table plus their existing family lifetime/accounting controls. This is not a full RuntimeBindings or performance gate.

    ```powershell
    foreach ($prefix in @('Angelscript.UnitTest.RuntimeBindings.Migration.EngineGameplay', 'Angelscript.UnitTest.RuntimeBindings.Runtime.Actors', 'Angelscript.UnitTest.RuntimeBindings.Runtime.Collision', 'Angelscript.UnitTest.RuntimeBindings.Runtime.InputUI')) {
        $result = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = $prefix; Fast = $true; TimeoutMs = 600000 }
        if ($result.exitCode -ne 0) { throw "5.5 proving selection failed: $prefix" }
    }
    ```

    Require complete Harness Automation reports with every planned/control case discovered, executed and passed on the identified binary. Zero discovery, skipped cases or an incomplete report fail completion even if a process exits successfully. Preserve task-specific case mapping if a later justified full run supplies this proof. Record omitted full suites, performance and additional target builds with their impact-based reasons; do not represent policy-fixture checks as another compiled target run.

## Task 6.4

- [ ] 6.4 Reconcile completion evidence and durable specification handoff

    **Outcome and inputs**

    After task 6.2 passes, produce `attachments/data/final-verification.md` mapping every proposal acceptance condition and delta Requirement/Scenario to the final product evidence, and synchronize exactly four current capabilities. Task 6.2 transitively supplies task 6.3's performance evidence and 6.1's complete migration/compatibility evidence. Read the complete four change-local delta files and current targets together. This is a documentation/specification handoff; it does not implement product behavior, start a Review, activate legacy services or close neighboring Changes.

    **Known baseline and bounded disposition**

    Read-only strict validation during this card's authoring returned exit `1` for `angelscript/bindings/runtime`: six preserved Scenario Cards have two-space note indentation, each reported as both a direct-detail and continuation error. `angelscript/runtime/binding-engine` returned exit `0`. The extensions and observability current capability directories do not yet exist. These are authoring observations, not task-6.4 completion evidence; recheck the existing targets before future synchronization.

    This proposed task explicitly includes a formatting-only correction in `openspec/specs/angelscript/bindings/runtime/spec.md` for the exact six records below. Add the separating blank line and indent the existing quoted note four spaces under its original clause. Preserve its text, label and parent clause; do not rewrite, delete, reparent or synthesize any scenario. This exact-record correction settles the baseline within the handoff scope and is not a repository-wide legacy formatting migration.

    | Requirement / preserved Scenario | Existing note and owner |
    | --- | --- |
    | Application preserves type dependencies and callable behavior / Call native members through the current VM | Observables under THEN; baseline line 33 |
    | Hosts can inspect the intended AS surface before installation / Dump sealed binding declarations | Details under THEN; baseline line 62 |
    | Hosts can inspect the intended AS surface before installation / Validate and compare dumps offline | Details under THEN; baseline line 69 |
    | Snapshot inspection preserves ownership and complete accounting / Seal namespace globals and retain snapshot lifetime | Boundaries under the borrowed-storage AND; baseline line 82 |
    | Snapshot inspection preserves ownership and complete accounting / Reconcile all eligible providers and expected members | Details under THEN; baseline line 88 |
    | Sealed snapshots receive engine-free pre-installation validation / Revalidate without changing a sealed snapshot | Boundaries under AND; baseline line 106 |

    Use requirement/scenario identity, not changing line numbers, to locate these notes. If the future baseline contains another failing preserved record, report that unresolved exact boundary and keep this task incomplete until its disposition is settled; neither a passing delta nor an unrelated failure waiver makes an affected current target pass.

    **Implementation and acceptance**

    1. Reconcile task-6.2 `verification-functional.md`, task-6.3 performance comparison/summary, every migration-family disposition and the final compatibility ledger. For each acceptance condition record its exact case identity, report/run reference, source/binary hashes, literal observable result and evidence kind (VM execution, native control, metadata, trace or static check). Confirm full expected case discovery and execution. Valid final-snapshot evidence may be reused; missing/stale proof returns to its owning outcome for verification and cannot be repaired by prose. Keep raw benchmark/trace paths and transcripts in evidence, with durable conclusions only in specs.
    2. Validate both existing current targets before writing. Retain their actual baseline results. Apply only the six named formatting corrections above if still needed. Preserve all unspecified scenarios and their complete clause-owned details, including `Call native members through the current VM`, which is not replaced by the runtime delta, and `Creation fails without a partially usable owner`, which is not replaced by the binding-engine delta.
    3. Create missing capabilities through Harness `openspec.spec` with argument lists `@('create','angelscript/bindings/extensions','--title','Binding extensions','--json')` and `@('create','angelscript/bindings/observability','--title','Binding observability','--json')`. Require exit `0`. The `angelscript` domain already exists. The command produces each `spec.yaml`; author each `spec.md` separately. If a target exists by implementation time, inspect/validate it and merge rather than recreate it. Do not fabricate manifests.
    4. Semantically merge the four deltas: runtime and binding-engine contain MODIFIED and ADDED requirements; extensions and observability contain ADDED requirements. Use the complete same-name delta Scenario Card as the replacement, append genuinely new scenarios, preserve unspecified cards and all their details, and change a requirement body only where the delta supplies replacement wording. Keep useful prose/examples/tables under their exact clauses, including the TArray<FString> VM example and native-transport distinctions. Remove operation headers from current specs. No REMOVED or RENAMED operation is present in the inspected deltas; do not infer either. Check that each requirement/scenario identity occurs once and a second semantic application yields no further change.
    5. Run the proving command below and retain each record ID, exit/result and resolved baseline disposition in final-verification.md. The evidence matrix must have no unmapped acceptance clause, unexplained eligible source site or unclassified retained compatibility consumer; successful Markdown validation alone does not establish those facts. Record omitted UE rebuild/Automation reruns, broad all-spec validation and aggregate profiles with their reasons: this node changes only owned documentation and consumes already-current product proof. Mark 6.4 complete only after both reconciliation and strict merged-target/Change validation pass. Later verify/archive follows its own lifecycle, with any actually requested Review handled there; this card does not claim an archive already happened.

    **Files**

    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/tasks.md`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/data/final-verification.md`
    - `openspec/changes/angelscript/refactor-bindings-two-stage-pipeline/attachments/INDEX.md`
    - `openspec/specs/angelscript/bindings/runtime/spec.md`
    - `openspec/specs/angelscript/runtime/binding-engine/spec.md`
    - `openspec/specs/angelscript/bindings/extensions/spec.yaml`
    - `openspec/specs/angelscript/bindings/extensions/spec.md`
    - `openspec/specs/angelscript/bindings/observability/spec.yaml`
    - `openspec/specs/angelscript/bindings/observability/spec.md`

    The Change's proposal, deltas, task evidence, inventories and functional/performance reports are inputs. Keep this node's evidence and checkbox in tasks.md under the shared execution-state convention; no product files are owned by this handoff.

    **Verification**

    Run from the selected workspace after the shared PowerShell 7 Harness import/context setup. No new product build is required for this document-only node. Before synchronization, run the same validation operation for the two existing capability IDs to capture the baseline; the following complete command proves the final Change and all four merged targets.

    ```powershell
    foreach ($record in @(@('angelscript/refactor-bindings-two-stage-pipeline','change'), @('angelscript/bindings/runtime','spec'), @('angelscript/runtime/binding-engine','spec'), @('angelscript/bindings/extensions','spec'), @('angelscript/bindings/observability','spec'))) {
        $result = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @($record[0], '--type', $record[1], '--strict', '--json')
        if ($result.exitCode -ne 0) { throw "6.4 record validation failed: $($record[0])" }
    }
    ```

    All five records must validate with exit `0` and valid strict JSON results. Preserve the six unspecified note bodies and clause ownership, create no duplicate cards, and retain the completed evidence matrix and semantic-merge/idempotence inspection result. Do not copy task status, one-off measurements or benchmark transcripts into durable behavior.

## Rationale and authoring checks actually performed

The replacement 5.5 connects inspected fixture methods to literal inputs/results and to reachable proving selections. It separates native host/metadata controls from actual VM execution, makes the missing collision VM fixture explicit, and assigns the family-wide independent oracle to task 1.1's handoff plus 5.5's pre-migration reconciliation. It preserves the migration outcome and IDs while including the concrete fixture/helper callers that must change to execute it.

The replacement 6.4 includes exact target-creation and semantic-merge behavior, accounts for the six preserved baseline formatting failures, and uses document-specific completion criteria. Strict validation was actually run read-only through Harness for the existing runtime and binding-engine specs: runtime failed with 12 indentation diagnostics for six notes; binding-engine passed. Both new target directories were checked and were absent. Product builds, UE Automation, benchmarks, trace capture and synchronization were not run. The only written artifact in this exercise is this proposed replacement document.
````
