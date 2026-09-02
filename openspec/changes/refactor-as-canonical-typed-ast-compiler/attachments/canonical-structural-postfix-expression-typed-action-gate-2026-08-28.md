# CTA-S33 structural postfix expression typed-action gate (2026-08-28)

## Scope

This card advances the remaining structural `EXPRTERM` Parser-to-Sema
authority boundary:

- ordered member references and property-get rewrites;
- receiver-aware member calls, including copied scope and named arguments;
- index stages with every source argument retained in order;
- postfix calls on callable/member values;
- postfix `++` / `--` mixed with structural stages;
- prefix operators wrapped after the complete postfix chain;
- one exact base expression identity and one exact final term identity.

The native `snExprTerm` / `snExprPostOp` tree remains unchanged for syntax,
recovery, the explicitly selected LEGACY compiler, reference tests and
differential rollback. CANONICAL Sema must not walk that tree to reconstruct
the migrated chain after this card turns green.

This slice does not migrate initializer-list terms, statements, bodies,
defaults or general lifetime routes. It must remove only the two structural
generic `ActOnParsedExpr` publications, leaving the two initializer-list
publications for CTA-S34.

## Required pointer-free action contract

The short-lived Parser payload must own copied/build-local facts only:

- current declaration owner;
- exact base `ExprId`;
- ordered copied prefix operators;
- ordered structural steps with an explicit step kind;
- copied member/callee name and qualified-scope segments;
- exact ordered positional/named argument `ExprId` values;
- copied operator spelling;
- exact step and whole-term half-open processed-source offsets.

No `asCScriptNode*`, `asCScriptCode*`, token-buffer pointer, Runtime pointer,
numeric TypeId or durable snapshot-local ID may be retained by the action or
sealed graph.

## Sema invariants

1. Validate the owner, base, every argument identity, operator spelling and
   monotonic source extent before publishing the final term identity.
2. Apply steps strictly in source order. Every step owns the immediately
   preceding result as its receiver/base/callee; do not publish that receiver
   as an independent `Sequence` part and evaluate it again.
3. Member calls reuse the ordinary-call action semantics for overload,
   named/default/hidden arguments, exact scope, conversion, dispatch and
   lifetime wrapping.
4. Index selection sees the complete argument vector. The existing adapter's
   first-argument-only behavior is not an acceptable action contract.
5. Postfix-call selection retains copied argument names and never derives the
   callee by replaying a native member/call node.
6. Apply postfix unary stages in source order and prefix operators in reverse
   source order after the complete structural chain.
7. Bind one exact expression identity to `snExprTerm`; complete native-node
   adaptation becomes identity-only and diagnoses
   `structural-postfix-expression-action-missing` when the Parser action did
   not run.
8. Recovery may publish a completed prefix, but must not reinterpret an
   authored malformed argument as an empty call/index stage.

## AST-first tests

Test source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Required focused methods:

1. `SemaStructuralPostfixExprTypedActionOwnsOrderedChainWithoutScriptNode`
   constructs the action directly, without any Parser node, and proves an
   ordered receiver-aware member call, complete multi-argument `opIndex` and
   postfix mutation are represented by exact AST edges and resolved
   declarations.
2. `ParserStructuralPostfixExprActionBindsOrderedChainWithoutNodeReplay`
   parses an authored member/index/postfix chain, proves the exact term
   identity and selected overloads, and inspects the Parser source boundary:
   the dedicated binder must be present and only the two initializer-list
   generic callbacks may remain.
3. Existing single-evaluation regressions, including
   `MemberPostfixCallInternsOnceWithoutReceiverLessCallOnCompileSealPath`,
   `IndexCompoundAssignEvaluatesReceiverOnceOnCompileSealPath` and
   `PropertyCompoundAssignEvaluatesReceiverOnceOnCompileSealPath`, must stay
   green.

The direct method is added before the action API for the compile-time RED. The
Parser method is added after direct-action GREEN but before Parser wiring; a
generic-replay-shaped AST is not sufficient because its source-boundary
assertions must remain RED until the structural callbacks are replaced.

## Backend boundary

The current Index AST/verifier assumes exactly two children and Canonical
CodeGen consumes only `children[1]`. Because maintained LEGACY compilation
passes the complete `CompileArgumentList` to `opIndex`, CTA-S33 must not
silently discard later arguments.

The AST/Sema representation will therefore retain base plus all index
arguments and select against the complete vector. If complete multi-argument
Runtime ABI emission is not implemented in the same bounded repair, CodeGen
must reject that shape explicitly instead of emitting the first argument and
miscompiling it. The remaining ABI emission then stays recorded under Tasks
9.5/9.7 and the final active-language differential gate.

