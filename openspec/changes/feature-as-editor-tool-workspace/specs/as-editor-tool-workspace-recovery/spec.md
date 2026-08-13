## ADDED Requirements

### Requirement: Workspace drafts use a separate versioned bounded store
The Editor SHALL save unsubmitted workspace documents only beneath `Saved/Angelscript/ToolWorkspace/v1/` and SHALL keep that draft store independent from Tool History, active memory modules and runner sessions.

#### Scenario: Dirty draft becomes idle
- **WHEN** source editing remains idle for at least two seconds
- **THEN** the draft store SHALL best-effort publish the active document record
- **AND** a draft-write failure SHALL not compile, run or alter the active source module

#### Scenario: Tab or Editor closes
- **WHEN** the workspace tab closes or its Editor subsystem deinitializes with a dirty active draft
- **THEN** the store SHALL make one synchronous bounded save attempt
- **AND** SHALL report failure without persisting invocation arguments, returned payload, selection or runner state

#### Scenario: Tool History is forgotten
- **WHEN** the user forgets Tool History for a SourceId
- **THEN** workspace drafts for that SourceId SHALL remain unchanged until separately forgotten

#### Scenario: Draft is forgotten
- **WHEN** the user explicitly forgets one DocumentId
- **THEN** only that exact draft record and index entry SHALL be removed
- **AND** Tool History, active memory modules and runner sessions SHALL remain unchanged

### Requirement: Draft records are data-minimized and identity validated
Each draft record SHALL contain only schema/version identity, DocumentId, SourceId, ToolClassName, exact SourceText, SessionKey, optional submitted/active RevisionIds, dirty state and edit/save UTC times.

#### Scenario: Draft is written
- **WHEN** a valid document is autosaved
- **THEN** its record SHALL omit ArgumentsJson, PayloadJson, compiler diagnostics, editor context, UObject paths and tool fields

#### Scenario: Record identity mismatches its filename
- **WHEN** a draft record's DocumentId is not exactly the lowercase 32-hex identity used by its filename
- **THEN** that record SHALL be treated as corrupt and omitted from recovery

#### Scenario: Unsupported schema is found
- **WHEN** a draft or index uses an unsupported schema version
- **THEN** it SHALL remain inert with a recovery diagnostic
- **AND** SHALL NOT be migrated, compiled or executed automatically

### Requirement: Draft publication and retention are deterministic
Draft and index JSON SHALL use UTF-8 without BOM, same-directory temporary files and atomic replacement, with limits of 20 drafts, 1 MiB source per draft, 2 MiB per draft record, 4 MiB index and 32 MiB across the v1 root.

#### Scenario: Draft publication succeeds
- **WHEN** a draft save succeeds
- **THEN** readers SHALL observe a complete validated record before the index references its new state
- **AND** no temporary file SHALL be exposed as a recoverable draft

#### Scenario: Count or byte limit requires eviction
- **WHEN** saving a draft would exceed a store limit
- **THEN** the store SHALL evict the least-recently-edited eligible non-active draft first using DocumentId as the deterministic tie-break
- **AND** SHALL never evict the current active document

#### Scenario: Protected draft prevents admission
- **WHEN** no eligible eviction can admit the active draft
- **THEN** autosave SHALL return a capacity warning and preserve previously published records
- **AND** compile/run behavior SHALL remain available

#### Scenario: Stale temporary file remains after a crash
- **WHEN** the process leaves a draft temporary file
- **THEN** recovery SHALL ignore it
- **AND** bounded store maintenance MAY remove only recognized stale temporary names beneath the exact v1 root

### Requirement: Draft restoration is inert
Opening a recovered draft SHALL populate workspace document fields only and SHALL NOT compile source, dispatch a tool, recreate a runner session or claim that a historical class is active.

#### Scenario: Editor restarts with valid drafts
- **WHEN** the workspace opens after restart
- **THEN** it SHALL list at most 20 validated drafts ordered by most recent edit
- **AND** no draft SHALL be loaded into the compiler until the user chooses Compile or Compile & Run

