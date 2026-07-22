## 1. Provenance and source bridge

- [x] 1.1 Record the reviewed external sources in root documentation and the reference pull helper.
- [x] 1.2 Import the selected repositories into `Wiki/src/` from SSH at their reviewed baselines, then track their ordinary source files in the Wiki repository.
- [x] 1.3 Add the external-plugin manifest and test-first generated source bridge, then wire standard product commands to it.
- [x] 1.4 Move the Fira Code resource into the local Angelscript theme and remove the itonnote-theme runtime source dependency.

## 2. Document experience migration

- [x] 2.1 Rebase the project-local Angelscript theme on itonnote source and replace configuration defaults with fixed Notion light and retained legacy document preferences.
- [x] 2.2 Enable official TiddlyWiki Highlight for generic code blocks and port the selected mobile navigation/bottom-control behavior into TDGameStudio plugins.
- [x] 2.3 Restyle `as-code` semantic tokens to align with Highlight.js while preserving its current widget API and behavior.
- [x] 2.4 Enable bundled TiddlyWiki Markdown and consolidate reviewed Markdown More preference values without enabling the unselected extension.

## 3. Verification and documentation

- [x] 3.1 Add and update Node and Playwright regression coverage for the source bridge, defaults, mobile behavior, generic highlighting, and AngelScript code styles.
- [x] 3.2 Update Wiki and root documentation for the document baseline, imported-source provenance, and extension boundaries.
- [x] 3.3 Run formatting/lint/build/test/offline publish/Playwright verification and record the outcomes.
