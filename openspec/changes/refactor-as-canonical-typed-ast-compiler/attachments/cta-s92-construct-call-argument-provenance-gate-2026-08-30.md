# CTA-S92 construct call-argument provenance gate — 2026-08-30

## Status

CTA-S92 is closed for the focused Canonical AST producer,
publication-verifier, Sidecar persistence and execution-consumer slices for
ordinary constructor calls. The same-typed adversarial execution fixture proves
Bytecode placement follows sealed `formalIndex`, not record or child position.
The Parser temporary reference-class `AUTO_HANDLE` regression, Sidecar V11
mutation fixtures, Cache current-module authority and the PreClass `Super::`
native-shadow ambiguity discovered by the broad gates are also closed. The
latest complete evidence includes SemaAuthority **457/457**, ProductionCodeGen
**168/168**, Frontend CanonicalAST **183/183**, Compiler CanonicalAST **672/672**,
ASTBodySidecar V11 **25/25**, Cache **585/585** and Module **65/65**.

This closes CTA-S92 as a bounded constructor-provenance/persistence gate. It
does not by itself claim complete constructor/call-family breadth, product-
default CANONICAL readiness or Tasks 5.3/9.5/10.2/13.6. The derived-funcdef
closure and TypedASTJIT Runtime-binding authentication that were still open at
this checkpoint were subsequently addressed by CTA-S98 and CTA-S93 through
CTA-S97 respectively.

The design keeps `asAST_EXPR_CONSTRUCT` as a distinct expression kind while
giving ordinary constructor calls the same exact source-to-formal
`asSASTCallArgument` relation as `asAST_EXPR_CALL`:

- record order remains the existing CONSTRUCT evaluation/storage order;
- `formalIndex` selects the constructor ABI slot;
- `formal` and `formalType` authenticate the exact selected parameter;
- `origin`, `sourceOrdinal` and `sourceName` preserve positional, named,
  default, hidden or generated provenance;
- list-pattern construction remains a separate aggregate protocol and is not
  reinterpreted as a callable-formal relation.

The native AngelScript syntax tree remains intact for syntax/recovery,
explicit LEGACY, reference and differential use. No HIR or dump transport is
introduced.

## Focused AST-first fixture

Source test:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp:3398`

Method:

`ConstructNamedDefaultArgumentsSealExactFormalProvenance`

Fixture:

```angelscript
struct TConstructCallPlan
{
    TConstructCallPlan(int A = 40 + 2, int B = 1) {}
}

int Entry()
{
    TConstructCallPlan Value(B: 7);
    return 1;
}
```

The sealed `asAST_EXPR_CONSTRUCT` must contain two typed children and two
complete call-argument records:

1. formal `A`, formal index `0`, origin `DEFAULT`, with no authored source
   ordinal or source name;
2. formal `B`, formal index `1`, origin `NAMED`, source ordinal `0`, source
   name `B`.

Execution-consumer source test:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`

Method:

`PreparedConstructArgumentsUseSealedFormalOrdinalRelation`

The fixture constructs a two-`int` value whose correct result is `427`, then
adversarially swaps the stored child/record pairs while retaining their exact
formal ordinals. A consumer that treats record position as the ABI slot returns
`0`; the production consumer must still return `427`.

## Valid RED evidence

### Producer RED

```text
Saved/Tests/cta-s92-construct-provenance-red-isolated-20260830/
  20260830_145015_859_4d7a66fc/Report/index.json
Result: 0/1 PASS
Diagnostics:
  local-variable-declarator-action-invalid
  local-variable-declaration-action-invalid
  Seal returned -10
```

Static diagnosis found three connected omissions rather than a backend-only
ordering bug:

1. `BuildConstructExprAction()` rejected `snNamedArgument` instead of
   preserving the argument name in a typed Parser action;
2. direct global/field/local initializer actions likewise invalidated named
   arguments and transported only expression IDs;
3. `ConstructFromCallee()` / `ActOnConstruct()` discarded the arranged
   source-to-formal plan after exact constructor selection.

### Verifier RED

Source test:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Frontend/CanonicalAST/AngelscriptNativeCanonicalASTVerifierTests.cpp:3249`

Method:

`RejectsConstructMissingCallArgumentCoverage`

```text
Saved/Tests/cta-s92-construct-verifier-red-isolated-20260830/
  20260830_145441_657_61c6d237/Report/index.json
Result: 0/1 PASS
Expected rejection was absent:
  resolved CONSTRUCT with no call-argument relation was accepted
