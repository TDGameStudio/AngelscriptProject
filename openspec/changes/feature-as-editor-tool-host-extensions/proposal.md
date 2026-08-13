## Why

AngelScript users can already add editor menus and retain long-lived state in a user-owned `UScriptEditorSubsystem`, but fixed tools still lack first-class keyboard commands, dockable host surfaces and a stable way to capture the editor selection as one explicit invocation context. Those gaps force every project to write C++/Slate glue or read mutable editor globals during execution, even though tool ownership and lifecycle should remain with the user.

## What Changes

- Add an Editor-only transient context snapshot that captures the current editor world, selected actors, selected unloaded asset metadata and selected Content Browser folders without persisting or continuously observing them.
- Add a script-derivable command extension whose concrete classes register deterministic Unreal Editor commands, optional default chords and structured execute/can-execute callbacks.
- Add a script-derivable dock-tab extension whose concrete classes receive one retained transient instance per open tab and render reflected properties through a standard Details view plus explicit `CallInEditor` action buttons.
- Re-register command and tab declarations after AngelScript Full Reload while preserving compatible open-tab instances through reflected reference replacement where the existing class reinstancer supports it.
- Keep command execution objects stateless and make tab-instance state explicitly scoped to an open tab; projects use their own subsystem, settings object or `UAngelscriptToolRunner` when state must outlive that host instance.
- Do not add a tool directory, tool catalogue, automatic project-script scan, built-in user tools, arbitrary Slate widget bindings or Runtime-module behavior.

## Capabilities

### New Capabilities

- `as-editor-tool-context`: Explicit, bounded and non-persistent snapshots of the editor world and current Level Editor/Content Browser selection for tool invocation.
- `as-editor-command-extensions`: User-authored AngelScript command classes with deterministic registration, keyboard shortcut integration and reload-safe lifecycle.
- `as-editor-tab-extensions`: User-authored AngelScript dock-tab classes hosted through a standard reflected Details surface with explicit instance and reload semantics.

### Modified Capabilities

None.

## Impact

- Future implementation is confined to `Plugins/Angelscript/Source/AngelscriptEditor/EditorToolHost`, focused Editor automation tests and Chinese-first editor-extension documentation; `AngelscriptRuntime` gains no dependency or behavior.
- The command host composes with the existing Level Editor command list and Unreal command-binding preferences; the tab host composes with `FGlobalTabmanager`, `PropertyEditor` and the existing AngelScript Full Reload extension registry.
- Existing `UScriptEditorMenuExtension`, actor/asset menu extensions, Content Browser data source and `UScriptEditorSubsystem` remain compatible and continue to serve their current roles.
- `feature-as-stateful-tool-execution` is a recommended consumer-facing companion, not a source-level prerequisite for the context/command/tab primitives. No global runner or tool instance is created by this change.
