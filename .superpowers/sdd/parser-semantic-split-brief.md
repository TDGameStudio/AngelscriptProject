# Parser semantic-owner split brief

## Scope

Refactor only the current raw-SDK parser aggregate and the living records that
must follow its physical owner paths. This is a source-preserving semantic
split, not a coverage reduction, behavior change, or opportunity to redesign
the generated cases.

Primary source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/AngelscriptNativeParserCartesianDepthTests.cpp`

Current pre-edit evidence must be captured before editing:

- complete current file SHA-256;
- all nine `TEST_METHOD` bodies with a deterministic brace-aware SHA-256;
- nine class names, method names, automation paths, product IDs, source print
  counts, generated case IDs/literals, diagnostic text, and lifecycle shape;
- current catalog validation and source-reconciliation result.

Do not rely on historical line numbers as content authority.

## Required physical owners

1. Retain
   `Frontend/AngelscriptNativeParserCartesianDepthTests.cpp` for these five
   parser products:
   - `FRONTEND-PARSER-DECLARATION-FAMILIES`
   - `FRONTEND-PARSER-FUNCTION-PARAMETER-BODY-LINE-ENDINGS`
   - `FRONTEND-PARSER-EXPRESSION-OPERATOR-GROUPING`
   - `FRONTEND-PARSER-SEMANTIC-EXPRESSION-PLACEMENT`
   - `FRONTEND-PARSER-EXPRESSION-STATEMENT-FAMILIES`
2. Create
   `Frontend/AngelscriptNativeScriptNodeCartesianDepthTests.cpp` for:
   - `FRONTEND-NODE-DEEP-NESTING-COPY`
   - `FRONTEND-NODE-TRAVERSAL-COPY`
3. Create
   `Frontend/AngelscriptNativeScriptCodePositionTests.cpp` for:
   - `FRONTEND-SCRIPT-CODE-ROW-COLUMN`
4. Create
   `Frontend/AngelscriptNativeParserSourceRecoveryTests.cpp` for:
   - `FRONTEND-SOURCE-POSITIONS-RECOVERY`
5. Create
   `Support/AngelscriptNativeParserDepthTestSupport.h` containing only the
   genuinely cross-owner parser lifecycle/link helpers:
   - `ParseScriptCase`
   - `ReleaseParserCase`
   - `ValidateSiblingLinks`

Keep all other structs/helpers local to the one physical owner that needs
them. If a non-listed helper is genuinely required by more than one new
owner, first prefer a small owner-specific implementation with a
unity-unique name; do not silently enlarge the shared header or duplicate an
identically named file-scope definition that can collide in unity builds.

## Preservation requirements

- Preserve every class name, `TEST_METHOD` name, and Automation path byte for
  byte. A physical filename change must not rename the registered test.
- Preserve all nine method bodies semantically and textually except for the
  minimum qualified helper calls/includes required by the move.
- Preserve every product ID, expected generated ID, product-part count,
  source construction table, AS source text, source-print call, assertion,
  diagnostic oracle, parse/reset/recovery sequence, cleanup, and raw-engine
  Create/Destroy ordering.
- Keep `WITH_ANGELSCRIPT_UNITTESTS` gating correct in every `.cpp`.
- Follow `Documents/UnitTest/UnitTest.md`: readable Allman AS source,
  case-owned raw engine where currently present, no file-level assertion
  aliases, no hidden top-level test-flow wrapper.
- Keep the ScriptCode row/column product value-owned and engine-free.
- Do not add add-ons, `FAngelscriptEngine`, UE world/object fixtures, or UE
  debugger integration.
- Do not introduce the user-forbidden generic coverage word in new names or
  current records.
- Do not build or run UE Automation for this isolated move. The root agent is
  batching all structural edits before the next coherent build.
- Do not commit.
- Use `apply_patch` for every file edit.

## Living records to update

Update current owner paths only where the record is explicitly living:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- current generated audit/inventory outputs produced by the official scripts
- `tasks.md` task 4.7 wording/count only after the split is statically proven

Do not rewrite historical assertion-depth, predecessor, review, issue, or
implementation-ledger evidence merely because it retains the pre-split path.
If an official current-audit exporter updates current inventories, use it
rather than hand-editing generated rows.

Expected generated-source registry print counts by resulting owner:

- retained parser owner: 7 total source-reporting call sites across five rows;
- ScriptNode owner: 2 total across two rows;
- ScriptCode owner: 1;
- recovery owner: 1.

## Required static verification

Run the repository's existing OpenSpec scripts with their documented
arguments and record exact commands/results:

- catalog validation: 317 products / 46,140 expected IDs, no incomplete or
  duplicate products;
- current-source export/reconciliation: no unknown, duplicate, incomplete,
  or unresolved methods;
- generated-source registry reconciliation: all moved paths and print counts
  exact;
- internal-method, predecessor, API, boundary, and inline-AS checks remain
  green;
- explicit unity-oriented scan proves no duplicate file-scope definitions
  introduced by the four `.cpp` files/header;
- scoped and per-new-file whitespace checks;
- strict OpenSpec validation and planning-record validation;
- source inventory and living quality record agree, and required split count
  decreases from 7 to 6.

If any official script fails because of invocation/runtime misuse, correct the
invocation and record the tool problem; do not hide it by hand-editing output.

## Report

Write a concise implementation report to:

`.superpowers/sdd/parser-semantic-split-report.md`

The report must include:

- status (`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`);
- exact files changed/created;
- pre/post owner and method/product counts;
- preservation evidence including all nine method hashes or an exact
  explained equivalent;
- static commands and results;
- any discovered source, fork, test, record, or tool problem;
- explicit confirmation that no build/tests/commit occurred.
