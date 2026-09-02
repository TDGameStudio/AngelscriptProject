# CTA-S78 exact lifetime-author owner gate — 2026-08-30

## Status

This non-Standalone slice closes an exact-identity mismatch between Canonical
lifetime verification and three Sema lifetime authors. It does not close the
7.5 umbrella: native object-frame ABI, exception/suspend facts, mutable
globals/imports, call-site fallback and remaining Provider dependency families
still require explicit lowering or typed per-function fallback.

Formal OpenSpec progress remains **102/136 = 75.0%**. The product default also
remains LEGACY pending the complete cutover matrix.

## Problem

CTA-S75 had already made the publication verifier require the destructor
declaration owner's complete Canonical stable key to equal the cleaned value
type's stable key. Three Sema producer helpers still used a weaker condition:

```text
owner.stableKey == valueType.stableKey
    OR
owner.name == valueType.stableKey
```

The second branch was unsafe for an unqualified value-type key. For example,
the value type `FValue` could select the destructor owned by
`Wrong::FValue`, because that class's short name was also `FValue`. Sema could
then author a forged lifetime record and compatibility `scope-exit` cleanup.
The verifier would reject the completed graph later, but the producer and
consumer did not share one exact nominal-identity rule.

The affected authors were:

- `FindValueTypeDestructor()` in `as_sema_decl.cpp`;
- `FindAggregateElementDestructor()` in `as_sema_expr.cpp`;
- `FindLexicalValueDestructor()` in `as_sema_stmt.cpp`.

`as_sema_lifetime.cpp::ActOnCleanup()` was already exact and required no
production change.

## AST-first RED

`LexicalLifetimeAuthoringRejectsUnqualifiedSameNameDestructorOwner` constructs
the adversarial graph directly:

```text
value type key:       FValue
available class key:  Wrong::FValue
available short name: FValue
```

It then runs the typed block-statement Sema action. Before the fix, Sema
selected the wrong destructor, authored one lifetime record and emitted a
`scope-exit` cleanup. The companion source guard
`LifetimeAuthorsNeverFallbackFromStableOwnerKeyToUnqualifiedName` prevents the
same fallback from returning in any of the four lifetime-author source files.

The focused RED was **0/2**, with the behavior fixture observing the forged
lifetime record and the source guard identifying the stale producer code.

## Resolution

All three authors now accept a destructor only when:

```text
destructor.owner.stableKey == cleaned.valueType.stableKey
```

No short-name fallback remains in the lifetime-author boundary. An unresolved
or incompletely qualified value type therefore authors no destructor lifetime
record; later stages cannot infer or repair ownership from spelling.

This matches the intended Clang-like model: Sema resolves one exact declaration
relation, the sealed graph authenticates it, and later consumers use that
relation mechanically. Names remain diagnostic/source data, not a substitute
for nominal identity.

## Evidence

| Gate | Result |
| --- | --- |
| RED build | PASS — `Saved/Build/cta-s78-lifetime-author-exact-owner-red-build/20260830_074209_696_145935bc` |
| Focused RED | **0/2 expected failures** — `Saved/Tests/cta-s78-lifetime-author-exact-owner-red/20260830_074239_165_12c29ab1` |
| GREEN build | PASS — `Saved/Build/cta-s78-lifetime-author-exact-owner-green-build/20260830_074321_832_bbfd4f9e` |
| Focused GREEN | **2/2 PASS** — `Saved/Tests/cta-s78-lifetime-author-exact-owner-green/20260830_074337_726_471d7dfc` |
| Compiler CanonicalAST + TypedASTJIT | **691/691 PASS** (**637** Compiler + **54** TypedASTJIT) — `Saved/Tests/cta-s78-compiler-typedjit-full-green/20260830_074415_835_c95c28be` |

All recorded green test runs have zero failures and zero skips.

## Architectural effect and remaining boundary

The lifetime path now has one consistent ownership rule across authoring,
publication verification and authenticated backend consumption. This removes
one class of namespace-sensitive cleanup corruption without deleting the
original AngelScript parser AST or changing explicit LEGACY behavior.

At the CTA-S78 checkpoint this slice did not claim that every Canonical type
lookup was exact: the broader expression-Sema `FindNamedTypeDecl()` helper
still contained a stable-key-or-short-name lookup. That follow-up is now closed
by CTA-S79 with its own adversarial and full Compiler/TypedASTJIT gates; see
`attachments/cta-s79-exact-expression-type-owner-gate-2026-08-30.md`.
Native target binding and Runtime type projection remain separate exact-
relation work.

Standalone was not modified, built or tested.
