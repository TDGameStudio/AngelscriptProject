## ADDED Requirements

### Requirement: Matching-profile Generate consumes the primary Engine

When the Generate/Refresh request target profile equals the primary Engine target profile, the orchestrator SHALL build `CompiledSourceGraph` from that primary Engine's current compiled modules. It MUST NOT create a generation Engine for that matching request. `"bytecode"` SHALL use the primary bytecode graph. `"typed-ast"` SHALL use primary verified HIR.

#### Scenario: Editor matching-profile TypedASTJIT Generate

- **WHEN** the Editor primary Engine was created for `EditorDevelopment` with capture enabled, the frozen backend is `"typed-ast"`, and its source inventory is current
- **THEN** Generate emits Provider artifacts from primary verified HIR
- **AND** no `EAngelscriptEnginePurpose::StaticJITGeneration` Engine is constructed for that request

#### Scenario: Matching typed-ast without primary HIR fails closed

- **WHEN** matching-profile Generate selects `"typed-ast"` and the primary Engine has capture off or functions lack verified HIR
- **THEN** Generate returns `CaptureRequired` or `MissingTypedHIR`
- **AND** it does not create a generation Engine to obtain matching-profile HIR

#### Scenario: Stale primary source is rejected without a sibling Engine

- **WHEN** the primary Engine source inventory, content identity, or profile is stale
- **THEN** Generate returns `AuthoritativeEngineStale`
- **AND** it does not ForceClean, compile, reload, reinstance, or create a generation Engine

#### Scenario: Matching-profile BytecodeJIT also skips the sibling Engine

- **WHEN** the frozen backend is `"bytecode"` and Generate requests the primary target profile
- **THEN** orchestration uses the primary compiled bytecode graph
- **AND** it does not construct a temporary Engine solely for BytecodeJIT emit

### Requirement: Non-matching profiles use sequential generation Engines

Generate for a target profile other than the primary Engine profile SHALL use a contained `EAngelscriptEnginePurpose::StaticJITGeneration` Engine created for that profile. Editor and `UAngelscriptJITCommandlet` SHALL share this path. A batch MAY emit multiple profile trees: matching profile from primary, other profiles from sequential generation Engines. At most one generation Engine SHALL be alive at a time. Commandlet/CI with no live Editor primary SHALL use a generation Engine for every requested profile.

#### Scenario: Editor requests GameShipping artifacts

- **WHEN** the live Editor primary profile is `EditorDevelopment` and the user requests `GameShipping` Generate
- **THEN** orchestration creates one generation Engine with Shipping traits, emits `Generated/GameShipping`, and destroys that Engine
- **AND** the Editor primary Engine's modules, optional HIR, and packages are observably unchanged

#### Scenario: Batch Dev and Shipping from Editor

- **WHEN** one user action requests the matching Editor profile plus `GameDevelopment` and `GameShipping`
- **THEN** matching-profile artifacts are emitted in-process from the primary Engine
- **AND** each remaining profile uses one sequential generation Engine
- **AND** the three trees keep distinct profile identity in filenames and Provider manifests
- **AND** two generation Engines are never alive together

#### Scenario: Commandlet is isolated authority for pack-time profiles

- **WHEN** a non-Editor Commandlet performs Generate for one or more concrete profiles
- **THEN** each profile uses exactly one contained generation Engine in that process, sequentially
- **AND** the commandlet does not initialize or mutate a live Editor primary Engine

#### Scenario: Generation-Engine HIR capture is request-scoped

- **WHEN** a generation Engine compiles a `"bytecode"` request
- **THEN** typed-HIR capture stays off
- **WHEN** a generation Engine compiles a `"typed-ast"` request
- **THEN** capture is enabled on that Engine only and is destroyed with the Engine

### Requirement: Primary HIR capture is optional and frozen at Engine create

A primary Engine MAY enable typed-HIR capture before `FAngelscriptEngine::Create()`. Capture MUST NOT be toggled on a live Engine. `"bytecode"` primary Engines SHALL stay capture-off. Changing Static backend, primary target profile, or capture policy SHALL require process restart.

#### Scenario: Capture-on Editor startup restores or compiles HIR

- **WHEN** Editor starts with primary capture enabled
- **THEN** the primary Engine compiles or ExactStartup-restores functions with verified HIR attached
- **AND** Hot Reload recompile replaces HIR on affected functions in that same Engine

#### Scenario: Capture-off Editor still runs

- **WHEN** Editor starts with primary capture disabled
- **THEN** matching `"bytecode"` Generate remains available from the primary bytecode graph
- **AND** matching `"typed-ast"` Generate is rejected until restart with capture enabled

#### Scenario: Backend switch is rejected without restart

- **WHEN** a running Editor session attempts to change Static backend from `"bytecode"` to `"typed-ast"` or the reverse
- **THEN** the configuration change is rejected or deferred until restart
- **AND** no live Engine toggles `SetTypedSemanticIRCapture`

### Requirement: Generate freezes Hot Reload for the request

Matching-profile Generate SHALL freeze the Hot Reload queue for the duration of analysis, emit, and owned-file write. It MUST NOT ForceClean Cache, FullReload, SoftReload, or reinstance actors as part of artifact generation.

#### Scenario: File change during Generate is queued

- **WHEN** a `.as` file changes while matching-profile Generate is running
- **THEN** the watcher queues the change
- **AND** Generate still reads the frozen primary compiled graph
- **AND** Hot Reload runs only after Generate releases the queue

### Requirement: Primary Generate does not mutate Editor ownership

Matching-profile Generate MAY read primary descriptors, native reflection, optional HIR, and native-form catalog entries. It MUST NOT acquire `/Script/Angelscript` package ownership, sweep class caches, publish script routes, or replace global descriptor tables. A sequential generation Engine for a non-matching profile MUST use the existing containment boundary and MUST NOT mutate those primary tables.

#### Scenario: Successful matching-profile Generate is containable

- **WHEN** matching-profile Generate succeeds
- **THEN** before/after snapshots show no primary package, route, CDO, or class-cache mutation
- **AND** only owned Provider files under the requested profile directory change

#### Scenario: Failed matching-profile Generate is containable

- **WHEN** HIR verification, eligibility, emit, or packaging fails
- **THEN** the same containment boundary holds
- **AND** no generation Engine is left alive
