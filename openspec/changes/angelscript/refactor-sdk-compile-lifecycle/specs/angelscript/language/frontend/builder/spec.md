## Purpose

Define independently executable AngelScript frontend stages whose results remain inspectable without a script engine or an active runtime backend.

## MODIFIED Requirements

### Requirement: Independent typed compilation stages

The Builder SHALL compile through explicit typed stage results without requiring an AngelScript engine, and SHALL distinguish declaration readiness, body readiness, definition freeze, and bytecode emission.

#### Scenario: Stop after declarations and resume bodies

- **WHEN** a caller collects and resolves declarations before analyzing bodies
- **THEN** signatures are inspectable while body storage remains writable by the owning compilation session

    > Observables: Resuming body analysis preserves declaration identity and uses the retained active Token stream.

- **AND** running the same stages separately or together produces equivalent semantic results and deterministic text/JSON observations
- **BUT** an invalid stage transition or failed required stage cannot publish a successful later result

#### Scenario: Compile without a host consumer

- **WHEN** a caller supplies source, immutable language options, explicit type context and diagnostics without an Engine or UE reflection consumer
- **THEN** syntax, semantic definitions and layout validation complete and create actual TypeInfo owned by `asCModuleDefinitionSet` with null Engine and TypeId -1

    Script compile does not create Engine-owned runtime objects and does not assign process TypeIds. ClassGen UClass materialize remains a later host step.

- **BUT** unavailable execution backends remain explicit unsupported operations, not hidden legacy fallbacks

    Stopping at `DefinitionsFrozen` does not require stable bytecode. Default `RunThrough` continues through `ByteCodeEmitted`.

## ADDED Requirements

### Requirement: Builder yields two takeable products

The Builder SHALL expose `asCCompileOutput` and `asCModuleDefinitionSet` as parallel products after a successful run, and SHALL NOT place TypeInfo, functions, or bytecode inside `asCCompileOutput`.

#### Scenario: Take the definition set off the Builder

- **GIVEN** a snapshot Builder that successfully ran through at least `DefinitionsFrozen` on `class Unit { int32 Value; void Set(int32 V) { Value = V; } }`
- **WHEN** the caller calls `TakeModuleDefinitionSet()`
- **THEN** the returned UniquePtr uniquely owns the Unit TypeInfo and methods

    `GetEngine()` is null. `GetTypeId()` is -1. A second Take returns null. The Builder no longer owns the graph.

- **AND** destroying that UniquePtr without Registration deletes those TypeInfo objects
- **BUT** a failed RunThrough does not yield a usable Taken set

#### Scenario: Compile a later unit against a Taken set

- **GIVEN** a Taken `asCModuleDefinitionSet` from a successful compile of `class First { int32 Value; }`
- **WHEN** a second snapshot Builder compiles `class Second { First@ Ref; }` with `Options.Dependencies` holding a non-owning pointer to that set
- **THEN** Second resolves First without any Engine Registration

    The first set remains immutable. The second set uniquely owns Second only.

- **BUT** depending on a set that has not finished a successful RunThrough is rejected

    Cross-unit cycles are rejected. Types that must see each other share one snapshot.

#### Scenario: CompileOutput carries ClassGen descriptors without ScriptType

- **WHEN** the caller `GetCompileOutput()` or `TakeCompileOutput()` after a successful compile of a class named `Widget`
- **THEN** `asCDefinitionCompileOutput` contains `FAngelscriptModuleDesc` / `FAngelscriptClassDesc` whose class name is `Widget`

    `FAngelscriptClassDesc::ScriptType` is null. `FAngelscriptFunctionDesc::ScriptFunction` is null. The bag does not own TypeInfo or bytecode.

- **BUT** CompileOutput is not a substitute for `TakeModuleDefinitionSet`

### Requirement: Default RunThrough emits stable bytecode

The Builder SHALL emit stable bytecode onto each script `asCScriptFunction` when `RunThrough` uses the default stop `ByteCodeEmitted`, using the public `asCByteCodeEmitter`.

#### Scenario: Default RunThrough includes Emit

- **WHEN** a caller constructs snapshot `asCBuilder` and calls `RunThrough()` with the default stage
- **THEN** the run includes Emit and each script function on the Taken set reports a non-empty stable bytecode view
- **BUT** native `asFUNC_SYSTEM` functions keep an empty stable body
