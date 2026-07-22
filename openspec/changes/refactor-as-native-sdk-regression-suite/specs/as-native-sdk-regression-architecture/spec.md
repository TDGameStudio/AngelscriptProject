## ADDED Requirements

### Requirement: Native SDK regression tests use nine ownership domains
The native AngelScript SDK suite SHALL organize registering tests beneath `AngelScriptSDK/{Engine,Frontend,Compiler,Runtime,Module,TypeSystem,Language,Embedding,Conformance}` and non-registering helpers beneath `AngelScriptSDK/Support`.

#### Scenario: Directory and ID ownership agree
- **WHEN** an SDK test source is inspected
- **THEN** its directory SHALL match the first segment after `Angelscript.TestModule.AngelScriptSDK`
- **AND** no registering test source SHALL remain directly in the `AngelScriptSDK` root
- **AND** all nine domains SHALL remain part of the existing `AngelscriptTest` UE module rather than becoming new UE modules

#### Scenario: Support does not register tests
- **WHEN** the `Support` directory is scanned
- **THEN** it SHALL contain no `TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`, or legacy automation registration

### Requirement: Native test cases own deterministic raw SDK state
Each native SDK `TEST_METHOD` SHALL explicitly own its raw engine, modules, contexts, registrations, and message state unless a documented immutable fixture proves that sharing is safe.

#### Scenario: Test case exits normally or early
- **WHEN** a native test method completes or an assertion exits its scope
- **THEN** all case-owned contexts SHALL be unprepared and released
- **AND** all case-owned modules SHALL be discarded before the engine is shut down
- **AND** messages from another test case SHALL NOT remain visible

#### Scenario: Engine profile is selected
- **WHEN** a test constructs a native engine
- **THEN** it SHALL select either `BareSdk` or `ForkCompatibility` explicitly
- **AND** the selected profile SHALL apply a deterministic documented property set

#### Scenario: Core API changes process-global state
- **WHEN** a public core API has no getter/restore surface or is already owned by the production runtime
- **THEN** in-process SDK automation SHALL NOT replace, clear, or unprepare that state
- **AND** `audits/global-state.md` SHALL assign it a non-mutating integration/source-audit or Fork N/A disposition

#### Scenario: A reversible global or thread-local operation runs
- **WHEN** an SDK test acquires a global lock, starts a worker, allocates global memory, or installs case-owned state with a restore surface
- **THEN** a narrow scope SHALL restore/free/join/clean it before test exit
- **AND** the test SHALL NOT rely on suite order for cleanup

### Requirement: Declaration lookup and execution are unambiguous
The support layer SHALL provide exact declaration lookup, separate name lookup, and one context-based invocation path with type-correct argument and return handling.

#### Scenario: Exact declaration is absent
- **WHEN** `FindFunctionByDecl` or the compatibility `GetNativeFunctionByDecl` is called for a declaration that does not exist
- **THEN** it SHALL return null
- **AND** it SHALL NOT fall back to a same-name or sole module function

#### Scenario: Float and double functions execute
- **WHEN** the invoker executes a function returning `float` or `double`
- **THEN** it SHALL read the return value through the accessor for the declared type
- **AND** engine precision configuration SHALL NOT cause the float and double accessors to be interchanged

#### Scenario: Runtime stops without finishing
- **WHEN** a function suspends, aborts, or raises an exception
- **THEN** the invocation result SHALL preserve that exact AngelScript execution state
- **AND** the test SHALL be able to assert it without treating the state as a generic false result

### Requirement: Fork and upstream semantics remain explicitly classified
Every conformance scenario SHALL be classified as active current-fork behavior, active compatible behavior, compiled-disabled future 2.38 behavior, or documented structural non-applicability.

#### Scenario: Current fork semantics are asserted
- **WHEN** a behavior differs intentionally from AngelScript 2.38
- **THEN** an enabled test SHALL assert the current fork result and diagnostics exactly
- **AND** the test SHALL NOT accept multiple contradictory outcomes

#### Scenario: Future 2.38 expectation is recorded
- **WHEN** a selected 2.38 behavior is not yet supported
- **THEN** its topic-named test class SHALL compile and register with `TEST_CLASS_WITH_FLAGS_AND_TAGS`
- **AND** its flags SHALL include `EAutomationTestFlags::Disabled`
- **AND** its CQTest class tags SHALL include `TEXT("#as-v238-backport")`
- **AND** the test body SHALL state the desired 2.38 assertion

