## 1. Behavior contracts

- [x] 1.1 <!-- TDD --> Add an external-source regression test that rejects preview glass from the runtime manifest and generated plugin bridge.
- [x] 1.2 <!-- TDD --> Change the product plugin baseline to require preview-glass absence and hidden Vanilla sidebar search.
- [x] 1.3 <!-- TDD --> Add desktop command-palette geometry, theme token, focus, result-panel, and narrow-screen overflow coverage.

## 2. Search and plugin implementation

- [x] 2.1 <!-- TDD --> Remove preview glass from `external-plugins.json` while retaining its imported reference source.
- [x] 2.2 <!-- TDD --> Add the local command-palette preference that hides the duplicate Vanilla sidebar search.
- [x] 2.3 <!-- TDD --> Refine the imported command-palette source stylesheet for the desktop-first visual contract and remove obsolete local sidebar-search refinements.
- [x] 2.4 <!-- TDD --> Add incremental real-source mirroring to product dev commands so imported command-palette edits hot-reload through the generated bridge.

## 3. Documentation and generated sources

- [x] 3.1 <!-- TDD --> Register the AngelScript content type/parser and make the directly opened source fixture use shared highlighting.
- [x] 3.2 <!-- Non-TDD --> Update bilingual Wiki maintainer guidance for the selected runtime plugins, direct command-palette source ownership, hot reload, and direct AngelScript source tiddlers.
- [x] 3.3 <!-- Non-TDD --> Regenerate the disposable external plugin source bridge and confirm preview glass is absent.
- [x] 3.4 <!-- TDD --> Expand `AngelscriptCodeExamples` with grouped, real-project-derived fixtures covering the major AngelScript and Unreal dialect syntax families.

## 4. Verification

- [x] 4.1 <!-- Non-TDD --> Run OpenSpec validation, lint, type checking, external-source tests, plugin tests, build, and offline publish tests.
- [x] 4.2 <!-- Non-TDD --> Start the product Wiki, run the full Playwright suite, and visually inspect desktop and narrow-screen command palette screenshots.
- [x] 4.3 <!-- Non-TDD --> Verify an add/remove probe under a real source reaches and leaves the running Wiki without manually preparing or restarting it.
