## Context

`feature-as-stateful-tool-execution` deliberately stops at reusable APIs: a caller-owned runner, stable Editor memory-source compilation, exact active-class resolution and bounded Tool History. `feature-as-editor-tool-host-extensions` adds explicit Editor context capture plus command/tab registration, but it does not decide how temporary source should be edited.

The current `FAngelscriptSnippetRunnerWindow` is a modal-like standalone window around isolated `/Angelscript/Memory/Immediate/` snippets. It has no stable class session, compile-only operation, source recovery or dock-tab lifecycle. Expanding that surface would conflate one-shot snippets with stateful tools and break the established Immediate-module contract.

This change adds one official Editor workspace as a consumer of the two preceding changes. It does not make the plugin responsible for project tool discovery or ownership.

## Goals / Non-Goals

**Goals:**

- Provide one dockable place to iterate on a bounded temporary full-source `UAngelscriptTool` subclass.
- Keep compile-only, run-active, compile-and-run and session reset explicit and independently reported.
- Make failed attempted source and last-known-good active source visually distinct.
- Recover unsubmitted drafts and retained source revisions without executing either.
- Let the user export useful source to any chosen `.as` destination and then manage it normally.
- Keep workspace state, Tool History state and runner UObject state separate.

**Non-Goals:**

- A project tool catalogue, fixed tool pack, directory scan, categories, favourites, publishing workflow or Content Browser asset type.
- Replacing an external IDE, language server or debugger; v1 has no syntax completion, semantic hover, breakpoints or multi-file project editor.
- Async/latent tool execution, Stop, cancellation, polling, progress protocol, background thread execution or log-stream capture.
- Persisting invocation arguments, returned payloads, editor context, selected objects or runner/tool UObject fields.
- Browsing persisted compile-attempt/run-summary streams not exposed by the underlying public Tool History API.
- Any Runtime dependency on Slate, UnrealEd, workspace drafts or Editor settings.

## Decisions

### 1. The workspace is a singleton UI surface, not a singleton execution framework

Register one nomad tab `Angelscript.ToolWorkspace` through the Editor tool-host registry and expose it under the Window/AngelScript Tools group plus the existing Tools menu. Unreal layout persistence may reopen the tab, but only one workspace tab exists per Editor process.

Add `UAngelscriptToolWorkspaceSubsystem : UEditorSubsystem` as the native owner of:

- one `UAngelscriptToolRunner` created explicitly through the Runtime factory;
- the current bounded document collection and active document ID;
- open-tab/controller coordination and draft-save scheduling.

This is a deliberate host-specific lifetime choice. The underlying runner remains caller-owned and projects can still create any number of independent runners. Closing the tab does not reset workspace sessions; **Reset Session** or Editor shutdown does. Restarting the Editor creates a new runner and never restores tool UObject fields.

The Slate widget owns presentation only. `FAngelscriptToolWorkspaceController` performs validation, calls the reflected Editor tool APIs and produces an immutable view model so compile/run behavior is testable without opening a window.

Reusing `FAngelscriptSnippetRunnerWindow` was rejected because snippets are unique/discardable functions while workspace sources are stable class modules. Making the public runner global was rejected because only this UI needs one Editor-process owner.

### 2. A bounded document names the exact memory source and class

Each workspace document contains:

- a persistent workspace-only 32-lowercase-hex DocumentId;
- canonical SourceId and exact ToolClassName accepted by `CompileToolSource`;
- current SourceText, capped at the underlying 1 MiB UTF-8 limit;
- last submitted RevisionId and active RevisionId when known;
- dirty/submission state, latest structured compile/run result and last edit UTC time;
- a normalized SessionKey, defaulting to `Default`.

The workspace holds at most 20 drafts. **New Draft** creates a local DocumentId but never generates a timestamp/GUID SourceId; the user chooses a stable SourceId such as `Scratch/CurrentTool`. Duplicate open documents for the same canonical SourceId are rejected so two buffers cannot race one memory module identity.

