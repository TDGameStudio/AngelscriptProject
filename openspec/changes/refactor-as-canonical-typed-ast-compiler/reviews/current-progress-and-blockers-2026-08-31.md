# Current progress and blockers — 2026-08-31

## Verdict

The non-Standalone Canonical compiler architecture is substantially complete,
but CANONICAL is not yet ready to become the product default.  The exact
OpenSpec task completion is `102/136 = 75.0%`; practical architecture is about
`98%`, practical implementation is about `95%`, and default-cutover readiness
is about `94%`.

CTA-S114 through CTA-S116 are now closed at focused AST/CodeGen and production-
corpus scope:

- authored script value classes receive exact conditional implicit copy/
  assignment lifecycle declarations when every member has a valid route;
- unavailable generated special members stay bodyless and unpublished instead
  of poisoning unrelated functions or falling back to raw non-trivial copies;
- generated wide-POD getters, setters and member assignments use exact-width
  `asBC_COPY`;
- implicit-handle reference and funcdef locals receive explicit typed-null
  initialization, while value locals retain exact default construction;
- a later verifier regression that excluded funcdef null conversions was found
  and repaired without broadening nullable value types.

The unchanged preprocessed `Example_Struct.as` gate is `1/1 PASS`, the combined
copy/accessor regression is `6/6 PASS`, the funcdef/reference default-null gate
is `1/1 PASS`, and the value-local construction control is `1/1 PASS`.

The whole Script/Engine Canonical corpus now contains `17` exact Sema
diagnostics and `7` unique downstream CodeGen/verification failures.  This is
an improvement from the post-CTA-S113 `19 + 9` inventory and the earlier
post-CTA-S108 `21 + 10` inventory.  Focused success still does not authorize
the product-default switch.

Detailed CTA-S110/CTA-S111 evidence and the previous whole-engine inventory are
recorded in
`attachments/cta-s110-s111-null-and-delegate-constructor-progress-2026-08-31.md`.
CTA-S112/CTA-S113 implementation evidence and the current ownership-promotion
root cause are recorded in
`attachments/cta-s112-s113-finalization-and-script-type-promotion-2026-08-31.md`.
CTA-S114/CTA-S115 implicit lifecycle and wide-POD evidence, CTA-S116 reference-
local repair, the adjacent verifier regression, and the current whole-corpus
inventory are recorded in
`attachments/cta-s114-s116-copy-lifecycle-wide-pod-and-reference-local-2026-08-31.md`.

## Immediate critical path

1. diagnose and close the four same-cardinality interface-dispatch
   authentication mismatches as one relation/ordering batch;
2. diagnose and close the three `FString` materialized-lvalue receiver failures
   as one ownership/lifetime batch;
3. make the eleven bare ambiguous-overload diagnostics attributable before
   changing overload ranking, then close `ApplyFormat`, `CreateWidget`,
   `NewObject`, `NodeName` and global initialization;
4. run the complete non-Standalone build/test/cache/hot-reload/StaticJIT matrix;
5. change the default only after those gates are clean.

CTA-S112 closed the previously diagnosed source-order hole: at the earlier
consumer parse point the Runtime bridge reports the generated value type as
unavailable, so finalization now classifies the final Canonical class and
atomically reconciles the stored call edge.  CTA-S113 proves the same phase is
also the right owner for generated getter/setter plans and closes the later
shell-to-authored ownership transition.  The first promotion-only attempt was
recorded as a disproved hypothesis because eager `opImplConv` projection wrote
the native origin back; the final repair protects authored ownership at both
boundaries rather than weakening the test.

The current refreshed corpus is recorded in
`attachments/cta-s114-s116-copy-lifecycle-wide-pod-and-reference-local-2026-08-31.md`.
Its Sema inventory is `11` ambiguous overloads, `3` unresolved callees, `2`
unresolved inherited identifiers and `1` non-constant global initializer.  Its
downstream inventory is `4` interface-dispatch authentication mismatches and
`3` invalid materialized `FString` receivers.

CTA-S114 removed both `FExampleStruct` lifecycle diagnostics, CTA-S115 removed
the unsupported 24-byte generated accessor read, and CTA-S116 removed the
dangling `AActor` local Construct.  These are exact corpus deltas, not an
inference from the focused tests alone.

## Explicit non-goals for this gate

- Standalone adaptation;
- deleting the original native AngelScript AST/compiler;
- restoring HIR;
- using an AST dump as compiler input;
- weakening native SYSTEM identity or backend fail-closed checks;
- declaring the default cutover complete from focused tests alone.
