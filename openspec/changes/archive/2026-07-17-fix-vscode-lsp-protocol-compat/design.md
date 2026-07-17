## Context

Hazelight's `vscode-unreal-angelscript` repository provides the editor-facing LSP and Debug Adapter. Its Language Server connects to the Unreal DebugServer on `127.0.0.1:27099`, requests the debug database, and decodes `DebugDatabaseSettings` using a versioned sequence of boolean fields. The current plugin intentionally removed Haze-specific behavior, but the removal also removed a slot from the binary message instead of preserving the established wire layout.

The runtime must remain Haze-free while retaining interoperability with the existing Hazelight client. The change is limited to the settings message; the message enum, envelope framing, JSON debug database, and debugger handshake already match the client.

The upstream checkout under `Reference/` is ignored by the parent repository and is kept as a read-only comparison source. The maintained extension will live under `Extensions/AngelscriptVSCode/` so its LSP, Debug Adapter, grammar, and build configuration can be changed and reviewed together with this project.

## Goals / Non-Goals

**Goals:**

- Emit the established version 7 settings payload expected by Hazelight VS Code 1.9.2.
- Keep unsupported legacy settings represented only as compatibility slots, with no Haze code path or behavior.
- Prove the payload can be consumed in the same field order as the TypeScript client.
- Keep a project-owned VS Code extension source tree that can be built into a VSIX without depending on the ignored reference checkout.
- Document how to open the `Script` workspace and connect the extension.

**Non-Goals:**

- Do not restore `WITH_ANGELSCRIPT_HAZE` or any Haze-only runtime behavior.
- Do not implement `StopPIE`; Hazelight's extension exposes it, but the reference plugin source has no matching engine-side implementation.
- Do not rewrite or vendor the Hazelight Language Server into the Unreal plugin.
- Do not modify `Reference/vscode-unreal-angelscript/`; it remains the upstream comparison source.

## Decisions

### 1. Preserve the wire layout with reserved slots

`FAngelscriptDebugDatabaseSettings` will serialize version `7` and keep the same field order consumed by the Hazelight Language Server. The removed Haze slot and unsupported Hazelight-only settings will be represented by reserved boolean members initialized to `false`. Their names will not reintroduce the removed `bUseAngelscriptHaze` member or compile-time macro.

The alternative of lowering the version to `2` avoids the decoder over-read but silently drops static-class deprecation information and leaves unused bytes in the message. The alternative of changing the upstream reference client would require distributing a project-specific extension before the standard Marketplace extension works. Preserving the existing layout keeps the current Hazelight client usable without a client fork.

### 2. Test the external field order explicitly

The existing C++ round-trip test only proves that the plugin can deserialize its own DTO. A test-only decoder DTO will read the full Hazelight field sequence and assert that the serialized payload has no read error and reports version `7`. This catches missing compatibility slots while remaining independent of Node.js installation or network access.

### 3. Keep StopPIE documented as a limitation

The Debug Adapter's extra `StopPIE` message is outside the minimum LSP compatibility path and has no corresponding implementation in the reference Unreal plugin. It will not be added speculatively. The user guide will state that ordinary editing, diagnostics, completion, navigation, and debugging are supported while the Stop PIE command remains unavailable.

### 4. Maintain an in-repository extension copy

The extension source will be copied into `Extensions/AngelscriptVSCode/` without its nested Git metadata. Its package publisher and repository metadata will identify the TDGameStudio-maintained variant, while the internal LSP and Debug Adapter behavior stays aligned with the known Hazelight 1.9.2 baseline until project-specific changes are intentionally made.

Keeping a source copy is preferred over a submodule because the stated goal is to modify the extension together with this repository, and the parent repository already ignores the reference checkout.

## Risks / Trade-offs

- [Protocol drift] Future Hazelight fields may be added → keep the field-order decoder test adjacent to the runtime DTO and update both deliberately.
- [Reserved fields are easy to misinterpret] A future maintainer may treat them as active settings → use `Reserved` naming and assert their false values in the protocol test.
- [No live editor in CI] A full VS Code-to-Unreal connection may not be available on every machine → validate the binary contract in automation and perform live connection testing when an editor is running.
- [Copied extension diverges from upstream] Future Hazelight updates will not be automatic → record the source baseline and use the ignored reference checkout for explicit update comparisons.

## Migration Plan

1. Add the failing external-layout regression test.
2. Add reserved wire slots and emit version 7.
3. Run the focused Debugger database test and the project build gate.
4. Build the project-owned extension from `Extensions/AngelscriptVSCode/` and install its generated VSIX.
5. Use the extension with the project `Script` folder as the workspace root.

Rollback is limited to reverting the DTO and test changes; no persisted data or public asset format is changed.

## Open Questions

None for this compatibility fix. A separate change can implement a project-specific Stop PIE command if the editor integration requirements are defined.
