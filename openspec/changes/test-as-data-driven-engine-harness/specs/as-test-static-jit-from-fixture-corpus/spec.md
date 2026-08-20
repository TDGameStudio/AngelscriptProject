## ADDED Requirements

### Requirement: Test AngelScript corpus is the StaticJIT input
The data-driven harness SHALL treat the plugin test AngelScript corpus as the source of truth for StaticJIT generation. That corpus SHALL include authored fixture `.as` files and in-memory generated AngelScript products. The harness SHALL NOT require a third handwritten tree of `.jit.cpp` files that copy those AngelScript functions.

#### Scenario: Authored fixture generates StaticJIT
- **WHEN** case `syntax.optional-empty` lists profile `typed-ast-generate` with `engine` set to `isolated`
- **THEN** the harness SHALL run StaticJIT generation against `Fixtures/Syntax/OptionalEmpty.as`
- **AND** it SHALL NOT compile a separately authored C++ copy of `EchoEmpty`

#### Scenario: Generated product generates StaticJIT
- **WHEN** a catalog names generator `integral-bitwise` and lists profile `typed-ast-generate`
- **THEN** the harness SHALL materialize that product's AngelScript and run StaticJIT generation against it
- **AND** it SHALL NOT require a checked-in `int8_bitand.jit.cpp` authored by hand

#### Scenario: Handwritten jit.cpp that shadows a fixture is rejected
- **WHEN** an author adds a test `.jit.cpp` whose body is a manual transcription of a Fixtures or product function
- **THEN** that file SHALL NOT be accepted as the StaticJIT proof for that case
- **AND** the generate profile leaf SHALL remain the proof

### Requirement: Derived StaticJIT follows one module one translation unit
StaticJIT output for a corpus module SHALL go through the existing packager contract: one `<StableModuleKey>.<TargetProfile>.jit.cpp` per non-empty AngelScript module. The harness SHALL NOT emit per-function slices or a `"dual"` backend. Wave A SHALL use profile `typed-ast-generate` only. If a later `bytecode-generate` profile is registered, it SHALL be an isolated additive profile and SHALL use the same corpus pairing.

#### Scenario: Generation uses StaticJITGeneration purpose
- **WHEN** a `typed-ast-generate` leaf runs and `AS_CAN_GENERATE_JIT` is true
- **THEN** the harness SHALL create an isolated engine with purpose `StaticJITGeneration`
- **AND** it SHALL NOT attach a Runtime `asIJITCompiler` as the StaticJIT proof

#### Scenario: Missing generate capability skips
- **WHEN** a corpus case lists `typed-ast-generate` and `AS_CAN_GENERATE_JIT` is false
- **THEN** the leaf SHALL Info-skip
- **AND** it SHALL NOT fail the suite

### Requirement: Generate profiles materialize AngelScript onto an isolated disk root
A StaticJIT generate profile SHALL present corpus source through an isolated engine script root whose virtual paths follow `/Angelscript/Game/<logical-path>`. Memory-only mounts SHALL NOT be the generate path. The harness SHALL NOT point `GetProjectDir` at the host project directory when that would compile unrelated host `Script/` files.

#### Scenario: Generated product is written to a temp Script root
- **WHEN** an `integral-bitwise` leaf runs `typed-ast-generate`
- **THEN** the harness SHALL write the generated AngelScript under a temp `Script/` directory for that leaf
- **AND** generation SHALL use that directory as the isolated project dir
- **AND** the temp `.as` SHALL NOT be committed to `Fixtures/Generated/`

#### Scenario: Authored fixture generate uses disk mount
- **WHEN** `syntax.optional-empty.typed-ast` runs
- **THEN** the leaf SHALL use a disk mount of `OptionalEmpty.as`
- **AND** a shared-engine memory mount SHALL NOT be accepted for that profile

### Requirement: Session jit.cpp is derived output, not the corpus
Wave A StaticJIT proofs SHALL treat emitted C++ as a session artifact under the automation Saved tree. The harness SHALL NOT require those files to be committed. Publishing mechanically into `AngelscriptTestJIT` SHALL remain an optional later step and SHALL still be generated from the AngelScript corpus.

#### Scenario: Wave A does not require TestJIT Provider load
- **WHEN** `typed-ast-generate` succeeds or skips
- **THEN** the leaf SHALL NOT require a loaded `AngelscriptTestJIT` Provider DLL as the pass condition
- **AND** a recorded generation completion or typed fallback reason SHALL be sufficient

#### Scenario: Production save still does not generate
- **WHEN** a developer saves a `.as` file in the editor
- **THEN** that save SHALL NOT become the test harness generate path
- **AND** corpus StaticJIT generation SHALL remain an explicit generate-profile or Generate/Verify action

### Requirement: Corpus generate leaves are StaticJIT tests
A catalog case that lists `typed-ast-generate` (or a later generate profile) SHALL count as a StaticJIT generation test of that AngelScript module. The same corpus source SHALL be the input for the corresponding `vm` execute observations when those are also listed. The harness SHALL NOT require a second AngelScript copy under `StaticJIT/` to claim generate coverage for that module. These leaves SHALL NOT replace packager, Provider ABI, coordinator, or diagnostics CQTest.

#### Scenario: OptionalEmpty tests VM and StaticJIT generate
- **WHEN** catalogs include `syntax.optional-empty` with `vm` and `syntax.optional-empty.typed-ast` with `typed-ast-generate`
- **THEN** both leaves SHALL use `Fixtures/Syntax/OptionalEmpty.as`
- **AND** the generate leaf SHALL be the StaticJIT generation proof for `EchoEmpty`
- **AND** no additional AS file SHALL be required under `StaticJIT/`

#### Scenario: Generated product tests VM and StaticJIT generate
- **WHEN** `integral-bitwise` has a `vm` leaf and a separate `typed-ast-generate` leaf for `int8` `mutable_lvalue`
- **THEN** both leaves SHALL use the same generated AngelScript product
- **AND** the generate leaf SHALL be the StaticJIT generation proof for that cell

#### Scenario: Generate success is the Wave A StaticJIT oracle
- **WHEN** `AS_CAN_GENERATE_JIT` is true and generation finishes
- **THEN** the leaf SHALL pass if the generator completes and records emit or a typed fallback reason for the module functions
- **AND** it SHALL NOT require executing a loaded Provider native entry as the Wave A pass condition

#### Scenario: StaticJIT contract tests stay
- **WHEN** packager layout, Provider ABI, coordinator matching, or StaticJIT diagnostics need regression
- **THEN** those tests SHALL remain `Angelscript.TestModule.StaticJIT.*` CQTest
- **AND** a corpus generate leaf SHALL NOT be treated as covering those contracts

### Requirement: Catalogs list generate profiles explicitly
The harness SHALL NOT invent a StaticJIT generate leaf for every fixture or product cell. A generate leaf exists only when the case lists `typed-ast-generate` or a later registered generate profile id.

#### Scenario: vm-only product has no generate leaf
- **WHEN** `integral-bitwise` Wave A golden lists only profile `vm`
- **THEN** enumeration SHALL NOT add a `typed-ast-generate` leaf for every type cell
- **AND** a separate case or explicit profile list SHALL be required for generate pairing
