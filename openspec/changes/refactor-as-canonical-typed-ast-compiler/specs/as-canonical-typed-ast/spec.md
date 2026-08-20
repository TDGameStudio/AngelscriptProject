## ADDED Requirements

### Requirement: Canonical AST uses one Clang-style semantic ownership model
Every successful AngelScript source build SHALL produce one module-owned canonical typed AST through `SourceManager -> Parser + Sema actions -> ASTContext`. The AST SHALL separate declarations, canonical/qualified types, statements, and expressions, and SHALL be the sole source-level semantic authority after sealing. Concrete Clang classes or libraries MUST NOT be a build or runtime dependency.

#### Scenario: Successful source build seals one semantic graph
- **WHEN** a module containing declarations and executable bodies builds successfully
- **THEN** one ASTContext owns its translation unit, declarations, types, statements, expressions, and source table
- **AND** the graph is sealed before Bytecode, StaticJIT, cache, dump, or public snapshot consumers receive it

#### Scenario: Rejected source does not publish an executable AST
- **WHEN** Parser or Sema reports an error that prevents successful module build
- **THEN** error/recovery nodes may exist only in the unpublished build context
- **AND** no executable, cached, or public snapshot is published from that failed graph

### Requirement: Source identity is independent from node storage
The frontend SHALL use a SourceManager that distinguishes stable logical source identity from snapshot-local source IDs and maps authored, processed, and generated coordinates. AST nodes SHALL carry compact source locations/ranges rather than owning section strings or relying on Parser token-node lifetime.

#### Scenario: Diagnostic coordinates survive Parser destruction
- **WHEN** Parser storage is destroyed after a successful build
- **THEN** the retained AST snapshot still resolves every published source range to the same logical section and maintained row/column diagnostics

#### Scenario: Cache restore remaps source IDs
- **WHEN** a retained AST is restored into another Engine from stable Cache V2 source coordinates
- **THEN** the restored snapshot assigns new snapshot-local source IDs without changing logical paths or source offsets

### Requirement: Sema materializes complete resolved language semantics
Sema SHALL be the only authority for lookup, overload and constructor selection, implicit conversions, access, property/mixin rewrites, argument origins, effective receivers, temporaries, lifetime/cleanup, imports/globals/dependencies, and control-transfer targets. Those results SHALL be explicit immutable AST facts so a backend does not decode Bytecode or repeat Sema.

#### Scenario: Implicit call semantics are explicit
- **WHEN** source compilation selects a rewritten property call, default argument, hidden argument, conversion, constructor, or effective receiver
- **THEN** the sealed AST records the selected stable declaration target, ordered argument origins, exact qualified types, and implicit semantic nodes
- **AND** backend traversal does not perform another overload or conversion search

#### Scenario: Mutation target is evaluated once
- **WHEN** a prefix, postfix, compound assignment, indexed property, or other mutation target contains side effects
- **THEN** the AST expresses the required sequencing and single-evaluation plan
- **AND** every backend observes the same source evaluation order

#### Scenario: Cleanup and transfer targets are verified
- **WHEN** control leaves a scope through fallthrough, return, break, continue, or an exceptional edge supported by current language semantics
- **THEN** the AST records the live cleanup plan and resolved transfer target
- **AND** the verifier rejects dangling, skipped-nearer, wrong-kind, duplicate, or non-ancestor targets

### Requirement: Canonical types have stable identity and a Runtime bridge
The AST SHALL use canonical `Type` plus qualified type references for source semantics. Runtime `asCDataType`, `asCTypeInfo`, numeric type IDs, layouts, behaviours, and target ABI SHALL be resolved through an explicit current-Engine bridge and MUST NOT be durable public/cache identity.

#### Scenario: Equivalent source types canonicalize
- **WHEN** two declarations resolve to the same type and qualifier set in one ASTContext
- **THEN** their qualified type references compare as the same canonical source type

#### Scenario: Restored types bind to the target Engine
- **WHEN** a stable AST type reference is restored into a different Engine instance
- **THEN** the Runtime bridge resolves it to that Engine's current type objects and IDs
- **AND** no persisted pointer or numeric ID from the publishing Engine is reused as identity

