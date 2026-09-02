# Canonical temporary full-expression lifetime gate — 2026-09-02

## Scope

CTA-S182 advances Task 5.7 with the first still-missing source lifetime family:
a non-trivial value temporary whose destruction point is the end of its full
expression.  This card is AST-first.  It does not count the existing
`Cleanup(MaterializeTemporary(Construct))` execution shape as lifetime
authority until Sema publishes and the shared verifier authenticates the exact
record.

## LLVM / Clang architecture reference

The design follows the local LLVM 22.1.8 reference rather than introducing a
backend cleanup scan:

- `Reference/llvm-project/clang/lib/Sema/SemaExprCXX.cpp`:
  `MaybeBindToTemporary` resolves the exact destructor and marks the current
  expression-evaluation context as needing cleanup; `ActOnFinishFullExpr`
  closes that context through `MaybeCreateExprWithCleanups`.
- `Reference/llvm-project/clang/lib/Sema/SemaStmt.cpp`:
  expression statements and return expressions call `ActOnFinishFullExpr` at
  their source-owned full-expression boundary.
- `Reference/llvm-project/clang/include/clang/AST/ExprCXX.h`:
  `ExprWithCleanups` is a typed full-expression wrapper.  Physical cleanup
  blocks remain CodeGen state.

The AngelScript mapping is therefore: `ActOnMaterializeTemporary` retains the
typed expression identity; the Sema statement action that owns the completed
full expression authors subject/action/activation/region facts; the shared
lifetime verifier derives committed-live and reverse cleanup facts.  Bytecode
and TypedASTJIT must not select a destructor by type/name or infer a lifetime by
walking an unverified expression tree.

## Source fixture and owner

- Test source:
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
- Exact method:
  `FCanonicalASTSemaAuthorityTests.SourceTemporaryFullExpressionSealsExactLifetimeRecord`
- Owning prefix:
  `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`

```angelscript
struct FTracked
{
    int Value = 41;
}

void Entry()
{
    FTracked();
}
```

## Required sealed facts

Before CodeGen the retained Canonical snapshot must prove:

1. exact `Cleanup(MaterializeTemporary(Construct(FTracked)))` and exact
   generated `FTracked::~FTracked()`;
2. exactly one `TEMPORARY` lifetime record whose subject is the materialize
   Expr rather than a fabricated local Decl;
3. `DESTROY_VALUE` with that exact destructor declaration;
4. activation at the materialization commit, after the child construction can
   no longer fail;
5. semantic region equal to the actual source ExprStmt and phase
   `FULL_EXPRESSION`;
6. supported routes `NORMAL | EXCEPTION`;
7. the shared view exposes an empty `liveBefore` / `abortCleanup` for the
   current construction and a one-record `liveAfter` /
   `reverseLiveCleanup` after successful materialization.

## Authentic RED

- The first Return-expression probe produced focused RED **0/1 FAIL** at
  `Saved/Tests/cta-s182-temporary-lifetime-authentic-red/`
  `20260902_024554_030_23b03955`: the source-built sealed AST contained
  Materialize Expr `7`, Cleanup Expr `8`, and exact `FTracked::~FTracked()`
  Decl `9`, but zero `TEMPORARY` lifetime records.
- The authoritative constructor-only build passed at
  `Saved/Build/cta-s182-temporary-exprstmt-red/`
  `20260902_025023_308_d0cd24ba`; the exact source test then failed **0/1** at
  `Saved/Tests/cta-s182-temporary-exprstmt-red/`
  `20260902_025052_561_53d30def`.  The retained AST had the exact
  `ExprStmt -> Cleanup -> MaterializeTemporary -> Construct` and destructor,
  but no `TEMPORARY` lifetime record.  This is the authoritative RED for the
  implemented slice.
- After the first Sema authoring step, the new shared-view positive and forged
  negative tests produced a second authentic RED: Frontend Verifier passed
  **70/72** at `Saved/Tests/cta-s182-temporary-verifier-red/`
  `20260902_025652_371_015d9da7`.  The missing capabilities were the derived
  full-expression exit plan and bidirectional rejection when a supported
  cleanup/materialize shape had no Sema-authored lifetime record.

An earlier runner invocation omitted the CQTest class segment and matched zero
tests.  It is discovery noise and is deliberately not counted as RED evidence.

## Implemented production boundary

1. Sema owns `ActOnFinishFullExpression` and calls it only after a real,
   non-recovered expression statement has an owning Stmt identity.  Legal
   empty expression statements such as the first `;` in `for (; Cond; )` are
   not full expressions and bypass the hook.
