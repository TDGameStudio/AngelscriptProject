## ADDED Requirements

### Requirement: Catalog cases expand to independent Automation leaves
The Angelscript test module SHALL register a COMPLEX Automation bridge that discovers fixture catalogs and expands each `(case id, profile id)` pair into one independently selectable Automation leaf under `Angelscript.TestModule.DataDriven`.

#### Scenario: Catalog with two profiles yields two leaves
- **WHEN** a valid catalog case `syntax.optional-empty` lists profiles `vm` and `cache-roundtrip`
- **THEN** Automation enumeration SHALL include `Angelscript.TestModule.DataDriven.Syntax.syntax.optional-empty.vm` and `Angelscript.TestModule.DataDriven.Syntax.syntax.optional-empty.cache-roundtrip`
- **AND** each leaf SHALL have a distinct parameter command that identifies that pair

#### Scenario: A single leaf can be run by prefix
- **WHEN** the runner is invoked with prefix `Angelscript.TestModule.DataDriven.Syntax.syntax.optional-empty.vm`
- **THEN** only that `(case, profile)` pair SHALL execute
- **AND** sibling profiles SHALL NOT run

#### Scenario: Unit-test gate omits the bridge
- **WHEN** `WITH_ANGELSCRIPT_UNITTESTS=0`
- **THEN** the COMPLEX bridge SHALL NOT register Automation tests

#### Scenario: DataDriven is not the script-suite bridge
- **WHEN** a catalog leaf is enumerated
- **THEN** its beautified name SHALL start with `Angelscript.TestModule.DataDriven`
- **AND** it SHALL NOT be registered under `Angelscript.ScriptTests`
- **AND** `RunTest` SHALL NOT invoke `UAngelscriptTestSuite` or `FAngelscriptScriptTestRunner`

### Requirement: The COMPLEX bridge uses a per-leaf session
The registered `FAutomationTestBase` instance SHALL be a handwritten COMPLEX subclass (`bInComplexTask` true) and SHALL NOT store `FAngelscriptEngine` pointers or compiled modules across `RunTest` calls. Each `RunTest` SHALL construct a short-lived session that acquires engines, runs observations, and releases them before return. `Parameters` SHALL be a catalog lookup key. The harness SHALL NOT reimplement CQTest `TEST_METHOD` registration or migrate existing CQTest files onto this base.

#### Scenario: Command is a key not a packed blob
- **WHEN** `GetTests` emits a leaf for `syntax.optional-empty` profile `vm`
- **THEN** `OutTestCommands` SHALL contain a parseable key such as `Syntax/syntax.optional-empty@vm`
- **AND** it SHALL NOT contain observation values or an `FAngelscriptEngineConfig` serialization
- **AND** it SHALL NOT contain a JSON object, `@file` path, or comma-packed expected values

#### Scenario: Session does not leak onto the registered instance
- **WHEN** two DataDriven leaves run in sequence on the same COMPLEX instance
- **THEN** the second leaf SHALL NOT observe engine pointers or compiled modules stored as members of the registered Automation object
- **AND** shared-engine leaves SHALL still `ResetModules` in session teardown

#### Scenario: CQTest macros are not the expander
- **WHEN** a catalog case is added without a new C++ `TEST_METHOD`
- **THEN** `GetTests` SHALL still enumerate that leaf from the catalog snapshot
- **AND** the change SHALL NOT require a CQTest `TEST_CLASS` for that case

### Requirement: Complex payloads do not travel on COMPLEX Parameters
The COMPLEX `Parameters` string SHALL remain a catalog lookup key. Structured input (observations, `cacheRoot`, generated source, later `args` or JSON oracles) SHALL live in the in-memory catalog snapshot, or in a Saved sidecar whose path is stored in that snapshot. Structured output SHALL leave through `ExecutionInfo` and Saved artifacts. `OutTestCommands` SHALL NOT contain JSON objects, `@file` tokens, or comma-packed expected values.

