# Module Assertion-Depth Repair Review

## Scope and method

This is the independent final source review of the sixteen `Module` products
marked `ChangeRequired` in
`assertion-depth-runtime-module-review.csv`.

The review covered the seven API-contract repairs documented in
`module-api-assertion-depth-implementation.md` and the nine remaining repairs
documented in `module-core-assertion-depth-implementation.md`. Each row was
checked against its current catalog owner, every explicitly labelled
product-part method, its declared evidence categories, and its observable
cleanup and isolation postconditions. The current source was reviewed directly;
the implementation handoffs were used only to locate the intended repair, not
as evidence that it was complete.

The row-level conclusions and current source ranges are in
`assertion-depth-module-repair-review.csv`.

## Result

- 16/16 prior `ChangeRequired` Module products are Complete.
- No catalog evidence category was removed or weakened.
- Module moves from 3 Complete / 16 ChangeRequired to
  19 Complete / 0 ChangeRequired / 0 Deferred.
- No source issue or assertion-depth blocker remains in these sixteen rows.

The API-contract group closes all seven prior rows: rename/reindex and same-name
rebuild, detached/attached compile-function ownership and negative no-mutation
paths, owned/foreign function removal, rejected and empty typedef inventories,
per-import unbind/rebind behavior, pre-class metadata lifetime and same-name
reuse, and nested-import visibility/deduplication.

The remaining group closes all nine prior rows: bytecode success/rejection/
recovery, function inventory and scalar/argument ABI execution, global
inventory/reset/removal, import binding/rebinding and bind-all behavior, module
discard/rebuild identity, namespace lookup and invalid-preservation, save/load
restoration and retry, exact section diagnostics and cross-section execution,
and rich state-table replacement.

## Acceptance evidence

The final evidence supplied for this review was read from its recorded
`RunMetadata.json`, `Summary.json`, and report output:

- focused global-state checkpoint:
  `Saved/Tests/as-native-sdk-module-globals-final/20260727_141921_615_92eafc4f/`
  — 3/3 PASS, zero failed/skipped, runner and process exit `0`, no timeout, no
  report failure hints;
- complete Module parent:
  `Saved/Tests/as-native-sdk-module-assertion-depth-green/20260727_142001_126_13598b04/`
  — 51/51 PASS, zero failed/skipped, runner and process exit `0`, no timeout, no
  report failure hints.

These runs are acceptance evidence after the direct source review. No row was
promoted solely because the Module prefix passed.

## Review constraints

This review did not edit plugin source or catalogs and did not rerun a build or
test. It adds only this Markdown handoff and its sibling CSV. The 51/51 Module
result is not represented as the later whole-SDK acceptance gate.
