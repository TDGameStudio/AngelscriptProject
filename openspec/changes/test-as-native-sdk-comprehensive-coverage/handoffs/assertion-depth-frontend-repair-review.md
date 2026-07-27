# Frontend Assertion-Depth Repair Review

## Scope

This review independently re-evaluates the thirty Frontend products marked
`ChangeRequired` by the original Frontend/Compiler review. It compares the
current owner, current catalog evidence, and current runtime result for each
product. A green Frontend parent is supporting execution evidence, not a
substitute for the row-level source review.

The exact dispositions and source evidence are stored in
`assertion-depth-frontend-repair-review.csv`.

## Result

- 30/30 prior `ChangeRequired` Frontend products are now `Complete`.
- The other 23 Frontend products that were already `Complete` remain
  unchanged.
- Frontend's final assertion-depth disposition is therefore 53 `Complete`,
  0 `ChangeRequired`, and 0 `Deferred`.

Fourteen products deliberately narrow unsupported evidence without deleting a
single generated cell:

- eleven tokenizer products remove `Compile` because their complete lexical
  inputs include malformed, unterminated, split, or non-module text;
- the tokenizer protected-helper and parser protected-predicate products
  remove `Compile` because they directly own internal classification rather
  than builder publication;
- the long-identifier boundary product removes `Compile` because it owns
  lexical span and following-token boundaries;
- the direct `asCScriptCode` row/column product removes `Cleanup` because it
  has no parser, module, or externally observable cleanup surface.

Full parser/compiler publication remains owned by dedicated parser and
compiler products. Evidence narrowing therefore corrects false claims rather
than reducing language coverage.

The remaining sixteen products gain direct postconditions:

- parser/tree owners release parser and builder storage before module discard,
  require `asSUCCESS`, and require name lookup absence;
- isolation owners execute independent clean controls and assert exact AST or
  diagnostic state;
- string owners release their owned graph before asserting external buffers,
  independent copies, and fresh empty baselines.

## Static evidence

- Catalog expansion: 317 products and 46,140 unique IDs:
  45,994 CurrentFork, 81 RejectByFork, and 65 Future238Disabled.
- Source reconciliation: 316 Implemented plus one DisabledImplemented,
  686 methods, and zero unresolved methods.
- Boundary audit: zero violations.
- Inline AS formatting: 296/296 conforming sources and zero violations,
  including the two registered escaped tokenizer inputs.
- Planning validation, strict OpenSpec validation, and scoped whitespace checks
  pass.

The generated-source registry was updated because the new parser isolation
controls are also printed in full for review.

## Build and runtime evidence

- Initial build:
  `Saved/Build/as-native-sdk-frontend-assertion-depth/20260727_113521_762_d058d298/`
  — retained test-source diagnostic: two `[[nodiscard]]` assertion results in
  the diagnostic cleanup helper were not consumed.
- Corrected build:
  `Saved/Build/as-native-sdk-frontend-assertion-depth-fix1/20260727_113602_196_85c7d1e4/`
  — PASS.
- Intermediate Frontend parent:
  `Saved/Tests/as-native-sdk-frontend-assertion-depth-retry/20260727_113654_288_49f6c419/`
  — 169/169 PASS.
- Final build:
  `Saved/Build/as-native-sdk-frontend-assertion-depth-final/20260727_113904_271_ec176619/`
  — PASS, process/final exit 0, 13,072 ms.
- Final Frontend parent:
  `Saved/Tests/as-native-sdk-frontend-assertion-depth-final/20260727_113923_886_aaa6ab57/`
  — 169/169 PASS, zero failed/skipped, process/wrapper exit 0,
  `TimedOut=false`, 34,171 ms, normal status-zero shutdown, and zero
  fatal/assert/unhandled/access-violation markers.

The final log contains 1,198 `[AS-SOURCE-BEGIN]` records and 599 unique printed
source IDs. Generated product inputs and the added isolation controls remain
visible in full.
