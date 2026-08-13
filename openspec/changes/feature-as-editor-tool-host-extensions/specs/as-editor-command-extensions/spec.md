## ADDED Requirements

### Requirement: Concrete script command classes register deterministic command identities
The Editor module SHALL discover only concrete loaded subclasses of `UScriptEditorCommandExtension` and SHALL register each valid unique CommandName under the `AngelscriptEditorTools` command-binding context.

#### Scenario: Valid concrete command is discovered
- **WHEN** initial AngelScript compilation or a later Full Reload produces a concrete command subclass with a valid unique CommandName and `ShouldRegister()` returns true
- **THEN** the Editor SHALL register `AngelscriptEditorTools.<CommandName>` with the declared display name, description and icon

#### Scenario: Abstract and ordinary tool classes are ignored
- **WHEN** a loaded class is abstract, derives only from `UAngelscriptTool`, or is an unrelated script class
- **THEN** command discovery SHALL NOT register it
- **AND** SHALL NOT treat script location or filename as a command declaration

#### Scenario: Invalid name is rejected
- **WHEN** CommandName is empty, longer than 64 ASCII characters, begins with an unsupported character or contains characters outside letters, digits, `_`, `-` and `.`
- **THEN** that class SHALL remain unregistered with a bounded diagnostic

#### Scenario: Duplicate names are deterministic
- **WHEN** two or more concrete command classes declare the same canonical CommandName
- **THEN** every conflicting declaration SHALL remain unregistered for that pass
- **AND** class iteration order SHALL NOT select a winner

### Requirement: Commands integrate with Unreal keyboard shortcut preferences
Every registered command SHALL create a dynamic `FUICommandInfo`, map into the Level Editor global command list and participate in Unreal Editor Keyboard Shortcuts through a reflected default chord.

#### Scenario: Valid default chord is declared
- **WHEN** a registered command declares a valid non-empty default key and modifiers
- **THEN** that chord SHALL be supplied as the command's default binding
- **AND** Unreal's normal user override shall remain authoritative after registration

#### Scenario: Chord is invalid or conflicts
- **WHEN** a declared default chord cannot be represented or conflicts with an already authoritative binding
- **THEN** the command SHALL remain registered and executable without that default chord
- **AND** the registry SHALL emit one bounded warning for the registration pass

#### Scenario: No chord is declared
- **WHEN** a valid command declares no default key
- **THEN** it SHALL appear unbound in the AngelScript Tools keyboard-shortcut context
- **AND** the user SHALL be able to assign a normal Editor shortcut

### Requirement: Command execution receives a fresh explicit context
Executing a mapped command SHALL create one temporary command instance, capture a new `UAngelscriptEditorToolContext` owned by that instance and invoke the command synchronously under the Editor script execution guard.

#### Scenario: Command executes successfully
- **WHEN** a registered command is invoked and its play-state/can-execute conditions permit execution
- **THEN** exactly one transient command instance SHALL receive exactly one Execute callback with a freshly captured context
- **AND** the instance SHALL become eligible for normal GC after the callback returns

#### Scenario: Repeated command executions
- **WHEN** the same command is invoked twice
- **THEN** the invocations SHALL use distinct command objects and distinct point-in-time context snapshots
- **AND** command-object field mutation from the first invocation SHALL NOT implicitly persist into the second

#### Scenario: Context capture is unavailable
- **WHEN** command dispatch cannot capture the requested Editor context
- **THEN** the Execute callback SHALL NOT run
- **AND** the command SHALL report a bounded unavailable diagnostic without retaining a partial instance

### Requirement: Command availability is explicit and side-effect bounded
The registry SHALL evaluate `ShouldRegister()` only during registration and SHALL evaluate `CanExecute()` on the class default object without constructing an execution context or transient execution instance.

#### Scenario: Registration predicate declines
- **WHEN** `ShouldRegister()` returns false
- **THEN** no command info or command-list mapping SHALL be created for that class during the pass

#### Scenario: Can-execute declines
- **WHEN** `CanExecute()` returns false
- **THEN** the mapped command SHALL not execute or capture selection

#### Scenario: Play session is disallowed
- **WHEN** PIE or SIE is active and the command does not opt into play-session execution
- **THEN** the command SHALL be disabled before constructing an execution instance

### Requirement: Command registration reconciles with reload and shutdown
The command registry SHALL unmap stale actions and rebuild valid declarations after Full Reload, and SHALL tear down all owned mappings idempotently during module shutdown or engine pre-exit.

#### Scenario: Command implementation reloads compatibly
- **WHEN** Full Reload retains the same valid CommandName on a compatible replacement class
- **THEN** the command identity and user shortcut preference SHALL remain stable
- **AND** subsequent execution SHALL instantiate the replacement class

#### Scenario: Command is removed or renamed
- **WHEN** a reload removes the concrete class or changes its CommandName
- **THEN** the old action SHALL be unmapped and unregistered
- **AND** no delegate SHALL invoke the obsolete class

#### Scenario: Editor module shuts down
- **WHEN** the Editor module shuts down or engine pre-exit occurs
- **THEN** command-list mappings, command infos and lifecycle delegates owned by this feature SHALL be removed exactly once

### Requirement: Command extensions remain Editor-only host declarations
Command discovery and dispatch SHALL be inert without an initialized Editor, Slate and Level Editor command list and SHALL NOT create Runtime APIs, commandlet behavior or persistent tool records.

#### Scenario: Headless commandlet initializes the plugin
- **WHEN** the Editor module loads in a commandlet without a usable Slate/Level Editor command surface
- **THEN** no script commands SHALL be registered or executed

#### Scenario: Command callback runs a user tool
- **WHEN** a project command chooses to call a user-owned subsystem or runner
- **THEN** that state and execution SHALL remain owned by the project callback
- **AND** the command host SHALL NOT retain the runner, discover tool classes or record tool history itself
