# CTA-S184a — Typed full-expression temporary gate

## Scope and owner rows

This AST-first card advances Tasks `0.2`, `5.8`, `7.5` and the reopened
subplan boundary in `15.8`. It implements one missing TypedASTJIT consumer
route for the already-authenticated CTA-S182/CTA-S183 direct
constructor-temporary family; closure remains validation-open until the
generated-provider workflow is green. It does not close the broad umbrella
rows by itself.

The source family is exactly one direct value-object constructor temporary in
an expression statement:

```angelscript
int DestructionTrace = 0;

struct FJitFullExpressionTracked
{
    int Id;

    FJitFullExpressionTracked(int InId)
    {
        Id = InId;
    }

    ~FJitFullExpressionTracked()
    {
        DestructionTrace = DestructionTrace * 10 + Id;
    }
}

int ProveSourceFullExpressionLifetime()
{
    DestructionTrace = 0;
    FJitFullExpressionTracked(7);
    return DestructionTrace;
}
```

This card does not add native object-frame execution. It authenticates the
pointer-free typed summary and requires an exact per-function
`UnsupportedLifetime` disposition rather than misclassifying a legal protocol
as `InvalidCleanupPlan`.

## Existing sealed/public AST authority

CTA-S182 already proves the source path in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` method
`SourceTemporaryFullExpressionSealsExactLifetimeRecord`. The source must
retain exactly one record and plan:

```text
subjectKind       = TEMPORARY
subject           = MaterializeTemporary ExprId
actionKind        = DESTROY_VALUE
actionTarget      = exact FJitFullExpressionTracked destructor DeclId
activationPoint   = the same MaterializeTemporary ExprId
semanticRegion    = the owning ExprStmt
phase             = FULL_EXPRESSION
supportedExitMask = NORMAL | EXCEPTION
exit plan kind    = FULL_EXPRESSION
```

The shared view must also prove the materialize commit, no fabricated lexical
scope edge, and a plan containing only that record. This card consumes those
facts; it must not recover a destructor from spelling, Cleanup literal, type
family or backend storage.

## RED 1 — source Typed lifetime facts and fallback

Test source:

```text
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/
CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp
```

Exact method:

```text
SourceTemporaryFullExpressionPublishesAuthenticatedTypedFallback
```

Before asserting Typed facts, the test must independently confirm that the
retained source snapshot and authenticated lifetime view already contain the
single exact temporary record and `FULL_EXPRESSION` plan above. This isolates
the missing Typed consumer from Sema or verifier retention mistakes.

Required GREEN typed facts:

```text
CleanupPlanState                  = ScriptDestructor
LifetimeSummary authenticated     = true
ProtocolRevision                  = asAST_LIFETIME_PROTOCOL_REVISION
StableKey / ABIKey                = nonzero and deterministic
RecordCount                       = 1
ExitPlanCount                     = 1
ActionFlags                       = DestroyValue
ExitPlanFlags                     = FullExpression (0x08)
SupportedExitMask                 = NORMAL | EXCEPTION
bNativeObjectFrameABIAvailable    = false
bHasExceptionCleanup              = true
bHasSuspendState                  = false
bCleanupPlanCoversAllTransfers    = true
```

Eligibility and emission must both fail only this function with:

```text
Reason = UnsupportedLifetime
Detail contains AuthenticatedFullExpressionTemporaryRequiresNativeObjectFrameABI
```

Current expected RED is a default/unverified zero summary followed by:

```text
Reason = InvalidCleanupPlan
Detail = CanonicalLifetimeProtocolAuthenticationFailed:
         the exact function has no complete authenticated lifetime summary.
