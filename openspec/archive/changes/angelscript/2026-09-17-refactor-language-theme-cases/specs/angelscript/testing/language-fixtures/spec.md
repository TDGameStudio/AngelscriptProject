## MODIFIED Requirements

### Requirement: Complete hand-authored Language inventory

The corpus SHALL expose every accepted Language FileTag, including positive theme pockets and their `CompileFail` / `RuntimeFail` siblings when those polarities exist, with complete source versions and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`.

#### Scenario: Query the complete author corpus

- **WHEN** the admitted catalog is queried for the accepted Language FileTags
- **THEN** every positive pocket and each existing Fail sibling is retrievable
- **AND** Const material remains under Language/Syntax/Const
- **AND** no Language query requires VersionTag `root` as the representative source

    > Observables: Casting positives use FileTags `Language/Casting/ClassHandleCast`, `NullHandle`, `NumericImplicitConversion`, and `NumericExplicitConversion`.

### Requirement: Negative programs remain valid source materials

The corpus SHALL store each negative program as a complete version with valid container metadata in a Fail sibling file, independently of whether its source compiles.

#### Scenario: Query an invalid struct member declaration

- **WHEN** Language/Syntax/StructFieldsCompileFail version `invalid-duplicate-field` is requested
- **THEN** the database returns the complete duplicate-member program
- **BUT** database admission does not claim compilation success or diagnose the language error

    > Boundaries: `@topic Negative` may still appear as an open label. Compile versus runtime polarity is the file suffix, not a closed topic enum.

### Requirement: Real production fixture adoption

The public corpus SHALL keep Language/Syntax/StructFields as a Family whose parentless version is not required to be named `root`.

#### Scenario: Read a child independently

- **WHEN** StructFields/`add-field` is read before and after StructFields/`fields-two`
- **THEN** both child reads return the same complete struct with X, Y and Z and the same annotations and origin mapping
- **AND** Language/Counter is absent from the production catalog
