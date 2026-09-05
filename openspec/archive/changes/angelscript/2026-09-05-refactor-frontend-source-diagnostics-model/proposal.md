## Why

The reconstructed frontend cannot safely share the current mixture of raw character pointers, parser-owned offsets, Builder-derived line numbers, and direct Engine message emission. Every later lexer, preprocessor, AST, and Sema result needs one immutable source lifetime, unambiguous UTF-8 coordinates, recoverable provenance, and diagnostics that can be tested without a live `asCScriptEngine`.

Clang demonstrates the useful separation between compact locations, a source manager, and optional richer preprocessing records. Its opaque 31-bit location encoding and manager-local lifetime are implementation choices, not contracts to copy. AngelScript can keep the clearer `(FileID, UTF-8 byte offset)` model while making snapshot ownership and cross-snapshot validity explicit.

## What Changes

- Add a fork-internal `frontend` source model built around immutable UTF-8 snapshots and snapshot-local file identities.
- Use explicit half-open source ranges, stable logical source anchors, content revisions, and a queryable origin graph.
- Derive line and column lazily from the authoritative byte buffer rather than storing them in every token or node.
- Add one structured diagnostic engine and replaceable consumer contract for lexer, preprocessor, Parser, and Sema.
- Keep the new API isolated from current production routing until the later unified frontend cutover.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/source-diagnostics`: Immutable source ownership, UTF-8 coordinates, provenance, and structured frontend diagnostics.

### Modified Capabilities

None.

## Impact

Future implementation is confined to the `Plugins/Angelscript` submodule's new ThirdParty frontend source and `AngelscriptTest/NewVersion/NativeEngine` tests, followed by parent-repository spec synchronization. It may reuse or supersede concepts in the existing `as_source_location`, `as_source_manager`, `as_source_provenance`, and AST diagnostic files, but production Parser/Builder/Engine entry points remain unchanged in this Change. Standalone, VM, Builder publication, UE reflection materialization, and Harness are out of scope.
