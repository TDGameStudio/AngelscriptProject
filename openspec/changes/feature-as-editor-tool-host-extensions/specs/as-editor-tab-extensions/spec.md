## ADDED Requirements

### Requirement: Concrete script tab classes register deterministic nomad tabs
The Editor module SHALL discover only concrete loaded subclasses of `UScriptEditorTabExtension` and SHALL register each valid unique TabName as `AngelscriptEditorTools.<TabName>` in an AngelScript Tools workspace group.

#### Scenario: Valid tab declaration is discovered
- **WHEN** initial AngelScript compilation or Full Reload produces a concrete tab subclass with a valid unique TabName and `ShouldRegister()` returns true
- **THEN** one nomad-tab spawner SHALL be registered with the declared label, tooltip and icon

#### Scenario: Duplicate tab names are found
- **WHEN** multiple concrete tab classes declare the same canonical TabName
- **THEN** every conflicting declaration SHALL remain unregistered for that pass
- **AND** no existing tab shall be rebound according to iteration order

#### Scenario: Ordinary classes are loaded
- **WHEN** a class does not derive from `UScriptEditorTabExtension` or remains abstract
- **THEN** it SHALL NOT produce a tab entry regardless of script path, class metadata or `CallInEditor` functions

### Requirement: One open tab owns one reflected host session
Spawning a registered tab SHALL create one transient reflected `UAngelscriptEditorTabSession` that retains one concrete extension instance and its latest explicit context for the lifetime of that physical open tab.

#### Scenario: Tab opens
- **WHEN** the user invokes a registered tab that is not open
- **THEN** the host SHALL create one session and one extension instance
- **AND** SHALL call `BP_Initialize` exactly once with the initial context snapshot

#### Scenario: Existing singleton tab is invoked
- **WHEN** the same registered nomad tab is invoked while already open
- **THEN** Unreal SHALL focus the existing tab
- **AND** the host SHALL NOT create a second session or invoke Initialize again

#### Scenario: Tab closes and reopens
- **WHEN** the user closes the tab and later opens it again
- **THEN** the old instance SHALL receive at most one `BP_Deinitialize` and be released
- **AND** reopening SHALL create a fresh instance whose prior fields are not implicitly restored

### Requirement: Script tab content uses reflected properties and explicit action buttons
The tab host SHALL render the concrete extension instance in a standard `IDetailsView` and SHALL build a native action section from eligible zero-parameter `CallInEditor` functions without exposing arbitrary Slate widget construction to AngelScript.

#### Scenario: Extension declares reflected controls
- **WHEN** the concrete tab object has editable reflected properties or supported `CallInEditor` functions
- **THEN** the Details surface SHALL present the properties according to normal Unreal property metadata and categories
- **AND** the action section SHALL present eligible functions with their normal display name, category, tooltip and ordering metadata

#### Scenario: Reflected action is invoked
- **WHEN** the user activates an eligible zero-parameter `CallInEditor` action
- **THEN** the host SHALL synchronously invoke that exact function on the current extension instance under `FEditorScriptExecutionGuard`
- **AND** SHALL NOT invoke a stale pre-reload UFunction pointer

#### Scenario: Function has unsupported parameters or return value
- **WHEN** a `CallInEditor` function requires parameters or returns a value unsupported by the v1 action host
- **THEN** the action section SHALL omit it with a bounded diagnostic
- **AND** SHALL NOT construct a prompt or guess argument values

#### Scenario: Extension has no reflected controls
- **WHEN** the extension instance exposes no eligible property or action
- **THEN** the tab SHALL remain valid and show an empty-state explanation
- **AND** SHALL NOT attempt to infer UI from arbitrary script methods

#### Scenario: Script requests custom Slate
- **WHEN** a tab extension has no reflected v1 API for returning `SWidget`
- **THEN** the host SHALL continue to use the Details surface
- **AND** SHALL NOT reinterpret UObject pointers, strings or metadata as native Slate widgets

### Requirement: Tab context refresh is explicit
The tab SHALL capture context on open and only replace it after an explicit Refresh Context action, then invoke `BP_ContextRefreshed` with the new snapshot.

#### Scenario: Editor selection changes while tab remains open
- **WHEN** the user changes selection without choosing Refresh Context
- **THEN** the tab session SHALL retain its previous context snapshot
- **AND** the extension SHALL receive no implicit context callback

#### Scenario: Refresh Context succeeds
- **WHEN** the user chooses Refresh Context and capture succeeds
- **THEN** the session SHALL replace its reflected context reference
- **AND** the extension SHALL receive one callback with that exact new context

#### Scenario: Refresh Context fails
- **WHEN** current editor context cannot be captured
- **THEN** the previous valid context SHALL remain installed
- **AND** the tab SHALL display a bounded host warning

### Requirement: Open tabs reconcile with AngelScript reload honestly
The host SHALL preserve only compatible live-tab state supported by normal reflected class reinstancing and SHALL close tabs whose declaration identity or class compatibility is lost.

#### Scenario: Body-only implementation changes
- **WHEN** an open tab's script receives a body-only reload without class replacement
- **THEN** the same physical extension instance SHALL remain hosted
- **AND** subsequent reflected actions SHALL use the updated function code

#### Scenario: Compatible structural replacement retains TabName
- **WHEN** Full Reload replaces the extension class compatibly and the reflected session reference is reinstanced
- **THEN** the tab SHALL bind its Details view to the replacement instance
- **AND** SHALL preserve only compatible reflected property state migrated by the existing class reinstancer

#### Scenario: Tab class is removed renamed or incompatible
- **WHEN** Full Reload cannot resolve a compatible concrete class for the same stable TabName
- **THEN** the host SHALL best-effort deinitialize and close the affected tab
- **AND** SHALL unregister its old spawner without claiming state migration

### Requirement: Tab teardown is idempotent and Editor-only
The host SHALL close and release all owned tab sessions and unregister all spawners/delegates during module shutdown or engine pre-exit, and SHALL remain inert in commandlets or non-Slate processes.

#### Scenario: Shutdown follows normal tab close
- **WHEN** a tab was already closed before module shutdown
- **THEN** shutdown SHALL NOT invoke Deinitialize a second time or release the session twice

#### Scenario: Shutdown occurs with tabs open
- **WHEN** the Editor module shuts down while hosted tabs remain open
- **THEN** every live extension SHALL receive at most one best-effort Deinitialize before its session is released

#### Scenario: Headless process loads the Editor module
- **WHEN** Slate or the global tab manager is unavailable
- **THEN** no script tab spawner or session SHALL be created