Expected detail:
  call-argument-count
```

This RED proved that adding producer data alone was insufficient: publication
also needed to reject an exact constructor whose formal coverage was missing
or partial.

### Execution-consumer mutation RED

The focused test was run against a temporary mutation that selected the
constructor argument record by reverse record position instead of the sealed
formal-to-record map:

```text
Saved/Build/cta-s92-construct-formal-relation-red-build-20260830/
  20260830_150615_758_696fa03c
Result: Succeeded

Saved/Tests/cta-s92-construct-formal-relation-red-isolated-20260830/
  20260830_150635_641_2619d2ef/Report/index.json
Result: 0/1 PASS
Observed execution result: 0
Expected execution result: 427
```

The mutation was then removed. This is valid consumer RED evidence because the
sealed AST remains valid and only the production placement consumer is made to
ignore its authoritative relation.

## Implementation boundary

- `as_parser.cpp` now preserves expression IDs and argument names for explicit
  construct expressions and direct variable initializers.
- `as_sema_expr.cpp`, `as_sema_decl.cpp` and `as_sema_stmt.cpp` route source
  construction through the ordinary call planner, freeze the relation after
  exact constructor selection and preserve converted expression IDs.
- `as_sema.cpp` authenticates supplied constructor records and synthesizes
  complete generated records only for non-source positional construction
  helpers.
- `as_ast_context.cpp` permits call-argument records on ordinary CALL and
  CONSTRUCT expressions.
- `as_ast_verifier.cpp` applies complete call-argument authentication to
  ordinary CONSTRUCT and deliberately excludes the separate `list-pattern`
  aggregate protocol.
- `as_bytecode_codegen.cpp::EmitConstructInto()` builds the constructor ABI
  placement map from sealed `formalIndex`. It evaluates in the stored relation
  order, then pushes in reverse formal ABI order without inferring meaning from
  child position.

Rejected alternatives:

- do not recover constructor parameter meaning from child index;
- do not reverse CONSTRUCT storage/evaluation order to imitate CALL;
- do not rename internal `$behN` Runtime behaviours;
- do not replay the native syntax tree in CodeGen;
- do not add HIR or use an AST dump as compiler transport;
- do not force list-pattern aggregate elements into callable-formal records.

## Current GREEN evidence

Build:

```text
Saved/Build/cta-s92-construct-provenance-green-build-20260830/
  20260830_145832_098_dd745300
Result: Succeeded, 23 actions
```

Producer/SemaAuthority:

```text
Saved/Tests/cta-s92-construct-provenance-green-isolated-20260830/
  20260830_145905_060_b73ffba7/Report/index.json
Result: 1/1 PASS
```

Verifier negative:

```text
Saved/Tests/cta-s92-construct-verifier-green-isolated-20260830/
  20260830_150038_017_d9d8ea67/Report/index.json
Result: 1/1 PASS
```

Execution consumer after restoring exact `formalIndex` lookup:

```text
Saved/Build/cta-s92-construct-formal-relation-green-build-20260830/
  20260830_150718_065_019f661b
Result: Succeeded

Saved/Tests/cta-s92-construct-formal-relation-green-isolated-20260830/
  20260830_150730_579_91eb5b5c/Report/index.json
Result: 1/1 PASS; Entry returned 427

Saved/Tests/cta-s92-production-codegen-full-green-20260830/
  20260830_150814_315_cdb2dec9/Report/index.json
Result: 168/168 PASS, 0 failed, 0 skipped
```

The final post-compatibility ProductionCodeGen result is recorded below and
supersedes this earlier intermediate run.

## Broad-regression findings and closure

The first complete SemaAuthority run after the focused change was **453/456**:

```text
Saved/Tests/cta-s92-sema-authority-full-green-20260830/
  20260830_150854_086_9401129a/Report/index.json
```

It exposed three compatibility boundaries rather than a failure of the sealed
formal relation itself:

1. routing every object construct through ordinary call resolution discarded
   an authored exact `QualType` for typed-action handle/template cases;
2. treating a parallel argument-name array containing only empty strings as a
   named call prevented maintained positional construction such as
   `array<int>` factories;
3. the direct zero-argument `ActOnCallExpr(C)` path failed to retain a
   `ClassDecl` when no explicit constructor declaration existed.

The first two are isolated GREEN after preserving the exact target type and
testing whether any name is actually non-empty. The third now builds and its
direct action test is **1/1 PASS**:

```text
Saved/Build/cta-s92-class-decl-construct-green-build-20260830/
  20260830_151656_797_7bec1292
