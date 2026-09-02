# Sibling OpenSpec reconciliation

This is a record of ownership conflicts discovered while expanding TestSource. This change does not edit or archive the siblings.

| Change | Existing useful responsibility | Reconciliation required before implementation |
|---|---|---|
| `docs-as-test-direction-map` | Subject/question map and fill order | Keep the semantic map; replace plugin `Fixtures/` as handwritten truth with TestSource as truth. |
| `test-as-data-driven-engine-harness` | COMPLEX runner, corpus lookup, engine profiles | Consume a reviewed TestSource release/import result; do not own a second handwritten library. |
| `test-as-hotreload-script-corpus` | HotReload driver and version-transition oracle | Consume root `TestSource/HotReload`; framework reload cases remain under `TestFramework/HotReload`. |
| `test-as-source-generation-rules` | Randomized/rule-based definitions, expressions and C++ static-function export | Consume the theme registry; treat the current 614 files as an initial seed rather than the complete source centre. |
| `test-as-script-corpus-and-functional-coverage` | Historical candidate scenarios | Non-authoritative research input only; it no longer decides layout, counts, runner, or acceptance. |

`Script/**` remains the project teaching and host script-test surface. Its files are inventoried as references and are not copied wholesale into TestSource.
