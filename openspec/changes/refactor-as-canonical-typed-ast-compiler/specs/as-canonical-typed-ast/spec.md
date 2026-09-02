## ADDED Requirements

### Requirement: Canonical AST uses one Clang-style semantic ownership model
Every successful CANONICAL AngelScript source build SHALL produce one module-owned canonical typed AST through `SourceManager -> Parser + Sema actions -> ASTContext`. LEGACY-selected builds MAY also construct a shadow Canonical graph for comparison, but their native syntax/compiler path remains separately authoritative for LEGACY output. The Canonical AST SHALL separate declarations, canonical/qualified types, statements, and expressions, and SHALL be the sole source-level semantic authority for every Canonical consumer after sealing. Concrete Clang classes or libraries MUST NOT be a build or runtime dependency.

#### Scenario: Successful source build seals one semantic graph
- **WHEN** a module containing declarations and executable bodies builds successfully
- **THEN** one ASTContext owns its translation unit, declarations, types, statements, expressions, and source table
- **AND** the graph is sealed before Bytecode, StaticJIT, dump, public snapshot, or explicitly enabled persistence-prototype consumers receive it

#### Scenario: Rejected source does not publish an executable AST
- **WHEN** Parser or Sema reports an error that prevents successful module build
- **THEN** error/recovery nodes may exist only in the unpublished build context
- **AND** no executable, cached, or public snapshot is published from that failed graph

### Requirement: Source identity is independent from node storage
The frontend SHALL use a SourceManager that distinguishes stable logical source identity from snapshot-local source IDs and maps authored, processed, and generated coordinates. AST nodes SHALL carry compact source locations/ranges rather than owning section strings or relying on Parser token-node lifetime.

#### Scenario: Diagnostic coordinates survive Parser destruction
- **WHEN** Parser storage is destroyed after a successful build
- **THEN** the retained AST snapshot still resolves every published source range to the same logical section and maintained row/column diagnostics

#### Scenario: Pointer-free DTO remaps source IDs
- **WHEN** the focused host-neutral DTO codec reconstructs a retained AST from stable source coordinates
- **THEN** the reconstructed snapshot assigns new snapshot-local source IDs without changing logical paths or source offsets
- **AND** this codec property does not require production Cache V2 restore to be enabled or complete

### Requirement: Sema materializes complete resolved language semantics
Sema SHALL be the only authority for lookup, overload and constructor selection, implicit conversions, access, property/mixin rewrites, argument origins, effective receivers, temporaries, exact lifetime action selection, activation/commit points, construction steps, semantic regions/phases, imports/globals/dependencies, and control-transfer targets. Those results SHALL be explicit immutable Canonical facts so a backend does not decode Bytecode or repeat Sema.

#### Scenario: Implicit call semantics are explicit
- **WHEN** source compilation selects a rewritten property call, default argument, hidden argument, conversion, constructor, or effective receiver
- **THEN** the sealed AST records the selected stable declaration target, ordered argument origins, exact qualified types, and implicit semantic nodes
- **AND** backend traversal does not perform another overload or conversion search

#### Scenario: Mutation target is evaluated once
- **WHEN** a prefix, postfix, compound assignment, indexed property, or other mutation target contains side effects
- **THEN** the AST expresses the required sequencing and single-evaluation plan
- **AND** every backend observes the same source evaluation order

#### Scenario: Lifetime and transfer facts are explicit
- **WHEN** a value, owning reference, temporary, or construction step enters or leaves a semantic scope or supported transfer region
- **THEN** the sealed Canonical snapshot records its exact subject, action target, activation/commit point, owner region/phase, reviewed exit applicability, and resolved transfer target
- **AND** no backend performs another destructor/release lookup or lifetime-family classification

#### Scenario: Class and interface override decisions are explicit
- **WHEN** Sema accepts a class method that overrides a base method or satisfies an interface method
- **THEN** the sealed Canonical snapshot records the exact snapshot-local source and target method declarations plus their declaring owners
- **AND** final verification proves owner kind, ancestry, exact signature, uniqueness, and completeness before a backend receives the graph
- **AND** CodeGen does not rediscover the relationship by method spelling, overload search, or native Builder metadata

#### Scenario: Invalid interface contract fails before publication
- **WHEN** an interface-method edge is missing, ambiguous, duplicated, foreign to the snapshot, attached to an invalid owner, outside the declared ancestry, or signature-incompatible
- **THEN** final verification rejects the Canonical graph with a deterministic source-located category
- **AND** no executable function, object type, interface slot, AST snapshot, or Runtime binding is published from the candidate