Result: Succeeded

Saved/Tests/cta-s92-class-decl-construct-green-isolated-20260830/
  20260830_151720_145_12860c07/Report/index.json
Result: 1/1 PASS
```

The second intermediate complete run was **455/456**:

```text
Saved/Tests/cta-s92-sema-authority-full-green2-20260830/
  20260830_151753_410_4c8d76c1/Report/index.json
Result: 455/456 PASS, 1 failed, 0 skipped
Failure:
  ClassTemporaryConstructInternsReferenceObjectNotValueObject
```

The dump already carried `typeKind=ReferenceObject` and the handle qualifier,
but the `Construct` expression had `quals=2` and failed the test's required
`AUTO_HANDLE` assertion. `QualTypeForConstructExpression()` now preserves the
exact target TypeId and adds `HANDLE | AUTO_HANDLE` for reference-object
construction. The focused gate changed to **1/1 PASS**, followed by complete
SemaAuthority **456/456**:

```text
Saved/Tests/cta-s92-construct-result-autohandle-green-isolated-20260830/
  20260830_152443_903_fefb083e/Report/index.json
Result: 1/1 PASS

Saved/Tests/cta-s92-sema-authority-final-green-20260830/
  20260830_152520_586_50424d0c/Report/index.json
Result: 456/456 PASS, 0 failed, 0 skipped
```

The post-fix cross-surface matrix is:

```text
CallArguments:
  Saved/Tests/cta-s92-call-arguments-final-green-20260830/
    20260830_152727_470_c062d7b3/Report/index.json
  10/10 PASS

ProductionCodeGen:
  Saved/Tests/cta-s92-production-codegen-final-green-20260830/
    20260830_152602_619_c373de1e/Report/index.json
  168/168 PASS

CodeGen transaction/rollback:
  Saved/Tests/cta-s92-codegen-transaction-final-green-20260830/
    20260830_152804_703_c19a08f6/Report/index.json
  21/21 PASS

Frontend CanonicalAST:
  Saved/Tests/cta-s92-frontend-canonicalast-final-green-20260830/
    20260830_152639_587_a0642b0c/Report/index.json
  183/183 PASS

Compiler CanonicalAST:
  Saved/Tests/cta-s92-compiler-canonicalast-final-green-20260830/
    20260830_152837_724_6725fd4c/Report/index.json
  672/672 PASS
```

## Sidecar V11 and Cache publication closure

Sidecar schema V11 persists and authenticates the complete constructor
`asSASTCallArgument` relation. The ordinary CONSTRUCT route is supported while
the separate `list-pattern` aggregate protocol remains excluded. The full
Sidecar gate is **25/25 PASS**:

```text
Saved/Tests/cta-s92-astbodysidecar-v11-full-green-20260830/
  20260830_154008_648_79e2ec06/Report/index.json
```

The first full Cache run was an honest **580/585**. Three failures were stale
negative fixtures whose intended unrelated corruption had started deleting
the new V11 `formalIndex` relation as collateral damage; those fixtures now
preserve V11 relation integrity and are **3/3 PASS**. A fourth failure exposed
that the default/global compile route did not establish the same
`CurrentModuleAuthority` used by module-local projection; the production route
now scopes that authority and its exact regression is **1/1 PASS**. These were
test-fixture and production-authority defects respectively, not reasons to
weaken Sidecar verification.

```text
Initial full Cache:
  Saved/Tests/cta-s92-cache-v11-full-green-20260830/
    20260830_154046_578_f1ec01ad/Report/index.json
  580/585 PASS, 5 failed

V11 negative-fixture correction:
  Saved/Tests/cta-s92-sidecar-v11-mutation-fixture-green-20260830/
    20260830_155628_709_a8cbd388/Report/index.json
  3/3 PASS

Global current-module authority:
  Saved/Tests/cta-s92-global-default-authority-green-20260830/
    20260830_160034_794_d98afd03/Report/index.json
  1/1 PASS
```

The fifth failure was the `Super::` publication defect described next. After
all five root causes were closed, the complete Cache gate is **585/585 PASS**:

```text
Saved/Tests/cta-s92-cache-v11-super-full-green-20260830/
  20260830_161926_505_ec756f82/Report/index.json
