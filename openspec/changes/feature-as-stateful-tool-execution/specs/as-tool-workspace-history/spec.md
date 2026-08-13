## ADDED Requirements

### Requirement: Tool History records only explicit Editor tool-source activity
The Editor module SHALL provide policy-controlled local Tool History for explicitly submitted memory tool sources and SHALL NOT observe or persist ordinary AngelScript compilation or Runtime runner calls.

#### Scenario: Default policy records source and diagnostics
- **WHEN** an Editor `CompileToolSource` or `CompileAndRunSource` request omits an explicit history policy and Tool History is enabled in Editor per-project user settings
- **THEN** the request SHALL use `SourceAndDiagnostics`
- **AND** record the exact submitted source revision and compile attempt diagnostics

#### Scenario: History can be disabled per request
- **WHEN** a Tool Source request selects `None`
- **THEN** compilation or execution SHALL proceed without reading or writing Tool History

#### Scenario: History can be disabled by local settings
- **WHEN** Editor per-project user settings disable Tool History
- **THEN** Tool Source requests SHALL perform their compile/run work without writing history
- **AND** return a distinct disabled history status rather than a compile/run failure

#### Scenario: Optional run summary is explicit
- **WHEN** an Editor `RunCompiledTool` or `CompileAndRunSource` request selects `SourceDiagnosticsAndRunSummary`
- **THEN** the Editor adapter SHALL record a bounded run summary after dispatch
- **AND** a Runtime `RunTool` call outside that Editor adapter SHALL NOT write a run summary

#### Scenario: Run-compiled is persistence-free by default
- **WHEN** a `RunCompiledTool` request omits an explicit history policy
- **THEN** the request SHALL use `None`
- **AND** SHALL NOT read or write Tool History

#### Scenario: Other script activity is ignored
- **WHEN** Snippet, disk script, generated source, project Hot Reload, Cache V2 or another AngelScript compile operation executes outside an explicit Tool Source request
- **THEN** Tool History SHALL NOT create a source, attempt or run record for it

### Requirement: Tool History uses a versioned contained local store
Tool History SHALL store records beneath `Saved/Angelscript/ToolHistory/v1/`, SHALL derive physical source directories from a cryptographic hash of canonical SourceId, and SHALL validate schema, identity, containment and bounded sizes on every read and write.

#### Scenario: Canonical SourceId maps to contained storage
- **WHEN** a valid canonical SourceId is recorded
- **THEN** its records SHALL be stored only beneath `Sources/<blake3(canonical-source-id)>/` in the v1 history root
- **AND** each manifest and record SHALL include the canonical SourceId and schema version

#### Scenario: Storage-key identity mismatch is rejected
- **WHEN** a manifest or record's SourceId does not hash to its containing source directory
- **THEN** the record SHALL be treated as corrupt
- **AND** SHALL NOT be returned as recoverable source

#### Scenario: Unsupported schema is inert
- **WHEN** a Tool History record has an unsupported schema version
- **THEN** it SHALL be ignored with a diagnostic
- **AND** SHALL NOT be automatically migrated, compiled or executed

#### Scenario: Invalid SourceId cannot access history
- **WHEN** a list, load or forget request supplies an invalid or non-canonical SourceId
- **THEN** the request SHALL fail before resolving a filesystem target

### Requirement: Source revisions and activity records have separate identities
Tool History SHALL store immutable content-addressed source revisions separately from compile attempts and run summaries so repeated activity is observable without duplicating identical source text.

#### Scenario: New source creates an immutable revision
- **WHEN** canonical SourceId, exact ToolClassName or exact UTF-8 SourceText differs from every retained revision identity
- **THEN** Tool History SHALL create one immutable revision containing those exact values and its content-derived RevisionId

#### Scenario: Validated source is journaled before compilation
- **WHEN** an explicit recording request passes SourceId, ToolClassName and SourceText validation
- **THEN** the Editor adapter SHALL best-effort publish its immutable source revision before preprocessing
- **AND** a history publication failure SHALL NOT prevent the compile attempt from proceeding

