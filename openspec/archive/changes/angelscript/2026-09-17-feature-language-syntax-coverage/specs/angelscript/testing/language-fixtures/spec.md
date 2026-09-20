## Purpose

Keep the Language author inventory aligned with per-syntax chapter FileTags after the second-wave flat pockets retire.

## MODIFIED Requirements

### Requirement: Complete hand-authored Language inventory

The corpus SHALL expose every accepted Language FileTag, including second-wave chapter positives such as `Language/Auto/InferFromLiteral`, `Language/Class/Constructor`, `Language/Inheritance/Override`, `Language/Destructors/ClassDestructor`, `Language/Typedef/Alias`, and `Language/Mixin/FunctionMixin`, the live `Language/Interface/Declare`, `Language/Delegate/Declare`, and `Language/Event/Declare` chapters, and their `CompileFail` / `RuntimeFail` siblings when those polarities exist, with complete source versions and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`. Flat FileTags `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin` SHALL NOT remain as representative admitted identities.

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

    > Boundaries: removed syntax stays out of the Language catalog in this Change.

#### Scenario: Query Delegate and Event chapters

- **WHEN** the admitted catalog is queried for `Language/Delegate/Declare` and `Language/Event/Declare`

    > Inputs: FileTags come from author paths under `AngelscriptTestCode/Language/Delegate/` and `Language/Event/`.

- **THEN** each FileTag returns at least one parentless callable-type declaration program
- **AND** their CompileFail siblings are retrievable when those polarities exist
- **BUT** `funcdef` programs are not required in this inventory

    > Boundaries: leftover `funcdef` is removed syntax and stays out of the Language catalog in this Change.
