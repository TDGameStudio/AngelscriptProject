# CTA-S35: Canonical parameter-default typed-action gate

Date: 2026-08-28

Status: `GREEN`

This card gates removal of `ActOnParameterDefaultFromNode`. Parameter identity,
type, direction and range already cross `asSParameterDeclAction`; the remaining
adapter still asks declaration Sema to inspect a completed `asCScriptNode` and
recover the default expression/text. CTA-S35 moves that final default fact to a
copied pointer-free action without changing the retained native Parser/AST or
the explicit LEGACY compiler path.

## Scope and action contract

Parser must publish one short-lived `asSParameterDefaultAction` containing:

- the exact parameter `asASTDeclId` returned by the typed header action;
- the exact already-published default `asASTExprId`;
- the copied authored default expression text;
- copied half-open begin/end offsets;
- an explicit recovery fact.

The action must contain no `asCScriptNode*`, token-buffer pointer, Engine or
Runtime object pointer, numeric Runtime `typeId`, dump text, HIR object or
durable snapshot-local identity. Parser may use its transient native tree only
to locate the exact previously bound ExprId and copy source facts while it owns
that syntax. Sema owns validation and the durable parameter/default binding.

## Required AST facts

1. A direct action test with no `asCScriptNode` binds the exact ExprId and
   authored text to one parameter.
2. Repeating the identical action is idempotent and does not duplicate the
   parameter init. A different ExprId cannot silently overwrite an already
   bound default.
3. Parser source `int F(int A = 40 + 1)` retains `40 + 1` as authored default
   text and the exact Binary AST expression as the parameter init.
4. The existing call-plan test must continue to synthesize omitted formal
   arguments from the recorded default and preserve reverse-formal order.
5. A malformed default continues to preserve the already-published parameter
   header but fabricates no default init.
6. Parser and public Sema contain no `ActOnParameterDefaultFromNode`; the old
   `InternParamDefaultExpr` helper is physically removed. A renamed generic
   Parser-node adapter is forbidden.

## RED tests

- `SemaParameterDefaultTypedActionOwnsExactExprAndTextWithoutScriptNode`
- `ParserParameterDefaultUsesTypedActionAndExactIdentity`
- strengthen `ParserParameterListUsesTypedActionWithoutParsedNodeTuple` to
  require the typed default action and physical absence of the node adapter.

Expected RED is a compile failure because `asSParameterDefaultAction` and
`asCSema::ActOnParameterDefaultAction` do not yet exist. The pre-existing
source-contract assertion also remains red while the old adapter is present.

## Required GREEN evidence

1. Development Editor build.
2. Focused direct action, Parser action, malformed-default and call-plan tests.
3. Full SemaAuthority.
4. ProductionCodeGen + Canonical Semantics + retained native ScriptNode.
5. Source scans proving the node adapter/helper are absent while native
   `ParseParameterList`, parameter nodes and LEGACY support remain.
6. Strict OpenSpec validation and parent/plugin `git diff --check`.

Every unexpected RED/GREEN issue and any bounded unsupported default-argument
shape will be appended to the final-completion issue log before this card can
be marked green.

## GREEN implementation

`asSParameterDefaultAction` now carries the parameter DeclId, exact already-
published default ExprId, copied authored text, copied half-open source range
and recovery state. `ParseParameterList` publishes that action after parsing
the retained native default subtree. `asCSema::ActOnParameterDefaultAction`
validates all copied source facts before mutation, binds the exact expression,
treats an identical repeat as idempotent, and rejects a conflicting rebind with
`parameter-default-already-bound` without changing the existing AST.

`ActOnParameterDefaultFromNode` and `InternParamDefaultExpr` are physically
absent from production. The retained native `ParseParameterList`, parameter
syntax nodes, Builder, `asCCompiler` and explicit LEGACY path are unchanged.

One bounded implementation fact is important: a simple default such as a
literal does not necessarily receive a transparent root identity from every
Parser wrapper. Parser therefore uses the existing exact-identity walk to find
one and only one distinct action-published expression below the transient
native default node. It neither reconstructs expression semantics nor accepts
ambiguous descendants. This remains a short-lived Parser normalization, not a
Sema node adapter or second durable semantic authority.

## Verified evidence

- expected RED build (typed action/API absent):
  `Saved/Build/cta-s35-parameter-default-action-red/20260828_030212_578_f76fb518/RunMetadata.json`;
- Development Editor GREEN build:
  `Saved/Build/cta-s35-parameter-default-action-build-1/20260828_030308_552_8be50a61/RunMetadata.json`;
- focused direct-action, Parser identity, source-contract, malformed-default
  and call-plan boundary: **5/5 PASS** at
  `Saved/Tests/cta-s35-parameter-default-focused-1/20260828_030345_602_e55d66b8/RunMetadata.json`;
- full SemaAuthority: **369/369 PASS** at
  `Saved/Tests/cta-s35-sema-authority-full/20260828_030901_427_dc0780de/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s35-secondary-gates/20260828_031012_497_2e89fcdd/RunMetadata.json`;
- source scan proves the production old adapter/helper are absent and the new
  action plus retained native `ParseParameterList` are present;
- strict OpenSpec validation and parent/plugin `git diff --check` pass; diff
  checks report only existing LF-to-CRLF conversion warnings.

No umbrella task row is independently complete, so the mechanical total stays
**87/125 (69.6%)**. This small declaration-authority slice does not justify a
rounded weighted/default-readiness increase: the reportable estimates remain
**about 68% overall** and **about 40% safe default-cutover readiness**.