2. The first deliberately narrow source family recognizes exactly
   `Cleanup("cleanup", MaterializeTemporary(Construct))`, authenticates the
   already-resolved value type and destructor owner, and authors one exact
   pointer-free `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record.  It does
   not perform a backend tree scan or unqualified destructor lookup.
3. The shared lifetime verifier authenticates the record in both directions:
   malformed records fail, and a supported source shape without its Sema
   record also fails.  Full-expression records do not fabricate a lexical
   scope edge.
4. The transient lifetime view derives a distinct `FULL_EXPRESSION` exit plan
   plus success-sensitive commit point.  No serialized protocol revision was
   needed because the exact subject/action/activation/region/phase/exit fields
   already existed; the exit-plan kind is derived state.
5. Forged tests reject a foreign destructor and an activation at the Construct
   rather than the Materialize identity.  The missing-record case proves that
   the compatibility Cleanup wrapper cannot remain hidden lifetime authority.

## Verified GREEN and regression finding

- Build after the shared verifier/view implementation: PASS at
  `Saved/Build/cta-s182-temporary-verifier-green/`
  `20260902_025840_578_02f06a79`.
- Frontend Verifier: **72/72 PASS** at
  `Saved/Tests/cta-s182-temporary-verifier-green/`
  `20260902_030136_946_255af567`.
- Exact source fixture: **1/1 PASS** at
  `Saved/Tests/cta-s182-temporary-source-green2/`
  `20260902_030256_317_99a64fcd`.
- The first complete SemaAuthority run was **545/547**, not accepted as GREEN,
  at `Saved/Tests/cta-s182-temporary-semaauthority-green/`
  `20260902_030330_899_0e55ce6f`.  Both failures shared one root cause: the
  full-expression hook rejected the legal empty initialization statement in
  `for (; Cond; )`.  The minimal repair gated the hook on a valid expression.
  The two exact regressions then passed **1/1** each at
  `Saved/Tests/cta-s182-empty-forcond-green/`
  `20260902_030645_958_7dd6277e` and
  `Saved/Tests/cta-s182-empty-unbraced-green/`
  `20260902_030718_385_7122d5b5`.
- Final complete SemaAuthority: **547/547 PASS** at
  `Saved/Tests/cta-s182-temporary-semaauthority-green2/`
  `20260902_030752_662_bbad2f95`.
- Existing ProductionCodeGen temporary execution now directly asserts both
  the Canonical publisher and zero LEGACY compiler invocations; it passes
  **1/1** at `Saved/Tests/cta-s182-production-temp-green/`
  `20260902_031015_847_477b7e6c`.

## Read-only review corrections and final checkpoint

The first read-only subagent review did not approve the initial GREEN. It found
one Critical and two Important publication-firewall defects:

1. a boolean supported-shape probe conflated a non-candidate with a malformed
   direct value temporary, so a missing/foreign destructor plus missing record
   could evade the bidirectional completeness gate;
2. the inner Construct owner/type was not authenticated against the
   materialized value;
3. the Cleanup wrapper type was not authenticated against Materialize.

Each became an explicit verifier RED before the repair:

- missing lifetime authority: **0/1 FAIL** at
  `Saved/Tests/cta-s182-malformed-temporary-red/`
  `20260902_032009_631_6070f4a0`;
- foreign constructed object: **0/1 FAIL** at
  `Saved/Tests/cta-s182-construct-owner-red/`
  `20260902_032243_567_6f0b4ada`;
- mismatched Cleanup wrapper type: **0/1 FAIL** at
  `Saved/Tests/cta-s182-cleanup-type-red/`
  `20260902_032505_154_7f6b1ec6`.

The repaired verifier uses `NOT_CANDIDATE / MALFORMED / VALID`. Once an exact
direct value-object constructor-temporary family is entered, missing or wrong
destructor, Construct, wrapper or type facts are `MALFORMED` and fail before
publication. The source authority test was also isolated to direct
Builder/Parser/Sema/`Seal()` rather than full `Module->Build()`, and every
`AddLifetimeRecord()` used by a forged fixture is asserted successful.

A fresh complete SemaAuthority run then exposed a separate **566/567**
regression at `Saved/Tests/cta-s182-review-fixes-sema-final/`
`20260902_032923_100_1029a0ee`:
`ClassTemporaryConstructInternsReferenceObjectNotValueObject`. The hardened
value-only classifier had treated a legal `class C { } ... C();` temporary as
malformed. The final boundary excludes only a coherent
`REFERENCE_OBJECT + HANDLE + AUTO_HANDLE` constructor temporary whose
Cleanup/Materialize/Construct types, XValue category, constructor kind, class
owner and stable key all agree. A partially forged value temporary remains
malformed. The source test now additionally asserts that the class temporary
publishes zero `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` records.

Final committed plugin checkpoint: `41cafb7`
(`[CanonicalAST] Refactor: author temporary full-expression lifetime`).

| Final gate | Result | Evidence |
|---|---:|---|
| Runtime/Editor build | PASS | `Saved/Build/cta-s182-reference-boundary-final/20260902_033534_942_1e2dbb2e` |
| Frontend Verifier | **80/80 PASS** | `Saved/Tests/cta-s182-verifier-final/20260902_033609_637_0e812273` |
| SemaAuthority | **567/567 PASS** | `Saved/Tests/cta-s182-sema-final/20260902_033609_637_f01926f7` |
| Production temporary | **1/1 PASS** | `Saved/Tests/cta-s182-production-final/20260902_033707_375_9a2b3619` |
| AST Body Sidecar | **27/27 PASS** | `Saved/Tests/cta-s182-sidecar-final/20260902_033707_375_b689e880` |

The final independent read-only review found no Critical or Important issue
and returned **Ready to commit**. Remaining non-blocking notes are the duplicate
coherent-reference predicate in Sema and verifier, a diagnostic token whose
name mentions only the destructor although the branch validates more facts,
and the exact-statement replay path that may need an idempotent finish hook if
recovered-action replay becomes supported.

No lifetime-record schema/revision bump was required. The record uses existing
typed fields, and `FULL_EXPRESSION` was appended only to the transient derived
exit-plan enum. AST Body Sidecar remains in scope and passed; the separately
deferred Cache V2/V12 product restore redesign was not reopened.

## Non-claims

This card does not close Task 5.7.  Lifetime extension, non-POD deferred/out and
`&inout`, reference-return aliases, globals, source delegating construction,
suspend boundaries, and their supported abort/exception routes remain separate
cards.  Multiple temporaries in one full expression, call-result temporaries,
conditional evaluation and Return-owned full expressions also remain open.
This slice proves AST/Sema/verifier authority; it does not claim runtime
destruction parity for the newly recorded ExprStmt shape.  Full protocol-only
Bytecode and TypedASTJIT consumption belongs to Tasks 9.5 and 7.5.
