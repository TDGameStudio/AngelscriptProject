# Verification Evidence

## Scope confirmation

- The local override exists only in the AngelscriptWiki configuration plugin and does not edit `node_modules` or a vendor plugin.
- The broad `$:/config/DragAndDrop/Enable = no` experiment was removed; the final behavior is confined to the outer normal-page `$dropzone`.
- The override retains `tc-page-container-inner`, the core navigator, the PageTemplate variable scope, and normal PageTemplate transclusion.
- The OpenSpec records external file and cross-Wiki payload import as intentionally unavailable on the normal page surface; explicit Import controls remain available.

## TDD evidence

- A browser expectation for the broad global configuration was added first and failed with `Expected: "no"; Received: ""`; it passed after the initial broad configuration was introduced.
- Once the user narrowed the requirement, the regression was rewritten to require that the global configuration be absent and that the page container not be a `tc-dropzone`. It failed while the broad configuration existed with `Expected: false; Received: true`.
- The page-template override then made the focused regression pass. The regression additionally verifies that a core Open-sidebar droppable target still prevents a cancelable `dragover` event.

## Final non-package verification commands (2026-07-23)

All commands were run from `Wiki/` and completed with exit code `0`:

```text
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:playwright        # 36/36 passed
PLAYWRIGHT_BASE_URL=http://127.0.0.1:8080 npm exec --yes pnpm@11.8.0 -- run test:playwright -- document-experience.spec.ts --grep "loads the selected document plugins"
```

The final focused command passed against the independently running local preview on port `8080`, rather than an ephemeral test server.

Before the repository's Wiki-first delivery constraint was explicitly restated, a one-off `npm run build` was run with the preview stopped and completed successfully. It produced a plugin-package artifact and is preserved only as historical evidence; it is not part of the normal verification contract for this Wiki project and must not be repeated without an explicit artifact request.

## Reference comparison

- `Experiment/RefWiki/wiki` has no local `$:/config/DragAndDrop/Enable`, `$:/config/Editor/EnableImportFilter`, or `$:/core/ui/PageTemplate` override.
- Its Kookma Utility reader-mode action toggles the same broad global switch; optional TiddlyFlex story templates use their own dropzones. Neither is a reusable narrow normal-page file-import setting.
- Official TiddlyWiki documentation defines the global setting as disabling all built-in drag-and-drop operations. Community guidance for preserving reorder behavior removes only the outer PageTemplate `$dropzone`, which is the approach recorded here.
