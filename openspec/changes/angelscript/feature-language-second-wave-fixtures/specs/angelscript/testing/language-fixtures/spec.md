## Purpose

Keep the hand-authored Language inventory complete after the second-wave themes are admitted.

## MODIFIED Requirements

### Requirement: Complete hand-authored Language inventory

The corpus SHALL expose every accepted Language FileTag, including the second-wave positives `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin`, and their `CompileFail` siblings when those polarities exist. A FileTag SHALL NOT be required to contain a version named `root`.

#### Scenario: Query a second-wave theme pocket

- **WHEN** the admitted catalog is queried for `Language/Auto` and `Language/ClassCompileFail`
- **THEN** each FileTag returns at least one parentless version with valid author metadata
- **AND** class-without-name and super-outside-class negatives are stored on Class or Inheritance Fail siblings, not duplicated on `Language/Syntax/ClassDeclarationCompileFail`
- **AND** no query requires VersionTag `root` as the representative source

    > Observables: first-wave Casting FileTags remain `ClassHandleCast`, `NullHandle`, `NumericImplicitConversion`, and `NumericExplicitConversion`. Const remains under `Language/Syntax/Const`.
