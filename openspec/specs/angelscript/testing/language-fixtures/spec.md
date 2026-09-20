# Language hand-authored fixtures

## Purpose

Provide hand-authored complete-version core-language source fixtures through the existing code database.

## Requirements

### Requirement: Complete hand-authored Language inventory

The corpus SHALL expose every accepted Language FileTag, including second-wave chapter positives such as `Language/Auto/InferFromLiteral`, `Language/Class/Constructor`, `Language/Inheritance/Override`, `Language/Destructors/ClassDestructor`, `Language/Typedef/Alias`, and `Language/Mixin/FunctionMixin`, the live `Language/Interface/Declare` chapter, DECLARE-based `Language/Delegate/Declare` and multicast `Language/Event/Declare` chapters, and their `CompileFail` / `RuntimeFail` siblings when those polarities exist, with complete source versions and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`. Flat FileTags `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin` SHALL NOT remain as representative admitted identities.

    Keyword-only `delegate` / `event` programs are transitional CompileFail siblings, not live positives. Those Fail siblings may be removed when a later Change deletes the dedicated Tokens.

#### Scenario: Query the complete author corpus

- **WHEN** the admitted catalog is queried for the accepted Language FileTags

- **THEN** every positive pocket and each existing Fail sibling is retrievable

- **AND** Const material remains under Language/Syntax/Const

- **AND** no Language query requires VersionTag `root` as the representative source

    > Observables: Casting positives use FileTags `Language/Casting/ClassHandleCast`, `NullHandle`, `NumericImplicitConversion`, and `NumericExplicitConversion`.

#### Scenario: Query a second-wave chapter pocket

- **WHEN** the admitted catalog is queried for `Language/Auto/InferFromLiteral` and `Language/Class/ConstructorCompileFail`

    > Inputs: FileTags come from author paths under `AngelscriptTestCode/Language/Auto/` and `Language/Class/`.

- **THEN** each FileTag returns at least one parentless version with valid author metadata

- **AND** Get of retired flat `Language/Auto` does not succeed as a representative pocket

- **AND** class-without-name and super-outside-class negatives stay on Class or Inheritance Fail siblings

- **AND** no query requires VersionTag `root` as the representative source

    > Observables: first-wave Casting FileTags remain `ClassHandleCast`, `NullHandle`, `NumericImplicitConversion`, and `NumericExplicitConversion`. Const remains under `Language/Syntax/Const`. NullHandle and ClassHandleCast bodies use live spellings `nullptr` and `Cast<T>(…)`.

    > Boundaries: admission does not compile or execute the chapter source.

#### Scenario: Query the Interface chapter

- **WHEN** the admitted catalog is queried for `Language/Interface/Declare`

    > Inputs: FileTags come from author paths under `AngelscriptTestCode/Language/Interface/`.

- **THEN** the FileTag returns at least one parentless interface-declaration program

- **AND** `Language/Syntax/FunctionModifiers` is retrievable when `local` or `access` authoring exists

- **BUT** import, asset, funcdef, and `property`-decorator programs are not required in this inventory

    > Boundaries: removed syntax stays out of the Language catalog.

#### Scenario: Query Delegate and Event chapters

- **WHEN** the admitted catalog is queried for `Language/Delegate/Declare` and `Language/Event/Declare`

    > Inputs: FileTags come from author paths under `AngelscriptTestCode/Language/Delegate/` and `Language/Event/`.

- **THEN** each FileTag returns at least one parentless `DECLARE_*` callable-type declaration program

    > Observables: ordinary or dynamic `DECLARE_*` spellings. The Event chapter uses `DECLARE_MULTICAST_DELEGATE` or `DECLARE_DYNAMIC_MULTICAST_DELEGATE`.

- **AND** their CompileFail siblings are retrievable when those polarities exist, including leftover `delegate` / `event` introducers

- **BUT** `funcdef` programs are not required in this inventory

    > Boundaries: leftover `funcdef` is removed syntax. Catalog admission does not prove Bind/Execute. Language folder execute is not this Change's proving command.

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
