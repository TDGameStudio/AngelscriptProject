# CTA-S-28 — binary-expression typed action gate

Date: 2026-08-27

Status: implemented and verified for the complete flat `snExpression`
composite. This advances open Tasks 4.2, 5.2 and 13.2; it does not complete
any of them and does not authorize the default-pipeline switch.

## Scope and invariant

Before this slice, `ParseExpression()` produced the native flat sequence

```text
term, operator, term, operator, term, ...
```

and the generic `ActOnParsedExpr(asCScriptNode*, ...)` path rediscovered the
operator sequence, precedence and logical-vs-binary node kind from
`snExpression`. That made the retained native AngelScript AST a CANONICAL
semantic input instead of an independent LEGACY/reference/recovery tree.

After this slice:

1. Parser retains the complete native `snExpression` and its alternating child
   layout for explicit LEGACY compilation, syntax recovery, differential
   reference and rollback.
2. Parser constructs pointer-free `asSBinaryExprAction` from already-bound
   exact operand `ExprId`s, copied operator token kinds/spellings and the
   complete half-open source range.
3. Sema validates the payload, owns precedence/associativity folding, selects
   logical versus ordinary binary construction, performs the existing
   overload/conversion/type rules, and returns one exact composite `ExprId`.
4. Parser binds that returned identity to the native node. The complete
   `snExpression` cases in both Sema adapters are identity-only and fail closed
   with `binary-expression-action-missing`; they no longer decode operators or
   rebuild a tree.
5. `ParseExpression()` contains `BindBinaryExprAction(...)` and no
   `ActOnParsedExpr(...)`. The maintained Parser still contains ten generic
   expression callbacks for other, not-yet-migrated expression families.

The native AngelScript Parser/AST/Builder/Compiler remain intentionally
present. HIR remains physically retired. No dump, HIR replay, fact merge,
fallback or `dual` backend was introduced.

## Action contract

`asSBinaryExprAction` owns:

- ordered exact operand `asASTExprId` values;
- one `asSBinaryExprOperatorAction` between each adjacent operand;
- every operator's tokenizer kind and copied source spelling;
- the complete expression's half-open source offsets.

Sema rejects an invalid source/range, fewer than two operands, a non-
alternating operand/operator cardinality, missing operand identities, unknown
operator tokens, and token/spelling disagreement. Text aliases `and`, `or`
and `xor` are accepted only with their matching token kind and normalize to
the Canonical spellings `&&`, `||` and `^^`.

The precedence table is the maintained fork's existing semantic order:

| From highest to lowest | Operators |
| --- | --- |
| power | `**` |
| multiplicative | `*`, `/`, `%` |
| additive | `+`, `-` |
| shifts | `<<`, `>>`, `>>>` |
| bitwise | `&`, `^`, `|` |
| relational | `<=`, `<`, `>=`, `>` |
| equality / identity / logical xor | `==`, `!=`, `is`, `!is`, `^^` |
| logical and | `&&` / `and` |
| logical or | `||` / `or` |

The two-stack fold preserves the old left-associative equal-precedence rule.
This slice intentionally matches the maintained AngelScript fork rather than
inventing C++/Clang operator semantics.

## Permanent tests

Source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Methods:

1. `SemaBinaryExprActionOwnsOrderedOperandsOperatorsAndPrecedenceWithoutScriptNode`
   calls the action directly for `1 + 2 * 3` and proves the root is `+`, its
   right child is `*`, operand identity/order is exact, and the complete source
   range is retained without passing an `asCScriptNode` to Sema.
2. `ParserBinaryExprActionBindsExactPrecedenceRootWithoutNodeReplay` parses a
   real function and proves both sides of the migration boundary: the native
   `snExpression` still has five flat children, while its bound Canonical root
   is the exact precedence tree. It also isolates the `ParseExpression()`
   implementation and requires the dedicated action while forbidding the
   generic node callback.

## RED evidence

The action contract did not exist:

- build RED:
  `Saved/Build/cta-s28-binary-action-red/20260827_231901_382_1e38604c/RunMetadata.json`;
- expected missing declarations were `asSBinaryExprAction`,
  `asSBinaryExprOperatorAction`, and `ActOnBinaryExprAction`.

After adding only the action API/Sema implementation, the direct action was
GREEN but the Parser architecture gate remained RED:

- API build:
  `Saved/Build/cta-s28-binary-action-api-green-build/20260827_232051_918_dc5cf0b8/RunMetadata.json`;
- direct action **1/1 PASS**:
  `Saved/Tests/cta-s28-binary-action-api-green/20260827_232120_515_6d96933c/RunMetadata.json`;
