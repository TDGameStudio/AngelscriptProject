# ProjectGeneration.Engine progress（2026-08-26）

Latest full group after the VALUE-`this` lvalue-address slice:

`Saved/Tests/cta-generation-after-value-this-lvalue/20260826_175409_830_d7ed69a1`

**30/32 PASS, 2/32 FAIL** (was 12/32 through the CodeGen fail-closed march).

## Closed generation tokens this session

| Token | Gate |
| --- | --- |
| `unclassified value-object call argument` / `sealedFormal=const ?&` | `canonical-wildcard-value-arg-address-gate-2026-08-26.md` |
| `unsupported lvalue address` / `kind=22 literal=this` | `canonical-value-this-lvalue-address-gate-2026-08-26.md` |

The `this` slice unblocked generated `BindUFunction(..., __DelegateSignature(this))`, which is why the group jumped instead of staying at 12/32 with a new common CodeGen token.

## Remaining two failures

These are **not** `Canonical staged CodeGen failed` tokens:

1. `FoldedGlobalKeepsStableHardValueDependencyThroughTypedASTEmission`  
   Cache V2 / snapshot freeze: no `HardValue` semantic-dependency row survives freeze. Previously hidden behind compile failure.

2. `LiteralAssetRolesUseAuthoritativePostInitPairs`  
   Sema `unresolved-callee:__CreateLiteralAsset` in the isolated generation fixture. Previously hidden behind `BindUFunction` CodeGen failure.

Do **not** check OpenSpec tasks `10.2` / `10.5` / `10.6` / `12.4` from this report. Default CANONICAL is unchanged. HIR / `asCScriptNode` remain.
