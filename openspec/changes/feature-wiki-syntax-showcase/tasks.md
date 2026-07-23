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

## 6. Comprehensive rendered Markdown regression baseline

- [x] 6.1 Extend the design and showcase specification with the approved rendered-only comprehensive Markdown baseline, separate extension page, and no-source-panel constraint. <!-- Non-TDD -->
- [ ] 6.2 Add failing Playwright coverage for the comprehensive basic Markdown and isolated extension Markdown rendered surfaces. <!-- TDD -->
- [ ] 6.3 Replace the small Markdown basic sample with the comprehensive rendered baseline, add the rendered-only extension tiddler, and update the directory links without mixing syntax families. <!-- TDD -->
- [ ] 6.4 Run the Wiki source checks, lint, full Playwright suite, OpenSpec validation, and local preview inspection without running package or publish commands. <!-- TDD -->
- [ ] 6.5 Record verification evidence, inspect the scoped diff, and hand off the unarchived showcase iteration. <!-- Non-TDD -->