### Requirement: Canonical lifetime protocol separates semantic facts from derived routing
The sealed Canonical snapshot SHALL own a versioned backend-neutral lifetime protocol containing exact action, activation, region, phase, and construction facts. A single deterministic shared lifetime/control view SHALL mechanically derive committed-live sets and reverse cleanup sequences for normal, transfer, and explicitly supported failure/exception edges. The view MUST NOT perform semantic lookup or selection, mutate the snapshot, persist as a Cache/Public/Provider/artifact representation, consume dump text, or become a renamed function-owned HIR. Bytecode and AOT MAY own backend-local labels, slots, active flags, cleanup/EH stacks, tables, and frame layout only after the shared protocol verifies.

#### Scenario: Local initializer activates only on success
- **WHEN** a cleanup-requiring local has a declaration statement followed by its exact initializer action
- **THEN** storage may exist while the subject remains pending
- **AND** the subject becomes cleanup-live only after the initializer action completes successfully
- **AND** an initializer failure does not run the current subject's destructor/release action

#### Scenario: Partial construction cleans only the committed prefix
- **WHEN** base, member, delegating, temporary, array, or aggregate construction fails at step N
- **THEN** the derived failure route contains only strictly earlier successfully committed steps in strict reverse order
- **AND** the failing step and later steps are absent
- **AND** the complete-object destructor is unreachable until the complete-object commit point
- **AND** an array or aggregate progress identity cannot advance past the last successful element

#### Scenario: Repeated derivation is deterministic
- **WHEN** the shared lifetime/control view is built repeatedly from the same Frozen/Publishable snapshot and protocol revision
- **THEN** its regions, edge roles, committed-live sets, action identities, order, and verification result are identical
- **AND** no address, Engine-local numeric ID, backend label, or dump formatting participates in the result

#### Scenario: Forged or incomplete protocol fails before consumption
- **WHEN** a protocol has a wrong subject/action target, pre-success activation, missing or duplicate action, wrong order/phase/region, foreign ID, unsupported revision, or an unrepresented exception/suspend exit
- **THEN** final verification fails or the unsupported native function remains typed per-function fallback
- **AND** Bytecode and AOT do not reinterpret the protocol as verified-empty or publish from it

#### Scenario: Lifetime diagnostics are not transport
- **WHEN** text, JSON, CFG/DOT, protocol summaries, or structural hashes are produced for diagnosis
- **THEN** no consumer parses rendered output to recover lifetime semantics
- **AND** the derived view is rebuilt from typed sealed facts after any explicitly supported DTO restoration
- **AND** backend cleanup stacks and expanded edge lists are not serialized

### Requirement: Canonical types have stable identity and a Runtime bridge
The AST SHALL use canonical `Type` plus qualified type references for source semantics and SHALL distinguish snapshot-local type references, durable semantic type keys, target/profile ABI-layout compatibility, generation-local Runtime bindings, and public numeric type-ID projections. Runtime `asCDataType`, `asCTypeInfo`, numeric type IDs, layouts, behaviours, properties, functions, and target ABI SHALL be resolved through an explicit current-Engine bridge. Engine pointers, snapshot-local IDs, numeric type IDs, and unverified hashes MUST NOT be durable public, Cache, Provider, cross-Engine, cross-snapshot, or cross-generation identity.

#### Scenario: Equivalent source types canonicalize
- **WHEN** two declarations resolve to the same type and qualifier set in one ASTContext
- **THEN** their qualified type references compare as the same canonical source type
- **AND** that snapshot-local reference is not compared as identity with a numerically equal reference from another snapshot

#### Scenario: Explicit remap binds types to the target Engine
- **WHEN** an explicitly enabled DTO/remap prototype reconstructs a stable AST type reference in a different Engine instance
- **THEN** the Runtime bridge verifies the complete stable type key and expected target/profile ABI-layout compatibility
- **AND** resolves it to that Engine's current type objects, properties, functions, layout, and numeric ID
- **AND** no persisted pointer or numeric ID from the publishing Engine is reused as identity

#### Scenario: Hot Reload retains two revisions of one nominal type
- **WHEN** generation A and replacement generation B have the same stable nominal type key but a different validated layout or ABI revision
- **THEN** each generation owns a distinct immutable Runtime binding and current-Engine numeric type-ID projection
- **AND** an existing generation-A lease continues to use A's type object/layout while new readers use B
- **AND** no published binding slot is retargeted in place

#### Scenario: Public numeric type ID remains an Engine-local projection
- **WHEN** a public embedding API, `TYPEID`, or list-factory contract requests a numeric type ID
- **THEN** the value is materialized from the current owning generation's Runtime binding
- **AND** equality of that integer outside the same live Engine/generation is not treated as semantic or ABI identity