```

## RED 2 — provider diagnostics grammar and forgery firewall

Test source:

```text
Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/Diagnostics/
AngelscriptStaticJITAotInstalledDiagnosticsTests.cpp
```

Exact method:

```text
FullExpressionLifetimeDiagnosticRequiresAuthenticatedPlanShape
```

A provider diagnostic row with these fields must validate:

```text
CanonicalASTState               = Verified
CleanupPlanState                = ScriptDestructor
LifetimeProtocolRevision        = 1
LifetimeStableKey / ABIKey      = nonzero
LifetimeActionFlags             = DestroyValue (0x01)
LifetimeExitPlanFlags           = FullExpression (0x08)
LifetimeSupportedExitMask       = NORMAL | EXCEPTION (0x21)
LifetimeRecordCount             = 1
LifetimeExitPlanCount           = 1
bNativeObjectFrameABIAvailable  = 0
```

The following independent forgeries must return
`InvalidDiagnosticString` at semantic row zero:

1. unknown plan bit `0x10` in addition to `0x08`;
2. FullExpression flag with zero plan count;
3. FullExpression flag with zero record count;
4. `CleanupPlanState=Unverified` with otherwise authenticated fields.

Current expected RED is rejection of the positive row because the provider
manifest accepts plan flags only through `0x07`.

## Typed identity and schema contract

The implementation must:

- add `FullExpression = 1u << 3` to the typed exit-plan flags;
- accept `asAST_LIFETIME_EXIT_PLAN_FULL_EXPRESSION` in the canonical summary;
- accept only `SUBJECT_TEMPORARY` whose subject is the sealed
  `MATERIALIZE_TEMPORARY` expression and whose exact action target is its
  authenticated value-class destructor;
- write the materialized stable type, qualifiers and value-class layout plus
  exact destructor identity into the lifetime ABI key;
- include typed exit-plan flags and plan count in the ABI key so different
  cleanup-plan families cannot alias;
- advance the internal lifetime ABI hash domain when its payload changes;
- keep StableKey deterministic and pointer/Engine-ID/snapshot-ID free;
- expand provider diagnostic valid plan flags from `0x07` to `0x0f`;
- advance provider diagnostics schema revision from 2 to 3 so older catalogs
  fail closed.

`FAngelscriptJITProviderAbi::Revision` remains 8 because no Provider entry
layout, execution ABI or artifact admission structure changes. The provider
diagnostics schema is a separate diagnostic catalog contract.

## LLVM/Clang design anchors

- `Reference/llvm-project/clang/lib/Sema/SemaStmt.cpp:3716-3738` completes
  return conversion before `ActOnFinishFullExpr`.
- `Reference/llvm-project/clang/lib/Sema/SemaExprCXX.cpp:6611-6699` binds the
  exact destructor and creates expression cleanup ownership in Sema.
- `Reference/llvm-project/clang/lib/CodeGen/CGStmt.cpp:1636-1729` keeps
  full-expression cleanup separate from outer lexical cleanup.
- `Reference/llvm-project/clang/lib/AST/ByteCode/Compiler.cpp:2913-2917`
  models `ExprWithCleanups` with an explicit full-expression scope.

The AngelScript summary therefore authenticates the Sema-owned plan and
publishes a precise unsupported-backend disposition. It must not manufacture
a partial native cleanup plan in Provider or AOT.

## Validation record

- Source Typed summary RED: **0/1 expected FAIL** at
  `Saved/Tests/cta-s184a-source-typed-red2/`
  `20260902_044639_481_314d263b`.
- Source Typed summary GREEN: **1/1 PASS** at
  `Saved/Tests/cta-s184a-source-typed-green/`
  `20260902_045612_706_394644b3`.
- Focused implementation build: **PASS** at
  `Saved/Build/cta-s184a-typed-full-expression-green-build/`
  `20260902_045533_832_733384fd`.
- Installed-provider diagnostic/forgery GREEN: **1/1 PASS** at
  `Saved/Tests/cta-s184a-provider-diagnostic-green/`
  `20260902_045646_986_362473b2`.
- StaticJIT Generate remains blocked by the existing CTA-S184a generation
  blocker. The exact Complete-composition oracle is **0/1 expected FAIL** at
  `Saved/Tests/cta-s184a-complete-fixture-dependency-red/`
  `20260902_052413_511_370e5778`; its containing build passed at
  `Saved/Build/cta-s184a-complete-fixture-dependency-red-build/`
  `20260902_052346_566_c7fd05fd`.
- Exact missing dependency: `FString(const FString&inout)`, owner `FString`,
  stable key
  `5dd2e37454d592763ad2d32ca5788dc8ad3b050821c766703d27811006302af6`.
  The function artifact carries the copy-constructor relocation, while the
  compiled function lacks the pointer-exact `SIGNATURE/FUNCTION` compiler
  dependency.
- The exact oracle refines the already-recorded Generate blocker; it is not a
  second blocker. `SemanticScalarBranch` missing from the provider probe is a
  cascade from the module skip, not a second TypedASTJIT semantic failure.
- Generated-source build, Verify, generated diagnostic transport and owner
  prefixes have not run because Generate is red. Task 15.8 remains unchecked.
- Detailed review and durable issue identity:
  `reviews/current-overall-progress-2026-09-02-0530.md` and
  `reviews/semantic-correctness-issue-ledger-2026-09-01.md`
  (`CTA-S184a-DEP`).

## Latest publication-chain supersession — 2026-09-02 06:20 CST

The preceding validation record is retained as historical RED evidence. The
new authoritative official run is:

    Tools\RunStaticJITTests.ps1 -Mode All

| Gate | Current result | Evidence |
|---|---:|---|
| baseline build | **PASS** | `Saved/Build/staticjit-testjit_01_baseline_build/20260902_060226_109_50ed870c` |
| Generate | **PASS** | `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_02_generate/20260902_060255_390_335efd81` |
| generated-source build | **PASS** | `Saved/Build/staticjit-testjit_03_generated_build/20260902_060709_047_68c9ea62` |
| Verify | **PASS** | `Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit_04_verify/20260902_060711_464_5f72657e` |
| StaticJIT owner prefix | **FAIL / CRASH-ABORTED** | `Saved/Tests/staticjit-testjit_05_tests/20260902_061127_197_1776782f` |

Generate preserved `Candidates=7 Captured=7 Skipped=0`, reported all owned
outputs unchanged and published Provider diagnostic schema revision 3. The
generated-source build and Verify both returned zero.

The owner prefix found 405 tests, completed 39 Success and three Fail, then
crashed the next started test; the remaining 362 did not complete. The four
observed findings are:

1. stale command-diagnostic expectation for schema revision 1 instead of 3;
2. opt-in Cache V2 restore failure, retained as deferred/non-gating per the
   explicit scope decision;
3. a recurring 1-versus-61 differential mismatch whose leading scope is the
   fresh-interpreter session/oracle authenticity;
4. an authentic native access violation in the generated object-lifetime
   route, where the copy-constructor operand treats `&v_TEMP_11` as an
   `FString` instead of consuming the `FString*` stored in `v_TEMP_11`.

The Cache prototype does not independently block this card. The differential
oracle blocker, generated-code crash and incomplete owner matrix do. Task
15.8 therefore remains unchecked. Detailed assessment:
`reviews/current-overall-progress-2026-09-02-0620.md`.
