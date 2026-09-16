## MODIFIED Requirements

### Requirement: Replacement tests use their final public identity

The system SHALL register new C++ Automation tests beneath `Angelscript.UnitTest.<Area>.<Scenario>` without exposing their temporary physical source directory in public test names, types, or capability identities.

#### Scenario: Isolated baseline is discoverable
- **WHEN** UE Automation discovers the replacement baseline test
    > Inputs: Discovery uses the public Automation name rather than the physical NewVersion directory.
- **THEN** it is addressable through the `Angelscript.UnitTest.Baseline` prefix and passes without legacy CQTest helpers or legacy engine-pool fixtures
    > Observables: The baseline appears under its final public identity and has no dependency on quarantined framework services.

    Example: the public identity is `Angelscript.UnitTest.Baseline`.

#### Scenario: NativeEngine CQTests use one stable prefix
- **WHEN** a replacement CQTest exercises the reconstructed native AngelScript frontend
    > Inputs: CQTest's TestDir is `Angelscript.UnitTest.NativeEngine.<Layer>`; its class supplies a distinct scenario family and methods supply observable cases.
- **THEN** Unreal Automation exposes it beneath `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>.<Method>`
    > Observables: The public name is independent of the temporary `NewVersion` directory and of any future physical source reorganization.
- **BUT** no replacement test registers beneath a legacy public prefix
    > Boundaries: `Angelscript.TestModule`, `Angelscript.CppTests`, and `Angelscript.Editor` remain absent in the default reconstruction baseline.

#### Scenario: Legacy Automation prefixes are absent by default
- **GIVEN** the checked-in default compile options
    > Inputs: Legacy compilation is disabled while replacement compilation remains enabled.
- **WHEN** UE Automation enumerates registered tests
    > Details: Registration names are evaluated after all enabled test translation units load.
- **THEN** no test is registered beneath `Angelscript.TestModule`, `Angelscript.CppTests`, or `Angelscript.Editor`
    > Observables: The legacy public namespaces have zero discoverable registrations in the default baseline.

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

The system SHALL make CQTest available to replacement NativeEngine tests under `WITH_ANGELSCRIPT_TESTS` without reactivating any legacy AngelScript test framework surface.

#### Scenario: Replacement CQTest compiles under the replacement gate
- **GIVEN** the checked-in reconstruction compile policy

    > Inputs: `WITH_ANGELSCRIPT_TESTS=1` and `WITH_ANGELSCRIPT_UNITTESTS=0`.

- **WHEN** the `AngelscriptTest` module builds a replacement NativeEngine test

    > Inputs: Registering units live under module-root `NativeEngine/<Layer>/`; `NewVersion/` is not an active source root.

- **THEN** the test can use CQTest registration and matcher assertions

    > Observables:

    - `CQTest` is an explicit replacement-test dependency.
    - No legacy force include is required.
    - The test translation unit is discovered outside every ignored `Legacy/` subtree.

- **BUT** legacy helpers, engine-pool startup, and legacy-only dependencies remain excluded

    > Boundaries: Enabling CQTest as a UE testing library does not enable the quarantined AngelScript test framework. `TestFramework/` headers and sources are replacement-only helpers and do not register Automation tests; the registering translation units remain under `NativeEngine/`.

#### Scenario: NativeEngine fixtures are frontend-local
- **WHEN** a NativeEngine test creates inputs and captures results
    > Details: Fixtures may own source snapshots, diagnostics, frontend options, and compilation sessions introduced by later Changes.
- **THEN** their ownership and cleanup are local to the replacement test class or replacement-only support code
- **AND** no fixture obtains a mutable ambient `asCScriptEngine` or `FAngelscriptEngine`
    > Verification: The foundation tests compile and execute with the legacy runtime still dormant.

#### Scenario: Focused feedback uses one managed process
- **WHEN** one NativeEngine area is verified after an incremental editor build
    > Inputs: The narrowest stable `Angelscript.UnitTest.NativeEngine.<Layer>` prefix and `Fast = $true`.
- **THEN** all scenarios for that area execute in one Harness-managed Unreal process
    > Observables: The result retains Automation report, process exit, timeout, and workspace evidence.
- **BUT** process duration is not a portable correctness threshold
    > Boundaries: The measured approximately 26.8-second startup floor is environment evidence used to group tests, not a cross-machine performance requirement.

#### Scenario: SDK execution fixtures explicitly own their runtime

- **WHEN** a replacement NativeEngine test exercises VM behaviour
- **THEN** its scenario owns the minimal SDK Engine, actual definitions, native storage, executable images and cleanup required by that case

    > Detached metadata, frontend, image-builder and structural-verifier fixtures remain AS-Engine-free; CQTest may still run in the UE host. Actual execution owns a minimal SDK runtime rather than pretending metadata pointers supply allocation, GC and Context services. VM-only support is separate from common frontend setup and never obtains a mutable ambient Engine or a legacy engine pool.

- **AND** tests remain addressable as `Angelscript.UnitTest.NativeEngine.<Area>.<Scenario>` under the replacement compile gate
- **BUT** neither the dormant corpus nor the proposed unified test framework is required to execute them

## ADDED Requirements

### Requirement: Replacement tenants have durable module-root homes

Replacement tests SHALL use module-root NativeEngine, Bindings, Framework/FrameworkTests and Baseline homes. TestFramework/NativeEngine SHALL remain helper-only. NativeEngine Layer and Class tokens SHALL not duplicate one another.

#### Scenario: Select one proof layer

- **WHEN** Automation selects `Angelscript.UnitTest.NativeEngine.Basic`
- **THEN** it discovers Basic tests including `Basic.Foundation.ReplacementGateProvidesCQTest` and no other proof layer
- **AND** Framework, RuntimeBindings and Baseline retain their existing complete public identities

    Physical relocation does not enable quarantined legacy registrations.

### Requirement: Relocation conserves discovered test identities

A relocation SHALL preserve each discovered pre-move case through an explicit identity mapping and reject missing, duplicate or incorrectly classified destinations.

#### Scenario: A renamed case is not registered

- **GIVEN** a pre-move Tooling method has an explicitly mapped destination
- **WHEN** post-move discovery lacks that destination even though its old name is absent
- **THEN** migration acceptance fails with the missing identity
- **BUT** passing smoke or unchanged total counts cannot conceal the loss

### Requirement: Language coverage has independently justified executed outcomes

Required language cells SHALL have concrete inputs, independently justified outcomes and actual proving cases. Positive source expressions SHALL execute with runtime inputs. Unsettled contracts and known product defects SHALL not count as passing coverage.

#### Scenario: Execute a source arithmetic case

- **WHEN** a source function accepts runtime arguments and compiles, links and executes in an explicitly owned Context
- **THEN** its return value and required side effects match an independently authored expectation
- **BUT** source file or opcode presence alone does not prove execution coverage

#### Scenario: Boundary semantics are unsettled

- **WHEN** a required cell lacks an established expected result or failure contract
- **THEN** it remains explicitly unresolved and prevents a complete matrix claim
- **AND** retired constructs require rejection proof without positive execution cells
