# CTA-S79 exact expression type-owner gate — 2026-08-30

## Status

This non-Standalone slice removes the remaining known short-declaration-name
fallback from the shared expression-Sema type-owner lookup. It closes a real
namespace-sensitive misbinding across property/member/operator/conversion
families, but does not close the complete 5.2, 5.3, 7.2 or 7.4 umbrellas.

Formal OpenSpec progress remains **102/136 = 75.0%** and the product default
remains LEGACY pending the full cutover matrix.

## Problem

`as_sema_expr.cpp::FindNamedTypeDecl()` maps a Canonical named type to the
class/interface declaration that owns its expression semantics. Its callers
include:

- property getter and setter rewrites;
- member variables and member calls;
- index, unary, binary and assignment operators;
- native method/property/constructor projection;
- implicit-conversion lookup;
- reference-object base convertibility.

The lookup accepted either complete stable-key equality or this fallback:

```text
declaration.name == namedType.stableKey
```

That fallback confused lexical spelling with nominal identity. If the Context
contained `Wrong::FValue`, a receiver whose type key was merely `FValue` could
be attached to the namespaced declaration because both shared the short name
`FValue`. Downstream overload/property logic would then operate consistently
on the wrong owner, making the error difficult to detect after Sema.

## AST-first RED

`ExpressionSemaRejectsUnqualifiedSameNameTypeOwner` constructs:

```text
class declaration: Wrong::FValue
method:            Wrong::FValue::GetValue()
receiver type key: FValue
source operation:  Object.Value
```

Before the fix, `ActOnMemberExpr()` rewrote the operation into a call to
`Wrong::FValue::GetValue()`. The correct fail-closed behavior is to leave the
unresolved access as a member reference; no exact `FValue` declaration exists.

`ExpressionNamedTypeLookupNeverFallsBackToShortDeclarationName` is the
companion source guard. The focused RED was **0/2**: the behavior fixture
observed the wrong call and the source guard found the fallback.

## Resolution

`FindNamedTypeDecl()` now accepts only a class/interface whose non-empty
declaration stable key equals the named type's complete stable key. It no
longer treats `Decl::name` as an identity candidate.

This does not remove AngelScript lexical lookup. Source type names are still
resolved by the normal Sema scope rules when the type is authored. The change
only prevents a later type-to-declaration association from guessing a
different owner by short spelling after the Canonical type key already exists.

All classes/interfaces produced through normal Canonical Sema and native type
projection receive stable keys through `FinishDecl()`. The complete regression
therefore also checks that no legitimate script or native projection depended
on the weaker branch.

## Evidence

| Gate | Result |
| --- | --- |
| RED build | PASS — `Saved/Build/cta-s79-expression-type-owner-red-build/20260830_074842_056_e4d28729` |
| Focused RED | **0/2 expected failures** — `Saved/Tests/cta-s79-expression-type-owner-red/20260830_074909_216_0d1c34b3` |
| GREEN build | PASS — `Saved/Build/cta-s79-expression-type-owner-green-build/20260830_074948_430_e63ee79d` |
| Focused GREEN | **2/2 PASS** — `Saved/Tests/cta-s79-expression-type-owner-green/20260830_075000_372_e6f41f5f` |
| Compiler CanonicalAST + TypedASTJIT | **693/693 PASS** (**639** Compiler + **54** TypedASTJIT) — `Saved/Tests/cta-s79-compiler-typedjit-full-green/20260830_075035_156_cfc38915` |

All recorded green test runs have zero failures and zero skips. UE HTTP
`generate_204` timeout lines in the long run are connectivity-probe warnings,
not automation failures.

## Architectural effect and remaining boundary

Canonical Sema now has one consistent nominal-owner rule for both lifetime
cleanup (CTA-S78) and general expression type association (CTA-S79): complete
stable-key equality. This is closer to the intended Clang-style separation:
lexical lookup resolves source spelling once; typed semantic consumers follow
the resolved declaration/type relation and do not repeat name heuristics.

The following remain separate work:

- native call targets are not yet represented everywhere by one immutable,
  verifier-authenticated Runtime binding relation;
- receiver-bearing TypedASTJIT calls remain safe typed fallback until their
  full evaluation/provenance/ABI contract is implemented;
- uncommon call/language families, exception/suspend, mutable globals/imports
  and Provider dependency closure remain incomplete;
- product-default selection and final focused/All cutover verification remain
  open.

The original AngelScript parser AST and explicit LEGACY pipeline are retained.
Standalone was not modified, built or tested.