#### Scenario: Future host API is absent from current headers
- **WHEN** the desired 2.38 contract requires a C++ symbol that the current fork header does not declare
- **THEN** `audits/upstream-compatibility.md` SHALL classify it as `Future238 API Deferred`
- **AND** the record SHALL name the missing surface, desired contract, and conversion condition
- **AND** the implementation SHALL NOT add dead code, fake production declarations, or uncompilable Disabled tests

#### Scenario: Disabled source patterns are audited
- **WHEN** the native SDK suite is scanned
- **THEN** future coverage SHALL NOT be hidden behind `#if 0`, constant-false conditions, or unregistered test helpers

### Requirement: Native implementation coverage is audit complete
The change SHALL maintain auditable dispositions for all 41 vendored `as_*.cpp` implementation units, all 36 concrete internal classes with out-of-line logic, all 12 public SDK interfaces, and the global/interface method families in the core public API inventory.

#### Scenario: Implementation source inventory changes
- **WHEN** the static audit compares the ThirdParty source directory with `implementation-units.md`
- **THEN** every discovered `as_*.cpp` file SHALL have exactly one disposition
- **AND** every non-platform implementation SHALL map to direct or behavioral regression coverage

#### Scenario: Internal class inventory changes
- **WHEN** exported/internal class declarations and `internal-classes.md` are compared
- **THEN** all 36 approved classes SHALL map to direct test coverage
- **AND** the 14 newly exported declarations SHALL contain `ANGELSCRIPTRUNTIME_API` and a `[UE++]` rationale

#### Scenario: Public interface inventory changes
- **WHEN** the 12 approved `asI*` interfaces are compared with `interfaces.md`
- **THEN** each interface SHALL map to behavioral or explicit contract coverage
- **AND** `public-api.md` SHALL classify its core method families and error paths without importing add-ons

#### Scenario: Inactive callfunc backend is evaluated
- **WHEN** a platform-specific callfunc implementation is not selected for the current Win64 MSVC build
- **THEN** its coverage disposition SHALL be `Platform N/A`
- **AND** shared callfunc semantics SHALL remain covered through active-backend calling and execution tests

#### Scenario: Existing method inventory is migrated
- **WHEN** the current SDK source and `audits/test-methods.csv` are compared
- **THEN** all 433 current `TEST_METHOD` definitions SHALL appear exactly once by current file, class, and method
- **AND** every row SHALL have one approved disposition and an exact final file, class, method, prefix, classification, and rationale
- **AND** a merge, replacement, duplicate deletion, or invalid deletion SHALL name its replacement evidence

### Requirement: Core language semantics are covered without add-ons
The suite SHALL exercise AngelScript core syntax and runtime behavior independently of the SDK add-on libraries.

#### Scenario: Core object language is exercised
- **WHEN** the language-semantics coverage inventory is inspected
- **THEN** it SHALL map active tests for class declarations, fields/properties, virtual properties, methods, default/parameterized/copy construction, destruction, inheritance, override/virtual dispatch, access control, and fork reference behavior

#### Scenario: Core procedural language is exercised
- **WHEN** the language-semantics coverage inventory is inspected
- **THEN** it SHALL map active tests for functions, parameters/default arguments, local and const-global variables, expressions/operators/conversions, branches, loops, switch, break/continue/return, exceptions, namespaces, imports, enums, typedefs, and funcdefs

#### Scenario: Add-on boundary is audited
- **WHEN** SDK test includes and registrations are scanned
- **THEN** they SHALL NOT depend on `sdk/add_on` implementations such as scriptarray, dictionary, weakref, datetime, math/complex, or standard string
- **AND** tests MAY provide a minimal host `asIStringFactory` implementation solely to verify the core engine interface contract

#### Scenario: A language theme is considered complete
- **WHEN** Declarations, Functions, Variables, Properties, Constructors, Destructors, Inheritance, References, Expressions, Operators, Conversions, ControlFlow, Foreach, or Exceptions is evaluated
- **THEN** all applicable grammar, resolution, runtime, type/value, interaction, lifecycle, negative, fork/upstream, and isolation dimensions from `audits/language-semantics.md` SHALL have named test evidence or an explicit non-applicability rationale
- **AND** the theme SHALL NOT be accepted based only on a file name, a smoke case, a compile-only result, or aggregate test count

### Requirement: Every native SDK domain meets the behavioral depth standard
Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Language, Embedding, and Conformance SHALL each provide named evidence for all applicable completion dimensions in `audits/test-depth.md`.

