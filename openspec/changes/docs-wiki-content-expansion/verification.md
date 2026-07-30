## Implemented scope

- Primary documentation navigation is exactly two visible levels in both `AS/Docs` and `AS/Navigation`: seven reader groups to concrete Chinese formal tiddlers.
- All current Chinese formal documents participate exactly once in the primary path.
- The original fifteen-topic and L0–L5 model remains available as the secondary knowledge-system view.
- The document set now contains 90 formal Chinese records:
  - reviewed: 4
  - published: 0
  - draft: 47
  - placeholder: 39
  - completed (`reviewed + published`): 4
- The fifth reader group is `C++ 使用与绑定`, with direct practical pages for automatic bindings, exposure metadata, C++ `ScriptMixin`, manual `Bind_*.cpp`, call paths/limits, and diagnostics, followed by the preserved UHT and calling-convention pages.
- `content-migration.json` accounts for all 73 current host Chinese knowledge articles.
- The explicit offline generator materializes 17 `Syntax_*` and 12 `AS_*` sources as 29 source-hashed draft tiddlers.
- `hazelight-public-doc-crosswalk.json` maps all 15 public Hazelight Script Features to existing local logical documents without copying upstream prose or media.

## Verification evidence

Run from `Wiki/` unless stated otherwise.

| Check | Result |
| --- | --- |
| `node --test scripts/document-content-contract.test.mjs scripts/document-resolution.test.mjs scripts/knowledge-content-migration.test.mjs` | 47/47 pass |
| `node --test scripts/multilingual-compatibility.test.mjs` | 3/3 pass |
| `node node_modules/typescript/bin/tsc --noEmit --skipLibCheck` | pass |
| ESLint `--quiet` on the changed document/migration/browser files | pass |
| `node scripts/run-product-tests.mjs feature document` | 21/21 pass |
| `node scripts/run-product-tests.mjs feature sidebar` | 33/33 pass |
| `node scripts/run-wiki-runtime-tests.mjs` | 1/1 pass |
| `node scripts/build-offline-wiki.mjs` | pass |
| `node --test scripts/publish-offline.test.mjs scripts/serve-playwright-artifact.integration.test.mjs` | 3/3 pass |
| `openspec validate docs-wiki-content-expansion --strict` (parent repository) | valid |
| `Wiki/dist/index.html` | 5,558,682 bytes (5.30 MiB), below the 5.8 MiB budget |

The scoped document, migration, type, and lint gates are clean. The broader source-boundary/lint aggregate still sees pre-existing, unrelated dirty `comparison-artifacts` references and source-snapshot whitespace in the shared Wiki workspace; those files are outside this change and were not rewritten or included to manufacture a repository-wide clean result.

The interactive preview remains available at `http://127.0.0.1:8080/#AS%2FDocs`.

## Deferred

- Draft and placeholder promotion is intentionally future content work, not counted as completed.
- English translation follows reviewed Chinese revisions.
- A future direct `workflow-validation` document may cover authoring Unreal-oriented unit tests in AngelScript; it does not require another navigation level or a broad new unit-test framework for ordinary Wiki content additions.
