## Why

The Wiki repository retains CodeMirror 6, preview-glass, and a sidebar-resizer vendor snapshot even though none is declared by the product manifest or serialized into the offline Wiki. It also retains an unshipped Modern.TiddlyDev reference-documentation bundle beneath `src/doc`. Keeping these inactive sources increases the tracked repository size and expands lint, documentation, and maintenance boundaries without providing a product capability.

## What Changes

- Remove the unused `Wiki/vendor/tiddlywiki-codemirror-6` and `Wiki/vendor/tiddlywiki-plugins` source snapshots.
- Remove the inactive `Wiki/vendor/tiddlyseq/src/sidebar-resizer` snapshot, retaining the product-owned left-sidebar resizer.
- Remove the unshipped `Wiki/src/doc` Modern.TiddlyDev tutorial bundle and its reference-only product-manifest entry.
- Remove their vendor allowlist and lint inputs, and add source-boundary regression coverage that prevents either retired directory from returning.
- Remove obsolete CodeMirror and vendor-resizer theme remnants, update the Chinese and English Wiki maintenance guidance, and remove README image references owned by the retired tutorial bundle.
- Preserve the parent repository's `Reference/tiddlywiki-codemirror-6` and `Reference/tiddlywiki-plugins` upstream research checkouts.
- Preserve the selected product plugin set, offline artifact budget, and reader-facing Wiki behavior.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `wiki-document-experience-integration`: The Wiki source boundary will exclude inactive editor integration snapshots while retaining the selected runtime plugin sources and their product behavior.

## Impact

- Affects the `Wiki` submodule's vendor tree, reference-only source inventory, lint command, source-boundary tests, theme CSS, README assets, and bilingual maintenance guidance.
- Does not change public APIs, installed product plugins, content tiddlers, offline export behavior, or package dependencies.
- Requires a Wiki submodule commit first, followed by this parent OpenSpec record and its updated Wiki gitlink.
