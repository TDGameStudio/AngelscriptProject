# Canonical AOT reverse live-only cleanup proof (2026-08-28)

## Result

CTA-S51 closes the first non-empty Canonical-AST lifetime-proof slice across
both semantic production and TypedASTJIT consumption:

```text
source
  -> Parser typed actions
  -> Canonical Sema lexical lifetime plan
  -> sealed verified Canonical AST
  -> independent structural AOT verifier
  -> pointer-free cleanup classification + transfer-coverage facts
  -> Provider diagnostics / per-function fallback decision
```

The proof is direct from the retained sealed AST. No dump, serialized AST,
bytecode reconstruction, native `asCScriptNode` replay or retired HIR is used
as compiler transport.

This advances Task 7.5 but does not close it. The supported result is a
truthful structural fact for ordinary initialized lexical reference/funcdef
release and exact value-object destructor actions. It does not grant the
scalar-only native emitter an object-frame ABI. Functions outside the proven
native subset continue to fall back per function to BytecodeJIT/VM.

## Semantic bug found before the AOT proof

`AppendLexicalCleanupPlansToTransfers` previously collected every
cleanup-requiring direct declaration in a block and attached the whole reverse
list to every transfer leaving that block. Declaration position was ignored.
The following source was therefore represented incorrectly:

```angelscript
int ProveSourceLifetime(bool Early)
{
    if (Early)
        return 1;
    FJitScopeValue Later;
    return 2;
}
```

The early return received a destructor action for `Later` even though the
declaration had not been crossed and the object could not be constructed. The
cleanup `DeclRef` then participated in lexical resolution before `Later` was
bound, producing `unresolved-identifier:Later` during Seal. This was both an
observable compilation defect and a violation of the live-only/partial-
construction contract.

## Sema correction

The block lifetime pass now walks a stable copy of the original direct child
sequence and maintains an active direct-declaration list:

1. a cleanup-requiring declaration becomes active only after its exact
   `DeclStmt` is crossed;
2. transfers in the current child subtree receive only the active list;
3. that list is appended in reverse declaration order;
4. nested blocks have already added their inner actions, so appending the
   current block actions preserves inner-to-outer order;
5. child IDs are copied before new AST nodes are allocated, avoiding stale
   `asCStmt*` values when arena arrays grow.

The focused source test proves that the early return has no `Later` cleanup,
the later return has exactly one `Later` cleanup, and the resulting graph
seals successfully.

## Independent TypedASTJIT structural proof

`AnalyzeAngelscriptTypedASTJITCanonicalLifetimeFacts` now derives expected
lexical actions from sealed declaration/type facts and independently compares
them with the authored statement tree. It does not trust the presence of a
cleanup literal by itself.

The verifier operates only on snapshot-local integer identities while the
existing generation lease is alive:

- `DeclId` identifies the lifetime target;
- `StmtId` identifies the owning lexical block and transfer target;
- exact Canonical type kind/qualifiers determine whether a local needs
  release or destruction;
- the exact destructor `DeclId` is required for `scope-exit`;
- no AST pointer, Context pointer, numeric Runtime TypeId or snapshot lease is
  copied into Provider facts.

For every ordinary block it proves:

- initialized non-reference direct locals are the only candidates;
- reference-object/funcdef locals require exact `scope-release`;
- value-object non-handle locals require an exact destructor-bound
  `scope-exit`;
- the trailing normal-exit actions exactly equal all cleanup-requiring direct
  locals in reverse declaration order;
- a declaration becomes active only after its `DeclStmt`;
- `return` cleans every active exited scope;
- `break`, `continue` and `fallthrough` clean only active lifetimes whose
  owning block does not contain the exact transfer target;
- action order is the reverse active stack, hence same-scope reverse order and
  inner-to-outer scope order.

A required local with a missing normal or transfer action now publishes
`Unverified` with transfer coverage false. It can no longer masquerade as
`VerifiedEmpty` merely because the malformed graph contains no cleanup node.
Exact non-empty graphs retain `NonEmpty` or `ScriptDestructor` classification
and may publish `bCleanupPlanCoversAllTransfers=true` only after this complete
structural comparison succeeds.

## Conservative boundary

The following remain deliberately fail-closed and keep Task 7.5 open:

- partial construction on exceptional edges;
- compiler exception regions and exception payload/lifetime routing;
- suspend/resume frame liveness;
- standalone loop/foreach phase actions that are not ordinary trailing-block
  or direct-transfer roles;
