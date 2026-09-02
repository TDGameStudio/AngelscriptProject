# CTA-S32 — ordinary-call typed-action gate (2026-08-28)

## Scope

This gate migrates an ordinary source `snFunctionCall` from the generic
Parser notification and Sema native-subtree replay boundary to one
pointer-free call action. It includes unqualified and explicitly-qualified
ordinary calls, ordered positional/named source arguments, overload
selection, conversions, default/hidden synthesis, deferred forward lookup,
automatic-import/native declaration projection and final dispatch metadata.

The action contract is intentionally reusable by the following structural
postfix/member slice. This gate binds only calls parsed with
`ParseFunctionCall(notifySema=true)`; a dot member call parsed with
`notifySema=false`, postfix callable invocation and index/member sequencing
remain open until they can supply the exact receiver and single-evaluation
plan through the same contract.

The retained `snFunctionCall`, `snScope`, `snIdentifier`, `snArgList`,
`snNamedArgument`, Parser, Builder and LEGACY compiler remain physically
available for syntax, recovery, explicit LEGACY compilation, differential
testing, reference and rollback. A complete ordinary CANONICAL call must not
walk those nodes after this family closes.

## Required action contract

`asSCallExprAction` must own only build-local canonical values and copied
source data:

- the lexical owner declaration identity;
- the copied callee name;
- copied ordered qualifier segments plus the absolute-scope bit;
- an optional exact canonical receiver identity;
- ordered source arguments, each containing one exact `asASTExprId` and its
  copied optional authored name; and
- the complete copied half-open source range.

No `asCScriptNode`, token-buffer pointer, Runtime pointer, numeric Runtime
`TypeId`, dump/HIR payload or persisted snapshot-local identity may cross the
action boundary. Sema, not Parser, owns exact scope lookup, overload ranking,
argument arrangement, conversion, default/hidden synthesis, dispatch,
deferred-call state, materialization and diagnostics.

## AST-first tests

The direct test must construct a qualified named call action without a native
node and prove:

- copied scope/name select the exact qualified overload rather than a visible
  global same-name function;
- source-order named arguments map to formal slots and the sealed call keeps
  reverse formal child order;
- every child descends from the exact action-supplied expression or a Sema-
  owned conversion/default/hidden node;
- dispatch, result type and full source range are sealed; and
- a same-range action containing a distinct exact argument cannot alias the
  first call.

The Parser test must parse an explicitly-qualified call with named arguments,
locate the retained `snFunctionCall`, require its exact canonical binding and
the selected qualified callee/argument plan, and inspect only the isolated
`ParseFunctionCall(bool notifySema)` source slice. That slice must call the
dedicated bind helper and contain no `ActOnParsedExpr`.

Existing forward-call, missing-scope, overload, native/global import,
default/hidden/named, recovery and successful-parse non-duplication tests stay
in the complete SemaAuthority group and are acceptance gates for the
migration.

## RED sequence

1. Add the direct action test before production types or entry points. The
   build must fail specifically because `asSCallArgumentAction`,
   `asSCallExprAction` and `ActOnCallExprAction` do not exist.
2. Implement the action API and direct Sema behavior.
3. Add/run the Parser boundary test before Parser wiring. Existing generic
   replay may make AST facts look correct, but the isolated source assertion
   must remain RED until `ParseFunctionCall` binds the action.
4. Wire Parser, make complete ordinary native-node adaptation identity-only,
   then run focused and broad gates.

### RED 1 — missing pointer-free action API

Status: **observed as intended**.

The first build fails only in the new direct action test because
`asSCallArgumentAction`, `asSCallExprAction` and
`asCSema::ActOnCallExprAction` are absent. No production source had been
changed for this run:

`Saved/Build/cta-s32-call-action-api-red/20260828_010919_547_340e6e29/RunMetadata.json`

The action API build then succeeds, and the direct pointer-free action test is
**1/1 PASS**:

- `Saved/Build/cta-s32-call-action-api-build/20260828_011055_227_1dd4d9fd/RunMetadata.json`
- `Saved/Tests/cta-s32-call-action-direct/20260828_011124_581_bfc0cea9/RunMetadata.json`

### RED 2 — Parser still used generic native replay

Status: **observed as intended**.

