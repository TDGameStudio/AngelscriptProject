# CTA-S-29 unary-expression typed-action gate (2026-08-28)

## Status

**Resolved and verified for pure prefix/postfix unary terms.** The pointer-free
Sema action, exact unary interning repair, Parser action construction/binding,
and identity-only native-node boundary are implemented. Member/index/call
postfix chains remain explicitly outside this slice, so no parent umbrella
task is checked by CTA-S-29 alone.

The retained native `snExprTerm`/`snExprPreOp`/`snExprPostOp` shape is
intentional. It remains syntax/recovery and explicit-LEGACY input. The missing
work is to stop using that shape as the CANONICAL semantic input for pure
prefix/postfix unary expressions.

## Scope and contract

The dedicated action is `asSUnaryExprAction`. It owns, without Parser-node
pointers:

- one exact operand `asASTExprId`;
- ordered prefix operators, each with token kind and owned spelling;
- ordered postfix operators, each with token kind and owned spelling;
- one copied half-open source range.

Sema applies postfix operators in source order and then prefixes in reverse
source order. For `-~Value++`, the expected graph is:

```text
UnaryExpr("-")
  UnaryExpr("~")
    UnaryExpr("post++")
      DeclRefExpr("Value")
```

This slice deliberately covers pure unary `EXPRTERM` only. Member, index and
call postfix chains remain assigned to their own typed actions; mixed
call/member/index/unary terms must not be misreported as closed here.

## AST-first RED/GREEN evidence

### RED 1: action contract absent

The direct Sema test was added before the production API. The build failed on
the missing `asSUnaryExprAction`, `asSUnaryExprOperatorAction` and
`ActOnUnaryExprAction` symbols:

`Saved/Build/cta-s29-unary-action-red/20260827_235602_654_0e2e9b86/RunMetadata.json`

Result: build exit 1 (`ProcessExitCode` 6).

### RED 2: range-only unary reuse aliased the chain

After adding the action API, the focused behavioral gate failed because all
three action stages shared the complete term range and the old unary interning
path reused the first expression found at that range. The expected outer `-`
root was therefore not retained:

`Saved/Tests/cta-s29-unary-action-behavior-red2/20260827_235820_275_d4255cda/RunMetadata.json`

Result: **1 total, 0 passed, 1 failed, 0 skipped**.

The repair replaces range-only reuse with exact reuse:

- built-in unary reuse requires range, canonical operator and exact child;
- overloaded unary-call reuse requires range, exact callee, exact receiver
  and exact child;
- lookup occurs after operator canonicalization/type resolution;
- synthetic/file-zero expressions do not gain accidental range reuse.

Build evidence after this repair:

`Saved/Build/cta-s29-unary-exact-intern-green-build/20260828_000016_306_cea1f2aa/RunMetadata.json`

Result: build exit 0.

Focused direct-action evidence:

`Saved/Tests/cta-s29-unary-action-green/20260828_000032_682_c7bc5915/Summary.json`

Result: **1 total, 1 passed, 0 failed, 0 skipped**.

### RED 3: Parser still used generic native-node replay

The Parser fixture parses:

```angelscript
int Entry(int Value) { return -~Value++; }
```

The runtime AST identity, unary nesting, operator spelling, operand identity,
source range and retained native syntax shape already match. The permanent
architecture assertion still fails because `ParseExprTerm` does not contain a
`BindUnaryExprAction` route and instead reaches generic
`ActOnParsedExpr(node, script)` replay:

`Saved/Tests/cta-s29-parser-unary-action-red/20260828_000216_429_be0b74ac/Summary.json`

Result: **1 total, 0 passed, 1 failed, 0 skipped**. The sole reported failure
is:

`ParseExprTerm must publish pure unary terms through the dedicated typed action`

This was a valid architectural RED. Generic replay could manufacture the same
visible unary graph, so AST shape alone would have been a false green.

An earlier command labeled `cta-s29-unary-action-behavior-red` matched no
tests because the full CQTest class path was omitted. It is explicitly not
RED evidence.

### Parser and broad GREEN

Parser now classifies complete expression terms into three routes:

- no composite action for a transparent primary-only term;
- `asSUnaryExprAction` for prefix operators plus postfix `++`/`--`;
- the retained structural adapter for member/index/postfix-call chains until
  those families receive their own ordered actions.

The unary builder requires exactly one already-bound primary identity, prefix
operators before it, and postfix `++`/`--` after it. It copies token kind,
owned spelling and the complete term range, calls `ActOnUnaryExprAction`, and
binds the returned exact parent to the retained `snExprTerm`. Eligible
recovery paths attempt the same action and fail closed when the exact operand
is absent; they do not replay the native unary syntax.

`InternParsedExprTerm` now recognizes pure unary syntax and accepts only the
exact Parser binding. This closes both `ActOnParsedExpr` and
`ActOnExprFromNode` entry routes without affecting structural postfix terms.

Build:

`Saved/Build/cta-s29-parser-unary-action-green-build/20260828_001258_995_0e6e30a5/RunMetadata.json`

Result: exit 0, five incremental actions succeeded.

Parser exact/action fixture:

`Saved/Tests/cta-s29-parser-unary-action-green/20260828_001314_589_9770049b/Summary.json`

Result: **1 total, 1 passed, 0 failed, 0 skipped**.

Complete SemaAuthority:

`Saved/Tests/cta-s29-sema-authority-green/20260828_001432_857_ac57d779/Summary.json`

Result: **355 total, 355 passed, 0 failed, 0 skipped**.

Production CodeGen:

`Saved/Tests/cta-s29-production-codegen-green/20260828_001355_983_e7e7bdb3/Summary.json`

Result: **114 total, 114 passed, 0 failed, 0 skipped**.

Canonical Semantics:

`Saved/Tests/cta-s29-canonical-semantics-green/20260828_001512_656_46f5b200/Summary.json`

Result: **12 total, 12 passed, 0 failed, 0 skipped**.

Retained native ScriptNode shape/range:

`Saved/Tests/cta-s29-native-scriptnode-green/20260828_001547_116_3576db07/Summary.json`

Result: **32 total, 32 passed, 0 failed, 0 skipped**.

An attempted concurrent launch let ProductionCodeGen acquire the worktree
runner lock and rejected the other three starts with `Another build or test
command is already running for this worktree`. Those rejected starts produced
no test evidence and are not failures. The three groups were rerun
sequentially at the paths above.

## Current implementation boundary

Implemented and verified:

- pointer-free unary action records in `as_sema.h`;
- action validation and ordered unary construction in `as_sema_expr.cpp`;
- exact child/operator-aware unary and overloaded-unary-call interning;
- Parser classification, action construction and exact parent binding;
- pure-unary identity-only handling in `InternParsedExprTerm`;
- permanent direct Sema and Parser architecture fixtures;
- retained native AngelScript syntax tree unchanged.

The next expression-term work is not part of CTA-S-29: cast/construct and
ordered call/member/index actions, including mixed structural-postfix unary
chains and their single-evaluation semantics.

## Issue record

### CTA-S29-I1 — range-only unary interning lost nested operators

**Status:** Resolved and focused-green.

Several nested unary nodes legitimately share a complete expression-term
range. Range and node kind are therefore not a semantic identity. Reuse now
also requires exact operator/callee/receiver/child identity as applicable.

### CTA-S29-I2 — generic replay hides the missing Parser action

**Status:** Resolved and verified.

`ActOnParsedExpr` could replay the retained native node and create a graph that
looked correct even though the Parser never crossed the typed action boundary.
Parser now calls `BindUnaryExprAction`, and `InternParsedExprTerm` accepts pure
unary terms only by exact binding. The source-boundary assertion is retained
until generic expression replay is physically absent from all completed
CANONICAL expression families.

## Progress and non-claims

- `tasks.md` remains **87/125 complete (69.6%)**.
- Weighted engineering progress remains **about 66%**.
- Default-CANONICAL readiness remains **about 38%**.
- Parser generic `ActOnParsedExpr` call count is now **9**, reduced from 10.
- This slice does not complete Tasks 4.2, 5.2, 5.4, 10.3, 10.6 or 13.2.
- It does not cover cast/construct/call/member/index, statement/control/body,
  default/initializer/lifetime, detached backend/AOT completion, or the final
  default cutover.