#### Scenario: Identical source reuses its revision
- **WHEN** the same canonical SourceId, ToolClassName and exact UTF-8 SourceText are submitted again
- **THEN** Tool History SHALL reuse the existing RevisionId
- **AND** SHALL NOT create a duplicate source body record

#### Scenario: Every compile has an attempt record
- **WHEN** an explicit Tool Source compile reaches preprocessing or compilation under a recording policy
- **THEN** Tool History SHALL append a distinct compile-attempt record referring to the RevisionId
- **AND** include UTC time, attempted status and scoped diagnostics

#### Scenario: Pre-validation failure is not persisted
- **WHEN** SourceId, ToolClassName or SourceText fails request validation before preprocessing
- **THEN** Tool History SHALL NOT create a source revision or attempt record

#### Scenario: Run summary refers to exact activity
- **WHEN** a run summary is enabled and dispatch is attempted
- **THEN** it SHALL refer to canonical SourceId, ToolClassName, known RevisionId, normalized SessionKey, run status, bounded message and UTC start/end times

### Requirement: Tool History minimizes persisted execution data
Tool History v1 SHALL NOT persist runtime object references, world identity, invocation arguments, returned payloads or tool UObject fields.

#### Scenario: Context and JSON bodies are omitted
- **WHEN** an Editor tool invocation is recorded with run-summary policy
- **THEN** its ContextObject, ArgumentsJson and PayloadJson SHALL NOT appear in the persisted run record

#### Scenario: Tool state is not serialized
- **WHEN** a runner session has mutable reflected or non-reflected fields
- **THEN** Tool History SHALL NOT serialize those fields
- **AND** restarting the Editor SHALL require a new runner/session initialized from normal class defaults

#### Scenario: Recovery is not replay
- **WHEN** a caller loads an old source revision
- **THEN** Tool History SHALL return source and metadata only
- **AND** SHALL NOT restore its old invocation, World, UObject session or prior side effects

### Requirement: History publication is atomic and recovery is fail-closed
Tool History SHALL publish immutable records through same-directory temporary files and atomic replacement, SHALL publish manifests/index only after their referenced records, and SHALL never compile or execute corrupt or partially published data.

#### Scenario: Successful publication leaves complete JSON
- **WHEN** a source revision, attempt, run, manifest or index write succeeds
- **THEN** readers SHALL observe a complete UTF-8 JSON record matching its declared schema and identity
- **AND** no temporary path SHALL be returned through public history APIs

#### Scenario: Record write fails before pointer publication
- **WHEN** an immutable record cannot be written or atomically published
- **THEN** its manifest and root index SHALL NOT be advanced to reference it

#### Scenario: Corrupt record is skipped
- **WHEN** a manifest refers to a missing, oversized, malformed or identity-mismatched record
- **THEN** list/load SHALL report a history diagnostic and omit that record
- **AND** SHALL NOT pass its source to the preprocessor

#### Scenario: Corrupt index can be rebuilt
- **WHEN** the root index is missing or corrupt but valid bounded source manifests remain
- **THEN** an explicit rebuild operation SHALL be able to reconstruct the index from validated manifests
- **AND** reconstruction SHALL NOT compile or execute any revision

#### Scenario: Stale temporary files are inert
- **WHEN** a previous Editor process leaves temporary history files
- **THEN** readers SHALL ignore them
- **AND** bounded maintenance MAY remove them without treating them as revisions

### Requirement: Tool History retention is deterministic and bounded
Editor per-project user settings SHALL default Tool History to at most 100 SourceIds, 50 revisions, 100 compile attempts and 100 run summaries per SourceId, and 256 MiB across the v1 root.

#### Scenario: Per-source activity exceeds its limit
- **WHEN** a successful record would exceed a per-source revision, attempt or run-summary limit
- **THEN** retention SHALL remove the oldest eligible records first
- **AND** preserve the newest revision and current last-known-good revision while that SourceId remains indexed

#### Scenario: Source count exceeds its limit
- **WHEN** recording a new SourceId would exceed the configured SourceId count
- **THEN** retention SHALL remove the least-recently-recorded eligible SourceId history first
- **AND** SHALL NOT delete the SourceId currently being recorded

