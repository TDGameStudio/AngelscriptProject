## ADDED Requirements

### Requirement: FunctionBody may link an optional canonical AST body sidecar
A Cache V2 FunctionBody MAY link one versioned `ASTBodySidecar` for the same FunctionKey and complete artifact profile. The sidecar SHALL contain pointer-free canonical function-body AST DTOs, snapshot-local integer IDs, stable source/type/declaration/function keys, semantic dependencies, and a content hash. It MUST NOT contain live AST objects, Parser nodes, `asCTypeInfo*`, `asCScriptFunction*`, or Engine-local numeric IDs as durable identity.

#### Scenario: Capture-on function publishes AST body data
- **WHEN** a retain-policy source compile seals and verifies a function body and publishes Cache V2
- **THEN** its FunctionBody may link an `ASTBodySidecar` with matching owner/profile/schema identity
- **AND** the FunctionBody VM payload is byte-identical to the payload produced when only AST retention differs

#### Scenario: Capture-off publication omits AST body data
- **WHEN** a discard-policy Engine publishes the same VM function
- **THEN** its FunctionBody records the canonical AST-sidecar absence coordinate
- **AND** no empty-payload record is used to impersonate absence

### Requirement: Cache V2 rebuilds a complete verified module AST snapshot
For retain-policy ExactStartup, Cache V2 SHALL reconstruct SourceManager, declarations, types, globals, and every required function body from version-compatible stable records, remap them into the target Engine, seal the ASTContext, and rerun the canonical verifier before module activation. Publication SHALL remain module-atomic.

#### Scenario: Exact restore publishes retained AST
- **WHEN** SourceIndex, ModuleInterface, TypeSchema, ModuleState, FunctionBody, ASTBodySidecar, dependencies, profile, and environment all match
- **THEN** ExactStartup restores VM state and one complete retained canonical AST snapshot without preprocessing, parsing, Sema, or Bytecode CodeGen

#### Scenario: AST fragment is missing or invalid
- **WHEN** a required sidecar is missing, wrong-kind, owner/profile mismatched, corrupt, unsupported, unremappable, or verifier-invalid
- **THEN** the retain-policy module is a safe restore miss before Engine mutation
- **AND** no partial AST or VM module is published

#### Scenario: Discard-policy Engine sees sidecars
- **WHEN** a discard-policy Engine restores a valid ModuleSnapshot containing AST sidecars
- **THEN** it may restore VM state while ignoring AST sidecars
- **AND** `AcquireASTSnapshot` remains unavailable

### Requirement: Incremental cache reuses canonical AST at function granularity
After the authoritative frontend re-establishes current declaration/type/source authority and validates actual dependency inputs, a changed module SHALL be able to reuse unchanged FunctionBody/ASTBodySidecar pairs and compile only function misses. The final replacement module and canonical AST snapshot SHALL still publish atomically.

#### Scenario: One function body changes
- **WHEN** one function source/input digest changes while sibling declarations, types, bodies, and actual dependencies remain valid
- **THEN** exactly that function's Bytecode and AST body are rebuilt
- **AND** unchanged body records are reused in the new complete module snapshot

#### Scenario: Type layout change invalidates AST references
- **WHEN** a declaration/type schema change affects body type or member references
- **THEN** the existing typed dependency closure selects every affected FunctionBody/ASTBodySidecar as a miss
- **AND** no stale stable type/member reference enters the new snapshot

### Requirement: AST persistence remains separate from SaveByteCode and dumps
AngelScript `SaveByteCode`, Cache V2 FunctionBody VM bytes, textual/JSON AST or HIR dumps, and public snapshot memory SHALL remain separate persistence domains. Only validated Cache V2 AST DTO records or the live same-build AST MAY supply a retained snapshot.

#### Scenario: SaveByteCode module is loaded
- **WHEN** a module is restored only through `SaveByteCode` data without canonical AST sidecars
- **THEN** VM functions may execute but no public or TypedASTJIT AST snapshot is available

#### Scenario: Dump files are present
- **WHEN** AST/HIR dump files exist beside Cache V2 packs or source
- **THEN** the loader ignores them and derives no AST identity or content from them
