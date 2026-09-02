# Canonical explicit-scope DeclRef gate

Worktree: `D:\as-cta`

Status: bounded explicit `DeclRef` scope gate GREEN; broader scope/candidate
and Parser-action umbrellas remain open.

Related OpenSpec tasks: `4.3`, `5.3`, `13.2`.

## Source fixtures

Missing scope:

```angelscript
int Value = 42;

int Entry()
{
	return Missing::Value;
}
```

Later valid scope:

```angelscript
int Value = 1;

int Entry()
{
	return Later::Value;
}

namespace Later
{
	int Value = 42;
}
```

## Required sealed semantic facts

1. An explicit qualifier is authoritative for variable references exactly as
   it is for calls. `Missing::Value` must not retry the visible global
   `Value` through lexical lookup.
2. While `Missing` remains unresolved, Canonical Sema retains one ERROR-typed
   `DeclRef` recovery node with no `resolvedDecl`, the literal `Value`, and a
   deterministic `unresolved-scope:Missing` diagnostic.
3. Structural sealing may retain that recovery graph, but publication
   verification and production CodeGen fail closed. A failed replacement must
   preserve the complete prior executable/snapshot/publisher generation.
4. If the exact qualifier is declared later, deferred reconciliation resolves
   only `Later::Value`; it must never approximate the reference with the
   earlier global `Value`.
5. Deferred state stores copied qualifier segments, absolute-scope intent,
   source range, identifier and AST IDs. It does not retain Parser nodes or
   Engine-local numeric type identity as durable semantic truth.

## TDD sequence

- [x] AST RED: prove `Missing::Value` currently binds global `Value`.
- [x] AST RED: prove `Later::Value` currently loses the exact qualifier and
      binds global `Value` before the namespace is parsed.
- [x] AST GREEN: missing scope stays ERROR/unbound with exactly one
      `unresolved-scope` diagnostic.
- [x] AST GREEN: later valid scope resolves exactly `Later::Value` and removes
      the recovery diagnostic.
- [x] Publication/CodeGen GREEN: unresolved qualified `DeclRef` rejects a
      replacement and preserves the previous generation.
- [x] Focused regression GREEN: complete SemaAuthority and ProductionCodeGen
      groups pass.

## Findings and repair

Both RED fixtures lost the qualifier and reused the unqualified/global
declaration. Canonical Sema now materializes an unbound ERROR-typed recovery
`DeclRef`, copies the qualifier segments and absolute-scope intent into
snapshot-owned deferred state, and retries only exact lookup after later
declarations become available. A permanently missing qualifier retains one
deterministic diagnostic; a later valid qualifier resolves only its own child
declaration and clears the recovery diagnostic.

The production replacement fixture proves that an unresolved qualified
reference cannot publish partial CodeGen state and that the prior generation,
publisher and executable result remain current.

## Evidence

- test build: PASS at
  `Saved/Build/cta-explicit-scope-declref-test-build/20260827_073543_083_1284d100/RunMetadata.json`;
- missing-scope and later-scope AST REDS: **0/1 PASS** each at
  `Saved/Tests/cta-explicit-scope-declref-missing-red/20260827_073600_238_e0ba0ee6/Report/index.json` and
  `Saved/Tests/cta-explicit-scope-declref-later-red/20260827_073632_935_83d68e14/Report/index.json`;
- repair build: PASS at
  `Saved/Build/cta-explicit-scope-declref-fix-build/20260827_073900_942_e1cc5738/RunMetadata.json`;
- production rollback test build: PASS at
  `Saved/Build/cta-explicit-scope-declref-codegen-test-build/20260827_074110_785_32da9d0c/RunMetadata.json`;
- focused missing-scope and later-scope AST GREENS: **1/1 PASS** each at
  `Saved/Tests/cta-explicit-scope-declref-missing-green/20260827_073926_356_412a364c/Report/index.json` and
  `Saved/Tests/cta-explicit-scope-declref-later-green/20260827_073958_876_4c34cc99/Report/index.json`;
- focused publication rollback GREEN: **1/1 PASS** at
  `Saved/Tests/cta-explicit-scope-declref-codegen-green/20260827_074127_303_4980f1b0/Report/index.json`;
- complete SemaAuthority after the DeclRef repair: **305/305 PASS** at
  `Saved/Tests/cta-explicit-scope-declref-sema-authority-green/20260827_074202_840_e4813450/Report/index.json`;
- complete ProductionCodeGen after the DeclRef repair: **113/113 PASS** at
  `Saved/Tests/cta-explicit-scope-declref-production-codegen-green/20260827_074350_654_8b270f56/Report/index.json`;
- final scope-family regressions after the related call/qualifier-kind repair:
  SemaAuthority **306/306 PASS** and ProductionCodeGen **113/113 PASS** at
  `Saved/Tests/cta-explicit-scope-qualifier-kind-final-green/20260827_075437_411_058b9e43/Report/index.json` and
  `Saved/Tests/cta-explicit-scope-qualifier-kind-production-final-green/20260827_075622_157_7850f302/Report/index.json`.

## Non-claims

- This gate does not close the complete scope/candidate matrix or the broad
  Parser action/Sema authority umbrellas.
- It does not change unqualified forward-reference semantics or add a generic
  deferred-name facility for every declaration kind.
- It does not change the LEGACY compiler default or Cache V2 default-disabled
  policy.
