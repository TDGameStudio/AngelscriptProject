# Canonical temporary full-expression Bytecode consumer gate — 2026-09-02

**Status:** GREEN at plugin commit `0816dd4`; the complete Task 5.7/5.8/9.5/
13.6 umbrellas remain open.

## Scope

This card advances Task 0.2 and the consumer half of Tasks 5.7, 9.5 and 13.6.
CTA-S182 already proves that a direct value-object temporary expression
statement publishes one verifier-authenticated
`TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` lifetime record and a derived
full-expression exit plan. This card makes Canonical Bytecode consume that
plan at the owning statement boundary.

The card is intentionally narrower than the remaining Task 5.7 matrix. It
does not claim return-expression temporaries, call/conditional/multiple
temporaries, lifetime extension, returned-object ownership, reference/handle
temporaries, exception unwinding, suspend/resume, globals or TypedASTJIT native
cleanup emission.

## LLVM/Clang architecture reference

The implementation follows the separation used by the local LLVM/Clang
reference rather than deriving cleanup from backend object slots:

- `clang/lib/Sema/SemaStmt.cpp:48-61` finishes an expression statement through
  `ActOnFinishFullExpr` before publishing the statement;
- `clang/lib/Sema/SemaExprCXX.cpp:6509-6699` lets Sema bind the exact temporary
  destructor and collect cleanup responsibility;
- `clang/lib/AST/ByteCode/Compiler.cpp:2913-2918` evaluates
  `ExprWithCleanups` inside a `FullExpression` local scope and destroys that
  scope after the subexpression;
- `clang/lib/AST/ByteCode/Compiler.cpp:3006-3017` still materializes a
  destructed temporary when its value is discarded.

The project-specific mapping remains:

```text
Sema-authored exact temporary/destructor/boundary fact
    -> authenticated asCASTLifetimeView
    -> FULL_EXPRESSION exit plan
    -> backend-local slot and destructor call
```

Bytecode may map the authenticated temporary subject to its own materialized
slot. It may not select the destructor from type metadata, wrapper text or the
function epilogue's generic live-object scan.

## AST-first prerequisite

Owned source test:

```text
AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp
FCanonicalASTSemaAuthorityTests.SourceTemporaryFullExpressionSealsExactLifetimeRecord
```

Source fixture:

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

Already-green sealed facts:

- exact `ExprStmt -> Cleanup -> MaterializeTemporary -> Construct`;
- one exact `TEMPORARY / DESTROY_VALUE / FULL_EXPRESSION` record;
- exact destructor declaration and materialize activation;
- owning ExprStmt semantic region;
- `NORMAL | EXCEPTION` supported routes;
- success-sensitive commit, no lexical scope edge, reverse full-expression
  exit plan;
- verifier negatives for missing/foreign destructor, wrong constructor owner,
  cleanup-wrapper type mismatch and partial reference-object disguise.

The authoritative prior evidence is recorded in
`canonical-temporary-full-expression-lifetime-gate-2026-09-02.md`.

## Production RED

Test source:

```text
Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/
AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp
```

Exact method:

```text
CanonicalDirectTemporaryDestroysAtFullExpressionBoundary
```

Fixture:

```angelscript
int DestructionTrace = 0;

struct FTracked
{
    int Id;

    FTracked(int InId)
    {
        Id = InId;
    }

    ~FTracked()
    {
        DestructionTrace = DestructionTrace * 10 + Id;
    }
}

int Entry()
{
    DestructionTrace = 0;
    FTracked(7);
    return DestructionTrace;
}
```

Expected result is `7`. A backend that leaves the materialized object live
until the generic function epilogue returns `0` and only then destroys it. The
fixture therefore distinguishes the full-expression boundary from eventual
function cleanup; a mere one-destructor final count cannot produce a false
green.

The test also requires:

- Canonical publisher provenance;
- zero LEGACY compiler invocations;
- the retained snapshot still contains the exact full-expression plan;
- the global trace remains `7` after execution, proving one destruction and
  excluding a later duplicate epilogue destruction.

## Required production behavior

1. `EmitStmt(ExprStmt)` evaluates the expression first.
2. It looks up only
   `FindExitPlan(stmt, asAST_LIFETIME_EXIT_PLAN_FULL_EXPRESSION)`.
3. For each authenticated record, it maps the subject Materialize Expr to the
   already-created backend-local materialized slot.
4. It calls the exact action target already stored in the record.
5. It marks the slot uninitialized/dead so the generic epilogue cannot destroy
   it twice.
6. Missing slot, wrong subject class/kind, wrong action, wrong Runtime owner or
   unavailable exact destructor fails before successful artifact publication.

The backend must not branch on `Cleanup.literal`, scan destructor names, read
dump text, choose `beh.destruct`, or author a new lifetime fact.

## RED/GREEN log

- Build before the semantic RED: PASS at
  `Saved/Build/cta-s183-direct-temp-codegen-red3-fixture/`
  `20260902_040905_524_e8ba95ae`.
- Authentic semantic RED: **0/1 FAIL** at
  `Saved/Tests/cta-s183-direct-temp-codegen-semantic-red/`
  `20260902_040948_183_ffc4b446`. The retained snapshot, lifetime record and
  full-expression exit-plan assertions passed first; execution then returned
  `0` instead of `7`, proving the backend delayed the exact destructor until
  the generic function epilogue.
- Production GREEN build: PASS at
  `Saved/Build/cta-s183-direct-temp-codegen-green/`
  `20260902_041145_634_87fe466a`.
- Focused semantic GREEN: **1/1 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s183-direct-temp-codegen-green/`
  `20260902_041203_747_21ba57b3`.
- Complete ProductionCodeGen owner: **235/235 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s183-production-owner/`
  `20260902_041245_215_3023a927`.
- AST Body Sidecar regression owner: **27/27 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s183-sidecar-regression/`
  `20260902_041831_991_3b5f70e1`.
- SemaAuthority regression owner: **567/567 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s183-sema-regression/`
  `20260902_041910_961_d98a4de2`.
- Frontend Verifier regression owner: **80/80 PASS**, zero failures/skips, at
  `Saved/Tests/cta-s183-verifier-regression/`
  `20260902_042045_841_93a07ffa`.

## Non-claims

- No durable protocol/revision change.
- No claim that a Return statement is currently a full-expression owner.
- No returned-value-object ownership or copy-elision contract.
- No general lifetime-extension contract or extending-owner field.
- No exception-unwind or suspend-frame implementation.
- No TypedASTJIT native object-frame cleanup; its existing authenticated
  summary/precise-fallback boundary remains unchanged.
- Cache V2/V12 product restore remains user-deferred and non-gating. AST Body
  Sidecar remains an in-scope regression owner.
