## Why

The planned stateful tool runner and Tool History APIs provide reusable execution and recovery primitives but intentionally provide no product UI. Users also need one official Editor surface where they can write a temporary full-source tool, compile it without running, execute a retained session, inspect diagnostics, recover an earlier source revision and export useful work into a user-owned `.as` file.

## What Changes

- Add one official dockable **AngelScript Tool Workspace** tab in the Editor, registered through the Editor tool-host infrastructure.
- Provide a bounded scratch-document model with explicit SourceId and ToolClassName, source editing, Compile, Run, Compile & Run and Reset Session operations.
- Capture a fresh `UAngelscriptEditorToolContext` only when the user executes and pass it explicitly to the workspace-owned caller-scoped runner.
- Show attempted-versus-active compile state, scoped diagnostics, last-known-good availability, runtime status and independent Tool History warnings without scraping the Output Log.
- Browse recent sources and retained source revisions through the data-only Tool History APIs; loading a revision updates the editor buffer but never compiles, runs or restores UObject state.
- Autosave bounded unsubmitted drafts beneath `Saved/Angelscript/ToolWorkspace/v1/` and restore them inertly after restart.
- Export the current buffer or an exact loaded revision through `Export As...`; the user chooses the destination and owns the resulting `.as` file.
- Do not add tool discovery, a managed tool library, categories/favourites, a built-in script pack, remote execution, asynchronous execution, cancellation, log capture or a Runtime dependency on Editor UI.

## Capabilities

### New Capabilities

- `as-editor-tool-workspace`: Dockable temporary-tool editing, explicit compilation/execution/reset, context capture and structured result presentation.
- `as-editor-tool-workspace-recovery`: Bounded inert draft recovery, Tool History revision browsing and user-directed `.as` source export.

### Modified Capabilities

None.

## Impact

- Future implementation affects `Plugins/Angelscript/Source/AngelscriptEditor/ToolWorkspace`, the Editor module startup/menu wiring, focused Editor tests and Chinese-first documentation.
- The change consumes the public contracts planned by `feature-as-stateful-tool-execution` and `feature-as-editor-tool-host-extensions`; it does not modify their Runtime execution, history storage or host-extension requirements.
- Drafts add a separate bounded Editor-local store under `Saved/Angelscript/ToolWorkspace/v1/`; compiled revisions, attempts and optional run summaries remain owned by `Saved/Angelscript/ToolHistory/v1/`.
- The workspace owns one runner for its own Editor-subsystem lifetime. That host choice does not make `UAngelscriptToolRunner` a plugin-wide singleton and does not retain or discover user tools outside the workspace.