- Parser action **0/1 expected FAIL**:
  `Saved/Tests/cta-s28-parser-binary-action-red/20260827_232155_329_30dc0f50/RunMetadata.json`.

The Parser RED is architecturally important: generic native-node replay had
already produced an exact-looking precedence tree. An AST-shape assertion
alone therefore could not prove the dedicated Parser action existed. The
permanent source-boundary assertion prevents that false green; see
CTA-S28-I1 in the issue log.

## GREEN evidence

- Parser action build PASS:
  `Saved/Build/cta-s28-parser-binary-action-green-build/20260827_232433_171_ace2cdeb/RunMetadata.json`;
- exact Parser/action gate **1/1 PASS**:
  `Saved/Tests/cta-s28-parser-binary-action-green/20260827_232448_872_add69b2a/RunMetadata.json`;
- initial complete SemaAuthority **352/352 PASS**:
  `Saved/Tests/cta-s28-sema-authority-green/20260827_232521_756_6cf42dbf/RunMetadata.json`;
- complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-s28-production-codegen-green/20260827_232602_755_bd2e6b12/RunMetadata.json`;
- complete Canonical Semantics **12/12 PASS**:
  `Saved/Tests/cta-s28-binary-semantics-green/20260827_232823_945_077bfc5c/RunMetadata.json`;
- focused native ScriptNode shape **14/14 PASS**:
  `Saved/Tests/cta-s28-binary-scriptnode-green/20260827_232858_711_af0f4042/RunMetadata.json`;
- complete native ScriptNode **32/32 PASS**:
  `Saved/Tests/cta-s28-binary-scriptnode-full-green/20260827_233007_557_62e448c5/RunMetadata.json`.

Static boundary scan after the GREEN implementation:

- `ParseExpression()` has two recovery/success calls to
  `BindBinaryExprAction(...)` and zero calls to `ActOnParsedExpr(...)`;
- Parser-wide generic `ActOnParsedExpr(...)` call sites fall from **12** to
  **10**;
- native `CreateNode(snExpression)` remains present;
- the old `SemaExprPrecedence` native-node replay helper is absent;
- complete `snExpression` Sema cases report
  `binary-expression-action-missing` when exact binding is absent.

## Review issue and residual risk

CTA-S28-I1 is resolved by the permanent Parser source-boundary assertion.

CTA-S28-I2 was then reproduced and resolved. The first probe began at source
offset zero, where interning deliberately does not reuse nodes, and passed;
that run is not RED evidence. Moving the action to nonzero offset produced the
real **0/1 FAIL** because the outer `1 + 2 + 3` fold aliased the inner `1 + 2`.
Binary reuse now happens after conversion normalization and requires exact
left/right child identities in addition to kind/range/operator. This preserves
idempotent replay without collapsing distinct nested folds.

- valid same-operator RED **0/1**:
  `Saved/Tests/cta-s28-i2-same-operator-red2/20260827_234052_056_a01151d3/RunMetadata.json`;
- repair build PASS:
  `Saved/Build/cta-s28-i2-same-operator-green-build/20260827_234151_111_a6698340/RunMetadata.json`;
- focused GREEN **1/1**:
  `Saved/Tests/cta-s28-i2-same-operator-green/20260827_234205_882_dcfdfb1b/RunMetadata.json`;
- final complete SemaAuthority **353/353**:
  `Saved/Tests/cta-s28-i2-sema-authority-green/20260827_234240_435_58468881/RunMetadata.json`;
- final ProductionCodeGen **114/114**:
  `Saved/Tests/cta-s28-i2-production-codegen-green/20260827_234321_804_a1b941cf/RunMetadata.json`;
- final Canonical Semantics **12/12**:
  `Saved/Tests/cta-s28-i2-semantics-green/20260827_234400_070_9d2115e9/RunMetadata.json`.

## Non-claims and next boundary

This slice does not claim:

- unary/prefix/postfix expression-term action authority;
- member, index, call, cast/construct or init-list action authority;
- default argument, property initializer, statement, control, body or cleanup
  action authority;
- full Builder-shell separation or complete-language detached CodeGen/AOT;
- Task 4.2, 5.2, 5.4, 10.6 or 13.2 completion;
- readiness to change the product default from LEGACY to CANONICAL.

The next expression migration boundary is CTA-S-29: split the remaining
`snExprTerm` prefix/postfix/value routes into explicit actions, beginning with
unary/prefix/postfix semantics and keeping member/index/call identity exact.
