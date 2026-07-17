## Why

The Hazelight VS Code extension 1.9.2 is a reusable Language Server and Debug Adapter for this project, but its `DebugDatabaseSettings` decoder still follows Hazelight's version 7 wire layout. The current plugin removed the Haze-specific semantic field and now emits a shorter version 6 payload, so the Language Server can read past the end of the message before it receives the Unreal type database.

## What Changes

- Restore a stable version 7 wire layout for `DebugDatabaseSettings` without restoring Haze runtime semantics.
- Preserve removed or unsupported settings as explicit compatibility slots with deterministic false values.
- Add a regression test that decodes the emitted payload using the Hazelight Language Server field order.
- Import the Hazelight VS Code extension source into `Extensions/AngelscriptVSCode/` as the project-owned extension that can evolve with this fork.
- Update the owned extension metadata and documentation to identify TDGameStudio as the maintained project version.
- Document the supported VS Code workflow and the remaining optional `StopPIE` limitation.

## Capabilities

### New Capabilities

- `vscode-lsp-protocol-compat`: Preserve the binary DebugServer contract required by Hazelight's VS Code Language Server and Debug Adapter.

### Modified Capabilities

None.

## Impact

- Runtime protocol DTO and DebugDatabase emission in `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/`.
- Existing Debugger database automation coverage in `Plugins/Angelscript/Source/AngelscriptTest/Debugger/`.
- User-facing VS Code integration documentation.
- No new external dependency and no reintroduction of `WITH_ANGELSCRIPT_HAZE`.
- The ignored `Reference/vscode-unreal-angelscript/` checkout remains an upstream reference and is not modified.