#### Scenario: Global byte limit requires eviction
- **WHEN** a successful record would exceed the configured global byte limit
- **THEN** retention SHALL evict oldest eligible history deterministically until the record fits

#### Scenario: Protected data prevents admission
- **WHEN** no eligible eviction can admit a new record without deleting protected data
- **THEN** the history write SHALL fail with a distinct capacity status
- **AND** SHALL leave already published history valid

#### Scenario: Limits cannot be configured as unbounded
- **WHEN** Editor settings are edited
- **THEN** every history count and byte limit SHALL remain within finite validated minimum and maximum bounds

### Requirement: History status does not override compile or execution truth
Every Editor tool-source result SHALL report Tool History status and warnings separately from authoritative compile and run results.

#### Scenario: Compile succeeds while history write fails
- **WHEN** source compiles successfully but history publication fails
- **THEN** the compile result SHALL remain successful and return the active tool class
- **AND** the history result SHALL report its independent failure and diagnostic

#### Scenario: Run succeeds while summary write fails
- **WHEN** a tool run succeeds but its optional run-summary write fails
- **THEN** the run result SHALL remain `Succeeded`
- **AND** the history result SHALL report its independent failure

#### Scenario: Compile fails and attempt history also fails
- **WHEN** the attempted source fails compilation and its history attempt cannot be written
- **THEN** the compile result SHALL retain its scoped compiler diagnostics
- **AND** SHALL NOT replace them with only the history error

### Requirement: Recovery APIs are explicit bounded and inert
The Editor module SHALL expose bounded recent-source, revision-list, revision-load and last-known-good-load APIs whose results contain data only and never cause compilation or execution.

#### Scenario: Recent sources are listed newest first
- **WHEN** a caller requests recent Tool Source metadata with a valid bounded Limit
- **THEN** the API SHALL return at most Limit validated entries ordered by most recent recorded activity

#### Scenario: Revisions are listed newest first
- **WHEN** a caller requests revisions for one valid SourceId with a valid bounded Limit
- **THEN** the API SHALL return at most Limit validated revision metadata entries ordered newest first

#### Scenario: Exact revision is loaded
- **WHEN** a caller requests a retained SourceId and RevisionId whose record validates
- **THEN** the API SHALL return exact SourceText, ToolClassName, identity and associated metadata
- **AND** SHALL NOT modify the active AngelScript module

#### Scenario: Last-known-good revision is loaded
- **WHEN** the per-source manifest identifies a retained successfully compiled RevisionId
- **THEN** the API SHALL return that exact revision as last-known-good
- **AND** SHALL NOT claim that it is currently loaded unless live module validation separately confirms it

#### Scenario: Invalid list limit is rejected
- **WHEN** a list request supplies a Limit outside 1 through 200
- **THEN** the API SHALL reject the request rather than scan or allocate without a bound

### Requirement: Exact history deletion does not control live execution
The Editor module SHALL expose an exact `ForgetToolHistory(SourceId)` operation and SHALL NOT expose a reflected clear-all history operation in v1.

#### Scenario: Exact source history is forgotten
- **WHEN** a caller explicitly forgets one valid canonical SourceId
- **THEN** only that SourceId's contained history directory and index entry SHALL be removed through a same-parent tombstone publication flow
- **AND** the result SHALL report whether deletion completed

#### Scenario: Interrupted forget is inert
- **WHEN** an interrupted forget leaves a tombstone directory
- **THEN** list, load and rebuild SHALL ignore that tombstone
- **AND** bounded maintenance MAY remove it without treating it as recoverable history

#### Scenario: Forget does not unload or reset
- **WHEN** history for an active SourceId is forgotten
- **THEN** the active AngelScript module and generated class SHALL remain governed by normal engine lifetime
- **AND** every runner session SHALL remain unchanged until separately reset or released

#### Scenario: Missing history is harmless
- **WHEN** a caller forgets a valid SourceId that has no history
- **THEN** the operation SHALL report a deterministic not-found/no-change outcome
- **AND** SHALL NOT create history or touch another SourceId

#### Scenario: Runtime cannot delete Tool History
- **WHEN** code is built without the Editor module
- **THEN** no Tool History list, load, rebuild or forget API SHALL be available
