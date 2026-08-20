## ADDED Requirements

### Requirement: AngelScript fixtures live outside C++ test methods
Reusable authored AngelScript sources SHALL live as files under `Plugins/Angelscript/Source/AngelscriptTest/Fixtures/` and SHALL NOT be copied as inline `ASTEST_AS` strings inside data-driven harness cases. Homogeneous generated products are a separate source kind defined below and MUST NOT be required to exist as checked-in `.as` files.

#### Scenario: Fixture file is the source of truth
- **WHEN** a catalog case names `Syntax/OptionalEmpty.as`
- **THEN** the harness SHALL read that file from the Fixtures root
- **AND** the C++ driver SHALL NOT contain a second copy of that fixture body

#### Scenario: Host Script tree is not the fixture library
- **WHEN** the editor or commandlet performs normal project script discovery
- **THEN** files under `AngelscriptTest/Fixtures/` SHALL NOT be compiled as `/Angelscript/Game/` product scripts
- **AND** host `Script/` teaching or `UAngelscriptTestSuite` files SHALL NOT be required for the data-driven harness to load its fixtures

### Requirement: Tests fetch authored scripts by TestCorpus virtual path
The test module SHALL expose a Shared corpus API (`FAngelscriptTestScriptCorpus`) that loads authored fixture source by canonical virtual path `/Angelscript/Memory/TestCorpus/<relative>.as`. Any `AngelscriptTest` CQTest, World/functional test, or the data-driven harness SHALL be able to call this API without going through a catalog leaf. The API SHALL NOT be a production Runtime interface. The type SHALL NOT be named `FAngelscriptTestFixture`. Lookup SHALL reject `/Angelscript/Game/` paths, host `Script/` paths, `..`, and paths outside the Fixtures root.

#### Scenario: Virtual-path lookup returns OptionalEmpty
- **WHEN** a test calls `TryGetByVirtualPath` with `/Angelscript/Memory/TestCorpus/Syntax/OptionalEmpty.as`
- **THEN** the call SHALL succeed
- **AND** the record SHALL contain the checked-in OptionalEmpty source
- **AND** `RelativePath` SHALL be `Syntax/OptionalEmpty.as`

#### Scenario: A CQTest can load without a catalog case
- **WHEN** a CQTest that is not a DataDriven leaf requests that same virtual path
- **THEN** the corpus API SHALL return the source
- **AND** the test SHALL NOT be required to add a `cases.json` row

#### Scenario: Game virtual paths are rejected
- **WHEN** a caller requests `/Angelscript/Game/Syntax/OptionalEmpty.as`
- **THEN** `TryGetByVirtualPath` SHALL fail
- **AND** it SHALL NOT read host `Script/`

#### Scenario: Prefix enumerate lists authored fixtures
- **WHEN** a caller enumerates `/Angelscript/Memory/TestCorpus/Syntax/`
- **THEN** the result SHALL include `/Angelscript/Memory/TestCorpus/Syntax/OptionalEmpty.as`
- **AND** it SHALL NOT include host `Script/` files or `cases.json`

#### Scenario: Memory compile helper uses the same key
- **WHEN** a test calls `TryCompileMemory` with `/Angelscript/Memory/TestCorpus/Syntax/OptionalEmpty.as` on a clean shared engine
- **THEN** the module SHALL compile from corpus source
- **AND** `int EchoEmpty()` SHALL execute as `0`

#### Scenario: Generated products are overlay records not Game scripts
- **WHEN** generator `integral-bitwise` emits the `int8` `mutable_lvalue` cell
- **THEN** `TryGetByVirtualPath` for that cell's TestCorpus product path SHALL return the generated source
- **AND** the source SHALL NOT be checked in under `Fixtures/Generated/`
- **AND** that path SHALL still be under `/Angelscript/Memory/TestCorpus/`

### Requirement: Catalogs bind cases to fixture paths and virtual mounts
Each theme directory under Fixtures SHALL provide a `cases.json` catalog that lists relative fixture paths and a mount kind. The harness SHALL apply only the mounts declared by the running case. A `cache-roundtrip` case MAY also set `cacheRoot`; that value names a Cache V2 directory under `Saved/Automation/` and SHALL NOT be treated as a fixture path.

#### Scenario: Memory mount uses TestCorpus virtual paths
- **WHEN** a case declares mount kind `memory` with virtual root `/Angelscript/Memory/TestCorpus/Syntax`
- **THEN** each listed `.as` file SHALL compile through a memory-backed descriptor under that virtual root
- **AND** the harness SHALL NOT require a physical project `Script/` directory for that leaf

#### Scenario: Disk mount uses an isolated script root
- **WHEN** a case declares mount kind `disk`
- **THEN** the harness SHALL present the selected fixtures through an isolated engine script root whose virtual paths follow existing `/Angelscript/Game/<logical-path>` rules
- **AND** that engine's `GetProjectDir` SHALL NOT be the host project's real directory when doing so would compile unrelated host scripts

#### Scenario: One catalog does not load another theme's fixtures
- **WHEN** a Syntax case lists only `Syntax/OptionalEmpty.as`
- **THEN** compiling that case SHALL NOT add `Language/` fixtures to the engine
- **AND** a Language case SHALL NOT observe Syntax modules unless it lists them