The initial source template is a documentation-quality, user-editable `UAngelscriptTool` subclass using the chosen ToolClassName. It is inserted into the buffer only and is not a built-in runnable tool or checked-in product script.

V1 uses `SMultiLineEditableTextBox` with line/column navigation and monospaced styling. Syntax highlighting, language-server features and multi-file include editing are deferred; users export and move to their normal IDE when the tool becomes permanent.

### 3. Compile and execution operations preserve the lower-level truth

The controller exposes four commands:

1. **Compile** calls `CompileToolSource` with `SourceAndDiagnostics` and never creates or runs a session.
2. **Run Active** calls `RunCompiledTool` for the exact active module/class and current SessionKey without preprocessing.
3. **Compile & Run** calls `CompileAndRunSource` and runs only when the submitted source succeeds.
4. **Reset Session** resets the exact most-recent successful `FAngelscriptToolSessionId` for the current document/key; it does not forget history, unload a module or delete a draft.

At execution time, the workspace captures a fresh `UAngelscriptEditorToolContext` and sets it as `Invocation.ContextObject`. It does not persist the context. Arguments JSON is a current-session input field capped by the runner contract and is deliberately omitted from draft/history persistence.

After a failed compile, **Compile & Run** never dispatches the old code. If the result reports last-known-good, the UI exposes a separate, clearly labelled **Run Last Known Good** action that calls `RunCompiledTool`; it requires a deliberate click and retains the failed buffer for editing.

The toolbar is disabled while the synchronous operation is on the stack. There is no Stop button: synchronous v1 cannot safely cancel a VM call. A long-running tool blocks the Game Thread, and the UI states that constraint before execution.

Compile, runtime, Tool History and draft-store results remain separate in the view model. The workspace never converts a history/draft warning into compile failure and never scrapes Output Log text.

### 4. Optional run summaries remain an explicit privacy choice

Compile operations use the underlying default source-and-diagnostics history policy when Tool History is enabled. A per-project-user workspace setting **Record data-minimized run summaries** defaults to false. When enabled, Run Active and Compile & Run select `SourceDiagnosticsAndRunSummary`; otherwise run-only uses `None` and compile-and-run uses `SourceAndDiagnostics`.

The workspace shows the exact data-minimization statement from the underlying contract: run summaries omit ContextObject, ArgumentsJson, PayloadJson and tool fields. It does not add another execution log.

### 5. Draft recovery is separate, bounded and inert

Add an internal `FAngelscriptToolWorkspaceDraftStore` rooted at:

```text
Saved/Angelscript/ToolWorkspace/v1/
  index.json
  Drafts/<document-id>.json
```

Each record contains schema version, DocumentId, SourceId, ToolClassName, exact SourceText, SessionKey, last submitted/active RevisionId when known, dirty state and UTC edit/save times. It never contains ArgumentsJson, PayloadJson, editor context, selection, UObject path, compile diagnostics or runner state.

Limits are fixed in v1: 20 drafts, 1 MiB source per draft, 2 MiB per JSON record, 4 MiB index and 32 MiB total root. When admission exceeds the count/byte bound, the store evicts the least-recently-edited non-active draft; it never evicts the active document. If only protected data remains, autosave reports capacity warning and leaves execution unaffected.

The active dirty draft is autosaved after two seconds without text changes and synchronously on tab close/Editor shutdown. Records use same-directory temporary files and atomic replacement. Unsupported, malformed, oversized or identity-mismatched data is inert and reported in the recovery panel. Loading or restoring a draft updates a buffer only; it never compiles, runs or recreates a session.

Users can **Forget Draft** for one exact DocumentId. There is no reflected or UI clear-all action in v1. Removing a draft has no effect on Tool History or active memory modules.

Using Tool History for every keystroke was rejected because that store records explicitly submitted revisions and compile diagnostics. Drafts exist only for unsubmitted workspace recovery and have their own smaller lifecycle.

### 6. History browsing consumes only bounded public recovery APIs

The History panel uses:

- `ListRecentSources(100)`;
- `ListRevisions(SourceId, 50)`;
- `LoadRevision(SourceId, RevisionId)`;
- `LoadLastKnownGood(SourceId)`.

