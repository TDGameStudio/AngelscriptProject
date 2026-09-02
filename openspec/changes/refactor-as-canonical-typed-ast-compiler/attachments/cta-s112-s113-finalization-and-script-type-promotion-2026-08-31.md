# CTA-S112 / CTA-S113 — finalization and script-type ownership promotion

Date: 2026-08-31  
Scope: non-Standalone CANONICAL source pipeline  
Status: CTA-S112 and CTA-S113 focused semantic/production gates GREEN; whole-corpus refresh captured

## Executive status

- Exact OpenSpec checklist: `102/136 = 75.0%`.
- Practical architecture completion: about `98%`.
- Practical end-to-end implementation completion: about `95%`.
- Default-cutover readiness: about `93%`.
- CANONICAL remains explicit opt-in; product default remains LEGACY.
- Standalone is deferred by product decision and is not part of this gate.
- The original AngelScript native AST/parser/builder/compiler remains retained
  for LEGACY, reference, differential validation and rollback.  HIR remains
  physically removed.

No OpenSpec checklist item is newly checked by these focused sub-gates.  The
final non-Standalone matrix and product-default cutover tasks remain open.

## CTA-S112 — deferred non-POD by-value call copies

### Closed defect

An earlier call could be parsed before a later generated/script value class had
its final Canonical traits and copy constructor.  The call therefore retained a
raw lvalue argument.  After type publication, CodeGen correctly rejected that
edge as `invalid sealed by-value copy transfer` because no owned
`Cleanup(MaterializeTemporary(Construct(copy)))` plan had been sealed.

Final class layout now invokes `asCSema::ReconcileDeferredByValueCopyPlans()`.
For a stored by-value formal that finally requires exact object copy semantics,
Sema constructs the exact copy plan and uses
`asCASTContext::ReplaceCallArgumentExpression()` to update the two redundant
authenticated edges atomically:

```text
CallExpr.children[index]
CallExpr.callArguments[index].expression
```

The replacement keeps the exact `ParamDecl`, formal `QualType`, source order
and selected copy-constructor `DeclId`.  CodeGen remains fail closed and does
not rediscover the constructor by name or Runtime numeric ID.

### Evidence

| Gate | Result | Evidence |
|---|---:|---|
| post-change build | PASS | `Saved/Build/cta-s112-deferred-copy-plan-first-green-build/20260831_011510_880_6dea778c/` |
| AST-first `GeneratedValueCopyReconcilesAfterEarlierConsumer` | 1/1 PASS | `Saved/Tests/cta-s112-deferred-copy-plan-ast-first-green/20260831_011743_304_2b9e159b/` |
| production/object Delegate pair after reconciliation | 1/2 progression | `Saved/Tests/cta-s112-production-and-object-delegate-green/20260831_011820_028_65c008bd/` |
| production/object Delegate pair after CTA-S113 ownership closure | 2/2 PASS | `Saved/Tests/cta-s113-production-and-object-delegate-post-ownership/20260831_015026_294_34b03e31/` |

The earlier `1/2` pair was progression evidence rather than a complete
production GREEN.  The object Delegate discriminator passed while the
production fixture advanced beyond the by-value call transfer and stopped at
the next independent fact:

```text
generated non-POD getter lacks its exact sealed copy-construction route:
AExampleEventActor::GetExampleEvent field ExampleEvent
```

After CTA-S113 closed the generated accessor plan and ownership boundary, the
same unchanged pair is now `2/2 PASS`.  This proves the two finalization passes
compose through the real preprocessed Delegate source and staged CodeGen path;
it is not only a synthetic AST success.

## CTA-S113 — generated non-POD accessor finalization

### Paired AST-first gate

`GeneratedAccessorCopyReconcilesAfterLaterValueType` now covers both directions
for a generated property accessor whose value class is declared later:

- getter: exact `Construct` relation from the owning field through the authored
  one-parameter const-reference copy constructor;
- setter: exact `Assign` relation from the same owning field and the generated
  setter parameter through the authored one-parameter `opAssign` method.

The source fixture deliberately authors `opAssign(const T& Other)` without an
explicit `in`.  Canonical source qualifiers preserve that spelling, while the
LEGACY Runtime ABI later normalizes an unspecified reference direction to
inout.  The Verifier therefore accepts source direction `none`, explicit `in`
or explicit `inout`, but rejects pure `out` for the assignment source.

### Implemented finalization shape

`RequiresExactValueObjectPlan()` now owns final classification.  Script classes
use their final Canonical `TRIVIAL_STORAGE_COPY` trait; genuine native type
views use current-generation Runtime ABI facts.  Dynamic numeric TypeId is not
stored as durable identity.

`ReconcileGeneratedAccessorPlans()` runs after final class layout and before
the CTA-S112 call-argument reconciliation.  It revisits generated accessors
that still lack inits and attaches only exact authenticated plans:

```text
final Canonical class/layout
  -> generated getter copy plan
  -> generated setter assignment plan
  -> earlier call-argument copy plans
  -> verifier / lifetime / CodeGen
```

### Failure chain and final GREEN

| Gate | Result | Evidence |
|---|---:|---|
| original getter-only AST RED | expected 0/1 | `Saved/Tests/cta-s113-generated-accessor-copy-ast-red/20260831_012047_077_bbe87b60/` |
| paired getter/setter AST RED | expected 0/1 | `Saved/Tests/cta-s113-generated-accessor-pair-ast-red/20260831_012822_223_2a9e7766/` |
| first implementation build | PASS | `Saved/Build/cta-s113-generated-accessor-finalization-first-green-build/20260831_013142_566_6b84eedf/` |
| source-direction repair build | PASS | `Saved/Build/cta-s113-generated-accessor-source-direction-green-build/20260831_013444_501_502456d1/` |
| paired AST run after source-direction repair | 0/1 | `Saved/Tests/cta-s113-generated-accessor-pair-ast-green-v2/20260831_013507_901_6dd73318/` |
| authored-origin/unique-copy AST RED | expected 0/1 | `Saved/Tests/cta-s113-authored-promotion-ast-red/20260831_014406_046_bbb4b164/` |
| first promotion-only repair build | PASS | `Saved/Build/cta-s113-authored-promotion-first-green-build/20260831_014517_096_ca185113/` |
| first promotion-only run | 0/1, hypothesis disproved | `Saved/Tests/cta-s113-authored-promotion-first-green/20260831_014529_483_0ac76a2b/` |
| final ownership-boundary build | PASS | `Saved/Build/cta-s113-authored-opimplconv-boundary-green-build/20260831_014825_837_dbc7eb2c/` |
| paired getter/setter ownership gate | 1/1 PASS | `Saved/Tests/cta-s113-authored-opimplconv-boundary-green/20260831_014838_778_15cfa969/` |
| native/TypeId/production `opImplConv` regressions | 4/4 PASS | `Saved/Tests/cta-s113-opimplconv-regression/20260831_014937_386_66bccab1/` |
| CTA-S112 plus accessor regressions | 3/3 PASS | `Saved/Tests/cta-s113-s112-accessor-regression/20260831_014937_386_d18fe123/` |
| production/object Delegate pair | 2/2 PASS | `Saved/Tests/cta-s113-production-and-object-delegate-post-ownership/20260831_015026_294_34b03e31/` |

The intermediate `0/1` was no longer missing getter/setter semantics.  Its sealed dump
contains both correct plans:

```text
GetValue.init -> Construct
  resolvedDecl = authored FGeneratedAccessorValue(const FGeneratedAccessorValue&)
  source       = FGeneratedAccessorOwner::Value

SetValue.init -> Assign
  resolvedDecl = authored FGeneratedAccessorValue::opAssign(const FGeneratedAccessorValue&)
  lhs          = FGeneratedAccessorOwner::Value
  rhs          = generated setter parameter
```

It also contains the invalid ownership contamination:

```text
D9  Class FGeneratedAccessorValue
    origin=canonical-native-type-view

D12 authored copy constructor
    FGeneratedAccessorValue(const FGeneratedAccessorValue&)
    formal quals=9

D20 duplicate Runtime-projected copy constructor
    FGeneratedAccessorValue(const FGeneratedAccessorValue&inout)
    formal quals=57
```

The test was tightened to select the authored constructor explicitly and also
require authored class ownership plus exactly one copy constructor.  This kept
the gate RED without accepting the corrupted declaration set.

## Confirmed two-stage root cause

The first defect was the shell-to-source ownership transition.  A type can be
encountered in this order:

1. an earlier class references a value type declared in a later section;
2. type/runtime preparation creates a range-less Canonical shell and marks it
   `canonical-native-type-view`;
3. `ActOnStartClassDecl()` later reaches the real source declaration, reuses
   the same `DeclId` and supplies the valid source range;
4. the transition did not retire the native-view origin.

`ActOnStartClassDecl()` now clears the native-view origin when a valid authored
source range promotes that same stable declaration identity.  However, the
first promotion-only repair still produced the unchanged corrupted dump.  That
failed GREEN attempt was important evidence: clearing the origin at declaration
start was necessary but not sufficient.

The second and decisive defect was eager conversion-method projection:

1. overload ranking asks `InternNativeMethods(..., "opImplConv")` for every
   argument type before candidate ranking;
2. `InternNativeMethods()` protected authored classes for every method name
   except `opImplConv`;
3. parsing the authored `opAssign(const T& Other)` therefore asked for
   `opImplConv` on `T`, rewrote the just-promoted class back to
   `canonical-native-type-view`, and made the later constructor import legal;
4. the ABI-normalized `const T&inout` duplicate was then appended beside the
   authored `const T&` constructor.