### Requirement: Public AST V1 is an immutable reference-counted module snapshot
The public API SHALL expose an explicitly versioned `asIASTSnapshot` acquired from `asIScriptModule`. It SHALL use reference counting, snapshot-local opaque Decl/Stmt/Expr/Type IDs, size/versioned POD views, stable keys, and source ranges. It MUST NOT expose writable nodes, internal arena pointers, concrete node C++ layouts, `asCTypeInfo*`, `asCScriptFunction*`, or Engine-local numeric FunctionId as durable identity.

#### Scenario: Retained module publishes a V1 snapshot
- **WHEN** a module builds with `asAST_RETAIN_SNAPSHOT` and a caller requests the supported V1 API
- **THEN** `AcquireASTSnapshot` returns an AddRef-owned immutable snapshot whose translation-unit root and referenced views are valid until the caller releases it

#### Scenario: Discard policy has no public snapshot
- **WHEN** a module builds with `asAST_DISCARD_AFTER_CODEGEN` and CodeGen completes
- **THEN** `AcquireASTSnapshot` reports unavailable/null
- **AND** VM execution does not depend on retained AST storage

#### Scenario: Unsupported API version fails closed
- **WHEN** a caller requests an AST API version not implemented by the Runtime
- **THEN** acquisition fails without returning a lower-version object under the requested contract

### Requirement: AST retention is frozen per module build
`asIScriptModule` SHALL expose `SetASTRetentionPolicy`, `GetASTRetentionPolicy`, and `AcquireASTSnapshot`. Retention policy SHALL freeze when `Build()` begins; a built module MUST reject an in-place policy change. Every source build constructs canonical AST for CodeGen, but only retain-policy modules publish complete snapshots after CodeGen.

#### Scenario: Policy is selected before build
- **WHEN** a caller selects retain policy before `Build()`
- **THEN** the resulting successful module keeps a complete sealed AST available for internal and public acquisition

#### Scenario: Policy change after build is rejected
- **WHEN** a caller attempts to change retention policy on an already-built module
- **THEN** the call fails without discarding, rebuilding, or changing the current snapshot

### Requirement: Hot Reload publishes snapshots atomically and leases old generations
Hot Reload SHALL publish the replacement module and its verified AST snapshot atomically. Existing AddRef readers of the prior snapshot SHALL retain a self-consistent immutable generation until release, while `IsCurrentGeneration()` reports false after replacement. Cross-snapshot/module references MUST use stable keys rather than foreign arena pointers.

#### Scenario: Reader survives Hot Reload
- **WHEN** a caller holds an AST snapshot while Hot Reload successfully publishes a replacement module
- **THEN** the caller can continue traversing the old snapshot safely
- **AND** the old snapshot reports that it is no longer the current generation

#### Scenario: Failed replacement preserves the current snapshot
- **WHEN** replacement parsing, Sema, verification, cache remap, or module activation fails
- **THEN** the previous module and snapshot remain current and unchanged
- **AND** no partial replacement graph is visible

### Requirement: Canonical AST has deterministic verification and inspection
The AST SHALL provide a deterministic verifier and dump/inspection representation independent of addresses and Engine-local IDs. Verification SHALL cover ownership, node kinds, IDs, types, child/reference validity, source ranges, declaration targets, sequencing, cleanup, transfer targets, stable references, and sealed-state invariants.

#### Scenario: Repeated builds dump identically
- **WHEN** identical source, compiler options, bind surface, and profile are built twice
- **THEN** normalized AST dumps and verifier results are byte-identical and contain no pointer spelling

#### Scenario: Malformed graph is rejected before publication
- **WHEN** a test or cache decoder creates a dangling ID, wrong node kind, invalid type, foreign owner, invalid cleanup, or unresolved required stable target
- **THEN** verification fails with a stable source-located category
- **AND** the graph is not published to a backend, cache, or public reader

### Requirement: AST is sufficient for future backends without depending on LLVM
The canonical AST SHALL contain exact types/value categories, resolved declarations and calls, implicit conversions, sequencing, temporaries, cleanup, control targets, source provenance, and stable dependencies needed for a future LLVM lowering without Bytecode decoding or a second Sema pass. This change MUST NOT add LLVM types, libraries, emitters, tests, or runtime lifecycle.

#### Scenario: Backend-neutral boundary contains no LLVM state
- **WHEN** canonical AST and public/cache views are built and inspected
- **THEN** no node or interface contains `llvm::Value`, LLVM IR type, LLVM context, ORC, object-cache, or executable-memory ownership
- **AND** Bytecode and TypedASTJIT can consume the same semantic graph through backend-local state
