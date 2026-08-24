# TestSource corpus

This directory is the runner-neutral AngelScript observation corpus for core
manual Bind surfaces, plus an isolated reflected test-framework conformance
corpus. It is the product of `openspec/changes/test-as-manual-bind-source-coverage`.

Counts:

- 614 Bind+framework `.as` sources (576 Bind + 38 TestFramework)
- 2,427 additional handwritten theme `.as` sources planned in
  `inventory/planned-theme-sources.csv` (Language 642, Definitions 519,
  Containers 186, Feature 367, World 123, Gameplay 262, Optional 116,
  HotReload 209, Debugger 3)
- `Generation/` is a separate generation-rules package. It does not emit
  Bind or theme `.as` files.

Inventory identity (read-only against the OpenSpec plan): 204 physical
`Bind_*.cpp` shards, 127 logical Bind units, 3,015 Bind surfaces. One
logical unit (`BlueprintCallable`) is infrastructure-only and has **zero**
planned sources.

## Layout

```
TestSource/
  README.md
  Bindings/<LogicalBindName>/Test_<ScenarioCategory>_<Part>.as
  TestFramework/<Area>/Test_<Name>.as
  Language/  Definitions/  Containers/  Feature/  World/
  Gameplay/  Optional/  HotReload/  Debugger/
  Generation/   (independent generation-rules corpus; not a test theme)
```

There are no `_Type` or `_Functions` shard directories. Multiple physical
shards that publish one logical API share one `Bindings/<LogicalBindName>/`
folder.

Scenario categories used by Bind files:

- `ConstructionAndAssignment`
- `Operators`
- `IndexAndIteration`
- `Queries`
- `MutationAndLifecycle`
- `ConversionAndFormatting`
- `NamespaceAndGlobalFunctions`
- `Behavior`

## Runner-neutral Bind vs framework-owned sources

**`Bindings/**` is runner-neutral.** Files declare a `namespace TS_<LogicalBind>_<Scenario>_<Part>`
and observation functions (`Observe_*`, plus `ExerciseExpectedFailure` when
the task is `NegativeDiagnostic`). They must not inherit `UAngelscriptTestSuite`
and must not call `FAngelscriptTest`. They are not UE Automation tests.

**`TestFramework/**` is framework-owned.** Only these files may use
`UAngelscriptTestSuite`, `FAngelscriptTest`, or `ULatentAutomationCommand`.
The reflected test protocol is the subject; payload APIs (arithmetic, a
spawned actor, a delay) are incidental unique messages/locations for a
future C++ external oracle.

This wave does **not** compile AngelScript, run UE Automation, generate C++
inline export, or emit Bind/theme `.as` bodies from CSV. Structural presence
of planned paths is necessary but not sufficient. Bind sources are accepted
only when every planned callable publishes a runner-readable observation.
Theme sources keep the referenced C++ `ASTEST_AS` declarations and add
empty/default and boundary observations with a runner-readable oracle.
TestFramework sources stay **provisional** until a later C++ external oracle
exists.

## Observation contract (Bind)

Every Bind `Observe_*` / `ExerciseExpectedFailure` has a row in
`openspec/changes/test-as-manual-bind-source-coverage/inventory/observation-contracts.csv`
keyed by `TaskId + PlannedSymbol`. The source must match that contract:

- a non-void result, out/inout record, identified host-visible state, or
  expected diagnostic
- discarded locals (`b...ObservationsHold` / `b...Hold` / `b...Returned`),
  log lines, and successful `void` no-arg returns are not observations
- tautologies and `requiredFixture == nullptr || expected` are forbidden
- missing required fixtures throw a setup failure
- spawned actors and timers have named cleanup (`DestroyActor`,
  `ClearAndInvalidateTimerHandle`)
- `RequestExit`, `LaunchURL`, clipboard mutation, and `ServerTravel` are
  isolated (`SubprocessOnly` / `FixtureIsolated`) and are not
  default-executable

Execution policies: `DefaultSafe`, `FixtureIsolated`, `SubprocessOnly`,
`DiagnosticOnly`, `CompileOnlyPendingHarness`.

A later driver change supplies the executable red/green cycle. This corpus
does not claim compile or run success.

## Knowledge comments

Comments are English and knowledge-oriented. There is no mandatory `@covers`
tag and no fixed metadata card.

Bind files explain:

- purpose of the scenario family
- the AS-facing API actually called
- chosen inputs (including empty/default and a relevant boundary)
- expected result or effect
- the important boundary or ownership rule (copy vs alias, out writeback,
  handle lifetime, container append-without-clear, `Math::` vs `FMath::`,
  and so on)

Framework files explain:

- the framework contract under test
- why the chosen payload is enough
- expected leaf, phase, or diagnostic observations
- which outcomes need a future C++ external oracle

Every Bind observation is runner-readable. Void, out/inout, reference,
handle, container, diagnostic, and lifecycle effects are observed when
the contract says they apply. Framework internal assertions are payload
for the later C++ oracle, not Bind-style acceptance.

## Eight Bind matrices (576 files)

`BlueprintCallable` is listed in matrix 1 as infrastructure-only (0 files).

### 1. Core publication and primitives (36)

Binding publication, primitives, diagnostics, console, profiling, hashing,
logging, stats, native-module bridge.

| Logical unit | Files |
|---|---:|
| BlueprintEvent | 3 |
| BlueprintType | 7 |
| ConfigEnums | 1 |
| Console | 4 |
| CoreGlobals | 1 |
| Debugging | 3 |
| Deprecations | 1 |
| FCpuProfilerTraceScoped | 1 |
| FMemoryReader | 4 |
| Hash | 1 |
| Logging | 4 |
| NativeModuleFunctionBinding | 1 |
| Primitives | 3 |
| Stats | 2 |

Sources: `Bindings/BlueprintEvent/`, `Bindings/BlueprintType/`,
`Bindings/ConfigEnums/`, `Bindings/Console/`, `Bindings/CoreGlobals/`,
`Bindings/Debugging/`, `Bindings/Deprecations/`,
`Bindings/FCpuProfilerTraceScoped/`, `Bindings/FMemoryReader/`,
`Bindings/Hash/`, `Bindings/Logging/`,
`Bindings/NativeModuleFunctionBinding/`, `Bindings/Primitives/`,
`Bindings/Stats/`.

### 2. Text, formatting, and serialization (74)

| Logical unit | Files |
|---|---:|
| FColor | 6 |
| FDateTime | 8 |
| FFormatArgumentValue | 2 |
| FGuid | 6 |
| FName | 5 |
| FNumberFormattingOptions | 5 |
| FString | 13 |
| FStringTableRegistry | 3 |
| FText | 7 |
| FTimespan | 8 |
| Json | 9 |
| JsonObjectConverter | 2 |

### 3. Math and geometry (221)

Scalar math (`Math::`, never `FMath::` unless a settings-selected
compatibility namespace is in play), vectors, rotators, quaternions,
transforms, matrices, integer vectors, ranges, bounds, planes, spheres,
layout values, random streams, and frame time.

| Logical unit | Files |
|---|---:|
| FAnchors | 3 |
| FBox | 7 |
| FBox2D | 2 |
| FBox3f | 7 |
| FBoxSphereBounds | 6 |
| FBoxSphereBounds3f | 6 |
| FFrameTime | 1 |
| FGeometry | 2 |
| FIntPoint | 4 |
| FIntVector | 6 |
| FIntVector2 | 3 |
| FIntVector4 | 4 |
| FLinearColor | 8 |
| FMargin | 3 |
| FMath | 27 |
| FMatrix | 2 |
| FPlane | 2 |
| FPlane4f | 2 |
| FQuat | 11 |
| FQuat4f | 11 |
| FRandomStream | 7 |
| FRange | 3 |
| FRotator | 10 |
| FRotator3f | 7 |
| FSphere | 3 |
| FSphere3f | 3 |
| FTransform | 9 |
| FTransform3f | 8 |
| FVector | 13 |
| FVector2D | 10 |
| FVector2f | 9 |
| FVector3f | 14 |
| FVector4 | 3 |
| FVector4f | 5 |

### 4. Containers and reference wrappers (42)

| Logical unit | Files |
|---|---:|
| FInstancedStruct | 5 |
| SoftObjectPath | 4 |
| TArray | 8 |
| TMap | 7 |
| TOptional | 4 |
| TSet | 6 |
| TSoftObjectPtr | 8 |

### 5. Objects, reflection, and assets (39)

