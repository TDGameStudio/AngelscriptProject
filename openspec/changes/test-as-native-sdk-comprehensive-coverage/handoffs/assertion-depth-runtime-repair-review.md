# Runtime Assertion-Depth Repair Review

## Scope and method

This is the independent final source review of the eleven `Runtime` products
marked `ChangeRequired` in
`assertion-depth-runtime-module-review.csv`.

Each row was checked against:

- its current catalog owner and current `Evidence` declaration;
- the exact owner method and any explicitly labelled product-part method;
- direct runtime, metadata, diagnostic, lifecycle, cleanup, isolation, and
  recovery postconditions in that source; and
- the currently recorded build/run evidence.

No row is promoted because the Runtime parent prefix passed. Parent execution is
used only as runtime acceptance after the row's direct source oracle has already
been established. `RT-CTX-RETURN-ABI-SHAPES` additionally uses the dedicated
`ContextReturnValueNegativeValue` `AggregateSupport` product-part for its signed
cell; that method prints the exact product case and asserts the ABI directly.

The row-level conclusions are in
`assertion-depth-runtime-repair-review.csv`.

## Result

- 11/11 prior `ChangeRequired` Runtime products are source Complete.
- No catalog evidence category was removed or weakened.
- Runtime moves from 11 Complete / 11 ChangeRequired to
  22 Complete / 0 ChangeRequired / 0 Deferred.

The direct closure by group is:

- Runtime Context, 6/6: explicit `Unprepare`, same-context recovery where
  faulted, independent control execution, explicit module discard, and exact-name
  null lookup now accompany the existing execution/ABI/diagnostic oracles.
- Runtime GC, 2/2: the empty-service owner contains every expected service
  operation and an independent engine; the cycle owner contains all four
  self/two-node and detect/direct-full cells with exact statistic, live-count,
  cleanup, and callback-state baselines.
- Runtime ScriptObject, 3/3: independent property mutation, balanced-reference
  survival, final-release destruction, per-origin `1 -> 2 -> 3` retirement,
  post-discard no-repeat counts, exact-name module absence, and recorder userdata
  cleanup are asserted directly.

Recovery is retained as strengthening for the arithmetic-exception and
stack-overflow owners even though it is not a separate catalog evidence label.

## Final Runtime acceptance

The previously pending coherent acceptance gate is now closed. The supplied
artifacts record:

- raw-object polymorphic ownership repair build:
  `Saved/Build/as-native-sdk-raw-object-polymorphic-ownership-fix/20260727_142459_213_cee1a389/`
  — build and process exit `0`, no timeout;
- derived object through a base-typed local:
  `Saved/Tests/as-native-sdk-this-pointer-polymorphic-ownership-fix/20260727_142516_653_561267f6/`
  — 1/1 PASS, zero failed/skipped, runner and process exit `0`, no timeout;
- focused ScriptObject ownership/lifecycle regression:
  `Saved/Tests/as-native-sdk-scriptobject-polymorphic-ownership-regression/20260727_142553_099_f942dbde/`
  — 4/4 PASS, zero failed/skipped, runner and process exit `0`, no timeout; and
- complete Runtime parent:
  `Saved/Tests/as-native-sdk-runtime-assertion-depth-final-green/20260727_142630_908_5de63093/`
  — 44/44 PASS, zero failed/skipped, runner and process exit `0`, no timeout.

The raw-object bridge was also reviewed at the production boundary:

- `as_scriptengine.cpp:4793-4811` and `4814-4854` resolve the registered
  dynamic type first. The compatibility predicate accepts exact type,
  dynamic-derived to static-base, and dynamic-implementation to
  static-interface; it rejects an unrelated type and the incompatible inverse
  directions.
- Reference transitions use the registered dynamic type, not the caller's
  static type.
- Final release invokes `CallDestructor(registeredType)` at
  `as_scriptengine.cpp:4841`, so destructor selection follows the dynamic type.
- The registry in `ASClass_Construction.cpp:28-142` keeps that exact dynamic
  type through balanced references, final destruction, destructor-time retain,
  and final storage retirement.

The focused executions directly cover exact compatibility, derived-to-base
compatibility, unrelated-type rejection, balanced/final release, and
destructor-time retain without a second destructor. The
`registeredType->Implements(objType)` interface-compatible direction was
confirmed by direct predicate inspection; the supplied focused sources do not
add a separate interface-typed runtime cell. That is a transparent coverage
note, not a blocker for the reviewed assertion-depth products.

The full SDK prefix remains a later whole-change acceptance gate.

## Review constraints

This review did not edit test or production source, did not change catalogs, and
did not rerun a build or test. It updates only the review handoff. The recorded
artifacts above were independently inspected for their current metadata and
summary results.
