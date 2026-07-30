# Verification Evidence

## Scope confirmation

- Markdown, Markdown More, and WikiText remain separate rendered tiddlers.
- `语法展示范式` is a directly searchable navigation tiddler only; it links to the three examples and does not transclude or tab-render their bodies together.
- Markdown More is sourced from the local `Wiki/vendor/tw-markdown-more/` snapshot at upstream `main` commit `d95cd86d0b9646703d07185c4ec94a516d6466f6`.
- `Wiki/.gitignore` explicitly permits the Markdown More vendor source to be tracked.
- No `publish`, `publish:offline`, or other release command was invoked.

## TDD evidence

- The syntax-directory browser test was added before `SyntaxShowcaseIndex.tid`; it failed because the title did not render, then passed after the tiddler was added.
- The Markdown image regression test initially failed because `data:image/svg+xml` is rejected by the official Markdown parser's data-URI whitelist. Replacing only the image payload with a local `data:image/png;base64,...` payload made the same rendered-image assertion pass.
- The Git-tracking source-boundary test was added before the `.gitignore` exception; it failed for the missing `!/vendor/tw-markdown-more/` rule, then passed after that rule was added.
- The TOC regression expectations were changed to require `toc/enable = no` and no `.md-container` or `.md-aside` output. They failed while the local configuration was `yes`, then passed after the enable configuration was changed to `no` and the local depth override was removed.

## Final commands (2026-07-23)

All commands were run from `Wiki/` and completed with exit code `0`:

```text
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:external-plugins  # 8/8 passed
npm exec --yes pnpm@11.8.0 -- run test:source-boundaries # 3/3 passed
npm exec --yes pnpm@11.8.0 -- run test:playwright        # 36/36 passed
```

The historical package-build command previously run for this change is intentionally omitted from the normal verification contract. AngelscriptWiki is a Wiki development project, not a plugin distribution project: future Wiki work uses the preview, type/lint/source checks, and Playwright; package-build and publish commands require an explicit artifact request.

## Follow-up: disable Markdown More TOC (2026-07-23)

- The active change remains open for later showcase and style iterations; it was not archived.
- The local `$:/config/markdown/toc/enable` override now resolves to `no`, and the local depth override was removed because it is no longer product policy.
- The focused document-experience and syntax-showcase browser suite passed `16/16` after the change.
- The full Playwright suite passed `36/36`; `check`, `lint`, external-plugin source tests (`8/8`), and source-boundary tests (`3/3`) also passed.
- This follow-up was committed as the Wiki-only temporary record `e3ad365 [Wiki] Fix: disable Markdown More TOC`; no parent-repository commit or OpenSpec archive was performed.

## Follow-up: disable accidental core drag-and-drop imports (2026-07-23)

- The active change remains open for later showcase and style iterations; it was not archived.
- TDD first: the browser expectation for `$:/config/DragAndDrop/Enable = no` was added before the configuration tiddler. The focused test failed with `Expected: "no"; Received: ""`, then passed after the broad global setting was added.
- The user clarified that only external-file import should be disabled. The regression was rewritten to require an absent global setting, no page-level `.tc-dropzone`, and a retained `.tc-page-container-inner`. It failed while the broad setting existed (`Expected: false; Received: true`).
- `src/angelscript-wiki-config/page-template-without-file-drop-import.tid` now mirrors the v5.4 core page template but replaces only its outer `$dropzone` with a plain layout container. This prevents the page-wide core importer while retaining normal core drag-to-reorder enablement. Intentional imports continue to use explicit controls.
- The regression also dispatches `dragover` to a normal core sidebar `droppable` target and verifies that it is still handled, covering the retained drag-to-reorder path.
- `Experiment/RefWiki/wiki` has no local `$:/config/DragAndDrop/Enable`, `$:/config/Editor/EnableImportFilter`, or `$:/core/ui/PageTemplate` override. Its Kookma Utility reader-mode action toggles the same broad global setting, while its optional TiddlyFlex layout has independent story-area dropzones; it does not provide a reusable single-file-import setting.
- The focused browser regression, `check`, and `lint` passed. The full Playwright suite then passed (`36/36`). No publish command, parent-repository commit, or OpenSpec archive was performed.

## Follow-up: comprehensive Markdown baseline and browser-source boundary (2026-07-23)

- The homepage and every existing `.tid` page retain their user-facing status. This follow-up moves only `*.spec.ts` browser-test source out of `wiki/tiddlers`; it does not hide, rename, tag, or archive a tiddler.
- Product browser source now lives in `tests/playwright/product/`; Modern.TiddlyDev fixture browser source now lives in `tests/playwright/examples/`. The source-boundary regression confirms no `*.spec.ts` remains below `wiki/tiddlers`, and the browser regression confirms `More → All` returns no non-system `*.spec.ts` titles.
- `Markdown 基础示例` is now a rendered-only visual baseline covering heading levels, emphasis, links/anchor, nested quotes and lists, task list, separator, fenced and indented code, tables/alignment, image, `details`, keys, and emoji. `Markdown 扩展语法示例` is linked from `语法展示范式` and separately covers footnotes, definition lists, insertions, marks, sub/superscripts, reference links/images, and inline-HTML `<abbr>` styling. The installed Markdown parser does not load `markdown-it-abbr`, so `*[HTML]: ...` is explicitly not represented as a supported parser contract.
- The initial full product run completed `39/40`; its only failure was the existing ordinary-core-codeblock copy-button test while a code element transiently intercepted a pointer event. The same test passed immediately when rerun in isolation. A second complete product run passed `40/40` in 31.0 seconds.
- The examples fixture suite uses the same fixed development port as the product preview and must not reuse a running product preview. After allowing its own `dev:examples` server to start, `test:examples` passed `2/2`; the product preview was restored and returned HTTP `200` at `http://127.0.0.1:8080/`.
- Final commands completed successfully without package-build or publish commands:

```text
npm exec --yes pnpm@11.8.0 -- run check
npm exec --yes pnpm@11.8.0 -- run lint
npm exec --yes pnpm@11.8.0 -- run test:external-plugins  # 8/8 passed
npm exec --yes pnpm@11.8.0 -- run test:source-boundaries # 4/4 passed
playwright test tests/playwright/product/syntax-showcase.spec.ts # 5/5 passed
playwright test tests/playwright/product/document-experience.spec.ts # 13/13 passed
playwright test # 40/40 passed
npm exec --yes pnpm@11.8.0 -- run test:examples # 2/2 passed
openspec validate feature-wiki-syntax-showcase --strict
```

- The active `feature-wiki-syntax-showcase` change intentionally remains unarchived for later style/showcase iterations. No publish command or remote operation was performed.
