## MODIFIED Requirements

### Requirement: Independent typed compilation stages

The Builder SHALL compile through explicit typed stage results without requiring an Engine and distinguish declaration readiness, body readiness, definition freeze and bytecode emission.

#### Scenario: Compile without a host consumer

- **WHEN** a caller supplies source, immutable options, explicit type context and diagnostics without an Engine or UE reflection consumer
- **THEN** syntax, semantic definitions and layout create actual ScriptEngine TypeInfo on asCDefinitions with null Engine and TypeId -1

    Script compilation does not create runtime objects or assign its private process TypeIds. ClassGen UClass materialization remains a later host step.

- **BUT** unavailable backends remain explicit unsupported operations rather than hidden legacy fallbacks

    Stopping at DefinitionsFrozen does not require stable bytecode. Default RunThrough continues through ByteCodeEmitted.

### Requirement: Builder yields two takeable products

The Builder SHALL expose asCCompileOutput and private asCDefinitions as parallel products and SHALL NOT place TypeInfo, functions or bytecode inside asCCompileOutput.

#### Scenario: Take the definition set off the Builder

- **GIVEN** successful compilation through DefinitionsFrozen of a Unit class with an int32 Value field and Set(int32) method
- **WHEN** the caller takes the Builder's definitions
- **THEN** the returned UniquePtr owns Unit and its methods with null GetEngine and TypeId -1

    A second take returns null; the Builder no longer owns that graph.

- **AND** destroying that unregistered owner deletes its private objects
- **BUT** failed compilation does not yield a usable taken graph

#### Scenario: Compile a later unit against a Taken set

- **GIVEN** frozen asCDefinitions containing First from an earlier compile
- **WHEN** a second Builder compiles class Second with a First handle field using Options.Dependencies
- **THEN** Second resolves First without Engine registration while owning only Second
- **BUT** unready dependencies and cross-unit cycles are rejected

    Mutually dependent types share one snapshot. Frozen HostProcess definitions may also be dependencies; their shared ownership and preassigned IDs do not assign an Engine or runtime IDs to private script objects.

#### Scenario: CompileOutput carries ClassGen descriptors without ScriptType

- **WHEN** a caller reads or takes CompileOutput after compiling Widget
- **THEN** asCDefinitionCompileOutput contains the Widget module/class descriptors with null ScriptType and ScriptFunction
- **BUT** that descriptor output does not own TypeInfo/bytecode and cannot replace taking the private definitions
