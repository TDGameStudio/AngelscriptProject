# Language and Conformance Assertion-Depth Repair Review

## Scope

This review covers the seven ordinary `ChangeRequired` rows from the original
Language/Conformance assertion-depth review. The selected-2.38 owner remains a
separate prerequisite-backed Deferred product and is not promoted by current
fork execution.

Row-level evidence is in
`assertion-depth-language-conformance-repair-review.csv`.

## Result

- 7/7 ordinary repaired products are Complete.
- The current-fork Conformance products in this batch retain enabled positive
  or negative execution.
- `V238-DESIRED-BEHAVIOR` remains discoverable Disabled and tagged
  `#as-v238-backport`.
- The complete 132-row Language/Conformance review therefore moves from
  124 Complete / 7 ChangeRequired / 1 Deferred to
  131 Complete / 0 ChangeRequired / 1 Deferred.

Evidence corrections are explicit:

- application-interface registration is Metadata/Isolation only because the
  public registration surface has no removal or cleanup observer;
- loop-condition transfer no longer claims Diagnostic because all catalog
  cells are successful runtime paths.

No source cell was removed. ControlFlow cells now finish explicit context and
module cleanup and detach native state before the next cell. Mixin support and
rejection remain separate owners so current fork behavior is not rewritten as
selected-2.38 behavior.

## Accepted runtime evidence

- ControlFlow:
  `Saved/Tests/as-native-sdk-controlflow-double-cleanup-fix/20260727_104430_521_52e7efbf/`
  — 12/12 PASS after retaining the first crash as test-defect evidence.
- Language:
  `Saved/Tests/as-native-sdk-language-assertion-depth-fix1/20260727_104531_588_2b524bb7/`
  — 162/162 PASS, 58,860 source-begin records, 29,430 unique IDs, normal
  shutdown, no crash.
- Conformance:
  `Saved/Tests/as-native-sdk-conformance-assertion-depth/20260727_104854_827_a4de4140/`
  — 4/4 active PASS, normal shutdown, no crash.

The current full-SDK run still predates these sources and remains a separate
final gate.
