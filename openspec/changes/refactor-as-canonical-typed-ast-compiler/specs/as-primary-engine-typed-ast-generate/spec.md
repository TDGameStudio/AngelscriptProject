## ADDED Requirements

### Requirement: Matching-profile Generate consumes the current primary AST snapshot
Editor Generate for the primary Engine's exact target profile SHALL freshness-check and lease the current primary compiled graph and retained canonical AST snapshot. It MUST NOT create `EAngelscriptEnginePurpose::StaticJITGeneration`, force-clean, compile, reload, reinstance, or mutate the primary Engine as part of that matching request.

#### Scenario: Current matching profile emits without another Engine
- **WHEN** the primary source inventory, target profile, compiled graph, and retained AST snapshot are current
- **THEN** matching-profile TypedASTJIT Generate reads that immutable graph and snapshot
- **AND** no generation Engine or additional source compile occurs

#### Scenario: Matching profile has no retained snapshot
- **WHEN** matching-profile TypedASTJIT Generate runs against a current primary Engine built with AST discard policy
- **THEN** Generate fails closed with a stable `ASTSnapshotRequired` result
- **AND** it does not create a sibling Engine as an implicit workaround

#### Scenario: Primary state is stale
- **WHEN** the primary source inventory or generation key cannot be proven current
- **THEN** Generate returns `AuthoritativeEngineStale` and directs the caller to the normal Hot Reload/recompile path
- **AND** it does not mutate or package output

### Requirement: Non-matching profiles use one contained generation Engine at a time
Editor batch and commandlet generation for a non-matching profile SHALL use exactly one contained generation Engine for that concrete profile, replay the complete bind surface, compile the complete Provider source graph to canonical AST once, perform descriptor-only analysis, emit the selected module set, and destroy request-owned state before another generation Engine starts.

#### Scenario: Editor emits another profile
- **WHEN** EditorDevelopment is primary and Generate requests GameShipping
- **THEN** one GameShipping generation Engine builds the complete source graph and canonical AST
- **AND** it emits only GameShipping-owned output and is destroyed before the request completes

#### Scenario: Batch requests multiple profiles
- **WHEN** a request includes multiple non-matching profiles
- **THEN** their generation Engines execute sequentially through the same helper
- **AND** no two extra Engines are alive simultaneously

### Requirement: Generate freezes Hot Reload and preserves primary ownership
Generate SHALL freeze application of queued Hot Reload changes while holding source/compiled-graph/AST leases. Success and every early-fail path SHALL leave primary packages, reflection objects, CDOs, routes, module/type/function registries, cache ownership, delegates, worlds, and pooled contexts unchanged except explicitly owned generated files.

#### Scenario: File changes during Generate
- **WHEN** a script file change arrives while Generate holds its immutable input leases
- **THEN** the change is queued for normal processing after Generate
- **AND** the current request neither applies nor discards it

#### Scenario: Generation fails after partial analysis
- **WHEN** bind replay, source compilation, AST verification, descriptor analysis, native-call classification, emission, or packaging fails
- **THEN** request-owned state is released through the same containment boundary as success
- **AND** before/after ownership snapshots show no primary mutation

### Requirement: Primary generation uses a stable native-form recipe catalog
Normal per-Engine bind replay SHALL remain authoritative for registering declarations. Each real registration MAY insert or validate a process-global native-form recipe keyed by stable declaration identity and target/bind profile. Matching-profile Generate SHALL resolve reviewed HeaderInline, module-exported, and bridge metadata from that catalog rather than requiring pointer-keyed forms from a sibling Engine.

#### Scenario: Primary bind replay supplies a recipe
- **WHEN** normal primary Engine registration attaches a reviewed native form to a stable declaration
- **THEN** matching-profile Generate can resolve the same recipe without replaying binds in another Engine

#### Scenario: Recipe is missing or ABI-incompatible
- **WHEN** a canonical AST call has no exact profile/identity/ABI/route-safe catalog recipe
- **THEN** TypedASTJIT uses its existing bridge or function fallback contract
- **AND** a display name alone is never treated as external DLL linkage proof

### Requirement: AST dump is separate from artifact generation
Developer/test AST inspection SHALL be a read-only snapshot request and MUST NOT be a StaticJIT backend, Provider input file, or compilation trigger. Matching-profile inspection MAY lease the primary retained snapshot; isolated profile inspection SHALL use a contained process/Engine appropriate to that profile.

#### Scenario: Matching-profile dump reads the primary snapshot
- **WHEN** a developer requests an AST dump for the current retained primary profile
- **THEN** the dump reads and verifies the existing snapshot without compiling or emitting Provider files

#### Scenario: Dump files exist beside cache or generated output
- **WHEN** textual or JSON AST/HIR dump files are present
- **THEN** Cache restore and TypedASTJIT Generate ignore them as inputs