- dedicated source-level proof fixtures for every targeted transfer shape;
- mutable globals, import slots, call-site fallback and the remaining Provider
  dependency families;
- native object storage, construction-live bits, destructor/release ABI and
  exceptional native-frame cleanup in the TypedASTJIT emitter.

The lifetime-route derivation is currently implemented once in Sema and once
in the independent AOT verifier. Independence is useful because the consumer
does not blindly trust producer metadata, but it creates a drift risk when new
type/lifetime families are added. A later closure should share a versioned
Canonical lifetime protocol or make the AST verifier publish a validated
protocol revision while retaining independent structural checks.

## TDD evidence

### Sema live-only production

The first RED fixture was invalid because it also read `Later.Value` after the
declaration. It is retained for chronology but excluded as authority evidence:

- excluded attempt:
  `Saved/Tests/cta-s51-live-only-transfer-red/20260828_141001_934_35ca1797/RunMetadata.json`

The corrected source returns a scalar constant after the declaration. It
still failed solely with `unresolved-identifier:Later`, proving the forged
early cleanup was the cause:

- registration build: PASS —
  `Saved/Build/cta-s51-live-only-transfer-clean-red-build/20260828_141204_849_89a9a9c6/RunMetadata.json`
- clean RED: **0/1**, exact `unresolved-identifier:Later` —
  `Saved/Tests/cta-s51-live-only-transfer-clean-red/20260828_141429_487_e771bd45/RunMetadata.json`
- GREEN build: PASS —
  `Saved/Build/cta-s51-live-only-transfer-green-build/20260828_141855_800_2eee2cc6/RunMetadata.json`
- focused GREEN: **1/1 PASS** —
  `Saved/Tests/cta-s51-live-only-transfer-green/20260828_141940_342_dd64979d/RunMetadata.json`

### Independent AOT coverage proof

The AST-first fixture contains an early return before a tracked local, a later
return after it, an exact normal-exit action and a second function that omits
required actions:

- registration build: PASS —
  `Saved/Build/cta-s51-aot-lifetime-coverage-red-build/20260828_142756_813_6afa3c3f/RunMetadata.json`
- clean RED: **0/1**, only the expected transfer-coverage assertion failed —
  `Saved/Tests/cta-s51-aot-lifetime-coverage-red/20260828_144253_434_58f98d57/RunMetadata.json`
- GREEN build: PASS —
  `Saved/Build/cta-s51-aot-lifetime-coverage-green-build/20260828_144528_042_72a4f6ea/RunMetadata.json`
- focused GREEN: **1/1 PASS** —
  `Saved/Tests/cta-s51-aot-lifetime-coverage-green/20260828_144544_348_79cea466/RunMetadata.json`

### Real-source cross-layer bridge and regressions

- real CANONICAL source -> retained sealed AST -> AOT lifetime facts build:
  PASS —
  `Saved/Build/cta-s51-source-lifetime-facts-build/20260828_144729_365_6be052c1/RunMetadata.json`
- real-source bridge: **1/1 PASS** —
  `Saved/Tests/cta-s51-source-lifetime-facts/20260828_144757_978_1d22ad50/RunMetadata.json`
- complete CanonicalASTJIT adapter class: **14/14 PASS** —
  `Saved/Tests/cta-s51-canonical-jit-adapter-regression/20260828_144835_167_d4803b96/RunMetadata.json`
- complete SemaAuthority class: **392/392 PASS** —
  `Saved/Tests/cta-s51-sema-authority-regression/20260828_145031_078_fe02e10e/RunMetadata.json`
- complete TypedASTJIT prefix: **43/43 PASS** —
  `Saved/Tests/cta-s51-typed-ast-jit-regression/20260828_145124_060_7419a76c/RunMetadata.json`

Two pre-existing build warnings remain outside CTA-S51: the known C4191 test
function-pointer cast and the adapter fixture's possibly uninitialized
`DividePosition`. Neither became a test failure in this slice.

## Progress impact

No umbrella task row closes, so the mechanical count remains **88/125
(70.4%)**. The weighted implementation estimate advances to **about 79%**.
Action-only Sema is **about 99%**, direct Canonical-AST AOT is **about 61%**,
Canonical Bytecode/Runtime remains **about 74%**, and safe default-CANONICAL
readiness remains **about 50%**. LEGACY remains the product default; the
original native AngelScript AST remains retained; HIR remains physically
deleted.
