## REMOVED Requirements

### Requirement: Native SDK 4 layers SHALL each have themed white-box unit test coverage
**Reason**: Four compiler-core layers are retained but are no longer an adequate architecture or completeness boundary for the native SDK suite.
**Migration**: Use the new ownership-domain and audit-backed requirement below; Tokenizer, Parser, ScriptNode, and Bytecode remain covered under Frontend/Compiler.

### Requirement: Native SDK tests SHALL register under the existing AngelscriptNative group without configuration changes
**Reason**: The root group stays stable, but obsolete Smoke filters must be removed and every test now requires a domain segment.
**Migration**: Run the stable `Angelscript.TestModule.AngelScriptSDK` root or a new domain-scoped prefix.

### Requirement: Existing native SDK tests SHALL remain green after each phase
**Reason**: The old requirement freezes four file/class names and a 17-case baseline that no longer matches the approved full reorganization.
**Migration**: Preserve behavior through the file/ID migration maps and validate at the two large phase checkpoints plus ordered final automation runs.

### Requirement: Native SDK tests SHALL share helpers via AngelscriptNativeTestSupport.h
**Reason**: The old requirement names the now-duplicated execution header as an implementation owner.
**Migration**: Keep `AngelscriptNativeTestSupport.h` as the stable thin umbrella and use the five focused internal Support headers.

### Requirement: Native SDK tests SHALL respect project test conventions and inline AS formatting rules
**Reason**: The archived scenario incorrectly requires AS content at column zero and conflicts with the current `UnitTest.md`/`ASInlineFormattingRule.md` dedenting contract.
**Migration**: Use visually indented `ASTEST_AS_ANSI(R"AS(...)AS")` fixtures and the current unit-test registration/assertion rules.

### Requirement: Native SDK test coverage SHALL document its current scale in the test catalog
**Reason**: Fixed `151 new` and `301/301` values are historical snapshots, not a durable post-refactor requirement.
**Migration**: Generate active/disabled/domain and coverage-inventory totals and record fresh verification evidence.

### Requirement: SDK namespace consolidation SHALL stay separate from SDK behavior coverage expansion
**Reason**: The approved change intentionally closes structural and P0/P1/core-language behavioral coverage together.
**Migration**: Use the new combined completeness requirement; the change remains open while any required coverage item is unowned.

### Requirement: Native SDK behavior coverage SHALL respect the bare-engine boundary
**Reason**: The boundary remains valid but is strengthened from documenting limitations to moving UE-dependent tests and executing feasible raw behavior.
**Migration**: Use the new raw-engine-boundary requirement below and the explicit moved-test map.

### Requirement: Native SDK tests SHALL use SDK naming and explicit behavior boundaries
**Reason**: The naming requirement is expanded to mandatory domain-scoped IDs and strict fork/compatible/future semantics.
**Migration**: Use the new domain-scoped naming and semantics requirement plus `audits/test-id-migration.md`.

## ADDED Requirements

### Requirement: Native SDK coverage SHALL be organized by implementation ownership
The `AngelscriptTest` module SHALL provide systematic native SDK coverage across Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, and Conformance, replacing the historical four-layer-only organization.

#### Scenario: Frontend compiler-core coverage remains present
- **WHEN** the reorganized suite is inspected
- **THEN** Tokenizer, Parser, ScriptNode, and Bytecode coverage SHALL retain literals/operators/whitespace, declarations/expressions/errors, shape/source-range/copy, and opcodes/jumps/optimization themes
- **AND** direct internal access patterns SHALL continue to exercise the real implementations

#### Scenario: P0 and P1 ownership coverage is present
- **WHEN** all module test sources and audit records are inspected
- **THEN** the suite SHALL cover engine lifecycle/configuration, parsing/building/compilation, execution/context/GC, module/import/save-load, internal type system, fork language behavior, native embedding, and conformance decisions
- **AND** no coverage claim SHALL rely only on aggregate test counts