#### Scenario: Hash collision or spelling alias cannot select a type
- **WHEN** two candidate types share a lookup hash or an incomplete display spelling but differ in complete stable key, kind, template arguments, qualifiers, owner, or ABI-layout expectation
- **THEN** Runtime remap and candidate installation reject the non-exact match
- **AND** no executable module, snapshot, Cache generation, or Provider entry is published from the ambiguous binding

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
- **WHEN** replacement parsing, Sema, verification, or module activation fails
- **THEN** the previous module and snapshot remain current and unchanged
- **AND** no partial replacement graph is visible

### Requirement: Canonical AST has deterministic verification and inspection
The AST SHALL provide a deterministic verifier and dump/inspection representation independent of addresses and Engine-local IDs. Verification SHALL cover ownership, node kinds, IDs, types, child/reference validity, source ranges, declaration targets, sequencing, lifetime protocol revision/actions/activation/regions/construction, reverse live-only cleanup coverage, transfer targets, stable references, and Frozen/Publishable-state invariants.

#### Scenario: Repeated builds dump identically
- **WHEN** identical source, compiler options, bind surface, and profile are built twice
- **THEN** normalized AST dumps and verifier results are byte-identical and contain no pointer spelling

#### Scenario: Malformed graph is rejected before publication
- **WHEN** a test or explicit DTO decoder creates a dangling ID, wrong node kind, invalid type, foreign owner, invalid lifetime protocol/cleanup, or unresolved required stable target
- **THEN** verification fails with a stable source-located category
- **AND** the graph is not published to a backend, cache, or public reader

### Requirement: Canonical AST provides Clang-inspired read-only debug and query tooling
The maintained frontend SHALL provide one generic const traversal model, an on-demand parent/edge index, deterministic tree-text and JSON inspection, stable filters, source-aware verifier paths, semantic graph diffing, and test-oriented query/assertion helpers. These tools MUST consume an unsealed build context only under compiler/test ownership or hold an immutable snapshot lease; they MUST NOT mutate a sealed graph, rerun Sema, expose arena pointers, or become Cache/compiler inputs. The implementation MUST remain AngelScript-native and MUST NOT link Clang tooling libraries.

#### Scenario: Developer filters one sealed function graph
- **WHEN** a developer or AST-first test filters a retained snapshot by module and stable function key
- **THEN** the tool returns the declaration, its named semantic edges, body subtree, exact types, resolved references and source coordinates in deterministic tree text or JSON
- **AND** the output contains no process address or Engine-local numeric function/type identity

#### Scenario: Verifier identifies the path to a malformed edge
- **WHEN** verification rejects a dangling, wrong-kind, foreign, cyclic, wrong-owner, wrong-target, unresolved-call or invalid-cleanup edge
- **THEN** the diagnostic identifies the offending node kind/ID, edge role, related target, stable category, logical source line/column and a deterministic root-to-node path or local subtree
- **AND** no backend, cache publisher or public current-generation slot receives the graph

#### Scenario: AST-first tests query semantic facts without dump substring coupling
- **WHEN** a test asserts a unique declaration, resolved call, conversion, control target, cleanup edge or canonical type
- **THEN** a typed query/assertion helper traverses the sealed graph and reports a structural mismatch path
- **AND** the test does not need to parse flat dump text or infer the fact from VM output

#### Scenario: Diagnostic JSON is not persistence
- **WHEN** tree JSON, filtered dumps, structural diffs or CFG/DOT diagnostics are produced
- **THEN** they are treated only as human/tool inspection output
- **AND** any explicitly enabled or future Cache restore accepts only a separately versioned pointer-free AST DTO and verification/remap protocol

### Requirement: AST is sufficient for future backends without depending on LLVM
The canonical AST SHALL contain exact types/value categories, resolved declarations and calls, implicit conversions, sequencing, temporaries, lifetime protocol facts, control targets, source provenance, and stable dependencies needed for a future LLVM lowering without Bytecode decoding or a second Sema pass. The bounded shared lifetime/control view MAY be derived for verification and backend admission, but this change MUST NOT add a general persisted CFG, LLVM types, libraries, emitters, tests, or runtime lifecycle.

#### Scenario: Backend-neutral boundary contains no LLVM state
- **WHEN** canonical AST and public/cache views are built and inspected
- **THEN** no node or interface contains `llvm::Value`, LLVM IR type, LLVM context, ORC, object-cache, or executable-memory ownership
- **AND** Bytecode and TypedASTJIT can consume the same semantic graph through backend-local state
