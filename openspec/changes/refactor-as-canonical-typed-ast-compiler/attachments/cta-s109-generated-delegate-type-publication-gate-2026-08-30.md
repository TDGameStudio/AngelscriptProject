# CTA-S109 generated delegate type publication gate — 2026-08-30

## Scope and disposition

CTA-S109 is the current focused production root after CTA-S108 removed the
inherited native-property cluster.  It owns the remaining
`unresolved-callee:Execute` failure from
`Script/Examples/Core/Example_Delegates.as` and the adjacent
`native-function-canonical-identity-invalid` diagnostics.

This gate is **RED and not complete**.  It records the current discriminating
evidence so the repair does not widen native identity, special-case
`Execute`, or incorrectly change null/numeric argument conversions.

## Evidence sequence

### 1. Raw generated-wrapper control is green

Test:

```text
FCanonicalASTSemaAuthorityTests.
GeneratedWrapperMethodReconcilesAfterEarlierConsumer
```

The first script section calls `FGeneratedWrapper::Execute(int)` and the
second section declares the generated struct and method.  It proves one
ClassDecl, one generated MethodDecl, exact call resolution, a publishable
snapshot and Canonical CodeGen execution.

Evidence:

```text
Saved/Tests/cta-s109-generated-wrapper-reconciliation-red/
20260830_233838_413_3e1e509a
1/1 PASS
```

Therefore generic cross-section forward method reconciliation is not the
production root.

### 2. A simple preprocessed delegate control was green

The first preprocessor-shaped control used a delegate with an `int` formal and
called the generated `IsBound`, `Execute` and `ExecuteIfBound` helpers.

Evidence:

```text
Saved/Tests/cta-s109-real-preprocessed-delegate-red/
20260830_234305_758_3704e4ca
1/1 PASS
```

Therefore the existence of a delegate macro, generated helper source, or an
appended helper section alone is not sufficient to reproduce the production
failure.

### 3. The exact production source is red

Test:

```text
FCanonicalASTSemaAuthorityTests.
PreprocessedProductionDelegateExecuteUsesGeneratedScriptMethodIdentity
```

The test creates a complete transient `FAngelscriptEngine`, selects CANONICAL,
loads `Script/Examples/Core/Example_Delegates.as`, and compiles it through the
real preprocessor/CompileModules lifecycle.

Evidence:

```text
Saved/Tests/cta-s109-production-delegate-red/
20260830_234528_914_391f753b
0/1 PASS
```

The first exact failure is:

```text
unresolved-callee:Execute nargs=3 hits=0
 arg0=FExampleDelegate/InDelegate typeDecl=<none> resolve=miss
 arg1=void typeDecl=<none> resolve=miss
 arg2=double typeDecl=<none> resolve=miss
native-function-canonical-identity-invalid
native-function-canonical-identity-invalid
```

`nargs=3` includes the receiver.  `hits=0` is lexical lookup evidence and is
not by itself proof that Runtime has no method.  The stronger signal is that
the receiver has neither a Canonical type declaration nor a current Runtime
bridge match.

### 4. The production argument shape reproduces without the production name

Test:

```text
FCanonicalASTSemaAuthorityTests.
PreprocessedObjectDelegateExecuteSeparatesParameterConversionFromProductionIdentity
```

Fixture:

```angelscript
delegate void FCanonicalObjectDelegate_7F2A(
    UObject Object,
    float Value);

void ConsumeCanonicalObjectDelegate_7F2A(
    FCanonicalObjectDelegate_7F2A InDelegate)
{
    InDelegate.Execute(nullptr, 5.4);
    InDelegate.ExecuteIfBound(nullptr, 1.0);
}
```

After correcting an initial test-only name typo, the valid RED is:

```text
Saved/Tests/cta-s109-object-delegate-discriminator-name-fix/
20260830_235225_461_c62eb769
0/1 PASS
```

It reproduces the same receiver failure and one native-identity diagnostic.
This removes the following hypotheses from the primary root:

- the exact `FExampleDelegate` name;
- the surrounding `event` declaration;
- `AExampleEventActor` or its properties/methods;
- the rest of the production example file.

The `UObject + float` delegate signature and the real prepared UE lifecycle
remain in the reproducing shape.  However overload conversion has not yet been
reached because the receiver owner declaration is absent.

### 5. Parser-time inventory is not final-state evidence

`unresolved-callee` diagnostics now enumerate a same-name ClassDecl when
`FindNamedTypeDecl` fails.  The focused rerun reports:

```text
arg0=FCanonicalObjectDelegate_7F2A/InDelegate
 typeDecl=<none>
 authored=0
 implConv=0
 sameNameCount=0
 resolve=miss
```

Evidence:

```text
Saved/Tests/cta-s109-delegate-identity-diagnostic/
20260830_235523_828_cded7ccd
0/1 PASS
```

This diagnostic is emitted by the first parser-time `ActOnCallExpr`, before the
later generated record has been parsed.  `ResolveDeferredNames` retains the
original diagnostic while a retry remains unresolved and only removes it after
a successful bind.  Consequently `sameNameCount=0` describes the initial call
site graph, not the graph at the final deferred retry.  It cannot authenticate
absence of a final ClassDecl or a stable-key mismatch.

