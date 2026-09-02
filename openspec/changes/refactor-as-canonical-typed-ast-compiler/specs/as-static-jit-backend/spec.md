## ADDED Requirements

### Requirement: Typed source generation uses canonical AST retention
The Static backend selection and AST retention policy SHALL freeze before the authoritative source compile. A `typed-ast` request SHALL consume a complete verified canonical AST snapshot for its exact target profile; a `bytecode` request SHALL remain valid without retained AST and SHALL analyze Bytecode through BytecodeJIT.

#### Scenario: Typed generation profile retains AST
- **WHEN** a source build is created for a `typed-ast` artifact request
- **THEN** its modules build with AST retention and expose verified snapshots to the typed backend

#### Scenario: Bytecode generation profile discards AST
- **WHEN** a source build is created only for a `bytecode` artifact request
- **THEN** it may discard AST after Bytecode CodeGen
- **AND** BytecodeJIT behavior and output do not depend on AST retention

#### Scenario: Retention/profile mismatch is detected
- **WHEN** a `typed-ast` request receives a capture-off or wrong-profile compiled graph
- **THEN** orchestration fails the whole request with a stable mismatch reason before per-function analysis
- **AND** it does not reconstruct AST from Bytecode

### Requirement: Generation Engine containment includes AST ownership
A non-matching generation Engine SHALL own and release its SourceManager, canonical ASTContext, immutable Runtime type-resolution view, descriptors, functions, types, and request-local state. Runtime resolution SHALL verify stable type/declaration keys plus target/profile ABI-layout compatibility; Provider identity and persisted output MUST NOT use that Engine's numeric type IDs or type pointers as durable symbols. Destroying the generation Engine MUST NOT sweep or invalidate primary Engine AST snapshots, packages, routes, reflection, caches, contexts, or Provider bindings.

#### Scenario: Generation Engine succeeds
- **WHEN** a contained generation Engine completes analysis/emission/packaging
- **THEN** all generation-owned AST and Engine-local semantic objects are released after stable output is produced
- **AND** primary state remains externally owned and unchanged

#### Scenario: Generation Engine fails
- **WHEN** parsing, Sema, AST verification, descriptor analysis, or StaticJIT emission fails
- **THEN** the same request-owned cleanup boundary runs
- **AND** no partial AST or Provider state publishes into the primary Engine

#### Scenario: Two generation Engines assign different type IDs
- **WHEN** equivalent canonical type/declaration inputs are compiled in two contained Engines whose registration order produces different numeric type IDs
- **THEN** typed generation compares stable keys and target/profile ABI compatibility
- **AND** equivalent Provider identity/output does not depend on either numeric ID
- **AND** generation-local pointers and IDs are released with their owning request after stable output is produced