### Requirement: Native SDK tests SHALL register under the stable AngelScriptSDK root
The reorganized tests SHALL be discoverable through the existing root `Angelscript.TestModule.AngelScriptSDK`, and domain-specific execution SHALL use one of the nine approved first-level segments.

#### Scenario: Domain automation prefixes are discovered
- **WHEN** the Unreal automation framework scans tests after this change is applied
- **THEN** test classes SHALL register under `Angelscript.TestModule.AngelScriptSDK.<Domain>.<Class>`
- **AND** the root group SHALL discover all nine domains without separate smoke aliases

#### Scenario: Build system discovers moved sources
- **WHEN** files are moved into subdirectories beneath `AngelscriptTest`
- **THEN** the standard Unreal build SHALL discover and compile them without explicit source-file lists

### Requirement: Native SDK tests SHALL remain behaviorally complete after restructuring
The refactor SHALL preserve meaningful existing assertions while deleting duplication, correcting false coverage, and replacing permissive assertions with one authoritative expected result.

#### Scenario: Existing behavior is moved or replaced
- **WHEN** an old test file is deleted or split
- **THEN** its valid scenarios SHALL appear in the file map with a destination test or an explicit obsolete/duplicate rationale
- **AND** disabled fake Atomic/Thread/StringUtil scenarios SHALL be replaced by tests that call the real runtime implementations
- **AND** `audits/test-methods.csv` SHALL account for all 433 current methods exactly once

#### Scenario: Compile-only label is used honestly
- **WHEN** a test only verifies compilation or metadata
- **THEN** its class/method name and assertion text SHALL state that boundary
- **AND** it SHALL NOT be counted as executed runtime behavior

#### Scenario: Runtime behavior is feasible on the raw engine
- **WHEN** a language/object/runtime case can execute without the UE wrapper
- **THEN** the test SHALL execute it and assert the observable result, exception, suspend, abort, or state transition

### Requirement: Native SDK tests SHALL share helpers through focused support headers
Cross-file SDK helpers SHALL have one implementation owner in the five `Support` headers and SHALL be aggregated by `AngelscriptNativeTestSupport.h`.

#### Scenario: Shared helpers have one definition
- **WHEN** the SDK directory is scanned
- **THEN** engine ownership, module building, function invocation, compiler access, builder access, diagnostics, and binary streaming SHALL each have one shared implementation
- **AND** file-local helpers SHALL be class-private or uniquely named for unity-build safety

#### Scenario: Unity build compiles
- **WHEN** `Tools/RunBuild.ps1` builds the editor target with the repository's normal unity configuration
- **THEN** the `AngelscriptTest` module SHALL have zero duplicate-symbol or redefinition failures from merged SDK test units

### Requirement: Native SDK tests SHALL respect current unit-test and inline AS rules
All modified native tests SHALL follow `Documents/UnitTest/UnitTest.md` and `Documents/Rules/ASInlineFormattingRule.md`.

#### Scenario: Registration gate is inspected
- **WHEN** an SDK `.cpp` contains CQTest or automation registration
- **THEN** the registration body SHALL be guarded by `#if WITH_ANGELSCRIPT_UNITTESTS`
- **AND** no old or broader unit-test gate SHALL be introduced

#### Scenario: Raw SDK source is embedded
- **WHEN** a native test passes inline source as `const char*` or `std::string`
- **THEN** it SHALL use `ASTEST_AS_ANSI(R"AS(...)AS")`
- **AND** the source and closing delimiter SHALL be visually indented and dedented by the wrapper
- **AND** it SHALL use Allman braces and not `"\\n"` concatenation

#### Scenario: CQTest assertions are modified
- **WHEN** a CQTest main flow is refactored
- **THEN** it SHALL prefer matcher assertions and keep scenario intent visible in the `TEST_METHOD`

