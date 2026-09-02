## ADDED Requirements

### Requirement: TypedASTJIT lowers Frozen/Publishable canonical facts without decoding Bytecode
TypedASTJIT SHALL analyze dependencies, validate eligibility, and emit C++ exclusively from the Frozen/Publishable canonical AST, its verifier-authenticated lifetime protocol/shared derived view, and Runtime/native-linkage views. It MUST NOT read function Bytecode to recover body semantics, reconstruct the retired HIR, rerun Sema, mutate AST nodes, scan names to select destructors, classify lifetime families independently, or treat a declaration statement as proof that initialization succeeded.

#### Scenario: Eligible canonical function emits through TypedASTJIT
- **WHEN** a retained canonical function and its reachable closure satisfy existing TypedASTJIT semantic, route, linkage, observability, cleanup, exception, and recursion gates
- **THEN** TypedASTJIT emits the existing Provider entry shapes from canonical AST
- **AND** Bytecode is not traversed for body analysis or emission

#### Scenario: Canonical AST is missing or invalid
- **WHEN** a typed generation request lacks the required retained snapshot or verification fails
- **THEN** the generation task fails closed at the profile/input boundary
- **AND** it does not synthesize AST/HIR from Bytecode or dump files

#### Scenario: Lifetime facts are invalid or unsupported for native emission
- **WHEN** a function has a missing/mismatched protocol revision, incomplete activation/edge coverage, unsupported failure/suspend region, partial construction not supported by the native frame ABI, or another unproven lifetime fact
- **THEN** TypedASTJIT reports a typed per-function unsupported/fallback reason
- **AND** it does not publish `VerifiedEmpty`, invent a cleanup action, retain an AST pointer, or widen native eligibility

#### Scenario: Lifetime facts are published pointer-free
- **WHEN** eligibility copies verified cleanup/transfer/exception facts into generated diagnostics or Provider metadata
- **THEN** the copy contains stable identity, protocol revision, bounded action/coverage summaries, and reviewed ABI compatibility only
- **AND** no AST/protocol pointer, snapshot-local ID, Engine type pointer, backend label, or numeric TypeId becomes durable Provider identity

### Requirement: TypedASTJIT migration preserves current capability and fallback
Changing the semantic input from HIR to canonical AST SHALL NOT reduce currently supported TypedASTJIT behavior or widen unproven native eligibility. Unsupported native forms SHALL remain valid canonical/Bytecode functions and SHALL use the existing per-function `TypedASTJIT -> BytecodeJIT -> VM` fallback and Provider contracts.

#### Scenario: Existing supported fixture migrates
- **WHEN** a HIR-era TypedASTJIT scalar, conversion, call, control-flow, cleanup, dependency, exception, or routing fixture is run through canonical AST
- **THEN** generated output and isolated VM/BytecodeJIT/TypedASTJIT behavior satisfy the existing expectation

#### Scenario: AST supports more than native emitter
- **WHEN** canonical AST and Bytecode support an object, container, lambda, delegate, lifetime, reflection, or suspend form outside current TypedASTJIT eligibility
- **THEN** TypedASTJIT reports the existing typed unsupported/fallback reason
- **AND** canonical compilation succeeds without invoking a legacy frontend

### Requirement: TypedASTJIT holds snapshot and code-image lifetimes independently
TypedASTJIT analysis/emission SHALL hold an immutable AST snapshot lease and an immutable generation-local Runtime type-resolution view for the request. Published Provider bindings SHALL retain only stable identity, expected target/profile ABI compatibility, generated artifacts, semantic dependencies, and code-image leases; they MUST NOT retain AST node pointers, Engine type pointers, or numeric type IDs as durable identity after generation completes.

#### Scenario: Hot Reload follows generation
- **WHEN** a generation request leases AST generation A and Hot Reload publishes generation B
- **THEN** the in-flight request completes consistently against A or fails its freshness gate
- **AND** published entries are selected later by stable generation/content/profile identity rather than AST addresses

#### Scenario: Native emission needs Runtime type metadata
- **WHEN** canonical eligibility or emission needs a type layout, behavior, native form, property, or public type-ID projection
- **THEN** it reads the request's already-validated generation-local Runtime resolution view
- **AND** it does not reinterpret a persisted numeric type ID or rerun name/hash lookup as source semantics
- **AND** the published Provider contains only stable identity and verified ABI/linkage metadata required for later exact selection

## REMOVED Requirements

### Requirement: TypedASTJIT lowers HIR without decoding bytecode
**Reason**: Function-owned HIR is replaced by sealed canonical AST as the shared source-semantic authority.

**Migration**: Port HIR analysis/emission visitors and their tests to canonical Decl/Stmt/Expr/Type nodes while preserving all existing backend and fallback contracts.
