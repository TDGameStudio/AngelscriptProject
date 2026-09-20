## MODIFIED Requirements

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
- **AND** each module descriptor's ScriptModule remains null

    CompileOutput does not construct `asCModule`. Register later fills ScriptModule.

- **BUT** that descriptor output does not own TypeInfo/bytecode and cannot replace taking the private definitions

#### Scenario: CompileOutput keeps Projected descriptors after definitions exist

- **WHEN** a caller compiles a USTRUCT with a UPROPERTY through `DefinitionsFrozen` or the default `ByteCodeEmitted` stop

    The source is `USTRUCT() struct FPoint { UPROPERTY() int X; };`.
    DefinitionsBuilt has already created private TypeInfo on `asCDefinitions`.

- **THEN** CompileOutput modules still come from `DescriptorConsumer.Project`

    `FPoint.bIsStruct` is true and `Properties` contains one entry named `X`.
    A TypeInfo name-only scan is not the CompileOutput authority.

    > Verification: NativeEngine CompileLifecycle `ProjectedUStructSurvivesDefinitionsFrozen` and `ProjectedUStructSurvivesByteCodeEmitted`.

- **AND** `ScriptType`, `ScriptFunction`, and `ScriptModule` remain null

    CompileOutput still does not own TypeInfo, bytecode, or `asCModule`.

- **BUT** taking private definitions remains a separate product

    `TakeDefinitions()` still returns the unique TypeInfo graph.
