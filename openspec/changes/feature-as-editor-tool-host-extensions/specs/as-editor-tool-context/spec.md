## ADDED Requirements

### Requirement: Editor tool context capture is explicit and owner-scoped
The Editor module SHALL expose a Game Thread-only operation that creates one transient `UAngelscriptEditorToolContext` using an explicit valid Owner and SHALL NOT retain that context in a global service.

#### Scenario: Valid owner captures a context
- **WHEN** a caller supplies a valid reachable Owner while the Unreal Editor is available
- **THEN** the operation SHALL create a transient context whose Outer is that Owner
- **AND** the caller or its reflected owner SHALL control how long the context remains reachable

#### Scenario: Invalid owner is rejected
- **WHEN** the caller supplies null, unreachable or pending-destruction ownership
- **THEN** capture SHALL fail before querying Level Editor or Content Browser selection
- **AND** SHALL NOT create a rooted or globally retained context

#### Scenario: Off-thread capture is rejected
- **WHEN** capture is requested outside the Game Thread
- **THEN** it SHALL return a structured unavailable result
- **AND** SHALL NOT access Editor selection state

### Requirement: Context snapshots bounded editor state without loading assets
One captured context SHALL contain the current Editor world, Level Editor actor selection, Content Browser asset metadata and Content Browser virtual-folder selection, together with capture-time PIE/SIE state and independent truncation indicators.

#### Scenario: Current selections are captured
- **WHEN** actors, assets and virtual folders are selected at capture time
- **THEN** the context SHALL contain the selected actors, `FAssetData` values and canonical virtual folder names observed during that operation
- **AND** the asset capture SHALL NOT synchronously load an asset solely to populate the snapshot

#### Scenario: Empty selections remain explicit
- **WHEN** no actor, asset or folder is selected
- **THEN** the context SHALL contain empty corresponding collections
- **AND** SHALL still record the available Editor world and play/simulate flags

#### Scenario: Collection bound is reached
- **WHEN** any selected collection contains more than 4096 entries
- **THEN** the context SHALL retain at most 4096 entries from that collection in stable source order
- **AND** SHALL set that collection's truncation indicator without discarding the other context categories

#### Scenario: Editor integration is unavailable
- **WHEN** `GEditor`, the Level Editor selection service or the Content Browser selection service is unavailable
- **THEN** capture SHALL report which category was unavailable
- **AND** SHALL NOT invent selection values from project files or a previous snapshot

### Requirement: A captured context is inert and point-in-time
`UAngelscriptEditorToolContext` SHALL NOT subscribe to selection delegates, auto-refresh, persist to disk or reinterpret later editor state as part of the original capture.

#### Scenario: Selection changes after capture
- **WHEN** the user changes actor, asset or folder selection after a context was created
- **THEN** the existing context SHALL continue to expose its captured values
- **AND** a caller SHALL request a new context to observe the new selection

#### Scenario: Map or object lifetime changes after capture
- **WHEN** the captured world is replaced or a selected actor becomes invalid
- **THEN** the context SHALL expose the reference only while it remains valid
- **AND** SHALL NOT resolve a replacement world or actor by name

#### Scenario: Editor restarts
- **WHEN** the Editor process exits and later restarts
- **THEN** no context, selection or captured UObject identity SHALL be restored from `Saved` or configuration

### Requirement: Context World resolution uses only the captured Editor world
The context's `GetWorld()` SHALL return the captured Editor world while valid and SHALL NOT switch to a later PIE, GameInstance or globally active world.

#### Scenario: Context is passed to a tool runner
- **WHEN** a captured context is used as a tool invocation ContextObject
- **THEN** world-sensitive dispatch SHALL be able to resolve the capture-time Editor world through that object

#### Scenario: No Editor world was captured
- **WHEN** capture succeeded without an available Editor world
- **THEN** `GetWorld()` SHALL return null
- **AND** SHALL NOT fall back to `GEditor`, the context Owner or the first active PIE world
