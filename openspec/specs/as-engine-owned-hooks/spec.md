# as-engine-owned-hooks Specification

## Purpose
TBD - created by archiving change refactor-as-engine-owned-hooks. Update Purpose after archive.
## Requirements
### Requirement: Engine-scoped hooks are owned by the active engine

The runtime SHALL store AngelScript runtime, behavior-changing compilation, and reload-lifecycle hooks on `FAngelscriptEngine` rather than on `FAngelscriptRuntimeModule` or on `FAngelscriptClassGenerator` static fields.

#### Scenario: Hook fires for its owning engine

- **WHEN** a caller registers a pre-compile, post-compile, class-analyze, pre-generate-classes, post-compile-class-collection, component-created, literal-asset-created, dynamic-spawn-level, debug-break, debug-object-suffix, **class-reload, enum-created, enum-changed, struct-reload, delegate-reload, full-reload, post-reload, or literal-asset-reload** hook through an engine-owned hook surface
- **THEN** that hook SHALL be invoked at the same lifecycle moment previously provided by the module-level or class-generator-level hook

#### Scenario: Hook does not leak to a different engine

- **WHEN** two independent `FAngelscriptEngine` instances exist and a hook is registered on only one instance
- **THEN** operations performed through the other engine SHALL NOT invoke that hook

#### Scenario: Reload hooks fire only for the engine performing the reload

- **GIVEN** Engine A and Engine B are both initialized
- **AND** a class-reload subscriber is registered on Engine A only
- **WHEN** Engine B performs a class reload
- **THEN** Engine A's class-reload subscriber SHALL NOT be invoked
- **AND** Engine B's reload SHALL NOT mutate any reload state owned by Engine A

### Requirement: Runtime module no longer exposes hook storage
`FAngelscriptRuntimeModule` SHALL NOT expose static hook getter APIs after the migration is complete.

#### Scenario: Module keeps only module lifecycle responsibilities
- **WHEN** code includes `AngelscriptRuntimeModule.h`
- **THEN** the module API SHALL expose UE module startup/shutdown and initialization compatibility behavior, and SHALL NOT expose migrated `Get*` hook getters

#### Scenario: Callers use explicit owners
- **WHEN** runtime, bind, debug, preprocessor, compiler, editor, or test code needs a migrated hook
- **THEN** it SHALL access the hook through `FAngelscriptEngine` or the dedicated editor/debug bridge instead of `FAngelscriptRuntimeModule`

### Requirement: Behavior-changing class analysis remains mutable
Class analysis hooks SHALL preserve their ability to mutate generated statics and class static metadata.

#### Scenario: Class analyze hook mutates generated statics
- **WHEN** a class analysis hook appends generated static code and updates the static flag during preprocessing
- **THEN** the generated code SHALL include the hook-provided static content and the static flag SHALL affect whether generated code is emitted

### Requirement: Editor/debug bridge hooks are not owned by the runtime module
Editor-facing debug and asset creation hooks SHALL move out of `FAngelscriptRuntimeModule` without becoming general runtime module globals.

#### Scenario: Editor module registers bridge behavior
- **WHEN** `AngelscriptEditor` starts up and registers debug asset listing, blueprint creation, or create-blueprint-default-path behavior
- **THEN** runtime debug requests SHALL still reach the registered editor behavior through the dedicated bridge

#### Scenario: Bridge can be reset in tests
- **WHEN** editor or debugger automation tests temporarily override bridge behavior
- **THEN** the tests SHALL be able to restore or clear the bridge without using `FAngelscriptRuntimeModule`

### Requirement: ClassGenerator does not own process-wide reload hooks

`FAngelscriptClassGenerator` SHALL NOT expose process-wide static delegates for reload-lifecycle events.

#### Scenario: Reload hook is registered through the engine

- **WHEN** runtime, editor, or test code needs a class-reload, enum-created, enum-changed, struct-reload, delegate-reload, full-reload, post-reload, or literal-asset-reload notification
- **THEN** it SHALL register through the active `FAngelscriptEngine`'s direct hook accessor (`FAngelscriptEngine::Get().GetOnXxx()`) rather than through `FAngelscriptClassGenerator::OnXxx`

#### Scenario: ClassGenerator header has no static reload delegate fields

- **WHEN** `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h` is inspected
- **THEN** it SHALL NOT declare any `static FOnAngelscript*` delegate field
- **AND** the corresponding definitions in `AngelscriptClassGenerator.cpp` SHALL be removed

#### Scenario: Hook accessors are direct members of FAngelscriptEngine

- **WHEN** application or test code wants to subscribe or broadcast on any of the 19 engine-owned hooks (compile lifecycle, class generation, reload lifecycle, asset lifecycle, runtime helpers)
- **THEN** the access path SHALL be `Engine.GetXxx()` directly on `FAngelscriptEngine`
- **AND** there SHALL NOT be an intermediate container struct (such as `FAngelscriptEngineHooks`) or `Engine.GetHooks()` method exposed by the engine

### Requirement: Editor reload state is per-engine

Editor subsystems that accumulate reload state across multicast notifications SHALL maintain that state per-engine rather than as process-wide singletons.

#### Scenario: ClassReloadHelper accumulates reload state per engine

- **WHEN** `Plugins/Angelscript/Source/AngelscriptEditor/ClassReloadHelper.h` collects entries from class / enum / struct / delegate / full / post / literal-asset reload notifications
- **THEN** the `FReloadState` storage SHALL be partitioned by the engine performing the reload
- **AND** `FReloadState` mutations from Engine A SHALL NOT be observable from a Engine B reload pass

#### Scenario: Editor subscribes per-engine via extension attach

- **WHEN** the AngelscriptEditor module wants to receive reload notifications from a newly created `FAngelscriptEngine`
- **THEN** it SHALL register its subscriptions through the existing engine extension attach/replay mechanism
- **AND** SHALL NOT register a single set of subscriptions during module startup that fires for any engine

