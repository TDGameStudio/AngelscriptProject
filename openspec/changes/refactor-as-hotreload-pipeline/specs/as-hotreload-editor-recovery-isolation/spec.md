## ADDED Requirements

### Requirement: Editor recovery state is Editor-owned
`FClassReloadHelper::FReloadState` SHALL remain in the Editor module. Runtime ClassGenerator SHALL publish reload mappings through `FAngelscriptEngine` delegates (`GetOnClassReload` and siblings). Editor SHALL subscribe per attached engine. A refactor SHALL NOT move BlueprintActionDatabase or ComponentTypeRegistry updates into Runtime.

#### Scenario: Helper subscribes per engine
- **WHEN** an Editor-attached `FAngelscriptEngine` is created
- **THEN** `FClassReloadHelperExtension` SHALL subscribe to that engine's reload delegates
- **AND** it SHALL detach on engine destruction

#### Scenario: Recovery maps are not a Runtime singleton
- **WHEN** full reload replaces a `UClass`
- **THEN** the old-to-new map used for reinstancing editor objects SHALL live in Editor `FReloadState`
- **AND** Runtime SHALL NOT own `FBlueprintActionDatabase` refresh

### Requirement: Process-wide ReloadState is an explicit debt
Until a recorded partition lands, `FReloadState` MAY remain a single static for the Editor's one active engine. New recovery fields SHALL NOT be added as additional process-wide maps without updating this isolation spec. A later slice that supports overlapping reloads on two Editor engines SHALL key recovery state by engine or forbid overlap with a failing assert.

#### Scenario: Multi-engine hooks still have a home
- **WHEN** `AngelscriptHotReloadMultiEngineHooksTests` run
- **THEN** they SHALL continue to prove engine-owned reload hooks
- **AND** a partition of `FReloadState` SHALL NOT land without those tests staying green

### Requirement: Production helper headers do not keep growing UnrealEd plus ClassGenerator includes
`ClassReloadHelper.h` SHALL NOT gain new includes of both UnrealEd UI registries and `AngelscriptClassGenerator.h` in the same public header. Test hook structs SHALL stay gated by `WITH_DEV_AUTOMATION_TESTS`. A header-split slice SHALL move UnrealEd includes to the `.cpp` or a private header without changing reload behavior.

#### Scenario: Test hooks stay gated
- **WHEN** `WITH_DEV_AUTOMATION_TESTS=0`
- **THEN** `FClassReloadHelperClassReloadTestHooks` SHALL NOT be part of the shipping Editor API surface

#### Scenario: Header split is behavior-neutral
- **WHEN** UnrealEd includes move out of `ClassReloadHelper.h`
- **THEN** existing prefix `Angelscript.TestModule.HotReload` SHALL still pass
- **AND** ClassGenerator `EReloadRequirement` policy SHALL be unchanged