| Logical unit | Files |
|---|---:|
| AssetBundleData | 3 |
| AssetManagerScriptMixins | 2 |
| AssetRegistry | 7 |
| UAssetManager | 5 |
| UDataTable | 4 |
| UEnum | 5 |
| UObject | 10 |
| UPackage | 1 |
| UStruct | 2 |

### 6. Actors, components, World, and collision (86)

| Logical unit | Files |
|---|---:|
| AActor | 5 |
| APlayerController | 3 |
| AVolume | 3 |
| CollisionProfile | 1 |
| FActorSpawnParameters | 3 |
| FBodyInstance | 3 |
| FCollisionQueryParams | 14 |
| FCollisionShape | 6 |
| FHitResult | 4 |
| FLatentActionInfo | 1 |
| FOverlapResult | 3 |
| LandscapeProxy | 1 |
| UActorComponent | 3 |
| UCollisionProfile | 1 |
| UFXSystemComponent | 1 |
| UGameInstance | 3 |
| ULocalPlayer | 1 |
| UPoseableMeshComponent | 1 |
| UPrimitiveComponent | 2 |
| UProjectileMovementComponent | 2 |
| USceneComponent | 4 |
| USkeletalMeshComponent | 2 |
| USkinnedMeshComponent | 2 |
| UWorld | 7 |
| WorldCollision | 10 |

Collision-channel enumerators use the ConfigEnums script names
(`ECollisionChannel::WorldStatic`), not the native `ECC_*` identifiers.

### 7. Input, UI, platform, and utilities (66)

| Logical unit | Files |
|---|---:|
| FApp | 1 |
| FCommandLine | 2 |
| FFileHelper | 2 |
| FGenericPlatformMisc | 1 |
| FInputActionKeyMapping | 1 |
| FInputActionValue | 4 |
| FInputBindingHandle | 4 |
| FMessageDialog | 1 |
| FParse | 1 |
| FPaths | 7 |
| FPlatformApplicationMisc | 1 |
| FPlatformMisc | 2 |
| FPlatformProcess | 3 |
| InputComponentScriptMixins | 1 |
| InputEvents | 17 |
| SystemTimers | 3 |
| UEnhancedInputComponent | 4 |
| UInputMappingContext | 4 |
| UInputSettings | 2 |
| UUserWidget | 5 |

### 8. Delegates, mixins, and subsystems (12)

| Logical unit | Files |
|---|---:|
| Delegates | 6 |
| FAngelscriptDelegateWithPayload | 2 |
| FAngelscriptGameThreadScopeWorldContext | 1 |
| FunctionLibraryMixins | 2 |
| Subsystems | 1 |

Exact per-file paths and TaskIds are `TestSource/Bindings/<Logical unit>/Test_<ScenarioCategory>_<Part>.as`
as listed in `openspec/changes/test-as-manual-bind-source-coverage/inventory/planned-test-sources.csv`
and `tasks.md` sections 1–8 (576 Bind rows).

## Eight framework areas (38 files)

Only `TestFramework/**` may use the reflected suite/command types. Comments
name the contract and the C++-oracle observations; they do not claim
pass/fail until that oracle exists. All 38 files are provisional. The
driver-handoff matrix is
`openspec/changes/test-as-manual-bind-source-coverage/attachments/implementation/framework-handoff-matrix.md`.

### Discovery (4)

- `TestFramework/Discovery/Test_SuiteAndMethodDiscovery.as` — `TS-FW-DISCOVERY-001`
- `TestFramework/Discovery/Test_AutomationFlagsAndDisabledCases.as` — `TS-FW-DISCOVERY-002`
- `TestFramework/Discovery/Test_InvalidDiscoveryDiagnostics.as` — `TS-FW-DISCOVERY-003`
- `TestFramework/Discovery/Test_RegistryGenerationRebuild.as` — `TS-FW-DISCOVERY-004`

### Assertions (6)

- `TestFramework/Assertions/Test_BooleanNullIdentityAssertions.as` — `TS-FW-ASSERTIONS-001`
- `TestFramework/Assertions/Test_EqualityAndOrderingAssertions.as` — `TS-FW-ASSERTIONS-002`
- `TestFramework/Assertions/Test_NearValueAssertions.as` — `TS-FW-ASSERTIONS-003`
- `TestFramework/Assertions/Test_ExpectedErrorAssertions.as` — `TS-FW-ASSERTIONS-004`
- `TestFramework/Assertions/Test_FailureDiagnosticsAndFailFast.as` — `TS-FW-ASSERTIONS-005`
- `TestFramework/Assertions/Test_AssertionExceptionsAcrossPhases.as` — `TS-FW-ASSERTIONS-006`

