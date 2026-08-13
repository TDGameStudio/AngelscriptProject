## Context

The Editor module currently supports three useful but incomplete patterns:

- `UScriptEditorMenuExtension`, `UScriptActorMenuExtension` and `UScriptAssetMenuExtension` discover concrete script classes after the initial compile and re-register them after Full Reload. Their callback objects are intentionally temporary.
- `UScriptEditorSubsystem` gives a project-owned script object an Editor-process lifecycle for durable in-memory state.
- `UAngelscriptContentBrowserDataSource` and source navigation expose script files through existing Unreal Editor surfaces.

There is no dynamic `FUICommandInfo` registration for user script commands, no script-declarative dock-tab host, and no general context object that freezes the current Level Editor and Content Browser selection for one operation. A tool can query editor globals itself, but doing so halfway through execution makes selection/world behavior implicit and difficult to test.

This change is an Editor-only host layer. It can be implemented independently of `feature-as-stateful-tool-execution`; when that runner exists, users may retain it in their own subsystem or tab object and pass the captured context as `FAngelscriptToolInvocation::ContextObject`.

## Goals / Non-Goals

**Goals:**

- Give C++, AngelScript and Blueprint callers one explicit transient snapshot of the editor world and current selection.
- Let one concrete AngelScript class declare one keyboard-bindable Editor command.
- Let one concrete AngelScript class declare one dockable Editor tab backed by a standard reflected Details surface.
- Define deterministic registration IDs, duplicate handling, shutdown and Full Reload reconciliation.
- Make host-instance lifetime and state ownership visible rather than implying a plugin-wide singleton.
- Reuse the existing class-discovery and engine-extension lifecycle patterns.

**Non-Goals:**

- Arbitrary Slate/`SWidget` construction from AngelScript, Editor Utility Widget Blueprint hosting, custom Details customization or sub-editor-specific extenders.
- A managed tool catalogue, script-root scan, `Script/Tools` convention, categories, favourites or built-in project tools.
- Automatic runner creation, source compilation, history persistence, command audit, remote control, async jobs, Tick, progress or cancellation.
- A live selection observer or a persisted editor-context record.
- Runtime module changes or any command/tab behavior in commandlets, packaged builds or non-Slate processes.

## Decisions

### 1. Editor context is an explicit bounded snapshot

Add `EditorToolHost/AngelscriptEditorToolContext.h/.cpp` with a transient reflected `UAngelscriptEditorToolContext` and a stateless `UAngelscriptEditorToolContextLibrary`.

`CaptureCurrentEditorContext(UObject* Owner)` requires a valid non-unreachable Owner, creates the context with that Owner as Outer and snapshots:

- the current Editor world, if one exists;
- selected Level Editor actors as reflected object references;
- selected Content Browser assets as `FAssetData`, without forcing asset loads;
- selected Content Browser virtual folders as canonical `FName` values;
- whether PIE or Simulate In Editor was active at capture time.

Each collection is capped at 4096 entries in stable source order. The object exposes independent truncation flags and a capture timestamp. `GetWorld()` returns only the captured Editor world while it remains valid; it never guesses a PIE world later. Map changes, actor destruction or asset changes can invalidate individual references after capture, and callers must validate them.

The snapshot never refreshes itself, subscribes to selection delegates or writes to `Saved`. Commands receive a new snapshot at Execute time. Tabs receive one on open and can request another only through an explicit Refresh Context action.

Passing arrays directly to every command event was rejected because it cannot act as the runner's WorldContext object and makes future context fields signature-breaking. A live singleton context service was rejected because selection could change between validation and execution.

### 2. One concrete command class declares one stable Editor command

Add an abstract, script-derivable `UScriptEditorCommandExtension`. Its class defaults define:

- required stable `CommandName`;
- `DisplayName`, `Description` and optional `IconName`;
- a reflected `FAngelscriptEditorCommandChord` containing `FKey` plus Ctrl/Alt/Shift/Cmd flags;
- whether execution is allowed while PIE/SIE is active.

`CommandName` is 1-64 ASCII characters, begins with a letter or `_`, and contains only letters, digits, `_`, `-` and `.`. The full Unreal command identity is `AngelscriptEditorTools.<CommandName>` inside one binding context named `AngelscriptEditorTools`. Identity is not derived from class path, so refactoring a class does not silently lose a user's shortcut override. Two concrete classes with the same valid name are both rejected for that registration pass with a deterministic diagnostic; iteration order never decides a winner.

The base exposes `ShouldRegister() const`, `CanExecute() const` and `Execute(UAngelscriptEditorToolContext* Context)` as BlueprintNativeEvents. Registration-time and can-execute queries run on the class default object under `FEditorScriptExecutionGuard`; Execute creates one transient instance, captures a context owned by that instance and releases the instance after the synchronous callback. Command-object fields therefore do not persist between invocations. Durable state belongs in a user subsystem, settings object or explicitly retained runner.

The registry creates dynamic `FUICommandInfo` entries and maps them into the Level Editor global action list. Valid default chords participate in Unreal Editor Keyboard Shortcuts; user overrides remain owned by Unreal's input-binding configuration. An invalid or conflicting default chord does not disable the command: the command registers unbound and emits one bounded warning.

Extending every `CallInEditor` menu function into a command was rejected because function metadata lacks a stable user-owned identity and would unexpectedly change all existing menu extensions. A single command base keeps registration opt-in and testable.

### 3. One concrete tab class owns one open-tab-scoped instance