The final repair makes ownership uniform for all Runtime method names,
including `opImplConv`: a current-module authored class never receives Runtime
method projection.  Legitimate native conversion operators remain visible by
walking the sealed Canonical base graph and projecting onto the exact native
base declaration that owns them.  Dedicated native, type-identifier and
production conversion tests remain `4/4 PASS`.

This is a declaration-ownership transition defect, not a dynamic-TypeId defect,
not a CodeGen relocation defect and not a reason to restore HIR or use dumps as
input.

## Implemented ownership boundary

The repair is deliberately split across the two ownership boundaries:

1. `ActOnStartClassDecl()` promotes a reused native shell to authored-script
   ownership on the first valid current-module source spelling;
2. `InternNativeMethods()` never projects a Runtime method onto an authored
   class, including during eager `opImplConv` ranking;
3. native base methods are projected onto their exact Canonical native base
   declarations rather than copied onto the authored derived class;
4. the AST gate authenticates authored origin, one copy constructor, and the
   exact getter/setter copy/assignment relations;
5. genuine external native type views remain range-less/native-owned and retain
   lazy property/method/behaviour projection.

The final CTA-S113 GREEN asserts all of the following rather than merely
selecting the first matching constructor:

- class origin is not `canonical-native-type-view`;
- exactly one one-argument copy constructor exists for the value class;
- getter plan resolves that exact authored constructor and field;
- setter plan resolves the exact authored `opAssign`, field and parameter;
- the context verifies, seals and is publishable.

## Post-CTA-S113 whole-Engine refresh

The complete project `Script/` root was rerun through the staged Canonical
compiler after the ownership repair:

| Gate | Result | Evidence |
|---|---:|---|
| whole Script/Engine Canonical refresh | expected startup compile failure; inventory captured | `Saved/Tests/cta-s113-whole-engine-post-ownership-refresh/20260831_015307_869_8833d6c6/` |

The refresh reports `19` exact Sema diagnostics:

| Family | Count | Current examples / interpretation |
|---|---:|---|
| `ambiguous-overload` | 11 | diagnostics currently omit candidate/name/range detail, so attribution must be improved or reproduced by focused fixtures before changing ranking |
| `unresolved-callee` | 3 | `ApplyFormat`, `CreateWidget`, `NewObject` |
| `unresolved-identifier` | 2 | inherited native property `NodeName` in `Example_BehaviorTreeNodes.as` |
| generated-accessor copy constructor unavailable | 1 | `FExampleStruct` property in `Example_Struct.as` |
| generated-accessor assignment operator unavailable | 1 | the same `FExampleStruct` property |
| `global-init-not-constant` | 1 | remaining global-initializer lowering/constant-classification root |

Compared with the valid post-CTA-S108 inventory, exact Sema diagnostics moved
from `21` to `19`:

- the unresolved `Execute` callee is gone after CTA-S111--CTA-S113;
- both `native-function-identity-invalid` diagnostics are gone;
- accessor finalization now exposes the missing `FExampleStruct` assignment
  route explicitly beside its existing missing-copy route, which is a more
  accurate paired lifecycle diagnosis rather than proof of a new backend
  regression.

The same run reports `9` unique downstream CodeGen/verification failures:

| Family | Count | Current examples / interpretation |
|---|---:|---|
| prepared interface-dispatch graph authentication mismatch | 4 | `AExampleMovingObject`, `AExamplePickupBase`, `AExampleReplicatedActor`, `AExampleActorType`; expected and actual cardinalities match, so relation identity/authentication remains the suspected boundary |
| invalid materialized `FString` lvalue receiver | 3 | Enhanced Input mapping, damage implementation and session tracker paths |
| dangling `Construct` declaration | 1 | `AActor ActorReference` in `Example_MixinMethods.as` |
| unsupported 24-byte generated accessor read | 1 | `FVector` getter in `AExamplePropertySpecifierActor` |

The downstream inventory moved from `10` to `9`: the earlier `FString` literal
construction failure is gone.  The remaining failures are independent closure
roots; they do not invalidate the CTA-S112/CTA-S113 ownership fix.

## Remaining verification

Focused build, CTA-S113, CTA-S112/accessor, conversion, production Delegate and
whole-Engine refresh verification are complete.  The remaining sequence is:

1. close the paired `FExampleStruct` generated-accessor lifecycle root with a
   focused AST-first fixture derived from the production source;
2. improve/reproduce the eleven bare ambiguous-overload diagnostics before
   altering ranking, then close `ApplyFormat`, `CreateWidget`, `NewObject`,
   `NodeName` and global initialization as independent roots;
3. close the nine refreshed downstream CodeGen/verification roots;
4. run the complete non-Standalone build/test/cache/hot-reload/StaticJIT matrix;
5. preserve LEGACY default until that complete matrix is clean.
