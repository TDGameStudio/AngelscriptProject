## Why

The maintained Builder currently takes a caller-created source snapshot and diagnostics engine. Snapshot.AddFile copies input bytes; default stage observations can additionally materialize full token text. Its later definition-summary branch replaces rich per-file descriptors with one first-file-named module. This makes the host/SDK input contract and early host interaction difficult to test independently.

## What Changes

- Keep one common FAngelscriptSource with its host fields and one FUtf8String body, prepared by the host and retained through shared-const references.
- Replace the maintained snapshot/diagnostics constructor with Source references, options, and optional borrowed callback objects. SDK owns source indexing and diagnostic association, not file acquisition.
- Preserve explicit stage execution, make text/JSON observations opt-in, and retain source-coordinate/lifetime guarantees without a second body store.
- Publish complete deep-read-only per-module declaration descriptions once after resolution; associate later definitions by stable key.
- Define synchronous ordered hooks, failure short circuit, once-only final notification, and terminal-only result transfer.
- Adapt necessary host consumers and replacement tests without restoring dormant code.

## Capabilities

### New Capabilities

None. This change refines existing frontend contracts.

### Modified Capabilities

- `angelscript/language/frontend/builder`: shared-source entry, optional observations, per-module declaration publication, callbacks, and result transfer.
- `angelscript/language/frontend/source-diagnostics`: shared source-version ownership behind existing UTF-8 coordinates and retained result lifetimes.

## Impact

Implementation belongs to the Plugins/Angelscript submodule: AngelscriptRuntime SDK/frontend, the common unreal source boundary, minimal runtime/editor source consumers, and AngelscriptTest/NewVersion. Parent-repository changes are OpenSpec records and later synchronization of the two affected specifications. Source/AngelscriptProject remains unchanged.

The approved design and public vocabulary are exported under attachments/drafts/. The separate diagnostic tooling Change shares some Source/Builder files, but its catalog, full owned diagnostic API, tooling edits, and LSP work are not prerequisites or absorbed scope.

## Non-goals and authority

No VFS, mounts, filesystem discovery/loading in SDK, token streaming refactor, full UClass generation, hot-reload commit/rollback, standalone LSP restoration, or legacy activation. No broad relocation of all F-prefixed types. Creation and planning are authorized now; product edits, UE runs, spec synchronization, archive, and Git operations are not performed by this planning turn.