#### Scenario: A non-language SDK domain is evaluated
- **WHEN** Engine, Frontend, Compiler, Runtime, Module, TypeSystem, Embedding, or Conformance is considered complete
- **THEN** its applicable public behavior, internal path, input partition, negative, lifecycle, interaction, isolation, and classification dimensions SHALL map to representative test method names or a justified non-applicability
- **AND** a file name, aggregate method count, source-unit owner, compile-only case, or smoke test SHALL NOT be accepted as sufficient evidence

#### Scenario: Deep evidence duplicates no external add-on behavior
- **WHEN** an input partition or interaction fixture is needed
- **THEN** it SHALL use core syntax, primitive/object/reference fixtures, or a minimal local host interface implementation
- **AND** it SHALL NOT import an AngelScript `sdk/add_on` library merely to increase breadth

#### Scenario: Interacting language features change behavior
- **WHEN** two core features affect overload resolution, access, initialization, dispatch, cleanup, or execution state
- **THEN** the owning theme SHALL include the meaningful interaction case
- **AND** it SHALL avoid redundant Cartesian combinations that do not change semantics

### Requirement: Internal white-box symbols are exported narrowly
The runtime SHALL export only the existing internal classes and string utility functions identified by this change so the separate `AngelscriptTest` DLL can call their real implementations.

#### Scenario: Export annotation is added
- **WHEN** one of the 14 approved internal classes or seven approved string functions is inspected
- **THEN** it SHALL have `ANGELSCRIPTRUNTIME_API` visibility
- **AND** the edit SHALL carry a `[UE++]` comment describing test visibility
- **AND** its layout, signature, ownership, and script registration behavior SHALL remain unchanged

### Requirement: Automation IDs use a single domain-scoped scheme
Every SDK test SHALL register below `Angelscript.TestModule.AngelScriptSDK.<Domain>.<Class>.<Method>` with no legacy alias registrations.

#### Scenario: Historical identities are scanned
- **WHEN** the SDK source and configuration are searched
- **THEN** no `ASSDK`, `NativeReference`, duplicate SDK smoke prefix, or flat pre-module SDK test identity SHALL remain
- **AND** `test-id-migration.md` SHALL map each retired prefix family to its replacement

#### Scenario: Root entry point is used
- **WHEN** `Angelscript.TestModule.AngelScriptSDK` is run
- **THEN** all nine domain prefixes SHALL be discoverable through that root
- **AND** `NativeCore` SHALL continue to include the root without per-domain duplication

### Requirement: Mis-layered UE tests move without coverage loss
Tests that require the UE wrapper, debugger, engine function callers, generated struct CppOps, or UE type registries SHALL live in their owning non-SDK test themes.

#### Scenario: Moved test destinations are executed
- **WHEN** implementation is complete
- **THEN** the exact prefixes `Compiler.ModulePipeline`, `Engine.ContextPool`, `Engine.FunctionCallers`, `Engine.TypeRegistry`, `Engine.TypeUsage`, `Debugger.Value`, `Debugger.Reification`, and `Generator.ASStruct.CppOps` SHALL be discoverable and pass independently

### Requirement: Phase-complete implementation precedes build and test execution
Applying this OpenSpec SHALL batch implementation into a complete structure phase and a complete coverage/integration phase, with no per-file or per-test build loop.

#### Scenario: Structure build begins
- **WHEN** the first `Tools/RunBuild.ps1` command is invoked for this change
- **THEN** all exports, support-layer migrations/deletions, cross-layer moves, nine-domain layout changes, automation-ID replacements, registration gates, and mechanical fixture migrations SHALL be complete
- **AND** the structure-mode static audit SHALL pass

#### Scenario: Final integration build begins
- **WHEN** the final planned `Tools/RunBuild.ps1` command is invoked
- **THEN** the P0/P1/nine-domain/core-language/future-2.38 coverage, complete audit records, configuration, and documentation SHALL be complete
- **AND** the complete static audit and strict OpenSpec validation SHALL pass

#### Scenario: Compile failures require another build
- **WHEN** a phase build reports multiple failures of the same causal class
- **THEN** the implementation SHALL batch those fixes before rerunning the build
- **AND** it SHALL NOT rebuild after each individual file fix

#### Scenario: Verification progresses from narrow to broad
- **WHEN** the final integration build passes
- **THEN** verification SHALL run the nine SDK domain prefixes, then moved-test prefixes, then the full SDK root, `NativeCore`, and `All`
- **AND** every command SHALL record its pass/fail counts and log location in `verification.md`