#### Scenario: cacheRoot is not a fixture path
- **WHEN** a `cache-roundtrip` case sets `"cacheRoot": "OptionalEmptyCustom"`
- **THEN** the harness SHALL resolve that name to a Cache V2 directory under `Saved/Automation/DataDriven/CacheRoots/`
- **AND** it SHALL NOT read or write packs under `Fixtures/`

### Requirement: Multiple fixtures may share one virtual root
The harness SHALL compile every `.as` file listed by a case under that case's single declared mount so `#include` and multi-module fixtures work without inlining. A case MAY list one or more files.

#### Scenario: Two files compile as one mount
- **WHEN** a case lists `Language/Types.as` and `Language/Values.as` under one memory or disk mount
- **THEN** both sources SHALL be available to that leaf's compile observation
- **AND** execute observations MAY call functions from either compiled module

#### Scenario: Relative paths cannot escape the Fixtures root
- **WHEN** a catalog fixture path contains `..` or an absolute path
- **THEN** catalog validation SHALL fail
- **AND** the case SHALL NOT register

### Requirement: CQTest and World tests may use the corpus without becoming harness leaves
Tests that are not data-driven harness cases MAY keep `ASTEST_AS` for one-off C++ regressions. They MAY also load reusable AngelScript from `FAngelscriptTestScriptCorpus` by virtual path and run their own World, bind, or debugger assertions. The fixture library SHALL NOT require Bindings, HotReload, Debugger, Dump, Native SDK, or World tests to register a DataDriven catalog case. The COMPLEX harness SHALL NOT drive World/Actor/Debugger observations in Wave A. HotReload before/after pairs SHALL be owned by sibling change `test-as-hotreload-script-corpus`, not by DataDriven engine-profile leaves.

#### Scenario: Bindings CQTest keeps inline AS for a one-off
- **WHEN** a Bindings contract test compiles a snippet that will not be reused
- **THEN** it MAY keep `ASTEST_AS` inside the `TEST_METHOD`
- **AND** it SHALL NOT be required to add a Fixtures catalog entry

#### Scenario: World CQTest loads corpus source by virtual path
- **WHEN** a World functional test needs a reusable Actor script that also exists under `Fixtures/`
- **THEN** it MAY `TryGetByVirtualPath` and compile that source itself
- **AND** it SHALL NOT be required to add a DataDriven leaf for that compile

#### Scenario: Matrix coverage must use the library
- **WHEN** a scenario is defined as the same AngelScript fixture under more than one engine profile
- **THEN** that AngelScript source SHALL live in the Fixtures library
- **AND** additional profiles SHALL be added to the catalog rather than by copying the source into another C++ file

### Requirement: Unique scenarios are authored files, homogeneous products are generated
The fixture library SHALL treat a case as an authored scenario when the AngelScript body is unique (named capability, UE object lifecycle, one-off diagnostic). The harness SHALL generate AngelScript from C++ case tables when the body is a homogeneous type-operator-category product whose expected result is a formula. The harness SHALL NOT check in one `.as` file per generated product in v1.

#### Scenario: Optional empty is an authored file
- **WHEN** the Syntax catalog includes `syntax.optional-empty`
- **THEN** its source SHALL be the checked-in file `Fixtures/Syntax/OptionalEmpty.as`
- **AND** no C++ loop SHALL emit that function body

#### Scenario: Integer bitwise cells are generated
- **WHEN** a catalog names generator `integral-bitwise` with axes from the native type table
- **THEN** the harness SHALL emit one product leaf per selected type and operand category
- **AND** it SHALL NOT require `Fixtures/Syntax/LocalInt8BitAnd.as` through `LocalUInt64Shift.as` to exist on disk

#### Scenario: Generated products materialize for cache-roundtrip
- **WHEN** an `integral-bitwise` leaf lists profile `cache-roundtrip`
- **THEN** the harness SHALL write the generated AngelScript under the isolated temp `Script/` root used by both producer and consumer engines
- **AND** it SHALL NOT check that file into `Fixtures/Generated/`

#### Scenario: Unique Coverage scenarios stay authored
- **WHEN** a later Coverage migration includes `TArray.Sort` on an Actor with `UPROPERTY` and `BeginPlay`
- **THEN** that source SHALL be an authored fixture file
- **AND** it SHALL NOT be produced by substituting type names into a bitwise or conversion template

#### Scenario: Homogeneous Coverage expression rows generate
- **WHEN** Coverage IntExpression `ArithmeticOperators` is migrated onto the harness
- **THEN** the harness SHALL emit product leaves from a type table
- **AND** it SHALL NOT require one checked-in `.as` file per integer width

#### Scenario: Corpus AngelScript is not jit.cpp
- **WHEN** a fixture or generated product is the StaticJIT input
- **THEN** the source of truth SHALL be the AngelScript corpus
- **AND** the harness SHALL NOT require a checked-in handwritten `.jit.cpp` that copies that source

#### Scenario: Native SDK white-box products stay on the SDK suite
- **WHEN** a product needs raw `asIScriptEngine` bytecode, tokenizer, or metadata evidence
- **THEN** it SHALL remain an `Angelscript.TestModule.AngelScriptSDK.*` generated case
- **AND** the data-driven harness SHALL add a leaf for that product only if the same source must also run an `FAngelscriptEngine` profile such as cache or JIT

