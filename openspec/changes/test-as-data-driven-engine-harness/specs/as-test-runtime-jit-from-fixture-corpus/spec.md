## ADDED Requirements

### Requirement: The test AngelScript corpus is the Runtime JIT input
The data-driven harness SHALL treat the same plugin test AngelScript corpus as the input for later Runtime JIT execute leaves. That corpus SHALL include authored fixture `.as` files and generated AngelScript products. The harness SHALL NOT require a third AngelScript tree under a Runtime JIT test folder, and SHALL NOT use StaticJIT `.jit.cpp` or a loaded StaticJIT Provider as the Runtime JIT input.

#### Scenario: Authored fixture prepares Runtime JIT
- **WHEN** catalogs include `syntax.optional-empty` with `vm` and a case that lists `runtime-jit`
- **THEN** both leaves SHALL use `Fixtures/Syntax/OptionalEmpty.as`
- **AND** no additional AS file SHALL be required under a Runtime JIT directory

#### Scenario: Generated products remain eligible
- **WHEN** a later catalog names generator `integral-bitwise` and lists `runtime-jit` for one type cell
- **THEN** the harness SHALL compile that product's AngelScript on an isolated Runtime JIT engine
- **AND** it SHALL NOT require a handwritten Runtime JIT test `.as` that copies `EvaluateBitAnd`

#### Scenario: StaticJIT generate is not Runtime JIT
- **WHEN** a leaf runs `typed-ast-generate`
- **THEN** that leaf SHALL NOT count as Runtime JIT coverage
- **AND** a Runtime JIT leaf SHALL use profile `runtime-jit` (or a later registered Runtime profile id)

### Requirement: Wave A registers a skip-or-run Runtime JIT profile
Wave A SHALL register profile `runtime-jit` as isolated-only. Catalogs SHALL refer to it by id. The profile SHALL apply coordinator `RuntimeOnly` and a configured BackendId through the C++ registry. When no compatible `IAngelscriptRuntimeJITBackendFactory` is registered, the leaf SHALL Info-skip and SHALL NOT fail the suite. Wave A SHALL NOT require Angelsea, LLVM, or any Runtime JIT plugin in default CI.

#### Scenario: Missing factory skips
- **WHEN** `syntax.optional-empty` lists `runtime-jit` and no compatible factory is registered
- **THEN** the leaf SHALL record an Info skip that names the missing BackendId or factory
- **AND** it SHALL NOT add an Error

#### Scenario: Shared engine is rejected
- **WHEN** a case lists `runtime-jit` with `engine` set to `shared`
- **THEN** catalog validation SHALL fail
- **AND** that case SHALL NOT register

#### Scenario: Runtime JIT is not StaticJITGeneration
- **WHEN** a `runtime-jit` leaf runs
- **THEN** the harness SHALL create an isolated Full test engine with coordinator `RuntimeOnly`
- **AND** it SHALL NOT set purpose `StaticJITGeneration` for that leaf

### Requirement: Runtime JIT execute reuses corpus oracles
When a compatible factory is present, a `runtime-jit` leaf SHALL run the case's execute observations against the Runtime JIT coordinator path. For the OptionalEmpty golden those observations SHALL be the same `executeInt` declarations and values as the `vm` leaf. The harness SHALL NOT invent a second oracle language for Runtime JIT in Wave A.

#### Scenario: OptionalEmpty matches VM when factory exists
- **WHEN** a compatible Runtime JIT factory is registered and `syntax.optional-empty` `runtime-jit` runs
- **THEN** `int EchoEmpty()` SHALL return `0` and `int EchoEmptyFallback()` SHALL return `7`
- **AND** those declarations SHALL be the same as the `vm` leaf

#### Scenario: Memory mount is allowed
- **WHEN** a `runtime-jit` case uses mount kind `memory`
- **THEN** catalog validation SHALL accept it
- **AND** the leaf SHALL NOT require a disk `Script/` root (that requirement stays on StaticJIT generate profiles)

### Requirement: Catalogs list Runtime JIT profiles explicitly
The harness SHALL NOT invent a `runtime-jit` leaf for every fixture or product cell. A Runtime JIT leaf exists only when the case lists `runtime-jit` or a later registered Runtime profile id. Wave A SHALL ship the OptionalEmpty Runtime JIT case as the prepare golden and SHALL NOT cartesian generated product types against Runtime JIT.

#### Scenario: vm-only product has no Runtime JIT leaf
- **WHEN** `integral-bitwise` Wave A golden lists only profile `vm`
- **THEN** enumeration SHALL NOT add a `runtime-jit` leaf for every type cell
- **AND** a separate case or explicit profile list SHALL be required for Runtime JIT pairing

### Requirement: Runtime JIT contract tests stay
Corpus `runtime-jit` leaves SHALL cover execute of that AngelScript on the Runtime coordinator path. They SHALL NOT replace factory ABI, snapshot isolation, session teardown, or typed-outcome CQTest owned by the Runtime JIT contract suite.

#### Scenario: Factory ABI stays CQTest
- **WHEN** backend ABI revision or Engine-local session isolation needs regression
- **THEN** those tests SHALL remain existing Runtime JIT CQTest
- **AND** a corpus `runtime-jit` leaf SHALL NOT be treated as covering those contracts
