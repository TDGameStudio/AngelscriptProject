# CTA-S84 direct Canonical call-argument relation consumption gate — 2026-08-30

## Status

This non-Standalone slice closes a silent argument-placement defect in the
TypedASTJIT Canonical emitter. The emitter now consumes the verifier-authenticated
relation already sealed on every supported direct `CALL` expression:

```text
stored evaluation record Expr.callArguments[evaluationIndex]
    .expression == Expr.children[evaluationIndex]
    .formalIndex -> invocation/formal temporary slot
    .formalType  -> reviewed C++ ABI spelling for that slot
```

The order of `Expr.children`/`Expr.callArguments` remains the evaluation order.
`formalIndex` alone determines final invocation placement. The removed rule was:

```text
formalIndex = childCount - evaluationIndex - 1
```

That positional rule happened to agree with ordinary reverse-formal children,
but it was not the semantic authority and could silently exchange same-typed
values in a verifier-valid reordered relation.

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2 and 7.4 are
umbrella tasks with root-entry formal identity and other call/language families
still open. After this slice, the current engineering estimate is about **92%**
for the requested non-Standalone architecture and about **76%** for a safe
product-default CANONICAL switch. These estimates are not task-completion claims.
The product default remains LEGACY. The original native AngelScript parser AST
remains available. HIR remains physically absent. Standalone was neither changed
nor run.

## Problem

Canonical Sema already owns argument arrangement, including positional, named,
default, hidden/generated and mixin-receiver forms. `ActOnCall` stores expression
children in evaluation order and stores the corresponding `asSASTCallArgument`
records in the same order. Publication verification authenticates, among other
facts:

- one relation record per formal argument;
- record expression equals the child at the same evaluation index;
- exact unique `formalIndex` and direct `ParamDecl` relation;
- exact Canonical `formalType`;
- argument origin, authored name/source ordinal and source range provenance.

TypedASTJIT nevertheless ignored `Expr.callArguments` during C++ emission and
derived the formal slot from reverse child position. With two `int` formals, a
sealed graph such as this remained type-correct while changing program meaning:

| Stored evaluation index | Expression value | Sealed `formalIndex` | Positional guess |
| --- | ---: | ---: | ---: |
| 0 | `2` | 0 | 1 |
| 1 | `1` | 1 | 0 |

The old generated code evaluated `2` into `arg1` and `1` into `arg0`. Because
both arguments were `int`, neither C++ compilation nor ABI type checking exposed
the swap.

## Frozen consumer contract

For the currently supported no-receiver direct-call emission profile:

1. `callDispatch` must be the sealed `DIRECT` disposition. Virtual, indirect
   and receiver-bearing routes remain typed per-function fallback until their
   distinct ABI/evaluation contracts are implemented.
2. `callArguments.count` must equal `children.count`, including the zero/zero
   case before the direct zero-argument fast path.
3. The emitter iterates the stored arrays in evaluation order and requires each
   relation's `expression` to equal the same-index child.
4. `formalIndex` must be in range and unique. A temporary is written directly to
   that formal slot; no reverse-position reconstruction is allowed.
5. The temporary's reviewed C++ ABI spelling comes from sealed `formalType`.
   The operand expression remains the evaluated value and owns any Sema-authored
   conversion expression.
6. Every formal slot must be populated before invocation construction.
7. Missing, mismatched, out-of-range, duplicate or incomplete relations fail
   closed and produce no native expression.

The publication verifier remains the primary graph authenticator. The emitter
checks the relation again at the code-generation boundary so a future caller
cannot accidentally treat malformed/unsealed input as positional authority.

## RED evidence

The regression test was added before production emission changed:

`CanonicalCallEmissionConsumesSealedFormalArgumentRelation`

It constructs two same-typed formals and a verifier-valid relation whose formal
placement differs from reverse-position reconstruction. The initial build
passed, but the focused test failed exactly on the generated value placement:

```cpp
const int32 as_ast_e3_arg1 = int32(2);
const int32 as_ast_e3_arg0 = int32(1);
ASJIT_Helper(Execution, as_ast_e3_arg0, as_ast_e3_arg1)
```

Evidence:

- RED test build: PASS —
  `Saved/Build/cta-s84-call-argument-relation-red-build/20260830_093519_517_2c5b9514`;
- intended focused RED: **0/1**, assertion only —
  `Saved/Tests/cta-s84-call-argument-relation-red/20260830_093547_294_0e60dbcf`.

This is semantic RED evidence: the AST sealed successfully and the emitter
reported success, but it ignored the exact relation and emitted the wrong
same-typed argument placement.

## Resolution map

| Boundary | Implementation |
| --- | --- |
| Sealed call record | `ThirdParty/angelscript/source/as_expr.h` (`callDispatch`, `callArguments`) |
| Sema arrangement | `ThirdParty/angelscript/source/as_sema.cpp`, `as_sema_expr.cpp` |
| Publication authentication | `ThirdParty/angelscript/source/as_ast_verifier.cpp::VerifyPublishedCallArguments` |
| Direct relation consumption and fail-closed guards | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCanonical.cpp` |
| Same-typed adversarial regression | `AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp` |

No HIR adapter, dump input, declaration-name lookup, Runtime pointer relation,
numeric TypeId identity or public Provider ABI field was added.

## GREEN and regression evidence

| Gate | Result |
| --- | --- |
| Incremental Editor build | PASS — `Saved/Build/cta-s84-call-argument-relation-green-build/20260830_093819_238_f003ce44` |
| Exact same-typed reordered relation | **1/1 PASS** — `Saved/Tests/cta-s84-call-argument-relation-green/20260830_093838_921_acbd441a` |
| Complete CanonicalASTJIT adapter class | **26/26 PASS** — `Saved/Tests/cta-s84-canonical-call-adapter-class-green/20260830_093913_550_2d9f188f` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **704/704 PASS**, zero failures/skips — `Saved/Tests/cta-s84-compiler-typedjit-nativebridge-full-green/20260830_093950_277_e6893b00` |
| Removed positional-formula source scan | zero matches for `children.GetLength() - EvaluationIndex - 1` in the TypedASTJIT consumer files |

The broad count increased from **703** to **704** only because this slice adds
one new regression method. The broad run emitted existing HTTP connectivity
warnings while exercising provider reload tests; they did not fail or skip a
test and are not compiler diagnostics.

## Remaining work and non-claims

CTA-S84 closes direct-call argument placement in the current supported
TypedASTJIT emission profile. It does not close all of 7.2 or 7.4:

- typed root wrapper emission still associates the nth `DECL_PARAM` child with
  the nth Runtime parameter slot. This is the next confirmed exact-relation
  issue (CTA-S85): root formals need a sealed ordinal/slot relation so
  same-typed declaration-child reordering cannot redirect input values;
- receiver-bearing calls remain explicit `UnsupportedReceiver` fallback;
- virtual/indirect calls, mutable globals/import slots and the complete import,
  mixin, property, constructor, delegate/funcdef, lambda and cross-TU matrices
  remain incomplete or explicit fallback;
- lifetime/native object-frame/provider-family closure and final default-cutover
  scans/focused/All verification remain open;
- this slice does not switch the default to CANONICAL, archive the change,
  remove explicit LEGACY, remove the original native AngelScript parser AST or
  claim Standalone parity.