Result: 585/585 PASS, 0 failed, 0 skipped
```

## PreClass `Super::` native-shadow closure

UE PreClass Canonical class graphs intentionally carry two orthogonal class
relations: the authored script superclass and a `canonical-native-type-view`
shadow such as `UObject`. `FindDirectBaseClass()` treated both as authored
concrete bases and failed closed, leaving deferred `Super::Compute()` calls
with a dangling/Error declaration until Cache publication verification.

The Sema fix ignores only `CANONICAL_NATIVE_TYPE_VIEW_ORIGIN` when selecting an
authored direct base, matching the existing layout-base rule. Multiple authored
concrete bases still fail closed. The publication verifier was not relaxed.
Permanent tests now prove both the plain Parser/Sema exact direct-base method
and the UE three-level PreClass graph with its native shadow. Evidence:

```text
Build:
  Saved/Build/cta-s92-super-regression-assertions-build-20260830/
    20260830_161743_530_02573e83
  PASS

Plain Sema `Super::`:
  Saved/Tests/cta-s92-super-sema-green-20260830/
    20260830_161529_165_4f551f4f/Report/index.json
  1/1 PASS

UE three-level Cache regression:
  Saved/Tests/cta-s92-super-regression-assertions-green-20260830/
    20260830_161802_535_ef80fde0/Report/index.json
  1/1 PASS

Complete SemaAuthority after the new regression:
  Saved/Tests/cta-s92-super-sema-authority-full-green-20260830/
    20260830_161843_468_13d7a77c/Report/index.json
  457/457 PASS

Module lifecycle regression:
  Saved/Tests/cta-s92-module-snapshot-regression-20260830/
    20260830_163156_522_6913d039/Report/index.json
  65/65 PASS
```

## Hot Reload diagnostic expectation closure

The first full Hot Reload rerun was **132/134**. Both functional failure-
rollback tests had already proved the correct product behavior: the broken
compile failed, old code still returned `5`, old classes/functions remained
visible, diagnostics were collected and no reload delegate was broadcast. The
only failures were expected-log registrations that still demanded two copies
of the same file header and overlapping full/partial `MissingType` messages,
while the compiler now emits one deterministic diagnostic.

The tests now expect one file location, one exact diagnostic and one failed-
reload rollback message; none of their functional rollback assertions were
removed. Both focused tests are **1/1 PASS**, and the complete Hot Reload prefix
is **134/134 PASS**:

```text
Initial full Hot Reload:
  Saved/Tests/cta-s92-hotreload-snapshot-regression-20260830/
    20260830_163229_750_bfa84510/Report/index.json
  132/134 PASS, 2 failed

Focused event rollback:
  Saved/Tests/cta-s92-hotreload-failed-event-diagnostic-green-20260830/
    20260830_163629_673_afdfbcc1/Report/index.json
  1/1 PASS

Focused old-code/diagnostic rollback:
  Saved/Tests/cta-s92-hotreload-failure-fallback-diagnostic-green-20260830/
    20260830_163704_586_6187dbeb/Report/index.json
  1/1 PASS

Complete Hot Reload:
  Saved/Tests/cta-s92-hotreload-full-green-20260830/
    20260830_163742_094_9af69e89/Report/index.json
  134/134 PASS, 0 failed, 0 skipped
```

## Evidence explicitly excluded

- The first attempted exact selector omitted the CQTest class segment and
  matched no test. It is selector-calibration output, not a RED or GREEN.
- The first verifier-test build had a CQTest matcher-parenthesis error. It is
  test-authoring compile failure, not semantic RED evidence.
- Concurrent attempts to run multiple UE automation prefixes were rejected by
  the worktree execution lock. They are infrastructure exclusions, not test
  failures or regression evidence; all remaining runs must be serial.

## Remaining work outside CTA-S92

CTA-S92's focused producer, verifier, persistence, Bytecode consumer and
publication-lifecycle gates are green. The enclosing change remains open for:

1. remaining uncommon call/language/provider breadth and exact typed fallback;
2. production-entry and default-cutover scans;
3. the complete focused-prefix and final All gates.

CTA-S98 later closed the derived-funcdef source-qualifier producer/consumer
relation. CTA-S93 through CTA-S97 later closed generation-local TypedASTJIT
type-binding, nested-native descriptor ABI and frozen root/helper signature
authentication. Those later closures do not broaden CTA-S92's own evidence.

The original native AngelScript AST/Parser/Builder/Compiler remains available
for syntax/recovery, explicit LEGACY, reference, differential and rollback use.
HIR remains absent. Standalone adaptation remains explicitly deferred.