#### Scenario: Fat input is looked up by key
- **WHEN** `RunTest` receives the command for `syntax.optional-empty` profile `vm`
- **THEN** the session SHALL load fixtures, observations, and expected values from the catalog snapshot keyed by that command
- **AND** it SHALL NOT parse observation JSON out of `Parameters`

#### Scenario: Failures report through ExecutionInfo
- **WHEN** an `executeInt` observation does not match
- **THEN** the leaf SHALL fail via the Automation test `ExecutionInfo`
- **AND** `RunTest` SHALL return false
- **AND** the mismatch SHALL NOT be encoded as a JSON blob in `Parameters`

#### Scenario: Generated source is not stuffed into the command
- **WHEN** a generated product leaf is enumerated
- **THEN** `OutTestCommands` SHALL still be a product key such as `Products/integral-bitwise.int8.mutable_lvalue@vm`
- **AND** the generated AngelScript SHALL live on the snapshot leaf or a Saved sidecar referenced by that snapshot
- **AND** on failure the log SHALL still contain `[AS-SOURCE-BEGIN]` dumps

#### Scenario: Performance blobs are files
- **WHEN** a leaf lists `perfCollect`
- **THEN** the collected metrics SHALL be written under `Saved/Automation/` as an artifact file
- **AND** that path SHALL NOT be placed in `OutTestCommands`

### Requirement: Each leaf reports its driving row in ExecutionInfo
Every DataDriven `RunTest` SHALL emit one Info event whose text starts with `[AS-DD-DRIVER]` and includes the lookup key, profile id, engine lifecycle, fixture paths or product cell, and a compact observation summary. On failure the first error SHALL repeat that card. The card SHALL NOT be placed in `OutTestCommands`. The card SHALL NOT include generated AngelScript source or a serialized `FAngelscriptEngineConfig`.

#### Scenario: A passing VM leaf logs the driver card
- **WHEN** `syntax.optional-empty` profile `vm` runs and passes
- **THEN** `ExecutionInfo` SHALL contain an Info entry starting with `[AS-DD-DRIVER]`
- **AND** that entry SHALL include `key=Syntax/syntax.optional-empty@vm`
- **AND** it SHALL include `profile=vm` and `engine=shared`
- **AND** it SHALL include fixture `Syntax/OptionalEmpty.as`

#### Scenario: A failing observation still names the row
- **WHEN** an `executeInt` observation fails
- **THEN** the error text SHALL contain `[AS-DD-DRIVER]` and the leaf key
- **AND** it SHALL still include the case id, profile id, and function declaration

#### Scenario: A skip still names the row
- **WHEN** `runtime-jit` Info-skips because no factory is registered
- **THEN** `ExecutionInfo` SHALL still contain the `[AS-DD-DRIVER]` Info entry for that key
- **AND** a separate Info entry SHALL name the missing BackendId

#### Scenario: The driver card is not the Automation command
- **WHEN** `GetTests` emits the OptionalEmpty `vm` leaf
- **THEN** `OutTestCommands` SHALL remain `Syntax/syntax.optional-empty@vm`
- **AND** it SHALL NOT contain the `[AS-DD-DRIVER]` line

### Requirement: Leaf identity maps back to the fixture file
The COMPLEX bridge SHALL report the primary AngelScript fixture path as the leaf source file so Session Frontend and failure output point at the `.as` fixture rather than only the C++ driver.

#### Scenario: Failure names the fixture
- **WHEN** an `executeInt` observation fails
- **THEN** `GetTestSourceFileName` for that complete test name SHALL return the primary fixture `.as` path
- **AND** the failure message SHALL include the case id, profile id, and function declaration

### Requirement: Generated products expand from case tables and dump source on failure
The harness SHALL accept catalog cases that name a product generator instead of a checked-in `.as` file. Each generated product SHALL become an independent Automation leaf whose id is a stable product key. On compile or execute failure the harness SHALL print the generated AngelScript with numbered lines.

#### Scenario: Generator expands type cells
- **WHEN** a catalog names generator `integral-bitwise` over the signed and unsigned integer native type cases and the `mutable_lvalue` category
- **THEN** `GetTests` SHALL emit one leaf per type such as `Angelscript.TestModule.DataDriven.Products.integral-bitwise.int8.mutable_lvalue.vm`
- **AND** those leaves SHALL NOT require matching files under `Fixtures/`

