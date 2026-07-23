## Context

TiddlyWiki's default `$:/core/ui/PageTemplate` wraps the complete normal page in a `$dropzone`. That widget accepts external files and other cross-window payloads, then sends `tm-import-tiddlers` to the core navigator, which opens the `$:/Import` workflow. During document reading and visual review this is an unwanted global interaction. Modern.TiddlyDev is used only as the local development harness: AngelscriptWiki is the product, so normal verification must not produce plugin-package artifacts.

The official `$:/config/DragAndDrop/Enable = no` switch is intentionally broader: it disables the core drag-and-drop mechanisms used by sidebar and tag/list ordering as well as the page importer. The local RefWiki reference contains no narrower core configuration; its reader-mode action uses the same broad switch.

## Goals / Non-Goals

**Goals:**

- Prevent the normal page surface from launching the core `$:/Import` workflow when an external file is dropped.
- Preserve the existing page container class, navigator, PageTemplate transclusions, and core internal drag-to-reorder behavior.
- Keep the implementation source-owned, visible in the local configuration plugin, and covered by a browser regression.
- Keep ordinary verification limited to the local preview, static checks, and browser regression rather than `build`/publish artifact commands.

**Non-Goals:**

- Do not remove explicit Import controls or editor-specific image/file insertion.
- Do not change custom plugin dropzones, including any future diagram or attachment surface.
- Do not add a new TiddlyWiki core widget, modify vendor source, or globally turn off drag-and-drop.
- Do not guarantee external cross-Wiki tiddler drag-in: it uses the same removed page-level importer as external file drops.

## Decisions

### Replace the outer page dropzone, not the global drag-and-drop setting

`page-template-without-file-drop-import.tid` shadows `$:/core/ui/PageTemplate` and replaces only the outer `$dropzone` with `<div class="tc-page-container-inner">`. The default `tv-enable-drag-and-drop` variable remains defined and `$:/config/DragAndDrop/Enable` remains unset, so downstream core `droppable` and draggable widgets retain their default enablement.

The alternative global configuration was rejected because it disables ordinary sidebar/tag/list ordering. CSS-only hiding was rejected because it cannot remove event handlers or prevent `tm-import-tiddlers`. `$:/config/Editor/EnableImportFilter` was rejected because it controls editor-specific file insertion rather than the normal page importer.

### Preserve the layout container class exactly

The plain replacement keeps `tc-page-container-inner`, which is the class emitted by the original outer dropzone and is used by the local theme. This limits the visual-layout effect to removal of drag-import event handling.

### Regression-test both sides of the boundary

The browser test asserts that the global setting is absent, the page container is not a `tc-dropzone`, and the page container remains singular. It also dispatches `dragover` to a core Open-sidebar `droppable` target and verifies that the event is still handled.

## Risks / Trade-offs

- [TiddlyWiki core PageTemplate changes in a later upgrade] → Keep the local override short and structurally aligned with the v5.4 template; compare it with upstream on every core upgrade.
- [Cross-Wiki tiddler drag-in no longer imports] → This is an intentional consequence of disabling the common page-level importer; use explicit Import controls for intentional external imports.
- [A custom plugin depends on the normal page dropzone] → Do not modify plugin-local dropzones; add an explicit plugin dropzone only if a future capability requires it.
- [Browser-specific default behavior for dropped local files] → The contract is limited to preventing the TiddlyWiki `$:/Import` workflow. Verify the target browsers during visual QA if file-drop navigation behavior itself becomes a concern.