#### Scenario: CQTest class and method structure is inspected
- **WHEN** a final active SDK test class is inspected
- **THEN** it SHALL use `TEST_CLASS_WITH_FLAGS`; only Future238 classes SHALL use `TEST_CLASS_WITH_FLAGS_AND_TAGS`
- **AND** scenario compile, execute, and assert intent SHALL remain visible in scenario-specific `TEST_METHOD`s
- **AND** one-class helpers SHALL be private with `public:` restored before hooks and methods
- **AND** helpers receiving `FAutomationTestBase&` SHALL receive `*TestRunner`

#### Scenario: Native SDK engine lifecycle is inspected
- **WHEN** a raw SDK `TEST_METHOD` creates or mutates SDK registrations
- **THEN** it SHALL own a raw `asIScriptEngine` for that method and release all case-owned state
- **AND** it SHALL NOT use the class-level `FAngelscriptEngine` wrapper lifecycle
- **AND** moved wrapper CQTests SHALL continue to follow the class-level lifecycle in `UnitTest.md`

### Requirement: Native SDK coverage scale SHALL be generated and documented
The final source/test counts, active/disabled totals, per-domain totals, and coverage-inventory closure SHALL be produced by the static audit and reflected in test documentation.

#### Scenario: Test catalog is updated
- **WHEN** implementation and verification finish
- **THEN** `TestCatalog.md` SHALL report the generated per-domain definition counts, active/disabled totals, and latest full SDK pass/fail result
- **AND** it SHALL not retain the stale `301/301` snapshot as the current post-refactor result

#### Scenario: Test guide lists domain commands
- **WHEN** `Documents/Guides/Test.md` is inspected
- **THEN** it SHALL list an explicit `Tools\RunTests.ps1` command with `-TimeoutMs` for each of the nine domain prefixes

### Requirement: Native SDK structural and behavioral completeness SHALL be evaluated together
The OpenSpec SHALL not represent the refactor as complete until helper/layout/ID cleanup and the approved P0/P1 behavior records are both closed.

#### Scenario: Structural work is complete but coverage entries remain open
- **WHEN** any implementation-unit, internal-class, interface, public-API, domain-depth, or language-semantics coverage item lacks its approved disposition or named test mapping
- **THEN** this change SHALL remain incomplete
- **AND** the missing row SHALL remain an unchecked task rather than an untracked follow-up

### Requirement: Native SDK behavior coverage SHALL respect the raw-engine boundary
Raw SDK tests SHALL not initialize or rely on `FAngelscriptEngine`, UE reflection registration, editor services, or generated UE types.

#### Scenario: UE integration is required
- **WHEN** a scenario requires the plugin engine wrapper, Debugger, UE type registry, generated struct CppOps, or engine-specific function callers
- **THEN** it SHALL move to the owning non-SDK test layer
- **AND** the SDK file map SHALL record its new prefix

#### Scenario: Fork-specific raw behavior executes
- **WHEN** the behavior is available through `asIScriptEngine`, public SDK interfaces, or exported internal classes
- **THEN** it SHALL remain in the native SDK suite and use raw ownership helpers

### Requirement: Native SDK tests SHALL use domain-scoped SDK naming and explicit semantics
Source files, classes, helper types, and automation IDs SHALL use `SDK` or descriptive native terminology and SHALL state runtime, compile, metadata, fork, compatible, or future-2.38 intent where ambiguity exists.

#### Scenario: Historical naming is collapsed
- **WHEN** the SDK source tree is scanned
- **THEN** there SHALL be no `ASSDK` source/class/helper/automation name and no `NativeReference` automation segment
- **AND** new names SHALL map to the nine ownership domains

#### Scenario: Permissive behavior assertion is encountered
- **WHEN** an existing test accepts either current fork behavior or a conflicting upstream behavior
- **THEN** it SHALL be split into one enabled current-fork assertion and, where approved, one disabled `#as-v238-backport` expectation