#### Scenario: Generated failure prints the AS
- **WHEN** a generated product leaf fails to compile or execute
- **THEN** the Automation log SHALL contain `[AS-SOURCE-BEGIN]` / numbered content / `[AS-SOURCE-END]` for that product id
- **AND** the leaf SHALL still fail

#### Scenario: Authored and generated leaves coexist
- **WHEN** enumeration includes both `syntax.optional-empty.vm` and an `integral-bitwise` product leaf
- **THEN** both kinds SHALL be independently selectable by prefix

### Requirement: Cases select shared or isolated engines
Each catalog case SHALL set `engine` to `shared` or `isolated`. Shared cases SHALL use `FAngelscriptTestEngine::GetSharedEngine` and `ResetModules`. Isolated cases SHALL use `FAngelscriptTestEngine::Create` and destroy the engine when the leaf ends.

#### Scenario: Shared VM case reuses the singleton
- **WHEN** a case sets `engine` to `shared` and profile `vm`
- **THEN** the harness SHALL acquire the shared test engine
- **AND** it SHALL reset compiled modules before compiling the case fixtures
- **AND** it SHALL reset compiled modules after the leaf

#### Scenario: Isolated case does not touch the shared engine
- **WHEN** a case sets `engine` to `isolated`
- **THEN** the harness SHALL create a new Full test engine from the profile config
- **AND** it SHALL NOT call `GetSharedEngine` for that leaf
- **AND** destroying the unique engine SHALL NOT destroy the shared singleton

#### Scenario: Shared is rejected for cache or JIT profiles
- **WHEN** a case lists `cache-roundtrip`, `typed-ast-generate`, or `runtime-jit` with `engine` set to `shared`
- **THEN** catalog validation SHALL fail
- **AND** that case SHALL NOT be registered as a leaf

### Requirement: Named profiles are C++ presets referenced by id
JSON catalogs SHALL refer to engine profiles by string id. The harness SHALL resolve ids through a C++ registry that applies `FAngelscriptEngineConfig`, JIT coordinator mode, and cache settings. Catalogs SHALL NOT embed a full `FAngelscriptEngineConfig` object.

#### Scenario: Unknown profile id is rejected
- **WHEN** a case lists profile id `does-not-exist`
- **THEN** catalog validation SHALL fail with that id in the diagnostic
- **AND** no leaf SHALL be registered for that case

#### Scenario: vm profile executes through VM
- **WHEN** a leaf runs profile `vm`
- **THEN** compile and execute observations SHALL run on the VM route
- **AND** the leaf SHALL NOT require a StaticJIT provider or Runtime JIT factory

#### Scenario: cache-roundtrip restores on a second engine
- **WHEN** a leaf runs profile `cache-roundtrip`
- **THEN** the harness SHALL create an isolated producer engine, compile the case AngelScript from a disk script root, persist Cache V2, destroy that engine, create a second isolated consumer engine with the same cache root and source identity, restore from that cache, and run execute observations only against the restored modules
- **AND** the restore path SHALL NOT re-parse fixture or generated source as the success oracle

#### Scenario: Generated product can cache-roundtrip
- **WHEN** a catalog names generator `integral-bitwise` and lists profile `cache-roundtrip` for one type cell
- **THEN** the harness SHALL materialize that product's AngelScript onto the producer disk script root before compile
- **AND** the consumer SHALL execute the same `executeInt` oracles as the matching `vm` leaf
- **AND** it SHALL NOT require a checked-in `int8_bitand.as` cache fixture

#### Scenario: cache-roundtrip configs stay in the profile hook
- **WHEN** a `cache-roundtrip` leaf runs
- **THEN** producer and consumer SHALL share `CacheV2RootOverride` and `GetProjectDir`
- **AND** the catalog SHALL NOT embed `FAngelscriptEngineConfig` or cache identity blobs
- **AND** neither engine SHALL be the shared test singleton