### 6. Final-retry probe proves the generated record and methods are present

The diagnostic was tightened again on 2026-08-31 to enumerate the active
Canonical record inventory, not only same-name declarations.  The focused
reproducer reports:

```text
arg0=FCanonicalObjectDelegate_7F2A/InDelegate
 typeDecl=<none>
 authored=0
 implConv=0
 sameNameCount=0
 recordCount=0
 resolve=miss
```

Build evidence:

```text
Saved/Build/cta-s109-delegate-record-inventory-diagnostic-build/
20260831_000017_765_ac2831ff
PASS
```

Expected focused RED:

```text
Saved/Tests/cta-s109-delegate-record-inventory-diagnostic/
20260831_000036_029_45bed9ab
0/1 PASS
```

The `recordCount=0` line above is the same parser-time snapshot and must not be
interpreted as a final inventory.  A temporary probe was instead placed in the
failed branch of `ResolveDeferredNames`, where it observes the current graph.
The rerun reports:

```text
deferred-callee-current:Execute
 records=7
 receiver=FCanonicalObjectDelegate_7F2A
 typeDecl=FCanonicalObjectDelegate_7F2A
 children=15

deferred-callee-current:ExecuteIfBound
 records=7
 receiver=FCanonicalObjectDelegate_7F2A
 typeDecl=FCanonicalObjectDelegate_7F2A
 children=15
```

Evidence:

```text
Saved/Tests/cta-s109-deferred-current-diagnostic-v2/
20260831_000806_425_4d172f62
0/1 PASS (expected RED)
```

This contradicts the earlier lifecycle-break hypothesis.  The generated
delegate record is present at final retry, has the exact receiver type identity
and owns fifteen generated declarations.  The remaining miss is therefore in
candidate viability/ranking or argument conversion, not generated-record input
or publication.

## Corrected current diagnosis

The corrected first missing relation is:

```text
generated ClassDecl and MethodDecl set (present and exact)
        + nullable `nullptr` argument represented as Canonical `void@`
        ↓
standard nullable reference/handle conversion and overload viability
        ↓ currently absent for the reproducing UObject/float delegate shape
deferred authored Execute call resolves to the exact generated MethodDecl
```

> 2026-08-31 correction: the text below supersedes the provisional diagnosis
> from the first CTA-S109 run.  The generated receiver owner is present at the
> final retry, and the focused `UObject + float` object-delegate discriminator
> now passes.  The former receiver-absent conclusion must not be used as a
> current implementation premise.

CTA-S110 added the general nullable-call rule and deliberately kept it narrow:
only a non-reference `REFERENCE_OBJECT` handle can accept the Canonical null
literal.  Reference formals, value objects, template/value pseudo-handles and
primitives remain rejected.  Sema ranking, Verifier authentication and CodeGen
conversion now apply the same predicate.

The remaining production fixture progresses beyond generated `Execute`
resolution and beyond the sealed-graph Verifier.  Its current failure is a
different lifecycle boundary: a by-value `FExampleDelegate` copy construct owns
an exact Canonical constructor declaration, but prepared CodeGen cannot bind
that declaration to one Runtime copy-constructor shell
(`invalid sealed by-value copy transfer`, Canonical ctor `D515`, Runtime `-1`).
The SYSTEM-only native identity publisher remains strict and must not be
relaxed; the next repair belongs in exact generated/script copy-constructor
publication or prepared relocation, not receiver lookup or nullable ranking.

## Safe repair boundary

The next implementation must prove all of the following in one focused gate:

1. The appended generated record header/body continues to produce exactly one
   source-authoritative Canonical owner and final deferred resolution sees it.
2. A Canonical null literal is viable only for nullable handle/reference
   targets, never value objects, primitives or mutable value references.
3. The selected conversion is explicit and verifier-authenticated so CodeGen
   consumes a representation-preserving null conversion without Runtime type
   inference.
4. `IsBound`, `Execute`, `ExecuteIfBound`, `BindUFunction` and the generated
   lifecycle functions remain script declarations with generated provenance.
5. Only actual `asFUNC_SYSTEM` methods enter native identity publication.
6. The authored `Execute` and `ExecuteIfBound` calls resolve to exact generated
   script MethodDecl identities.
7. The sealed graph contains no Runtime pointer, numeric TypeId or persisted
   function id; generation relocation stays stable-key based and Runtime
   coordinates remain generation-local.

Forbidden shortcuts:

- special-casing `Execute`, `FExampleDelegate`, delegate names, `UObject` or
  the `void@` spelling;
- projecting `asFUNC_SCRIPT` as a native method;
- allowing script functions through
  `PublishNativeFunctionDeclarationIdentity`;
- using a diagnostic dump as the compiler hand-off;
- persisting a dynamic TypeId/function id in the Canonical AST or cache.

## Remaining validation after GREEN

After the focused test is green:

1. remove the temporary final-retry diagnostic after the general nullable RED
   has authenticated the root;
2. rerun the exact production delegate test;
3. rerun the SemaAuthority prefix;
4. rerun the staged whole-Engine compile and require `Execute` plus the two
   native-identity diagnostics to disappear without increasing any other
   category;
5. inspect the newly exposed next root before changing unrelated overload
   ranking;
6. update the cumulative whole-Engine inventory and progress review.