Selecting metadata has no side effect. **Load Into Buffer** either replaces the current buffer after a dirty-content confirmation or creates a new draft, then marks it unsubmitted. A loaded revision must pass through Compile or Compile & Run before it can become active.

The panel does not read `Saved/Angelscript/ToolHistory/v1` directly and does not expose private attempt/run files. Adding attempt/run list APIs would be a separate change to the Tool History public contract; this workspace stays a consumer.

### 7. Export transfers ownership without creating a plugin convention

**Export Current Buffer As...** and **Export Revision As...** use the platform save dialog with an `.as` filter. No `Script/Tools` directory is required or created. If a project `Script/` directory exists it can be the initial browse location, but the user selects the final destination and confirms overwrite through the platform dialog.

The exporter validates that the final filename ends in `.as`, writes UTF-8 without BOM to a same-directory temporary file and atomically replaces the confirmed destination. Export does not create a Tool History entry, delete a draft, reset a session or directly invoke compilation. If the selected destination belongs to an existing watched script root, normal directory-watcher Hot Reload may subsequently observe it.

Exporting directly into a plugin-managed tools folder was rejected because the user, not the plugin, owns permanent tool organization.

### 8. The UI presents one explicit state machine

Each document is in one of: `Draft`, `Compiling`, `CompileFailed`, `Ready`, `Running` or `RunFailed`. Synchronous operations still enter transient Compiling/Running states before dispatch so re-entrant UI commands fail as Busy.

The tab layout is intentionally small:

- header: document selector, SourceId, ToolClassName and SessionKey;
- action row: Compile, Run Active, Compile & Run, conditional Run Last Known Good, Reset Session and Export;
- main area: source editor;
- lower panes: Diagnostics, Result, Context summary and Recovery/History.

Diagnostics retain severity, virtual path, row and column and can move the editor caret. Result shows attempted revision, active revision/class, runtime status/message and independent history/draft warnings. Context summary shows only counts, truncation and captured world/PIE state; it does not persist or serialize object selections.

## Risks / Trade-offs

- **Risk: Synchronous tools can freeze the Editor.** → State the limitation in the workspace, provide no misleading Stop control, and defer cancellation until the runner has a real async protocol.
- **Risk: Basic source editing is weaker than VS Code.** → Keep the workspace optimized for scratch iteration and export; do not duplicate the project language server.
- **Risk: Draft autosave and Tool History look like one store.** → Give them different roots, schemas, UI labels and deletion actions; drafts hold unsubmitted text while Tool History holds submitted revisions.
- **Risk: Export may trigger ordinary directory-watcher reload.** → Do not invoke compilation directly; document that normal watched-root behavior applies after the user creates the file.
- **Risk: Restored source may no longer compile against current bindings.** → Recovery remains inert and displays its original identity; the user explicitly compiles to get current diagnostics.
- **Risk: Workspace dependency changes are implemented out of order.** → Treat both preceding OpenSpecs as implementation prerequisites and keep this change plan-only until their public types are available.
- **Risk: repository guidance and the current local checkout name different UE versions.** → Leave the existing 5.7 documentation baseline and current 5.8 project/config selection untouched, then validate the Editor API surface through the configured build when implementation begins.

## Migration Plan

1. Implement and verify `feature-as-stateful-tool-execution` and `feature-as-editor-tool-host-extensions` first.
2. Add the workspace subsystem/controller/draft store with headless tests before registering the visible tab.
3. Register the tab and Tools-menu entry only after controller tests pass; keep the existing Snippet window untouched.
4. Add Chinese documentation and a concise README section after behavior is verified.
5. Rollback unregisters the tab and removes the workspace code. Draft JSON can remain inert under its versioned Saved root or be removed manually by the user; Tool History and Runtime sessions are unaffected.

## Open Questions

None for v1. Async execution, attempt/run-history browsing, syntax highlighting, Editor Utility Widget hosting and a permanent tool browser are deliberately separate future scopes.
