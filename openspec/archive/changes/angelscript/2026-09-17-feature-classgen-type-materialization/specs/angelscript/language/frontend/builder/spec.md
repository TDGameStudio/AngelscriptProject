## MODIFIED Requirements

### Requirement: Builder yields two takeable products

#### Scenario: CompileOutput keeps Projected descriptors after definitions exist

- **WHEN** a caller compiles a USTRUCT with a UPROPERTY through `DefinitionsFrozen` or the default `ByteCodeEmitted` stop

    The source is `USTRUCT() struct FPoint { UPROPERTY() int X; };`.
    DefinitionsBuilt has already created private TypeInfo on `asCDefinitions`.

- **THEN** CompileOutput modules still come from `DescriptorConsumer.Project`

    `FPoint.bIsStruct` is true and `Properties` contains one entry named `X`.
    A TypeInfo name-only scan is not the CompileOutput authority.

- **AND** `ScriptType` and `ScriptFunction` remain null

    CompileOutput still does not own TypeInfo or bytecode.

- **BUT** taking private definitions remains a separate product

    `TakeDefinitions()` still returns the unique TypeInfo graph.
