# CTA-S110 / CTA-S111 — null contract and generated delegate constructor progress

Date: 2026-08-31  
Scope: non-Standalone CANONICAL source pipeline  
Status: CTA-S110 closed; CTA-S111 partially closed, deferred non-POD by-value copy planning remains open

## Executive status

- OpenSpec checklist remains `102/136 = 75.0%`; no checklist item is marked
  complete merely because a sub-gate moved.
- Practical non-Standalone architecture completion remains about `98%`.
- Practical end-to-end implementation completion remains about `94%`.
- Default-cutover readiness remains about `92%`; CANONICAL must not replace the
  product default until the whole Script corpus and required matrices are clean.
- Standalone remains explicitly deferred by product decision and is excluded
  from the current critical path.

## CTA-S110 — exact null target contract

The maintained LEGACY compiler accepts `null` only for object handles.  It does
not make mutable references, value objects, template/value pseudo-handles or
primitives nullable.  CANONICAL now publishes the same rule through one exact
predicate at all three authorities:

1. Sema overload viability;
2. sealed-graph Verifier authentication;
3. Bytecode CodeGen conversion admission.

The accepted target is exactly:

```text
!formal.IsReference()
&& formal.IsHandle()
&& canonical type kind == REFERENCE_OBJECT
```

The implementation intentionally removed the earlier broad funcdef/value/
template admission.  It is a language rule and contains no Delegate, `Execute`
or `UObject` name special case.

### Valid evidence

| Gate | Result | Evidence |
|---|---:|---|
| post-change build | PASS | `Saved/Build/cta-s110-null-target-green-build/20260831_003107_970_62b1adc1/` |
| forged reference/value pseudo-handle Verifier negatives | 2/2 PASS | `Saved/Tests/cta-s110-null-target-verifier-green/20260831_003127_570_6db424dd/` |
| positive nullable UObject handle | 1/1 PASS | `Saved/Tests/cta-s110-nullable-object-green-v2/20260831_003204_480_f44c7432/` |
| legal source reference-formal rejection | 1/1 PASS | `Saved/Tests/cta-s110-null-reference-sema-green/20260831_003238_339_e7d0f257/` |

The source negative logs `unresolved-callee:AcceptNullableReference_4D19` with
rank `-1`, proving rejection occurred in Canonical Sema rather than in a later
backend.

### Excluded fixture attempts

The following exploratory runs are not RED evidence and must not enter test
counts:

- `Value is nullptr` is not valid AngelScript expression syntax in this fork;
- `CType@&in` and `CType@ &in` are not the legal source reference parameter
  spelling on this parser path;
- the valid spelling used by the final negative is `CType&in`.

## CTA-S111 — production Delegate progression

The fresh two-test characterization was:

```text
PreprocessedObjectDelegateExecuteSeparatesParameterConversionFromProductionIdentity
    PASS

PreprocessedProductionDelegateExecuteUsesGeneratedScriptMethodIdentity
    FAIL
```

Evidence:
`Saved/Tests/cta-s111-script-native-identity-red-v2/Tests/CTA-S111-script-native-identity-RED-v2/20260831_003510_508_1ed86a3f/`

This invalidated the provisional assumption that generated `Execute` receiver
identity or nullable argument ranking was still the active failure.  The
production fixture instead stopped at:

```text
VERIFY category=DANGLING_ID detail=construct-decl
```

The triggering source shape is the default construction of the preprocessor-
appended `FExampleDelegate` wrapper before that wrapper's generated lifecycle
declarations have finished publication.

### Implemented semantic repair

`asCSema::ResolveDeferredNames()` now retries only unresolved zero-argument
`ConstructExpr` nodes after later record finalization.  It uses the expression's
already-sealed exact `QualType` to locate one zero-argument constructor and then
publishes that declaration identity.  It does not:

- use spelling-only lookup;
- manufacture a CodeGen fallback;
- permit a non-zero-argument construct to be guessed;
- weaken the Verifier.

Build evidence:
`Saved/Build/cta-s111-deferred-default-construct-green/Build/cta-s111-deferred-default-construct-green-build/20260831_003744_720_396c49e0/`

After this change the Verifier failure disappeared and execution advanced into
prepared CodeGen.  This is a partial GREEN for the semantic relation, not a
GREEN for the whole production fixture.

The final tree after removing the temporary `deferred-callee-current` probe also
builds successfully, and the focused object-delegate discriminator remains
green:

- build: `Saved/Build/cta-s111-deferred-construct-final/Build/cta-s111-deferred-construct-final-build/20260831_004246_775_87926992/`;
- test: `Saved/Tests/cta-s111-object-delegate-final-green/Tests/CTA-S111-object-delegate-final-GREEN/20260831_004300_928_9e32373a/` (`1/1 PASS`).

### Current exact blocker — corrected after CTA-S112 identity probes

The current production failure is:

```text
Canonical staged CodeGen failed code=-7 line=5472:
invalid sealed by-value copy transfer
function=AExampleEventActor::BindExampleDelegates()
argument=58 construct=58 ctor=515 runtime=-1 type=FExampleDelegate
```

The first diagnostic described declaration `515` as `ctor`, which led to the
provisional Runtime-relocation hypothesis recorded above.  Two diagnostic-only
CTA-S112 probes disproved it:

- `Saved/Tests/cta-s112-copy-ctor-identity-probe-red/20260831_004927_635_2d77554d/`;
- `Saved/Tests/cta-s112-copy-ctor-owner-probe-red/20260831_005053_986_ca12a05e/`.

The sealed graph and current Runtime both already contain the exact generated
copy constructor:

```text
Canonical D1782
  FExampleDelegate::FExampleDelegate(const FExampleDelegate&)

Runtime id 80298
  FExampleDelegate::FExampleDelegate(const FExampleDelegate&)
  one const-reference formal, inout=3
```

The failing call argument instead remains expression `58`, the original local
`VarDecl` reference for `ExampleLocalDelegate`.  `argument=58 construct=58`
therefore means no `Cleanup/MaterializeTemporary(Construct(copy-ctor))` plan was
sealed at the call edge.  Declaration `515` is the referenced local variable,
not a malformed constructor declaration.  `EmitOwnedNonPodValueArgument()`
unwraps the argument, verifies that it is a `ConstructExpr`, and correctly
fails closed when it sees the raw declaration reference.

The active root is now upstream of prepared Runtime relocation:
`SealNonPodByValueCopyPlan()` returns the original argument before it can build
the exact copy-construction plan.  A temporary narrow Sema probe confirmed the
exact source-order-sensitive precondition:

```text
by-value-copy-plan-classification-probe:
FExampleDelegate:nonPrimitive=0:typeInfo=0:flags=0
```

Evidence:
`Saved/Tests/cta-s112-copy-plan-classification-probe-red-v2/20260831_005636_120_19bb4b2b/`
(`1 total / 0 pass / 1 expected fail`).

At the earlier consumer parse point the Runtime bridge cannot yet classify the
preprocessor-appended wrapper, so the function returns the raw lvalue.  Later
publication supplies both Canonical and Runtime constructors, but no phase
replays the already-built call edge.  The temporary Sema probe and the earlier
CodeGen inventory probe were removed after capture; their output is evidence,
not product behavior.

The fix must defer and then atomically reconcile the semantic copy-plan relation
after later declaration/type publication, updating both the call child and its
`callArguments.expression` relation.  It must preserve the fail-closed check in
`EmitOwnedNonPodValueArgument()`: CodeGen may consume only a sealed constructor
identity whose Runtime function has the same owner, one reference parameter and
the exact `FExampleDelegate` type.  A name/arity fallback, a second synthetic
Runtime shell, or relaxation of `PublishNativeFunctionDeclarationIdentity()` is
forbidden.

An attempted broad change that admitted every generated constructor to the
late generated-function shell set did not change this failure and was reverted.
It is not part of the implementation.

## Whole-engine baseline and remaining families

No new whole-engine run has been performed after the CTA-S110/CTA-S111 narrow
work, so the last valid whole-engine number remains `21` Canonical Sema
diagnostics:

- `11` ambiguous overloads;
- `4` unresolved callees (`Execute`, `ApplyFormat`, `CreateWidget`, `NewObject`);
- `2` unresolved identifiers;
- `2` native-function Canonical identity failures;
- `1` generated-accessor copy-constructor unavailable;
- `1` non-constant global initializer.

The prior downstream inventory contained ten roots: one dangling construct
identity, four interface-dispatch cases, one FVector accessor, one FString
literal, and three materialized FString receiver cases.  CTA-S111 has now
demonstrated a valid repair for the zero-argument dangling-construct semantic
identity, but the inventory must not be numerically reduced until the whole
engine is rerun.

## Architecture assessment

The architecture remains sound and consistent with the intended Clang-shaped
ownership model:

```text
Parser actions
  -> Canonical Sema exact Decl/Stmt/Expr/Type graph
  -> deferred source-order reconciliation
  -> fail-closed Verifier and lifetime plan
  -> prepared Canonical-to-current-Runtime relocation
  -> CodeGen consumes only authenticated identities
```

The current blocker is evidence that this separation is working: the Verifier
first rejected a genuinely unresolved zero-argument construction; after Sema
supplied that identity, CodeGen exposed a different incomplete semantic fact —
the by-value copy argument was never transformed into an owned copy plan.
Runtime relocation is already capable of matching the exact copy constructor.
The remaining work is therefore source-order-safe Sema reconciliation, not a
need to reintroduce HIR, consume a dump, restore parser-node authority, or add a
backend spelling fallback.

The original AngelScript native AST/parser/builder/compiler remains retained for
explicit LEGACY, reference, differential validation and rollback.  HIR remains
removed and must not be restored.