Before Parser wiring, every qualified/named AST assertion already passes
because `ActOnParsedExpr(node, script)` enters `InternParsedCall` and walks the
retained scope/identifier/argument subtree. The only failure is the isolated
source-boundary requirement for `BindCallExprAction`, proving that visible AST
shape alone would be a false green:

`Saved/Tests/cta-s32-call-parser-red/20260828_011200_242_1a0a8465/RunMetadata.json`

## Acceptance gates

- direct pointer-free action test;
- Parser qualified/named call action test;
- complete SemaAuthority;
- complete ProductionCodeGen;
- Canonical Semantics;
- retained native ScriptNode shape;
- Parser generic callback count;
- strict OpenSpec validation and focused diff check.

## Non-claims

This slice does not close member/mixin/property/index/postfix-call receiver
sequencing, initializer lists, general statements, complete body/default/
lifetime migration, detached backend/AOT closure or default CANONICAL cutover.
Tasks 4.2, 5.2, 5.3, 5.4, 10.6 and 13.2 remain open until their complete
wording is independently proven. Any newly discovered gap must be recorded in
the final-completion issue log before this gate is reported green.

## GREEN closure

Status: **closed for ordinary non-member source calls**.

`asSCallArgumentAction` and `asSCallExprAction` now carry only copied
qualifier/name/range values, exact build-local declaration/expression IDs and
the optional exact receiver identity. `ActOnCallExprAction` owns scope
resolution, automatic-import/native declaration projection, overload
selection, named/default/hidden argument arrangement, conversions, deferred
resolution, result type, dispatch, materialization and diagnostics. Automatic
import projection no longer needs a ScriptCode/ScriptNode pair for this path;
it consumes the copied qualified-scope spelling.

`ParseFunctionCall(notifySema=true)` builds and binds that action. Complete
standalone `snFunctionCall` handling in `ActOnParsedExpr` and
`ActOnExprFromNode` is identity-only and emits
`call-expression-action-missing` if Parser did not publish the action. The
retained native node remains unchanged for explicit LEGACY, syntax/recovery,
reference and differential tests. The structural member/postfix adapter still
calls its receiver-aware legacy helper directly and is the next migration
slice; it does not enter the completed standalone switch route.

Two broad-gate failures were deliberately not hidden:

- the offset-zero snippet fixture had no TranslationUnit, while the action
  contract correctly requires a lexical owner. The fixture now establishes a
  TU and proves the typed-action call is created before `InternParsedCall`
  only reuses its exact full-range identity;
- `FValue(` publishes an empty trailing `ParseArgList` recovery shell. Parser
  now permits only a final shell containing **no authored token** to be
  omitted from the action, preserving the already-recognized zero-argument
  construct/materialization/cleanup prefix. Any authored malformed argument
  still fails closed.

### Final evidence

- Runtime/Editor incremental build:
  `Saved/Build/cta-s32-call-recovery-fix-build/20260828_011917_167_9b9683b2/RunMetadata.json`
- direct pointer-free action: **1/1 PASS**:
  `Saved/Tests/cta-s32-call-action-direct/20260828_011124_581_bfc0cea9/RunMetadata.json`
- Parser qualified/named action: **1/1 PASS**:
  `Saved/Tests/cta-s32-call-parser-green/20260828_011413_789_ad21169e/RunMetadata.json`
- focused recovery regressions: **2/2 PASS**:
  `Saved/Tests/cta-s32-call-recovery-focused/20260828_011947_502_08636be7/RunMetadata.json`
- complete SemaAuthority: **361/361 PASS**:
  `Saved/Tests/cta-s32-sema-authority-green/20260828_012037_287_bf2a3ed7/RunMetadata.json`
- combined ProductionCodeGen **114/114**, Canonical Semantics **12/12** and
  retained native ScriptNode **32/32**: **158/158 PASS**:
  `Saved/Tests/cta-s32-secondary-gates/20260828_012125_713_51d037db/RunMetadata.json`
- focused diff check: clean (the only message is the existing LF→CRLF worktree
  warning for `as_parser.cpp`).

Parser generic `ActOnParsedExpr` call sites fall from **5 to 4**. The four
remaining sites are two initializer-list publications and two structural
member/index/postfix routes. No umbrella task checkbox changes at this bounded
gate: **87/125 (69.6%)** mechanical, **about 66%** weighted engineering and
**about 38%** default-cutover readiness.