## Evidence log

### TDD and Parser-boundary evidence

1. The direct pointer-free fixture first failed at compile time because the
   structural action contract and variadic Index APIs did not exist. This is
   the authoritative API RED:
   `Saved/Build/cta-s33-structural-action-api-red/20260828_013622_996_4e6afc6e/RunMetadata.json`.
2. After adding the action API, direct Sema construction built successfully at
   `Saved/Build/cta-s33-structural-action-direct-build/20260828_013946_114_1e46ad7c/RunMetadata.json`
   and passed **1/1** at
   `Saved/Tests/cta-s33-structural-action-direct/20260828_014017_629_32d8e76c/RunMetadata.json`.
3. The first Parser RED fixture used a handle form and a combined return/
   postfix-mutation shape that failed before reaching the intended authority
   assertion. It is retained as non-evidence at
   `Saved/Tests/cta-s33-structural-parser-red/20260828_014232_896_6bbacd8f/RunMetadata.json`.
4. The corrected `v.Next(1)[2]` fixture built at
   `Saved/Build/cta-s33-structural-parser-red-fixture-build/20260828_014328_859_07d02e8f/RunMetadata.json`
   and produced the valid **0/1 RED** at
   `Saved/Tests/cta-s33-structural-parser-valid-red/20260828_014347_398_d5689f11/RunMetadata.json`:
   the old generic adapter published a `Sequence`-shaped result instead of an
   Index owning its nested receiver-aware call.
5. Parser wiring built at
   `Saved/Build/cta-s33-structural-parser-action-build/20260828_014743_011_2154d1e1/RunMetadata.json`;
   the two new direct/Parser methods then passed **2/2** at
   `Saved/Tests/cta-s33-structural-focused-green/20260828_014755_479_9d0b634b/RunMetadata.json`.

### Physical replay removal and regression evidence

The structural action now owns ordered member, member-call, index, postfix-
call and unary steps. Complete structural `InternParsedExprTerm` adaptation is
identity-only. `InternParsedCall`, `SameSealedReceiverExpression` and
`TransparentCallResultOwnsReceiver` were physically removed from production.

The first build after that deletion intentionally exposed three tests that
still called `InternParsedCall` directly and failed at compile time:
`Saved/Build/cta-s33-structural-replay-removed-build/20260828_015144_732_e0cc0dd7/RunMetadata.json`.
Those tests were migrated to assert Parser typed-action ownership and exact
full-range call separation. The production/test migration then built at:

- `Saved/Build/cta-s33-structural-replay-removed-green-build/20260828_015308_221_259f3d5a/RunMetadata.json`;
- `Saved/Build/cta-s33-structural-focused-test-adjust-build/20260828_015421_147_72a4248e/RunMetadata.json`.

One intermediate focused run was **3/4** because a migrated test retained the
obsolete assumption that invoking the same typed action twice is a supported
replay operation:
`Saved/Tests/cta-s33-structural-replay-removed-focused/20260828_015334_953_c6a1a247/RunMetadata.json`.
The action contract is single publication followed by exact-identity reads,
so that test-only replay assertion was removed while its same-begin/different-
range anti-alias check was retained.

Final gates are green:

- focused structural and migrated-call boundary: **4/4 PASS** at
  `Saved/Tests/cta-s33-structural-replay-removed-focused-green/20260828_015442_280_b331932a/RunMetadata.json`;
- complete SemaAuthority: **363/363 PASS** at
  `Saved/Tests/cta-s33-sema-authority-full/20260828_015516_422_678286dc/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s33-secondary-gates/20260828_015610_290_828aafc9/RunMetadata.json`.

Static scans after the green gates show exactly **two** remaining Parser
`sema->ActOnParsedExpr(node, script)` call sites, both in initializer-list
publication, and zero occurrences of the three removed structural replay
symbols.

### Multi-argument Index boundary

AST/Sema now retain base plus every authored Index argument, select `opIndex`
against the complete argument vector, and verify Index as base plus at least
one argument. Current Canonical Bytecode emission is not yet complete for
multi-argument Index. It now fails closed on any Index with more than one
argument instead of silently compiling only `children[1]`. Completing that
Runtime ABI emission remains open under Tasks 9.5/9.7 and the final language
differential matrix.

## Non-claims

This card does not close Tasks 4.2, 5.2, 5.3, 5.4, 5.9, 9.5, 9.7, 10.3,
10.6 or 13.2 by itself. It does not change the default from LEGACY, delete the
native AngelScript AST/compiler, restore HIR, introduce a dump/replay bridge,
or claim the final full-suite matrix.
