# Canonical explicit-scope resolution gate

Worktree: `D:\as-cta`

Status: bounded explicit-call scope gate GREEN; broader scope/candidate and
Parser-action umbrellas remain open.

Related OpenSpec tasks: `4.3`, `5.3`, `13.2`.

## Source fixture

```angelscript
int Target()
{
	return 42;
}

int Entry()
{
	return Missing::Target();
}
```

## Required sealed semantic facts

1. The explicit `Missing::` qualifier is authoritative. If `Missing` cannot
   be resolved as a namespace/type/base scope, Canonical Sema must not retry
   `Target` from the surrounding function, namespace, or translation unit.
2. The `Target()` call remains an ERROR-typed recovery node with no
   `resolvedDecl`; it must not name the visible global `Target()` declaration.
3. Sema emits a deterministic `unresolved-scope:Missing` diagnostic at the
   qualified call range. A secondary `unresolved-callee:Target` diagnostic is
   not required because the primary failure is the qualifier, not overload
   resolution within a valid scope.
4. An unresolved explicitly qualified call has no Direct/Virtual/Native call
   dispatch and cannot enter deferred unqualified-call reconciliation.
5. Structural sealing may preserve the recovery graph for diagnostics, but
   publication verification and production CodeGen must fail closed. No
   Bytecode, StaticJIT row, publisher, or executable generation may be
   published from the unresolved call.

## TDD sequence

- [x] AST RED: source-to-Parser/Sema test proves the current implementation
      incorrectly binds the global `Target()` or otherwise violates one of the
      facts above.
- [x] AST GREEN: the same test proves exact qualifier failure, empty callee,
      ERROR type, no dispatch, and deterministic diagnostic.
- [x] Publication/CodeGen GREEN: production Canonical build rejects the source
      and preserves the prior generation/publisher.
- [x] Focused regression GREEN: complete SemaAuthority and ProductionCodeGen
      groups pass after the repair.

## Findings and repair

The first RED showed that an unresolved qualifier was replaced by the
translation unit and `Missing::Target()` bound the visible global `Target`.
The initial repair preserved unresolved qualifier segments for deferred
resolution and failed closed instead of retrying an unqualified lookup.

A second fixture exposed a distinct failure mode:

```angelscript
int Target() { return 42; }
namespace Present {}
int Entry() { return Present::Target(); }
```

Here the qualifier resolved correctly, but the member lookup still climbed
from `Present` to its parent and selected the global function. Qualified call
resolution now carries an `exactScope` bit through deferred-call storage,
candidate collection, funcdef-handle lookup, enum conversion lookup and
overload selection. Exact lookup uses only the selected scope; ordinary
unqualified lexical lookup retains its parent walk.

The first post-repair run produced a valuable second RED: the callee remained
unresolved, but the recovery `CallExpr` still advertised `direct` dispatch.
Direct dispatch is now published only after a valid `resolvedDecl` exists, and
deferred reconciliation assigns it only after exact resolution succeeds.

The complete SemaAuthority run then found that a qualifier spelling could be
selected through an unrelated same-name callable/constructor declaration.
Qualifier traversal now accepts only translation-unit, namespace, class,
interface and enum declarations and rejects multiple distinct scope
candidates. This preserves `DispatchBase::Resolve()` without reintroducing
parent fallback for the final member.

## Evidence

- initial test build: PASS at
  `Saved/Build/cta-explicit-scope-test-build/20260827_072340_356_0650268e/RunMetadata.json`;
- unresolved-scope AST RED: **0/1 PASS** at
  `Saved/Tests/cta-explicit-scope-red/20260827_072357_843_955de388/Report/index.json`;
- initial repair build: PASS at
  `Saved/Build/cta-explicit-scope-fix-build/20260827_072807_711_23251dc4/RunMetadata.json`;
- missing/later-qualified focused GREENS: **1/1 PASS** each at
  `Saved/Tests/cta-explicit-scope-green/20260827_072835_325_696cb5f8/Report/index.json` and
  `Saved/Tests/cta-deferred-qualified-scope-green/20260827_073027_614_8152af56/Report/index.json`;
- initial publication rollback GREEN: **1/1 PASS** at
  `Saved/Tests/cta-explicit-scope-publication-green/20260827_073100_056_2859ea6a/Report/index.json`;
- existing-scope/member-miss test build: PASS at
  `Saved/Build/cta-explicit-scope-existing-member-test-build/20260827_074558_312_08510684/RunMetadata.json`;
- existing-scope/member-miss AST and publication REDS: **0/1 PASS** at
  `Saved/Tests/cta-explicit-scope-existing-member-sema-red/20260827_074617_886_a69f2479/Report/index.json` and
  `Saved/Tests/cta-explicit-scope-existing-member-codegen-red/20260827_074650_223_950a8ec9/Report/index.json`;
- exact-member repair build: PASS at
  `Saved/Build/cta-explicit-scope-existing-member-fix-build/20260827_074826_407_934232de/RunMetadata.json`;
- stale-direct-dispatch second RED: **0/1 PASS** at
  `Saved/Tests/cta-explicit-scope-existing-member-sema-green/20260827_074850_676_631a6f9e/Report/index.json`;
- dispatch repair build: PASS at
  `Saved/Build/cta-explicit-scope-dispatch-fix-build/20260827_074939_006_93796a33/RunMetadata.json`;
- focused AST and publication GREENS: **1/1 PASS** each at
  `Saved/Tests/cta-explicit-scope-existing-member-sema-green2/20260827_074950_497_60d9ef33/Report/index.json` and
  `Saved/Tests/cta-explicit-scope-existing-member-codegen-green/20260827_075022_335_19c13fc1/Report/index.json`;
- full-suite qualifier-kind RED: **305/306 PASS** at
  `Saved/Tests/cta-explicit-scope-final-sema-authority-green/20260827_075057_528_8b63a5c0/Report/index.json`;
- qualifier-kind repair build and focused method GREEN: PASS at
  `Saved/Build/cta-qualified-scope-kind-fix-build/20260827_075348_536_b47aece7/RunMetadata.json` and
  **1/1 PASS** at
  `Saved/Tests/cta-qualified-scope-kind-method-green/20260827_075401_996_5bdd8419/Report/index.json`;
- final SemaAuthority: **306/306 PASS** at
  `Saved/Tests/cta-explicit-scope-qualifier-kind-final-green/20260827_075437_411_058b9e43/Report/index.json`;
- final ProductionCodeGen: **113/113 PASS** at
  `Saved/Tests/cta-explicit-scope-qualifier-kind-production-final-green/20260827_075622_157_7850f302/Report/index.json`.

## Non-claims

- This gate does not by itself close the complete scope/candidate matrix,
  Parser action-only migration, or Tasks `4.3`, `5.3`, and `13.2`.
- It does not change AngelScript namespace declaration-order semantics. A
  later-declared valid scope requires its exact qualifier identity to be
  retained for deferred resolution; it must never be approximated by an
  unqualified lookup.
- It does not change the transitional global compiler default or Cache V2
  default-disabled policy.