### Lifecycle (3)

- `TestFramework/Lifecycle/Test_AllAndEachHookOrder.as` — `TS-FW-LIFECYCLE-001`
- `TestFramework/Lifecycle/Test_FreshSuiteInstances.as` — `TS-FW-LIFECYCLE-002`
- `TestFramework/Lifecycle/Test_TeardownAndCleanupAfterFailure.as` — `TS-FW-LIFECYCLE-003`

### Commands (7)

- `TestFramework/Commands/Test_DoThenFifo.as` — `TS-FW-COMMANDS-001`
- `TestFramework/Commands/Test_StartWhenUntil.as` — `TS-FW-COMMANDS-002`
- `TestFramework/Commands/Test_WaitDelayTiming.as` — `TS-FW-COMMANDS-003`
- `TestFramework/Commands/Test_TeardownCleanupLifo.as` — `TS-FW-COMMANDS-004`
- `TestFramework/Commands/Test_CommandScopeAndQueueMutationErrors.as` — `TS-FW-COMMANDS-005`
- `TestFramework/Commands/Test_AdvancedLatentCommandLifecycle.as` — `TS-FW-COMMANDS-006`
- `TestFramework/Commands/Test_AdvancedCommandTimeoutAndClientPolicy.as` — `TS-FW-COMMANDS-007`

### World (5)

- `TestFramework/World/Test_PureObjectFixture.as` — `TS-FW-WORLD-001`
- `TestFramework/World/Test_WorldActorComponentLifecycle.as` — `TS-FW-WORLD-002`
- `TestFramework/World/Test_GameInstanceWorldCleanup.as` — `TS-FW-WORLD-003`
- `TestFramework/World/Test_TickAndAdvanceTime.as` — `TS-FW-WORLD-004`
- `TestFramework/World/Test_WorldFailureCleanup.as` — `TS-FW-WORLD-005`

### Automation (3)

- `TestFramework/Automation/Test_FlagBridgeAndSectionSession.as` — `TS-FW-AUTOMATION-001`
- `TestFramework/Automation/Test_HookFailureReporting.as` — `TS-FW-AUTOMATION-002`
- `TestFramework/Automation/Test_CommandOwnershipAndStaleHandles.as` — `TS-FW-AUTOMATION-003`

### HotReload (7)

- `TestFramework/HotReload/Test_RegistryRefreshAndCoalescing_V1.as` — `TS-FW-HOTRELOAD-001`
- `TestFramework/HotReload/Test_RegistryRefreshAndCoalescing_V2.as` — `TS-FW-HOTRELOAD-002`
- `TestFramework/HotReload/Test_LastGoodGenerationRetention_Good.as` — `TS-FW-HOTRELOAD-003`
- `TestFramework/HotReload/Test_LastGoodGenerationRetention_Broken.as` — `TS-FW-HOTRELOAD-004`
- `TestFramework/HotReload/Test_ActiveLeafCancellationAndCleanup.as` — `TS-FW-HOTRELOAD-005`
- `TestFramework/HotReload/Test_SessionReopenAcrossReload_V1.as` — `TS-FW-HOTRELOAD-006`
- `TestFramework/HotReload/Test_SessionReopenAcrossReload_V2.as` — `TS-FW-HOTRELOAD-007`

### SelfHosted (3)

- `TestFramework/SelfHosted/Test_FrameworkSelfHostedSmoke.as` — `TS-FW-SELFHOSTED-001`
- `TestFramework/SelfHosted/Test_FrameworkSelfHostedFailureOracle.as` — `TS-FW-SELFHOSTED-002`
- `TestFramework/SelfHosted/Test_FrameworkSelfHostedLatent.as` — `TS-FW-SELFHOSTED-003`

## Out of this wave

Not present and not claimed:

- compilation of this corpus
- UE Automation / CQTest discovery and execution
- C++ external oracles
- StaticJIT / AOT / UHT / generated binds
- GameplayTags, GAS, Standalone
- C++ inline export of these `.as` files
- CSV-to-AS generators or mechanical template dumps
- fake tests for native-only shards or `BlueprintCallable` infrastructure
