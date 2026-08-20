## ADDED Requirements

### Requirement: Legacy HIR retirement is consumer-gated
The maintained fork SHALL retain the existing function-owned TypedSemantic HIR only as a temporary shadow-convergence oracle. It MUST NOT be removed until canonical AST covers its semantics, TypedASTJIT and diagnostics no longer consume it, Cache V2 targets canonical AST DTOs, and all associated tests have migrated.

#### Scenario: A HIR consumer still exists
- **WHEN** any production TypedASTJIT, dump, cache, diagnostic, or compiler test still requires `asCTypedSemanticFunction`
- **THEN** the HIR deletion milestone remains incomplete
- **AND** no compatibility shim may silently reconstruct old HIR from Bytecode

#### Scenario: All HIR consumers have migrated
- **WHEN** canonical AST verifier/dump and all Bytecode/StaticJIT/cache/public consumers satisfy the migrated semantic tests
- **THEN** function-owned HIR, capture accessors, builder state, and HIR-only files are removed together
- **AND** canonical AST becomes the only retained high-level semantic representation

## REMOVED Requirements

### Requirement: Typed semantic IR capture is explicit and function-owned
**Reason**: A separate function-owned sidecar duplicates the canonical module AST and is unnecessary after every source compile and consumer uses ASTContext.

**Migration**: Use module AST retention policy and `asIASTSnapshot`; function bodies live in the module snapshot and optional Cache V2 `ASTBodySidecar` DTOs.

### Requirement: Typed semantic IR preserves resolved structured semantics
**Reason**: Resolved structured semantics move to canonical Decl/Type/Stmt/Expr nodes.

**Migration**: Port every existing semantic kind and test oracle into `as-canonical-typed-ast` before deleting the corresponding HIR node.

### Requirement: Typed semantic IR makes transfer, mutation, and safe-point semantics explicit
**Reason**: These are canonical AST requirements rather than sidecar-HIR-only metadata.

**Migration**: Represent transfer targets, sequencing, mutation single-evaluation, and safe-point roles in sealed AST nodes consumed by Bytecode and TypedASTJIT.

### Requirement: HIR makes failure and cleanup edges explicit
**Reason**: Failure and cleanup are required language semantics for all backends and therefore belong in canonical AST/Sema.

**Migration**: Move cleanup/failure plans and verifier cases into canonical AST before changing backend input.

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
