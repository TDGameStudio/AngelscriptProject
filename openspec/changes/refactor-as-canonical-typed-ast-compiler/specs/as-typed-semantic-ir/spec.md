## ADDED Requirements

### Requirement: Retired function-owned HIR remains absent
The maintained fork SHALL keep the completed physical retirement of function-owned TypedSemantic HIR closed. Canonical AST, its snapshot-owned semantic protocols, and transient deterministic derived verification views SHALL NOT recreate a separately captured/persisted/published function-owned HIR under a new name. AngelScript's native `asCScriptNode` syntax tree and explicitly selected LEGACY Parser/Builder/Compiler remain a separate retained boundary and are not HIR.

#### Scenario: Retired HIR symbol or transport returns
- **WHEN** a production/test source, build list, public/cache/provider schema, dump command, or backend again requires `asCTypedSemanticFunction`, `asCTypedSemanticIRBuilder`, `GetTypedSemanticFunction`, `VerifiedTypedHIR`, `TypedHIRSidecar`, or the retired HIR model files
- **THEN** the architecture gate fails
- **AND** no compatibility shim may reconstruct HIR from AST, Bytecode, Cache, or dump files

#### Scenario: Derived lifetime view is not HIR
- **WHEN** final verification, Bytecode, or TypedASTJIT constructs the approved shared lifetime/control view from a Frozen/Publishable snapshot
- **THEN** the view is deterministic, transient, non-persisted, non-published, and contains no independent semantic selection or backend transport state
- **AND** it is destroyed or discarded without affecting the sealed snapshot
- **AND** Canonical AST remains the only retained high-level semantic representation for CANONICAL

## REMOVED Requirements

### Requirement: Typed semantic IR capture is explicit and function-owned
**Reason**: A separate function-owned sidecar duplicates the canonical module AST and is unnecessary after every source compile and consumer uses ASTContext.

**Migration**: Use module AST retention policy and `asIASTSnapshot`; function bodies live in the module snapshot. The retained Cache V2 `ASTBodySidecar` prototype is optional and default-disabled.

### Requirement: Typed semantic IR preserves resolved structured semantics
**Reason**: Resolved structured semantics move to canonical Decl/Type/Stmt/Expr nodes.

**Migration**: Port every existing semantic kind and test oracle into `as-canonical-typed-ast` before deleting the corresponding HIR node.

### Requirement: Typed semantic IR makes transfer, mutation, and safe-point semantics explicit
**Reason**: These are canonical AST requirements rather than sidecar-HIR-only metadata.

**Migration**: Represent transfer targets, sequencing, mutation single-evaluation, and safe-point roles in sealed AST nodes consumed by Bytecode and TypedASTJIT.

### Requirement: HIR makes failure and cleanup edges explicit
**Reason**: Failure and cleanup are required language semantics for all backends and therefore belong in canonical AST/Sema.

**Migration**: Store exact action, activation, region, phase, construction and supported exit-kind facts in the sealed Canonical lifetime protocol. Derive committed-live sets and reverse cleanup routes through one shared transient verifier view. Do not require every failure/cleanup edge to be copied as an ordinary statement child, and do not persist the derived view as HIR.

### Requirement: Typed semantic IR normalizes function traits and effective receivers
**Reason**: Normalized declarations/calls/effective receivers become canonical Sema output.

**Migration**: Preserve the same trait/receiver tests against canonical declaration and call views.

### Requirement: Resolved calls preserve compiler rewrites and argument origins
**Reason**: Call rewrites and argument provenance become immutable canonical call-expression semantics.

**Migration**: Port resolved-call, default/hidden argument, mixin, property, and call-origin tests before retiring HIR call records.

### Requirement: HIR preserves global, binding, dependency, and source provenance
**Reason**: These dependencies and provenances must be shared by Bytecode, StaticJIT, cache, and public analysis through canonical AST.

**Migration**: Move stable global/import/binding/dependency/source records to canonical declarations/expressions and cache DTOs.

### Requirement: HIR capture does not alter VM compilation or persistence
**Reason**: There is no optional parallel HIR capture after canonical AST becomes the mandatory source compilation input.

**Migration**: AST retention remains optional and MUST NOT change VM behavior; `SaveByteCode` and VM FunctionBody payloads remain AST-free.

### Requirement: Typed semantic IR has deterministic read-only inspection
**Reason**: Deterministic verification/inspection is replaced by the canonical AST snapshot API and dump.

**Migration**: Convert HIR dump/verifier fixtures to canonical AST IDs, stable keys, and source ranges.

### Requirement: HIR test snapshots are deterministic diagnostics and never compiler inputs
**Reason**: Canonical AST diagnostics replace HIR snapshots; dump files remain non-inputs.

**Migration**: Rename/port test fixtures to AST snapshot diagnostics and preserve the no-dump-input rule.

### Requirement: Sparse semantic observations remain independent
**Reason**: The sparse observer remains compatible but is generated from canonical Sema events rather than coexisting with HIR capture.

**Migration**: Preserve `asISemanticObserver` behavior through an adapter over canonical Sema publication; do not expose mutable AST through it.
