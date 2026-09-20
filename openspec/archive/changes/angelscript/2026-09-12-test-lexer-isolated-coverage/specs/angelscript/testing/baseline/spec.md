# Lexer nested identity and replacement source root

## MODIFIED Requirements

### Requirement: Replacement tests use their final public identity

#### Scenario: Lexer unit uses a nested TestDir
- **WHEN** replacement CQTests exercise `asCTokenizer`

    > Inputs: TestDir is `Angelscript.UnitTest.NativeEngine.Lexer`. Class tokens name scenario groups, not the unit.

    Example public paths:

    - `Angelscript.UnitTest.NativeEngine.Lexer.Contracts.FrozenOptionsAreValueOwned`
    - `Angelscript.UnitTest.NativeEngine.Lexer.Contracts.EmptyAndTriviaOnlySourcesReachStableEOF`
    - `Angelscript.UnitTest.NativeEngine.Lexer.SpelledKinds.SpelledKindsRoundTrip`
    - `Angelscript.UnitTest.NativeEngine.Lexer.SpelledKinds.KeywordRecognitionIsCaseSensitive`
    - `Angelscript.UnitTest.NativeEngine.Lexer.Recovery.MalformedUtf8FamiliesAdvanceExactly`
    - `Angelscript.UnitTest.NativeEngine.Lexer.Recovery.Utf8BomIsWhitespace`

- **THEN** Unreal Automation exposes those tests beneath `Angelscript.UnitTest.NativeEngine.Lexer.<Scenario>.<Method>`

    > Observables: The unit token `Lexer` is the TestDir segment. The physical folders `NativeEngine/Lexer/` and `TestFramework/` do not appear in the public name.

- **BUT** the class token is not `Lexer`

    > Boundaries: Nesting must not publish `Angelscript.UnitTest.NativeEngine.Lexer.Lexer.*`.

### Requirement: NativeEngine tests own an isolated CQTest foundation

#### Scenario: Replacement CQTest compiles under the replacement gate
- **GIVEN** the checked-in reconstruction compile policy

    > Inputs: `WITH_ANGELSCRIPT_TESTS=1` and `WITH_ANGELSCRIPT_UNITTESTS=0`.

- **WHEN** the `AngelscriptTest` module builds a replacement NativeEngine test

    > Inputs: Translation units may live under `NewVersion/NativeEngine/` or under `NativeEngine/` at the module root, including `NativeEngine/Lexer/`.

- **THEN** the test can use CQTest registration and matcher assertions

    > Observables:

    - `CQTest` is an explicit replacement-test dependency.
    - No legacy force include is required.
    - The test translation unit is discovered outside every ignored `Legacy/` subtree.

- **BUT** legacy helpers, engine-pool startup, and legacy-only dependencies remain excluded

    > Boundaries: Enabling CQTest as a UE testing library does not enable the quarantined AngelScript test framework. `TestFramework/` headers and sources are replacement-only helpers and do not register Automation tests; the registering translation units remain under `NativeEngine/`.

