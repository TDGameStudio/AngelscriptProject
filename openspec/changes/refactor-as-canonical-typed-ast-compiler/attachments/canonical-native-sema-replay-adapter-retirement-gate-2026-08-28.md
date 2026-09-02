# Canonical native Sema replay-adapter retirement gate — 2026-08-28

## Outcome

CTA-S43 physically retires the completed-native-node expression and statement
semantic replay boundary from CANONICAL Sema. The following six entry points
are absent from production Parser/Sema source:

- `ActOnExprFromNode`;
- `InternParsedExprTerm`;
- `ActOnStmtFromNode`;
- `InternParsedChildStmt`;
- `InternParsedCompoundStmt`;
- `ActOnParsedStmt`.

This is a physical source boundary rather than a runtime mode check. A later
change cannot accidentally call one of these generic adapters because their
declarations and implementations no longer exist.

The native AngelScript AST is intentionally retained. `asCParser` still owns
`CreateNode`, still builds `asCScriptNode`, and the explicit LEGACY compiler
may continue to consume that tree. The retained native tree remains available
for syntax, recovery, reference and differential testing. CTA-S43 removes only
its former role as a completed expression/statement semantic replay input to
CANONICAL Sema.

## Architecture now implemented

```text
native Parser
  +-- still creates asCScriptNode for syntax/recovery/LEGACY/reference
  +-- submits copied, pointer-free typed actions while parsing
          |
          v
CANONICAL Sema
  +-- owns type/conversion/overload/control/lifetime decisions
  +-- returns exact Canonical DeclId/ExprId/StmtId identities
          |
          v
Parser-local construction state
  +-- carries exact returned identities into parent typed actions
          |
          v
sealed and verified Canonical AST
```

Before CTA-S43, all migrated primary expression and statement paths already
used typed actions, but generic completed-node adapters remained compiled as a
large dormant compatibility surface. CTA-S43 deletes that surface and makes
the intended boundary testable by source-contract tests.

## Physical-retirement contract

The new test
`CanonicalSemaPhysicallyRetiresNativeExpressionAndStatementReplayAdapters`
checks both sides of the architecture:

1. native Parser source must still contain `asCScriptNode *asCParser::` and
   `CreateNode(`;
2. Canonical Sema source must contain none of the six retired replay adapter
   names.

Several older source-contract tests previously extracted the body of a named
adapter and searched only that slice. Once the method disappeared, an empty or
clamped slice could pass without proving physical retirement. Those tests now
assert the whole adapter entry point is absent instead.

## TDD and verification evidence

- first test-authoring build exposed incorrect CQTest matcher-message
  placement (C4002), before the semantic RED could run:
  `Saved/Build/cta-s43-native-sema-adapter-retirement-red-build/20260828_064602_525_8eca3f21/RunMetadata.json`;
- corrected RED-test build **PASS**:
  `Saved/Build/cta-s43-native-sema-adapter-retirement-red-build-2/20260828_064632_986_5d42ec61/RunMetadata.json`;
- expected physical-boundary RED **0/1**, proving the test detected the still
  present adapters:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-red/20260828_064723_976_1cae12bc/RunMetadata.json`;
- production deletion build **PASS**:
  `Saved/Build/cta-s43-native-sema-adapter-retirement-build-1/20260828_065355_408_77350d7c/RunMetadata.json`;
- focused physical/source-contract set **6/6 PASS**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-focused-1/20260828_065458_996_93afe3da/RunMetadata.json`;
- strengthened source-contract build **PASS**:
  `Saved/Build/cta-s43-native-sema-adapter-retirement-build-2/20260828_065750_525_c959acb7/RunMetadata.json`;
- first complete SemaAuthority run **392/393**, exposing one obsolete test
  assumption rather than a product semantic regression:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-sema-authority-full-1/20260828_065809_660_92cd3b40/RunMetadata.json`;
- repaired source-contract build and exact-test recheck **1/1 PASS**:
  `Saved/Build/cta-s43-native-sema-adapter-retirement-build-3/20260828_065916_945_9b6e5f68/RunMetadata.json`,
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-repaired-source-contract-1/20260828_065937_772_bff9fdfe/RunMetadata.json`;
- final complete SemaAuthority **393/393 PASS**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-sema-authority-full-2/20260828_070010_099_8112d571/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode
  downstream gate **158/158 PASS**:
  `Saved/Tests/cta-s43-native-sema-adapter-retirement-secondary-gates/20260828_070052_050_b4d2b424/RunMetadata.json`;
- strict OpenSpec validation and parent/plugin `git diff --check` pass; diff
  checks report only existing LF-to-CRLF conversion warnings.

## Problems found and decisions

1. **The first failure was test-authoring, not semantic RED.** CQTest accepts
   the diagnostic message through the matcher rather than as an extra
   `ASSERT_THAT` macro argument. The C4002 build is retained as evidence, but
   the corrected 0/1 source-contract run is the actual expected RED.
2. **Method-slice source tests can become false green when a method is
   deleted.** The affected tests now check whole-source absence of the retired
   entry point. This converts a fragile implementation-detail slice into a
   durable architecture boundary.
3. **One old test expected a diagnostic owned only by the retired adapter.**
   `ParserLocalLoopVariableFamiliesUseTypedActionsWithoutDeclarationReplay`
   expected `local-declaration-action-missing`. Since that text existed only
   in `ActOnParsedStmt`, physical deletion correctly removed it. The test now
   verifies that neither the adapter nor that obsolete route exists.
4. **This does not prove every temporary native-node identity bridge is gone.**
   Declaration/type/scope construction still contains build-time
   `asCScriptNode *` identity and lexical helpers such as parsed declaration,
   expression-type and scope-owner lookup. They are not completed
   expression/statement semantic replay, but they require a separate audit
   before whole-Sema action-only authority can be called 100%.

## Progress and remaining boundary

No `tasks.md` umbrella row closes because lifetime/cleanup, uncommon
declaration/type/scope construction, detached backend breadth, direct
TypedASTJIT/AOT consumption and production cutover remain open. Mechanical
progress therefore remains **87/125 (69.6%)**.

The dependency/risk-weighted implementation estimate advances to **about
75%**. Safe production default-cutover readiness is **about 48%**. Whole-Sema
Parser-to-Sema action-only authority remains conservatively **about 98%**:
the generic completed expression/statement replay boundary is physically
closed, but residual declaration/type/scope node-identity bridges and explicit
lifetime/cleanup closure prevent a 100% claim.

The next critical slice is explicit materialization/lifetime/cleanup authority,
in parallel with a bounded audit of the remaining declaration/type/scope
identity bridges. It is followed by detached Canonical CodeGen/runtime
metadata breadth and direct Canonical-AST TypedASTJIT/AOT visitors. The
compiler default remains LEGACY.