#### Scenario: Missing JIT backend skips rather than fails
- **WHEN** a leaf requests `typed-ast-generate` and `AS_CAN_GENERATE_JIT` is false, or requests `runtime-jit` and no compatible backend factory is registered
- **THEN** the leaf SHALL record an Info skip naming the missing capability
- **AND** it SHALL NOT add an Error

#### Scenario: runtime-jit executes through RuntimeOnly when a factory exists
- **WHEN** a leaf runs profile `runtime-jit` and a compatible factory is registered
- **THEN** compile and execute observations SHALL run with coordinator `RuntimeOnly`
- **AND** the leaf SHALL NOT use purpose `StaticJITGeneration`

### Requirement: Cache roundtrip accepts a custom cache folder
A `cache-roundtrip` case MAY set `cacheRoot`. The harness SHALL resolve that value to one filesystem directory and pass it as `CacheV2RootOverride` on both the producer and the consumer. When `cacheRoot` is omitted the harness SHALL use `{ProjectSavedDir}/Automation/DataDriven/<leaf>/CacheV2`. Catalogs SHALL NOT place Cache V2 packs in Fixtures, host `Script/`, or the project's production cache tree.

#### Scenario: Default cache folder is per leaf
- **WHEN** a `cache-roundtrip` case omits `cacheRoot`
- **THEN** both engines SHALL use `{ProjectSavedDir}/Automation/DataDriven/<leaf>/CacheV2`
- **AND** two different leaf ids SHALL NOT share that default directory

#### Scenario: Relative cacheRoot is under Automation DataDriven
- **WHEN** a case sets `"cacheRoot": "OptionalEmptyCustom"` and lists `cache-roundtrip`
- **THEN** both engines SHALL use `{ProjectSavedDir}/Automation/DataDriven/CacheRoots/OptionalEmptyCustom/`
- **AND** producer persist and consumer restore SHALL see the same packs

#### Scenario: Illegal cacheRoot is rejected
- **WHEN** `cacheRoot` contains `..`, is empty, is an absolute path outside `{ProjectSavedDir}/Automation/`, or is set on a case that does not list `cache-roundtrip`
- **THEN** catalog validation SHALL fail
- **AND** that case SHALL NOT register

### Requirement: Observations are the pass/fail oracle
Each case SHALL declare an observations array. The harness SHALL execute them in order on the engine produced by the selected profile. A leaf SHALL fail if any observation fails.

#### Scenario: compile success
- **WHEN** an observation `{ "kind": "compile", "expect": "success" }` runs against a valid fixture
- **THEN** the leaf SHALL pass that observation only if every mounted fixture compiles

#### Scenario: compile expected diagnostic
- **WHEN** an observation expects compile failure with a diagnostic substring
- **THEN** the leaf SHALL pass only if compilation fails and at least one diagnostic contains that substring

#### Scenario: executeInt
- **WHEN** an observation `{ "kind": "executeInt", "decl": "int EchoEmpty()", "value": 0 }` runs after a successful compile
- **THEN** the harness SHALL invoke that global declaration and require the integer result `0`

#### Scenario: executeException
- **WHEN** an observation expects a script exception substring
- **THEN** the harness SHALL fail the leaf if the function returns normally or the exception text does not contain the substring

#### Scenario: perfCollect does not fail on duration
- **WHEN** an observation `{ "kind": "perfCollect" }` runs
- **THEN** the harness SHALL write a performance metrics artifact
- **AND** the leaf SHALL NOT fail because a sample exceeded an unpublished budget

### Requirement: Invalid catalogs fail closed at discovery
The harness SHALL validate catalogs before registering leaves. A malformed catalog SHALL NOT silently disappear from the suite.

#### Scenario: Malformed JSON
- **WHEN** a `cases.json` file is not valid JSON
- **THEN** harness self-tests or a discovery diagnostic leaf SHALL report the file path
- **AND** no cases from that file SHALL register

#### Scenario: Missing fixture path
- **WHEN** a case lists a fixture file that does not exist under the Fixtures root
- **THEN** catalog validation SHALL fail with that relative path
- **AND** the case SHALL NOT register
