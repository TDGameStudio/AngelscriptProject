# CTA-S76–S77 TypedASTJIT receiver and PreClass dual-relation gates — 2026-08-30

## Status

This attachment records two non-Standalone implementation slices completed
after CTA-S75. They close one TypedASTJIT safety defect and one cross-layer
Canonical class-identity defect. They do not close the broader 7.2/7.4/7.5
coverage rows and do not authorize the product-default switch.

Current formal OpenSpec progress therefore remains **102/136 = 75.0%**. The
implementation is farther along than that conservative umbrella ratio, but
the remaining cutover and final-verification rows are still real gates.

## CTA-S76 — receiver-bearing calls fail closed before typed closure

### Problem

The TypedASTJIT Canonical adapter treated ordinary call children as the entire
call input graph:

- eligibility skipped the dedicated `asAST_EDGE_EXPR_RECEIVER` edge;
- root call-closure discovery recursed only ordinary children;
- emission evaluated only the reverse-formal child list.

For a receiver-bearing call this could omit receiver-side effects, nested
script-call dependencies and the effective-receiver ABI. A receiver that
itself contains a nested call is the adversarial case: merely checking the
outer call name would not reveal the missing dependency.

### Resolution

`FAngelscriptTypedASTJIT` now rejects every Canonical `CallExpr` with a valid
dedicated receiver before typed root closure is accepted. The typed fallback
category is exactly `UnsupportedReceiver`.

This is intentionally a safety gate, not partial receiver lowering. Full
receiver provenance, evaluation order and native/script bridge ABI must land
together before these functions may become typed-native eligible. The normal
VM/Bytecode route remains available for the rejected function.

The focused test
`ReceiverBearingCallFallsBackBeforeTypedClosure` builds a sealed call whose
only nested call is reachable through the receiver edge and proves that typed
closure fails before that dependency can be lost.

### Evidence

| Gate | Result |
| --- | --- |
| RED build | PASS — `Saved/Build/cta-s76-typedjit-receiver-red-build/20260830_071339_919_fe605186` |
| Focused RED | **0/1 expected failure** — `Saved/Tests/cta-s76-typedjit-receiver-red/20260830_071403_503_46948987` |
| GREEN build | PASS — `Saved/Build/cta-s76-typedjit-receiver-green-build/20260830_071444_533_e295f722` |
| Focused GREEN | **1/1 PASS** — `Saved/Tests/cta-s76-typedjit-receiver-green/20260830_071459_405_0e1f1fec` |
| CanonicalASTMigration | **25/25 PASS** — `Saved/Tests/cta-s76-typedjit-canonical-migration-green/20260830_071533_463_fc4816be` |

## CTA-S77 — authored script base and PreClass shadow are orthogonal

### Symptom exposed by the full TypedASTJIT prefix

The first whole-prefix rerun reached the production fixture that creates two
fresh Engines sequentially. Its second compile was rejected while authenticating
the prepared class graph:

```text
prepared interface dispatch graph authentication failed:
prepared record shadow root differs from the sealed PreClass edge:
UStaticJITAotVirtualChild
```

The receiver patch did not cause this failure. It made the suite progress far
enough to expose a pre-existing disagreement between the sealed Canonical class
graph and the Stage 2 Runtime shell.

### Required model

AngelScript authored inheritance and Unreal PreClass embedding are not two
ordinary AngelScript base classes:

```text
authored `class Child : ScriptBase`
    -> Canonical ordinary class-base edge
    -> Runtime `derivedFrom`
    -> method/override/interface ancestry and inherited layout

host `PreClassData.ShadowType = NativeShadow`
    -> Canonical `canonical-native-type-view` edge
    -> Runtime `shadowType`
    -> native embedding/layout/authentication relation
```

Both relations may be present on the same class. The native view must not
replace `derivedFrom`, participate in script override ancestry, or be rejected
as AngelScript multiple inheritance.

### Layered defects

The focused compile-to-seal test exposed three stale consumers:

1. `asCSema::ActOnRecordBaseSpecifiersAction()` projected the PreClass native
   view only when the authored base list was empty. A class with `ScriptBase`
   therefore sealed no native shadow relation at all.
2. After Sema was corrected, the publication verifier counted every class-
   shaped base edge as method inheritance and rejected the graph with
   `method-relation-class-ancestry-multiple-bases`.
3. Detached Runtime type registration selected every class-shaped base as a
   candidate for `derivedFrom`; the native view therefore could overwrite the
   authored script base even though the prepared validator already understood
   the separate `shadowType` contract.

The initially opaque `Build() == -17` also exposed a diagnostic gap: Builder
Seal returned only `asINVALID_CONFIGURATION` after destroying the rejected
pending graph. The Builder publication boundary now reruns the same read-only
verifier and publishes the formatted category, invariant, node/path and compact
subtree diagnostic. The exact failure became:

```text
VERIFY category=INVALID_CHILD
detail=method-relation-class-ancestry-multiple-bases
```

