## ADDED Requirements

### Requirement: The Editor exposes one official dockable Tool Workspace
The Editor module SHALL register one singleton nomad tab named `Angelscript.ToolWorkspace` under the AngelScript Tools workspace group and SHALL provide an explicit Tools-menu entry to open or focus it.

#### Scenario: Workspace is opened
- **WHEN** the user invokes the Tool Workspace menu entry or tab command
- **THEN** the Editor SHALL open or focus the single workspace tab
- **AND** SHALL NOT create a second workspace runner or duplicate tab

#### Scenario: Slate is unavailable
- **WHEN** the Editor module runs in a commandlet or without initialized Slate
- **THEN** it SHALL NOT register or spawn the visible workspace
- **AND** Runtime tool execution APIs SHALL remain unaffected

#### Scenario: Existing Snippet window is used
- **WHEN** the user opens Run AngelScript Snippet
- **THEN** it SHALL retain its isolated Immediate source and default discard behavior
- **AND** SHALL NOT share the workspace runner, documents or drafts

### Requirement: Workspace runner lifetime is explicit and host-scoped
A native Editor subsystem SHALL explicitly own one `UAngelscriptToolRunner` for the workspace process lifetime, and that ownership SHALL NOT change the runner contract into a global or plugin-wide singleton.

#### Scenario: Workspace tab closes
- **WHEN** the visible tab closes while the Editor subsystem remains alive
- **THEN** the workspace runner and its admitted logical sessions SHALL remain owned by that subsystem
- **AND** reopening the tab SHALL reconnect to the same host-owned runner

#### Scenario: User resets one workspace session
- **WHEN** Reset Session receives the exact last successful SessionId for the current document and SessionKey
- **THEN** only that runner session SHALL be removed
- **AND** source history, draft text and active memory module SHALL remain unchanged

#### Scenario: Editor restarts
- **WHEN** the Editor subsystem deinitializes and a later process starts
- **THEN** a new runner SHALL be created
- **AND** no prior tool UObject fields or session instances SHALL be restored

### Requirement: Workspace documents use bounded stable source identity
The workspace SHALL support at most 20 draft documents, each with one valid canonical SourceId, exact ToolClassName, source text within the underlying 1 MiB UTF-8 limit and one normalized SessionKey.

#### Scenario: New draft is created
- **WHEN** the user creates a draft
- **THEN** the workspace SHALL allocate a workspace-only DocumentId and present an editable SourceId and ToolClassName
- **AND** SHALL NOT generate a timestamp or GUID as the memory SourceId

#### Scenario: Duplicate SourceId is already open
- **WHEN** the user attempts to open or rename a second document to a canonical SourceId already represented by another open draft
- **THEN** the operation SHALL fail with a focused validation message
- **AND** SHALL NOT let two buffers submit to the same memory module

#### Scenario: Source exceeds the execution bound
- **WHEN** current text exceeds 1 MiB after UTF-8 conversion
- **THEN** Compile and Compile & Run SHALL be disabled with an exact validation diagnostic
- **AND** existing active code and runner sessions SHALL remain untouched

#### Scenario: Draft limit is reached
- **WHEN** 20 drafts already exist and no eligible draft can be evicted under the recovery contract
- **THEN** New Draft SHALL fail without deleting the active draft or Tool History

### Requirement: Compile run and reset remain separate operations
The workspace SHALL expose Compile, Run Active, Compile & Run and Reset Session as distinct actions backed by the public stateful-tool APIs, preserving their nested structured results.

#### Scenario: Compile succeeds
- **WHEN** the user chooses Compile with valid full source
- **THEN** the workspace SHALL call compile-only with `SourceAndDiagnostics`
- **AND** SHALL display the resolved attempted and active identities without creating or running a tool session

#### Scenario: Run Active succeeds
- **WHEN** an exact valid active module/class is available and the user chooses Run Active
- **THEN** the workspace SHALL invoke `RunCompiledTool` without preprocessing or recompiling
- **AND** SHALL retain the returned exact SessionId for explicit reset

#### Scenario: Compile and Run succeeds
- **WHEN** the user chooses Compile & Run and the submitted source compiles to the requested valid tool class
- **THEN** the workspace SHALL run that newly successful active source through the workspace runner

#### Scenario: Compile and Run compilation fails
- **WHEN** the submitted source fails preprocessing, compilation or exact tool-class validation
- **THEN** the workspace SHALL display the attempted diagnostics
- **AND** SHALL NOT dispatch the failed source or silently run a prior active version

