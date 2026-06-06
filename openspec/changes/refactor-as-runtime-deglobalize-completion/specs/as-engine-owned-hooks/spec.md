# as-engine-owned-hooks Specification (delta)

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: ClassGenerator does not own process-wide reload hooks

`FAngelscriptClassGenerator` SHALL NOT expose process-wide static delegates for reload-lifecycle events.

#### Scenario: Reload hook is registered through the engine

- **WHEN** runtime, editor, or test code needs a class-reload, enum-created, enum-changed, struct-reload, delegate-reload, full-reload, post-reload, or literal-asset-reload notification
- **THEN** it SHALL register through the active `FAngelscriptEngine`'s hook surface (`FAngelscriptEngine::Get().GetHooks().GetOnXxx()`) rather than through `FAngelscriptClassGenerator::OnXxx`

#### Scenario: ClassGenerator header has no static reload delegate fields

- **WHEN** `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.h` is inspected
- **THEN** it SHALL NOT declare any `static FOnAngelscript*` delegate field
- **AND** the corresponding definitions in `AngelscriptClassGenerator.cpp` SHALL be removed

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