#### Scenario: Recovered draft references an old active revision
- **WHEN** a record contains a previous ActiveRevisionId
- **THEN** the workspace SHALL display it as historical metadata only
- **AND** live module validation SHALL independently decide whether Run Active is available

#### Scenario: Draft is malformed or oversized
- **WHEN** a draft cannot pass schema, identity or size validation
- **THEN** recovery SHALL skip it with a bounded diagnostic
- **AND** SHALL never send its source to the preprocessor

### Requirement: History browsing uses only public bounded data APIs
The workspace SHALL list and load Tool History through the public data-only recovery library and SHALL NOT parse the history root, manifests, attempt records or run records directly.

#### Scenario: Recent history is opened
- **WHEN** the user opens the Recovery/History panel
- **THEN** the workspace SHALL request at most 100 recent sources and at most 50 revisions for one selected SourceId

#### Scenario: Revision metadata is selected
- **WHEN** the user selects a history summary without choosing Load Into Buffer
- **THEN** no document, active module or runner session SHALL change

#### Scenario: Exact revision is loaded
- **WHEN** the user chooses Load Into Buffer for a validated revision
- **THEN** exact SourceId, ToolClassName and SourceText SHALL populate a new draft or a user-confirmed current draft
- **AND** the document SHALL be marked unsubmitted until explicitly compiled

#### Scenario: Current buffer is dirty
- **WHEN** loading a revision would replace dirty source text
- **THEN** the workspace SHALL require explicit discard/replace confirmation or create a separate eligible draft
- **AND** cancellation SHALL preserve the current buffer exactly

#### Scenario: Persisted attempt or run stream is requested
- **WHEN** the underlying public Tool History contract provides no bounded attempt/run list API
- **THEN** the workspace SHALL not read private JSON records to synthesize that UI

### Requirement: Export transfers exact source ownership to the user
The workspace SHALL provide Export Current Buffer As and Export Revision As operations that require a user-selected `.as` path and SHALL not create or require a managed tools directory.

#### Scenario: Current buffer is exported
- **WHEN** the user selects a destination ending in `.as` and confirms any overwrite
- **THEN** the workspace SHALL atomically publish the exact current source as UTF-8 without BOM
- **AND** the resulting file SHALL be owned and organized by the user

#### Scenario: Historical revision is exported
- **WHEN** the user exports an exact loaded Tool History revision
- **THEN** the exporter SHALL write that revision's exact SourceText rather than the current dirty buffer

#### Scenario: Destination is cancelled or invalid
- **WHEN** the save dialog is cancelled or the selected filename does not end in `.as`
- **THEN** no destination file, draft, history record, module or runner session SHALL change

#### Scenario: Destination is inside a watched script root
- **WHEN** a successful export creates a file beneath an already configured script root
- **THEN** the exporter SHALL not invoke compilation directly
- **AND** the existing directory watcher MAY observe the file through normal Hot Reload behavior

#### Scenario: Export write fails
- **WHEN** the temporary write or atomic destination replacement fails
- **THEN** the workspace SHALL report the exact file error
- **AND** SHALL preserve the source buffer and avoid claiming export success

### Requirement: Recovery actions preserve store and execution separation
Every recovery action SHALL identify whether it affects a workspace draft, Tool History data, active memory source or runner session and SHALL NOT broaden its side effects implicitly.

#### Scenario: Reset Session is used
- **WHEN** a runner session is reset
- **THEN** no draft or Tool History record SHALL be removed

#### Scenario: Forget Draft is used
- **WHEN** a workspace draft is forgotten
- **THEN** no active memory module SHALL be unloaded and no runner session SHALL be reset

#### Scenario: Revision is loaded
- **WHEN** historical source is loaded into a buffer
- **THEN** no compile, run, reset, forget or export operation SHALL occur without a separate user action
