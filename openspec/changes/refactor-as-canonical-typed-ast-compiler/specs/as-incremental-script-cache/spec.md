## ADDED Requirements

### Requirement: Cache V2 is disabled by default
`UAngelscriptCacheSettings::bEnableCacheV2` SHALL default to `false`. Engine
construction SHALL resolve that setting once into an Engine-local enablement
decision. Hosts and focused tests MAY explicitly override the decision for one
Engine, but ordinary Runtime, Editor, commandlet, and test Engines SHALL not
enter Cache V2 merely because the service code is present.

#### Scenario: Engine uses product defaults
- **WHEN** an Engine is constructed without a project or host override
- **THEN** Cache V2 is disabled for that Engine
- **AND** later Cache-specific settings cannot accidentally turn that existing Engine into a partially enabled lifecycle

#### Scenario: Focused Cache test opts in
- **WHEN** a focused Cache V2 test explicitly overrides enablement to true before Engine construction
- **THEN** that Engine may exercise the retained experimental Cache V2 implementation
- **AND** the opt-in does not change the product default or another Engine's decision

### Requirement: Disabled Cache V2 is a complete compiler-lifecycle bypass
When Cache V2 is disabled, startup SHALL not attempt ExactStartup or
cross-Engine restore, source compilation SHALL not prepare or publish Cache
capture transactions, Hot Reload SHALL not prepare or publish Cache capture
transactions, and shutdown SHALL not persist a Cache generation. Authoritative
`.as` source compilation and normal module publication SHALL continue without
requiring Cache V2.

#### Scenario: Default-disabled Engine compiles source
- **WHEN** a default-disabled Engine starts with valid `.as` source
- **THEN** preprocessing, canonical/legacy-selected compilation, module publication, and executable function discovery succeed from source
- **AND** Current and PendingColdStart Cache publications remain absent
- **AND** no function-reuse summary or persisted Cache files are produced

#### Scenario: Default-disabled Engine hot reloads source
- **WHEN** a default-disabled Editor Engine accepts a valid source Hot Reload
- **THEN** the replacement module and canonical snapshot follow the ordinary compile/publication path
- **AND** no Cache capture context or Cache transaction is created

### Requirement: Cache V2 redesign is not a canonical compiler cutover gate
The canonical compiler cutover SHALL NOT require Cache V2. The canonical typed
AST, Sema, Bytecode CodeGen, snapshot, Hot Reload, public
tooling, TypedASTJIT migration, HIR retirement, and production cutover SHALL be
verifiable with Cache V2 disabled. The retained `ASTBodySidecar`, ExactStartup,
and restore prototypes MUST remain separated from `SaveByteCode`, VM
FunctionBody bytes, public snapshot memory, and textual/JSON dumps, but this
change does not require unfinished cross-Engine remap or function-granular
incremental reuse to become production-ready. Prototype type/property identity
MUST use complete stable keys and explicit target/profile compatibility; it
MUST NOT persist a publishing-Engine numeric type ID, type/property pointer,
snapshot-local AST type reference, or hash-only identity.

#### Scenario: Canonical cutover is evaluated
- **WHEN** the canonical compiler completion gates are run with product-default settings
- **THEN** Cache V2 restore/capture is absent from the path under test
- **AND** an unfinished opt-in Cache V2 prototype cannot block or masquerade as canonical compiler completion

#### Scenario: Retained prototype is incompatible or incomplete
- **WHEN** an explicitly enabled prototype encounters an unsupported schema, unremappable declaration/type, incomplete invocation family, or invalid sidecar
- **THEN** it fails closed according to its focused test contract
- **AND** no partial module or AST snapshot becomes authoritative
- **AND** production remains protected because Cache V2 is disabled by default

#### Scenario: Prototype restores into an Engine with different numeric type IDs
- **WHEN** an explicitly enabled pointer-free AST prototype is decoded in a target Engine whose registration order assigns different numeric type IDs
- **THEN** admission compares complete stable type/property identity and target/profile compatibility rather than the publishing integers
- **AND** any live numeric ID or pointer is assigned only after exact remap and verification
- **AND** a failed remap publishes no partial executable, snapshot, or Cache generation
