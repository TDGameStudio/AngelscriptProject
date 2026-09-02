# Canonical reverse-operator family matrix gate (CTA-S173)

## Scope and outcome

CTA-S173 replaces the single `opAdd_r` example with a family-complete
characterization of every reverse binary operator name used by the maintained
LEGACY compiler. The matrix is structural and executable: each authored
`primitive op Object` expression must be a sealed rhs-receiver `Call`, and the
same source must execute through Canonical CodeGen with no LEGACY compiler
invocation.

All twelve forms passed without a production edit. This proves that the shared
Canonical binary-operator path already implements the complete reverse-name
mapping; the missing piece was evidence, not behavior.

The formal OpenSpec count remains **107/136 complete (78.7%)**. Task 5.3 stays
`[ ]`: the acceptance audit performed after the matrix found that the deleted
`TypedSemanticIR/CallRewrites/CompileOut` oracle has not yet been recreated on
the Canonical path. The detailed historical-oracle audit is in
`reviews/task-5.3-call-oracle-closure-audit-2026-09-01.md`.

## Exhaustive legacy-name inventory

The source-of-truth scan of `as_compiler.cpp` found these twelve non-comparison
reverse method names:

| Operator | Required method | Authored fixture |
|---|---|---|
| `+` | `opAdd_r` | `1 + Object` |
| `-` | `opSub_r` | `2 - Object` |
| `*` | `opMul_r` | `3 * Object` |
| `/` | `opDiv_r` | `4 / Object` |
| `%` | `opMod_r` | `5 % Object` |
| `**` | `opPow_r` | `6 ** Object` |
| `\|` | `opOr_r` | `7 \| Object` |
| `&` | `opAnd_r` | `8 & Object` |
| `^` | `opXor_r` | `9 ^ Object` |
| `<<` | `opShl_r` | `10 << Object` |
| `>>` | `opShr_r` | `11 >> Object` |
| `>>>` | `opUShr_r` | `12 >>> Object` |

The test deliberately uses non-commutative spellings and a unique sentinel
return from each method. It cannot pass by treating the operators as a
commutative `opAdd_r` special case.

## AST-first gate

Test source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTReverseOperatorMatrixTests.cpp`

Exact method:

`FCanonicalASTSemaReverseOperatorMatrixTests::AllLegacyReverseOperatorNamesSealExactRhsReceiverCalls`

For every row the test authenticates:

- one exact `asAST_EXPR_CALL` to the expected stable declaration key;
- direct dispatch;
- rhs `Object` as the effective receiver;
- the authored primitive lhs as the only positional argument;
- exact formal declaration `Value`, formal index `0`, and child/argument
  expression identity;
- result type `int`;
- no leftover `Binary` whose operand still has type `T`;
- Canonical CodeGen publisher and zero LEGACY compiler invocations.

Characterization evidence:

- build: `Saved/Build/cta-sema-call-53-reverse-matrix-characterization/`
  `20260901_144937_383_654a9ba1`, **PASS**;
- exact Sema matrix:
  `Saved/Tests/cta-sema-call-53-reverse-matrix-characterization/`
  `20260901_145015_984_640531a7`, **1/1 PASS immediately**.

Because the AST-first test passed on the first valid run, there is no authentic
RED and no production change. That is a valid characterization result: the
card records a formerly unproved family-completeness invariant rather than
inventing an implementation delta.

## Production execution gate

Exact method:

`FCanonicalASTProductionReverseOperatorMatrixTests::AllLegacyReverseOperatorNamesExecuteWithoutLegacyCompiler`

`Entry()` adds the twelve unique method sentinels and must return `78`. The
test also requires `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN` and legacy
invocation count `0`.

Evidence:

- `Saved/Tests/cta-sema-call-53-reverse-matrix-execute/`
  `20260901_145059_838_84d11a36`, **1/1 PASS immediately**,
  `Entry() == 78`.

## Acceptance audit and non-claims

CTA-S173 closes the reverse-operator family-completeness item from the
CTA-S172 inventory. It does not close Task 5.3 by itself.

The post-matrix audit resolved the literal `TypedSemanticIR/Call*` reference
against the last tree before HIR deletion (`ed22fbdf`) and found seven test
methods under `CallMetadata`, `CallRewrites`, `CallTargets`, and
`EvaluationOrder/Calls`. Hidden arguments, ordinary/constructor order, stable
callee/body representation, and the implemented import route have Canonical
equivalents. Native ABI-specific fields are intentionally split to Task 7.4's
immutable Runtime binding snapshot. The compile-out rewrite oracle is still a
real 5.3 gap: its three dispositions occur only in the LEGACY compiler today.
The exact bind/rebind/unbind import-target immutability oracle also needs a
focused Canonical characterization before final 5.3 acceptance.

Therefore this card makes no Task 5.3, 7.4, or 13.2 completion claim.
