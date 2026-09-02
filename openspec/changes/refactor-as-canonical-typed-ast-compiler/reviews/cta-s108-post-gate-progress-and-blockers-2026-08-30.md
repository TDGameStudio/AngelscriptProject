# CTA-S108 post-gate progress and blocker review — 2026-08-30

## Current assessment

The Canonical compiler architecture is largely established, but CANONICAL is
not yet safe as the product default. The latest production staged gate proves
real semantic convergence rather than only isolated-test growth:

- CTA-S105: whole-Engine Sema diagnostics **64 -> 55** after unified native
  nominal projection;
- CTA-S106: **55 -> 39** after type/companion namespace scope resolution;
- CTA-S107: **39 -> 29** after exact local `auto` deduction and production
  range-for closure;
- CTA-S108: **29 -> 21** after inherited native-property projection and exact
  property-owner relocation.

The current conservative percentages are:

- architecture-weighted non-Standalone implementation: **about 98%**;
- end-to-end non-Standalone completion: **about 94%**;
- safe product-default CANONICAL readiness: **about 92%**;
- formal OpenSpec checklist: **102/136 = 75.0%**.

The formal ratio stays lower because the 34 unchecked rows are mostly umbrella
sentences for complete language breadth, default cutover and final matrices.
Recent root closures are evidence inside those rows and do not justify checking
them prematurely.

## What CTA-S108 actually closed

The `AddUFunction` cluster was initially easy to misclassify as callback or
function-reference identity. Static source/log review corrected that hypothesis:
the `n"..."` arguments already resolved to `FName`; the event-property receiver
was missing because Canonical property projection was direct-type-only.

The repaired architecture now keeps three identities separate:

```text
sealed Canonical property identity
  = exact declaring base stable key + exact field declaration

generation relocation identity
  = authenticated exact Runtime property owner + type + offset

dynamic Runtime coordinate
  = generation-local TypeId/type pointer/property pointer
```

No Runtime pointer or numeric TypeId is persisted in the Canonical graph. The
focused test is **1/1 PASS**, and the production whole-Engine run removes:

- `AddUFunction ×3`;
- `Tags.Add ×1`;
- `OnComponentBeginOverlap` / `OnComponentEndOverlap`;
- `Tags`;
- one inherited `NodeName` occurrence.

Detailed evidence is recorded in
`attachments/cta-s108-inherited-native-property-and-exact-relocation-gate-2026-08-30.md`.

## Current semantic blockers

The latest whole-Engine Sema inventory is:

```text
11 ambiguous-overload
 4 unresolved-callee
 2 unresolved-identifier
 2 native-function-canonical-identity-invalid
 1 generated-accessor-copy-constructor-unavailable
 1 global-init-not-constant
-----------------------------------------------
21 total
```

The four unresolved callees are `Execute`, `CreateWidget`, `ApplyFormat` and
`NewObject`.

### 1. Generated delegate wrapper reconciliation (`Execute`)

This is the next selected root. The authored call appears before the
preprocessor appends the generated delegate wrapper. A raw later-section
generated wrapper is already green, but the exact prepared UE delegate
lifecycle remains red. A second custom `UObject + float` delegate reproduces
the production failure, removing the production type name and surrounding
event/class code from the primary root.

The parser-time diagnostic was initially read as:

```text
typeDecl=<none> sameNameCount=0 resolve=miss
```

That inventory belongs to the first authored-call parse and remains stale while
deferred resolution fails. A final-retry probe now proves the current graph has
seven records and an exact `FCanonicalObjectDelegate_7F2A` owner with fifteen
children. The generated ClassDecl lifecycle is therefore present. The
discriminating root is instead the missing standard conversion from Canonical
null literal `void@` to a nullable object handle/reference; the int-only control
passes while both `UObject + float` delegate fixtures fail. Adjacent
`native-function-canonical-identity-invalid` diagnostics independently show
that at least one generated/runtime script function is also reaching a
publication path reserved for `asFUNC_SYSTEM` functions.

The repair must add a general verifier-authenticated nullable conversion,
retry the deferred calls, and keep script method identity out of native-identity
publication. Relaxing the native gate or special-casing `Execute` would be
incorrect. The current RED/control sequence and corrected repair boundary are
recorded in
`attachments/cta-s109-generated-delegate-type-publication-gate-2026-08-30.md`.

### 2. Template covariance (`CreateWidget`)

`TSubclassOf<UExampleWidget>` must be accepted where
`TSubclassOf<UUserWidget>` is expected because the registered template carries
the maintained fork's covariance flag and the element type is derived. The
Canonical fact snapshot already carries template flags; missing pieces are
conversion ranking, exact nested base proof, representation-preserving CodeGen
and negative mutable-reference/invalid-template cases.

This cannot be implemented as a `TSubclassOf` or `CreateWidget` name allowlist.
Other fork templates also carry the covariance flag, so the rule must require
the exact same template declaration, arity, copied flag, recursively valid
arguments and legacy-compatible value/const-reference direction.

### 3. Remaining call/scope roots

- `NewObject` combines an authored script object argument with an unresolved
  class/template expression; the two causes must be separated before changing
  overload ranking.
- `ApplyFormat` currently receives an enum whose `typeDecl` is absent despite
  a stable enum resolution spelling.
- two `NodeName` identifiers and eleven ambiguous overloads remain to be
  grouped by shared receiver/type/provenance roots instead of fixed one line at
  a time.
- generated accessor copy construction and non-constant global initialization
  remain distinct semantic/lifecycle families.

## Current CodeGen/verifier blockers

The same staged run exposes ten downstream failures after semantic progress:

1. one dangling `ConstructExpr.resolvedDecl` in `Example_MixinMethods.as`;
2. four prepared-interface dispatch graph method-identity mismatches;
3. one unsupported 24-byte `FVector` generated-accessor read;
4. one unsupported `FString` literal construction;
5. three invalid materialized `FString` lvalue receivers.

These are not regressions introduced by CTA-S108. They were previously hidden
behind earlier Sema failures and are now explicit production roots. Each should
be repaired by a grouped semantic/ABI relation with a focused RED, then checked
against the staged whole-Engine inventory.

## Product and lifecycle disposition

- Product default remains **LEGACY**.
- Explicit CANONICAL remains staged/opt-in while these production roots are
  open.
- The original AngelScript parser/native AST/Builder/compiler remains retained
  for syntax/recovery, explicit LEGACY, differential reference and rollback.
- The obsolete HIR layer remains physically absent and must not be restored as
  an AOT hand-off.
- AOT/StaticJIT consumers should read the in-memory verified Canonical AST
  snapshot directly; diagnostic dump is an observer/tooling surface, not a
  compiler transport.
- Standalone remains deferred by user scope and is excluded from the 94%
  non-Standalone estimate.

## Next execution order

1. Add a focused generated-wrapper forward-declaration RED and close `Execute`
   plus script/native identity separation.
2. Rerun the exact prefix and whole-Engine staged gate; only then reclassify the
   two native-identity diagnostics.
3. Implement flag-governed template covariance with positive and hard-negative
   tests, then verify `CreateWidget` disappears.
4. Split `NewObject`, `ApplyFormat` and remaining ambiguity groups by their
   first missing typed relation.
5. Process the ten CodeGen/verifier roots in coherent batches and run the final
   cutover/default/full-suite matrices only after the whole `Script/` staged
   compile is clean.
