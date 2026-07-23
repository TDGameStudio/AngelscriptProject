## 1. Record and regression contract

- [x] 1.1 Record the source provenance, showcase requirements, configuration defaults, the separated syntax-directory boundary, and no-publish constraint in the OpenSpec artifacts. <!-- Non-TDD -->
- [x] 1.2 Add failing source-manifest and runtime showcase regression tests for the desired plugin and tiddler behavior. <!-- TDD -->

## 2. Source-managed Markdown More integration

- [x] 2.1 Import the current upstream `main` snapshot into `Wiki/vendor/tw-markdown-more` with its MIT license and register the plugin in `external-plugins.json`. <!-- TDD -->
- [x] 2.2 Apply the local Markdown More configuration overrides, ensure the imported source is Git-trackable, and update source-boundary maintenance documentation. <!-- TDD -->

## 3. Rendered showcase content

- [x] 3.1 Add the rendered-only official Markdown and Markdown More showcase tiddlers with direct-route discoverability and no homepage link. <!-- TDD -->
- [x] 3.2 Add the rendered WikiText showcase and its nonpersistent interaction/transclusion fixture. <!-- TDD -->
- [x] 3.3 Add the searchable `语法展示范式` directory tiddler, keeping Markdown and WikiText bodies separated. <!-- TDD -->

## 4. Validation and handoff

- [x] 4.1 Run source, type, lint, and Playwright verification without invoking package-build or publish commands. <!-- TDD -->
- [x] 4.2 Inspect the final diff, update OpenSpec task status and verification evidence, and hand off the Wiki-only change. <!-- Non-TDD -->

## 5. Follow-up interaction defaults

- [x] 5.1 Disable accidental core external-file drag-and-drop imports with a local configuration default and browser regression coverage. <!-- TDD -->