#### Scenario: Operation is re-entered
- **WHEN** a compile or run action is invoked while the same workspace controller is already compiling or running
- **THEN** the new action SHALL fail as Busy
- **AND** SHALL NOT create another runner, source submission or context snapshot

### Requirement: Last-known-good execution is a deliberate separate action
After a failed attempted update leaves an exact active last-known-good class, the workspace SHALL present that state separately and SHALL require an explicit Run Last Known Good action to dispatch it.

#### Scenario: Failed update retains active class
- **WHEN** compile reports `bHasLastKnownGood`
- **THEN** the UI SHALL keep the failed source and diagnostics in the editor
- **AND** SHALL label the separate action with the active revision/class identity when known

#### Scenario: User chooses Run Last Known Good
- **WHEN** the user explicitly invokes that action
- **THEN** the workspace SHALL revalidate and call `RunCompiledTool` for the exact active SourceId and ToolClassName
- **AND** SHALL NOT replace the failed source buffer with old text

#### Scenario: Active class is no longer valid
- **WHEN** revalidation cannot resolve the former last-known-good class
- **THEN** execution SHALL fail without global same-name fallback
- **AND** the UI SHALL clear the runnable-active indication after reporting the structured failure

### Requirement: Every execution captures context at click time
Run Active, Run Last Known Good and the run portion of Compile & Run SHALL capture one fresh `UAngelscriptEditorToolContext` and pass it as the invocation ContextObject without persisting it.

#### Scenario: Selection changes between runs
- **WHEN** the user runs the same logical session after changing Editor selection
- **THEN** each invocation SHALL receive its own point-in-time context
- **AND** the changed context SHALL NOT change session identity

#### Scenario: Context capture fails
- **WHEN** the workspace cannot capture a valid execution context
- **THEN** it SHALL not dispatch the tool
- **AND** SHALL preserve the buffer, active source and runner session

#### Scenario: Result is presented
- **WHEN** an invocation finishes
- **THEN** the UI MAY display context counts, truncation and world/play-state summary
- **AND** SHALL NOT display, serialize or persist the full selected-object set as run history

### Requirement: Synchronous execution is represented honestly
The workspace SHALL disable conflicting actions during synchronous compile/run dispatch and SHALL NOT expose Stop, Cancel or progress semantics that the v1 runner cannot honor.

#### Scenario: Tool is running synchronously
- **WHEN** the run callback remains on the Game Thread stack
- **THEN** Compile, Run, Reset, document switch and close-sensitive actions SHALL be disabled or rejected as Busy

#### Scenario: User seeks cancellation
- **WHEN** no asynchronous runner protocol exists
- **THEN** the workspace SHALL state that the operation cannot be cancelled safely
- **AND** SHALL NOT simulate cancellation by dropping the runner or context while dispatch is active

### Requirement: Workspace presents structured diagnostics and independent statuses
The workspace SHALL render scoped compile diagnostics, attempted/active revision state, Runtime result and Tool History/draft warnings from their structured results without scraping or reclassifying Output Log messages.

#### Scenario: Compile fails and history write also fails
- **WHEN** compilation returns source diagnostics and its history publication returns a separate error
- **THEN** both results SHALL be visible
- **AND** the history error SHALL NOT replace compiler truth

#### Scenario: Run succeeds and summary write fails
- **WHEN** Runtime returns Succeeded but optional run-summary publication fails
- **THEN** the displayed run status SHALL remain Succeeded
- **AND** the history failure SHALL appear as an independent warning

#### Scenario: Diagnostic is selected
- **WHEN** a displayed diagnostic has a valid row and column for the current virtual source
- **THEN** the workspace SHALL move the source editor caret to that position

### Requirement: Run-summary persistence is opt-in at the workspace level
The workspace SHALL default its per-project-user Record Data-Minimized Run Summaries setting to false and SHALL select the underlying history policy according to that explicit setting.

#### Scenario: Setting is disabled
- **WHEN** the user runs active compiled source with run-summary recording disabled
- **THEN** run-only SHALL use history policy `None`
- **AND** Compile & Run SHALL retain source-and-diagnostics recording without a run summary

#### Scenario: Setting is enabled
- **WHEN** the user enables data-minimized run summaries
- **THEN** subsequent workspace runs SHALL request `SourceDiagnosticsAndRunSummary`
- **AND** the UI SHALL state that context, arguments, payload and UObject fields are omitted