### Resolution

- Sema always projects the PreClass native view when present, independently of
  an authored script base, while still deduplicating the exact DeclId.
- the verifier classifies `canonical-native-type-view` explicitly and excludes
  it from script class reachability, single-base checks, method ancestor
  collection and ordinary layout-base selection;
- detached CodeGen ignores the native view when rebuilding `derivedFrom` and
  continues to publish it through the independent `shadowType` route;
- Builder Seal failures now retain actionable verifier diagnostics at the
  compiler boundary.

The new test `PreClassShadowCoexistsWithAuthoredScriptBase` verifies that the
same sealed class retains both the authored `ScriptBase` edge and the native
shadow view in the correct roles.

### RED/GREEN trail

| Gate | Result |
| --- | --- |
| Initial RED build | PASS — `Saved/Build/cta-s77-preclass-dual-relation-red-build/20260830_071912_009_a31cdc69` |
| Exact structural RED | **0/1 expected failure**; native edge absent — `Saved/Tests/cta-s77-preclass-dual-relation-red2/20260830_072022_066_b5c97e8f` |
| First producer build | PASS — `Saved/Build/cta-s77-preclass-dual-relation-green-build/20260830_072112_492_d18c3c89` |
| Next-layer RED | **0/1 expected failure** at Build — `Saved/Tests/cta-s77-preclass-dual-relation-green/20260830_072125_541_0fa09f84` |
| CodeGen classification build | PASS — `Saved/Build/cta-s77-preclass-dual-relation-green2-build/20260830_072221_231_9f1be224` |
| Remaining verifier RED | **0/1 expected failure** — `Saved/Tests/cta-s77-preclass-dual-relation-green2/20260830_072235_162_4e0b80c9` |
| Exact verifier diagnostic | **0/1 expected failure**, `method-relation-class-ancestry-multiple-bases` — `Saved/Tests/cta-s77-preclass-dual-relation-verifier-diagnostic/20260830_073007_060_92b115b7` |
| Final build | PASS — `Saved/Build/cta-s77-preclass-dual-relation-verifier-green-build/20260830_073115_000_a615a1fb` |
| Exact dual-relation GREEN | **1/1 PASS** — `Saved/Tests/cta-s77-preclass-dual-relation-verifier-green/20260830_073126_680_fecb2b94` |
| Original symptom + existing PreClass gates | **3/3 PASS** — `Saved/Tests/cta-s77-preclass-dual-relation-regression/20260830_073218_108_d552ddb2` |
| Full TypedASTJIT | **54/54 PASS** — `Saved/Tests/cta-s77-typedjit-full-green/20260830_073258_425_342698fd` |
| Full SemaAuthority | **438/438 PASS** — `Saved/Tests/cta-s77-sema-authority-green/20260830_073456_207_c077a49b` |
| Frontend + Compiler CanonicalAST | **817/817 PASS** (**182** Frontend + **635** Compiler) — `Saved/Tests/cta-s77-frontend-compiler-canonical-full-green/20260830_073708_674_1c4d2bb0` |

The three-test regression group includes:

- the original `CompleteTypedGenerationNeverTraversesBytecode` symptom;
- `PreClassNativeBaseIsVisibleBeforeDerivedBodySema`;
- `PreparedNativeShadowBaseIsAuthenticatedAsPreClassRelation`.

## Architecture assessment after CTA-S77

The production lifecycle is more coherent than before this slice:

- Canonical Sema is the only producer of the two explicit class relations;
- publication verification understands their semantic roles instead of
  inferring all class-shaped edges as inheritance;
- Runtime installation maps them mechanically to `derivedFrom` and
  `shadowType`;
- prepared dispatch validates both against the same sealed graph;
- TypedASTJIT consumes the resulting immutable snapshot and falls back before
  it can omit a receiver graph.

This is the desired Clang-like boundary: syntax/parser structures may help
produce semantic declarations, but later consumers operate on authenticated
typed relations and stable identities rather than rediscovering meaning from
names or native syntax-node shape.

## Remaining issues

Tasks 7.2, 7.4 and 7.5 remain open:

- receiver-bearing calls are now safe but not typed-native lowered;
- native target binding still reconciles some declarations through owner/name
  strings instead of one immutable verifier-authenticated binding relation;
- the native-shadow base role is currently authenticated through the sealed
  `canonical-native-type-view` origin marker; a future public AST schema may
  replace this string classification with an explicit base-relation enum, but
  that schema cleanup is not required for the current safe cutover;
- cleanup/destructor authoring still contains some stable-key/name/type-kind
  projection fallbacks that should become exact relation consumers;
- exception/suspend, mutable-global/import, native object-frame and provider
  dependency facts are not yet a complete typed fallback/lowering matrix;
- uncommon language families, default-selection scans and the final focused/
  All verification matrix remain before product-default CANONICAL cutover.

Standalone remains explicitly deferred and is not claimed by this evidence.
