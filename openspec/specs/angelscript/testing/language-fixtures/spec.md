# Language hand-authored fixtures

## Purpose

Provide hand-authored complete-version core-language source fixtures through the existing code database.

## Requirements

### Requirement: Complete hand-authored Language inventory

The corpus SHALL expose all 47 accepted FileTags under Language with complete source versions and valid v1 author metadata.

#### Scenario: Query the complete author corpus

- **WHEN** the admitted catalog is queried for the accepted Language FileTags
- **THEN** all 47 files and each root version are retrievable
- **AND** Const material is under Language/Syntax/Const

### Requirement: Negative programs remain valid source materials

The corpus SHALL store each negative program as a complete version with valid container metadata and a Negative topic, independently of whether its source compiles.

#### Scenario: Query an invalid struct member declaration

- **WHEN** Language/Syntax/StructFields version invalid-duplicate-field is requested
- **THEN** the database returns the complete duplicate-member program and its Negative metadata
- **BUT** database admission does not claim compilation success or diagnose the language error

### Requirement: Real production fixture adoption

The public corpus SHALL replace Language/Counter with Language/Syntax/StructFields while retaining independent source versions and annotation-bearing material.

#### Scenario: Read a child independently

- **WHEN** StructFields/add-field is read before and after StructFields/root
- **THEN** both child reads return the same complete struct with X, Y and Z and the same annotations and origin mapping
- **AND** Language/Counter is absent from the production catalog

### Requirement: Explicit source-only boundaries

The corpus SHALL distinguish lexical-only source material from supported positive language claims and keep host/import exclusions visible in migration provenance.

#### Scenario: Preserve directive-looking literal text

- **WHEN** Language/Preprocessor/DirectiveInString is queried
- **THEN** its literal/comment tokens are available as SourceOnly material without FString observer APIs
- **BUT** the fixture's admission does not prove host-free compilation or preprocessing execution

### Requirement: Authored source bytes survive C++ registration

The registered corpus SHALL preserve each migrated author's clean version source exactly, keyed by FileTag and VersionTag.

#### Scenario: Compare the complete registered corpus with its author sources

- **WHEN** every registered Language version is dumped and compared with the migrated author containers' parsed clean source
- **THEN** the complete file/version identity sets and each version's source bytes match exactly

    Source comments, literal content, whitespace and final-newline presence are significant. Container metadata and annotation markers follow the existing parser's authored-to-clean transformation. Expected source is obtained from authored containers; actual source is obtained from the compiled database.

- **AND** current file/version metadata and typed annotation names and clean-byte coordinates are preserved

    The file-level grammar version is distinct from each source VersionTag. Escaped annotation text follows the existing parser contract and does not create an annotation. Topic selection metadata and parent identity retain their meaning.

- **AND** missing or extra identities, failed queries, changed metadata/annotations and changed source bytes cause verification failure
- **BUT** equality does not assert unchanged legacy wrappers or language compilation/execution success