Add an abstract, script-derivable `UScriptEditorTabExtension`. Its class defaults define required stable `TabName`, display label, tooltip and optional icon. `TabName` uses the same validation shape as CommandName and maps to `AngelscriptEditorTools.<TabName>`.

Each valid concrete class registers one nomad tab spawner under an **AngelScript Tools** workspace group. Spawning creates a transient `UAngelscriptEditorTabSession` retained through a reflected property. The session owns:

- one instance of the concrete tab extension;
- the latest explicit `UAngelscriptEditorToolContext` snapshot;
- the canonical tab identity and lifecycle state.

The tab contains a small native header with **Refresh Context**, a standard `IDetailsView` bound to the extension instance, and a native action section built by scanning eligible zero-parameter `CallInEditor` functions. The Details view renders reflected editable properties; the action section invokes those functions under `FEditorScriptExecutionGuard`. This explicit action section is required because a generic `IDetailsView::SetObject` does not itself guarantee `CallInEditor` button injection for an arbitrary UObject. Script authors do not receive an `SWidget` pointer or arbitrary Slate-construction API.

The extension receives `BP_Initialize(Context)`, `BP_ContextRefreshed(Context)` and `BP_Deinitialize()` events. Initialize and Deinitialize occur at most once for each physical hosted instance. Closing the tab releases its session and instance after Deinitialize; reopening creates fresh state. A project that needs state across tab closure uses its own subsystem/settings/runner.

A retained tab object for the entire Editor process was rejected because that silently creates per-class singletons. Hosting arbitrary Editor Utility Widgets was deferred because it introduces UMG/Blutility asset ownership and a second UI-authoring contract unrelated to a code-first reflected tool surface.

### 4. One registry reconciles commands and tabs with AngelScript lifecycle

Add `FAngelscriptEditorToolHostRegistry` as an Editor-module-owned, non-reflected service. It discovers only concrete loaded subclasses of the two explicit extension bases after the initial AngelScript compile. This is declaration discovery, equivalent to existing menu-extension class discovery; it does not scan filesystem roots or identify ordinary `UAngelscriptTool` classes.

The registry owns one shared **AngelScript Tools** `FWorkspaceItem` and exposes that group only through a native Editor-module getter so later first-party tabs, including the Tool Workspace, can appear in the same Window hierarchy. Exposing the group does not register, enumerate or retain user tools.

The service attaches through `FAngelscriptEngineExtensionRegistry`, registers after initial compile, and reconciles on Full Reload:

- body-only reload leaves registered identities and live tab instances in place;
- a compatible replacement with the same stable TabName relies on the reflected session property for normal class reinstancing fix-up, then refreshes the Details view;
- a removed/incompatible class or changed TabName closes the affected live tab after best-effort Deinitialize and unregisters its spawner;
- commands are unmapped and rebuilt from the new concrete class set;
- module shutdown and engine pre-exit unmap commands, close owned tabs and unregister every spawner/delegate idempotently.

The registry keeps no runner and executes no user tool on discovery. Test-only dependency seams cover tab-manager, command-list, selection and diagnostics behavior without requiring visible windows.

### 5. Context capture and host events stay on the Game Thread

All public capture, registration, spawn, refresh and execution paths require the Game Thread and a valid initialized Editor/Slate environment. Context capture returns a structured unavailable result when `GEditor` or the Content Browser is absent; command/tab registration is inert in commandlets. User callback exceptions continue through the existing AngelScript exception reporting path and do not leave a mapped action, rooted instance or open session behind during teardown.

No transaction is started automatically. A user tool that mutates editor state chooses its own `FScopedTransaction` through existing editor APIs, matching the principle that the host provides invocation rather than policy.

## Risks / Trade-offs

- **Risk: A Details view is less flexible than arbitrary Slate.** → Keep v1 intentionally code-first and reflected; a later, separate OpenSpec can add an explicit UMG/Editor Utility Widget adapter without destabilizing command/context contracts.
- **Risk: Script `CanExecute` can be queried frequently by Slate.** → Do not capture selection or construct an execution instance for `CanExecute`; run only the CDO callback under the existing editor-script guard and document that it must remain fast and side-effect free.
- **Risk: A snapshot can contain stale actors or world references.** → Mark the context transient, expose capture time/truncation, return the captured world only while valid and require tools to validate members.
- **Risk: Hot Reload may not be able to migrate an incompatible tab instance.** → Preserve only existing compatible reinstancing guarantees; close the affected tab deterministically when identity/class compatibility is lost.
- **Risk: Dynamic shortcut IDs can collide or lose overrides.** → Require explicit stable names, reject every duplicate instead of picking one, and avoid class-path-derived IDs.
- **Risk: Command registration may be unavailable in headless Editor tests.** → Isolate registry logic behind test seams and cover one real Level Editor integration smoke path separately.
- **Risk: repository guidance and the current local checkout name different UE versions.** → Treat the existing 5.7 documentation baseline versus current 5.8 project/config selection as external workspace state, avoid editing either for this change and prove final API compatibility through the configured build entry point.

## Migration Plan

1. Land context and registry primitives with all extension classes opt-in; existing menu/subsystem behavior remains unchanged.
2. Register the new host service from `FAngelscriptEditorModule` after existing Editor initialization and unregister it before ToolMenus/module shutdown.
3. Document command/tab examples after the Chinese editor-extension guide has been updated.
4. Rollback removes only the new registry/types and module wiring; no persistent user data or Runtime API needs migration.

## Open Questions

None for v1. UMG hosting, arbitrary custom Slate, sub-editor command lists and persistent tab-instance state are deliberately deferred rather than left ambiguous.
