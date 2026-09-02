# CTA-S-30 cast-expression typed-action gate (2026-08-28)

## Status

**Resolved and verified.** This slice migrates explicit `Cast<T>(expr)` only.
Functional casts
parsed as construct calls, object construction, ordinary calls,
member/index/postfix-call chains, and their lifetime/single-evaluation
semantics remain later slices.

## Intended contract

`asSCastExprAction` will carry only build-local semantic values:

- exact operand `asASTExprId`;
- exact Parser-resolved target `asCQualType`;
- copied half-open source offsets.

No `asCScriptNode*`, token-buffer pointer, Runtime `asITypeInfo*`, or numeric
Runtime TypeId crosses the action. Parser retains native `snCast` for
syntax/recovery and explicit LEGACY, but CANONICAL Sema must accept a complete
cast only through the exact action binding.

## AST-first RED

Two permanent tests were added before production code:

- `SemaCastExprTypedActionOwnsTargetAndOperandWithoutScriptNode` asserts exact
  operand, target type, range, and non-aliasing of same-range casts with
  different targets;
- `ParserCastExprActionBindsExactOperandAndTargetWithoutNodeReplay` asserts the
  exact Parser binding, retained native `snCast`, and that `ParseCast` uses
  `BindCastExprAction` without generic `ActOnParsedExpr` replay.

The first build fails on the intentionally missing `asSCastExprAction` and
`asCSema::ActOnCastExprAction` API:

`Saved/Build/cta-s30-cast-action-red/20260828_001923_337_f7a59991/RunMetadata.json`

Result: build exit 1 (`ProcessExitCode` 6). This is the valid missing-contract
RED. The Parser runtime RED was then recorded after the direct action API
compiled and before Parser wiring.

## Implementation and GREEN

Production now contains pointer-free `asSCastExprAction` and
`asCSema::ActOnCastExprAction`. The action validates its source range, exact
operand identity and exact target `asCQualType`, then delegates to
`ActOnCastExpr`. `ActOnCastExpr` also performs exact conversion lookup using
the target type, operand and complete source range before creating a new
conversion.

The incremental UE build is green:

`Saved/Build/cta-s30-cast-action-api-green-build/20260828_002158_513_34cb2693/RunMetadata.json`

Result: **17/17 build actions, exit 0**. This proves only that the new action
contract compiles; it does not prove Parser ownership or exact conversion
behavior.

The corrected focused test names first produced two real RED results:

- direct action: **0/1** at
  `Saved/Tests/cta-s30-cast-action-direct-green-corrected/20260828_002348_985_21539470/RunMetadata.json`;
- Parser pre-wiring: **0/1** at
  `Saved/Tests/cta-s30-cast-parser-prewire-corrected/20260828_002418_434_ed8b382a/RunMetadata.json`.

The direct-action RED was a fixture defect, not evidence that the
exact lookup aliases two different target types. The test chose `float` and
`double`, but this Engine has `floatIsFloat64=true`; `ActOnQualType("float")`
and `ActOnQualType("double")` therefore intentionally intern the same
canonical `float64` type. The fixture must use guaranteed-distinct canonical
targets such as `float32` and `float64` before conversion-identity behavior
could be concluded. The corrected fixture now uses explicit `float32` against
the configured default `float64`; its rebuild and direct action gate are:

- build **4/4 actions, exit 0** at
  `Saved/Build/cta-s30-cast-distinct-fixture-build/20260828_003058_524_720cdd1d/RunMetadata.json`;
- direct action **1/1 PASS** at
  `Saved/Tests/cta-s30-cast-action-direct-green-fixed/20260828_003118_505_e0e40100/RunMetadata.json`.

The Parser RED is valid pre-wiring evidence: `ParseCast` still used the
generic `ActOnParsedExpr` route, and the expected exact cast binding is absent.
The repair adds `BuildCastExprAction` / `BindCastExprAction`, binds complete
and eligible recovery paths, and makes `ActOnExprFromNode(snCast)` exact-
identity-only with `cast-expression-action-missing` on a missing Parser action.
The native `snCast` remains intact for syntax/recovery and explicit LEGACY.

The first post-wiring Parser run still failed **0/1** at
`Saved/Tests/cta-s30-cast-parser-action-green/20260828_003318_539_1374ad7a/RunMetadata.json`.
This was the same configured-float fixture error in the Parser assertion:
`Cast<float>` resolves to stable key `double` when `floatIsFloat64=true`, but
the fixture hard-coded `float`. The assertion now uses the existing
`GetResolvedDefaultFloatTypeKey()` policy helper; all exact identity, operand,
range and source-boundary assertions then pass.

Two earlier invocations omitted the test-class segment from their full
Automation names and reported `No automation tests matched`. Those runs are
tooling mistakes and are explicitly excluded from implementation evidence.

## Final evidence

| Gate | Result | Evidence |
| --- | ---: | --- |
| Parser exact action | **1/1 PASS** | `Saved/Tests/cta-s30-cast-parser-action-green-policy/20260828_003448_634_bb170b73/RunMetadata.json` |
| SemaAuthority | **357/357 PASS** | `Saved/Tests/cta-s30-sema-authority-green/20260828_003530_601_b3051a26/Summary.json` |
| ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-s30-production-codegen-green-final/20260828_003626_695_ff88c0bc/Summary.json` |
| Canonical Semantics | **12/12 PASS** | `Saved/Tests/cta-s30-canonical-semantics-green/20260828_003705_555_24a79903/Summary.json` |
| retained native ScriptNode | **32/32 PASS** | `Saved/Tests/cta-s30-native-scriptnode-green/20260828_003742_392_1a725e43/Summary.json` |
| final Parser/test rebuild | **4/4 actions, exit 0** | `Saved/Build/cta-s30-cast-parser-fixture-policy-build/20260828_003427_653_b863b5a3/RunMetadata.json` |

Parser generic `ActOnParsedExpr` calls fall from **9 to 6**: construct call,
ordinary call, two init-list routes and two structural postfix routes remain.

No parent OpenSpec task is checked by this local slice because the enclosing
expression/Sema umbrella remains incomplete.
