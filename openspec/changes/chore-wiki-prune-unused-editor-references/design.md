## Context

The integrated Wiki product is assembled only from `product-sources.json`, but its tracked `vendor/` tree also retains the inactive CodeMirror 6, preview-glass, and sidebar-resizer source snapshots. The first two add approximately 1.48 MiB of tracked files; the resizer adds 8.6 KiB and is superseded by `angelscript-tools`. Separately, `src/doc` retains a 466 KiB Modern.TiddlyDev tutorial bundle that is declared only as a reference source and cannot reach the offline artifact.

## Goals / Non-Goals

**Goals:**

- Remove the inactive Wiki-local editor reference snapshots and prevent their accidental return.
- Remove the superseded vendor sidebar-resizer and the unshipped Modern.TiddlyDev reference-documentation bundle.
- Keep the selected product plugins, offline artifact behavior, and parent `Reference/` research checkouts intact.
- Make the vendor allowlist, lint scope, theme CSS, and maintenance documentation describe the actual Wiki product boundary.

**Non-Goals:**

- Removing or changing Command Palette, Autocomplete, Draw.io, Markdown More, Highlight, Fira Code, or the offline artifact byte budget.
- Deleting `Reference/tiddlywiki-codemirror-6`, `Reference/tiddlywiki-plugins`, or the unimplemented Notion cover/icon proposal.
- Redesigning the editor or adding a replacement editor integration.

## Decisions

1. **Remove only the Wiki-local duplicate references.** The parent `Reference/` checkouts remain the recovery and research source, so the Wiki submodule no longer carries unshipped copies.
2. **Guard retirement with the existing source-boundary suite.** The suite will assert that both retired vendor directories and their CodeMirror-specific theme selectors are absent; this makes the intended product boundary executable rather than documentation-only.
3. **Keep the product manifest unchanged.** It already excludes both integrations, so adding a tombstone entry would create a second source-of-truth instead of relying on the product allowlist.
4. **Keep existing offline and browser negative assertions.** They already prove both plugin titles are absent from the emitted product; the cleanup adds repository-boundary coverage without duplicating product tests.
5. **Retire superseded sources instead of relocating them.** The product-owned left-sidebar resizer remains the sole sidebar-resizing implementation. The unshipped Modern.TiddlyDev tutorials are recoverable from Git history and are not moved into the parent `Reference/` tree because relocation would preserve the same storage and maintenance burden.

## Risks / Trade-offs

- **A maintainer later wants either editor integration** -> Recover the audited upstream source from the retained parent `Reference/` checkout and introduce it through a separately reviewed product-manifest change.
- **A stale lint or ignore path is missed** -> Source-boundary, vendor lint, and full Wiki verification run after removal.
- **Theme cleanup unexpectedly affects an active editor** -> Only `.CodeMirror` and `.cm-code-block-line` selectors with no active product producer are removed; the Highlight and AngelScript grammar paths remain covered by offline and browser tests.
- **A Wiki maintainer needs the historical Modern.TiddlyDev tutorials** -> Recover them from Git history or the upstream Modern.TiddlyDev project; they were not part of the product runtime or offline artifact.

## Migration Plan

1. Add failing source-boundary and product-manifest assertions for the retired directories, selectors, and reference documentation bundle.
2. Delete the retired vendor trees and reference documentation bundle, then align the source inventory, TypeScript includes, allowlist, lint command, theme CSS, README, and maintenance guides.
3. Run focused boundary, artifact, browser, and complete Wiki verification.
4. Commit the Wiki submodule first, then commit this OpenSpec record and the parent gitlink update.
