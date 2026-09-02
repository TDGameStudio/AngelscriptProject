# Canonical lambda-header typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-21 — pointer-free lambda header and explicit-parameter actions |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | direct `asSLambdaHeaderAction` construction plus authored `function(int x)` parse-before-body and complete parse routes |
| Construction/sealed-AST assertion | Sema creates one exact `<lambda>` FunctionDecl under the supplied owner; explicit parameter type/name/range enter through `asSParameterDeclAction`; the retained Parser shell only binds/retrieves that Decl identity |
| Architecture assertion | `ParseLambda` calls the lambda-header and parameter actions, pushes the exact returned DeclContext, and does not call `NotifySema(node)`; declaration Sema has no `ActOnQualTypeFromNode`, `WalkParameterSequence`, or `WalkParameterList` |
| Expected RED | the action type/API and Parser route do not exist, while declaration Sema still decodes the complete `snFunction` and its `snDataType` children |
| Production edit allowed after RED | one short-lived lambda-header payload/API, Parser-side explicit parameter action collection/publication, exact parsed-declaration binding, and deletion of the residual lambda node-to-type walkers |

## Locked bounded design

1. Parser recognizes the lambda token, optional explicit parameter types and
   names while it owns syntax. It copies only ASTContext-local construction
   facts into short-lived actions; no Parser node, Engine pointer, numeric
   TypeId or durable snapshot identity enters the action.
2. Sema creates or reuses one `<lambda>` declaration by exact owner and source
   identity, marks `asAST_TRAIT_LAMBDA`, and owns stable-key construction.
3. Parser publishes every explicitly typed parameter through the existing
   `asSParameterDeclAction` after it has the exact lambda DeclId. It then pushes
   that exact DeclContext before parsing the body.
4. The retained `snFunction` remains only the LEGACY/recovery shell. Canonical
   expression replay may retrieve its previously bound DeclId and attach the
   separately named body adapter, but may not recover signature facts from the
   node.
5. Preserve the current migration-phase recovery return-type behavior in this
   bounded slice so existing Canonical fixtures do not acquire an unrelated
   semantic change. This recovery value is not final lambda/funcdef signature
   authority and must be replaced by contextual signature/return inference
   before Task 4.4 can close.

## Required RED/GREEN evidence

1. Add the direct action and Parser-boundary tests before production edits.
2. Build the tests and require the missing action/API or old Parser route to
   produce a valid RED.
3. Implement the bounded action route and delete the node-to-type walkers.
4. Run the complete SemaAuthority group, ProductionCodeGen, Parser declarations,
   Frontend Type and lambda/compiler regressions.
5. Run source scans proving zero `ActOnQualTypeFromNode` and zero lambda
   parameter walkers in declaration Sema.
6. Run strict OpenSpec validation plus parent/plugin diff checks.
7. Record every build/test/runner failure, root cause, correction and non-claim
   in this card and the final issue log/execution ledger.

## Mutation checks

The permanent tests must fail if a future change:

- removes `asSLambdaHeaderAction` or its node-free Sema entry point;
- restores `NotifySema(node)` as the lambda-header semantic boundary;
- reintroduces `ActOnQualTypeFromNode`, `WalkParameterSequence`, or
  `WalkParameterList` for lambda signatures;
- uses `lastActedDecl` instead of the exact returned lambda DeclContext;
- carries a Parser node, Runtime type pointer or numeric TypeId in the action;
- creates two Canonical declarations for one authored lambda.

## Explicit non-claims after implementation

- Untyped non-zero lambda parameters are still context-dependent language
  semantics and are not made authoritative by this header slice.
- Lambda-to-funcdef contextual return/parameter binding and return inference
  remain open.
- The statement/body expression adapter remains transitional.
- General expression/statement/lifetime action authority, detached Runtime
  installation, production HIR retirement and final cutover remain open.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD result

The permanent tests were added before any production edit. The supported
Runtime/Editor build failed at:

`Saved/Build/cta-lambda-header-red-test-build/20260827_154559_687_cecce7e7/RunMetadata.json`.

This is a valid compile-time RED for CTA-S-21: the new test cannot name
`asSLambdaHeaderAction`, and `asCSema` has no `ActOnLambdaHeaderAction`. The
failure therefore proves the test reaches the missing typed-action contract,
not a typo in an existing API.

The same adaptive non-unity build independently compiled
`AngelscriptNativeContextReturnValueTests.cpp` and reproduced its known clean
aggregate blocker: four `ASTEST_AS_ANSI` uses have no declaration because the
file includes native support/CQTest headers but not `AngelscriptTestMacros.h`.
That failure is in a separate translation unit and predates CTA-S-21. It is
recorded separately and will not be repaired or counted as part of this slice.

## Production result

CTA-S-21 now has a real pointer-free lambda-header route:

- `asSLambdaHeaderAction` carries only owner, recovery return `QualType` and
  source offsets. It carries no Parser node, Runtime pointer, numeric TypeId or
  foreign snapshot-local AST reference.
- `ParseLambda` resolves every explicitly typed parameter through
  `BuildQualTypeSyntaxAction -> ActOnQualTypeAction`, publishes the header via
  `ActOnLambdaHeaderAction`, attaches parameters with the existing exact-owner
  `ActOnParameterDeclAction`, and pushes the exact returned lambda DeclId while
  parsing the body.
- `ParseLambda` no longer calls `NotifySema(node)` for the completed header and
  no longer relies on `lastActedDecl` to identify the lambda body owner.
- `ActOnLambdaFromNode` is now a body-only migration adapter. It retrieves the
  exact previously bound declaration, validates the lambda trait and fails
  closed with `lambda-header-action-missing` when the binding is absent. It
  does not recover names, parameters or types from the node.
- `ActOnQualTypeFromNode`, `WalkParameterSequence`, `WalkParameterList`,
  `FindExistingFunctionLike` and their private node-decoder helpers have been
  physically deleted. A final source scan reports zero matches.

The intentionally bounded migration-phase recovery return type is the first
explicit parameter type, or `int` when there is none. It preserves the prior
fixtures but is not claimed as final contextual lambda/funcdef inference.

## Build and test issue record

The first production build reached the implementation but did not complete:

`Saved/Build/cta-lambda-header-green-build/20260827_155518_820_e025dd40/RunMetadata.json`.

It exposed two independent facts:

1. the existing Canonical TypeSema test helper still called the now-deleted
   `ActOnQualTypeFromNode`; the in-slice correction migrated that test to the
   public Parser syntax-action plus Sema type-action boundary instead of
   restoring the deleted compatibility API;
2. the already-recorded `AngelscriptNativeContextReturnValueTests.cpp` clean-
   aggregate blocker again compiled without `AngelscriptTestMacros.h`.

A validation-only include was applied for the second issue, the complete
supported build passed at
`Saved/Build/cta-lambda-header-green-build-workaround/20260827_155700_053_4034ffea/RunMetadata.json`,
and the include was immediately removed. `git diff --quiet HEAD --` for that
file is true, so the workaround is absent from the implementation and does not
claim the unrelated blocker is fixed.

One initial read-only scan also used the stale guessed path
`Private/AngelscriptCode/...`; the maintained fork is actually under
`AngelscriptRuntime/ThirdParty/angelscript/source`. The stale scan produced no
evidence and was discarded before the final inventory.

## GREEN evidence

- SemaAuthority **337/337 PASS**:
  `Saved/Tests/cta-lambda-header-sema-green/20260827_155733_206_0edcdf13/RunMetadata.json`;
- migrated Canonical TypeSema **1/1 PASS**:
  `Saved/Tests/cta-lambda-header-type-sema-green/20260827_155825_582_d8c0f5b0/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-lambda-header-parser-declarations-green/20260827_155919_446_58eb69e2/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-lambda-header-production-codegen-green/20260827_160000_979_728abf3e/RunMetadata.json`;
- Frontend Type **20/20 PASS**:
  `Saved/Tests/cta-lambda-header-frontend-type-green/20260827_160044_351_9b26546b/RunMetadata.json`.

The final direct line-bearing `asCScriptNode` inventory is declaration **49**,
expression **41**, statement **20** and core **5**. The large declaration drop
reflects physical removal of the signature/type-reconstruction helpers, not a
claim that all remaining node adapters are semantically complete.

CTA-S-21 is therefore repaired and verified as a bounded slice. Tasks 4.2,
4.3, 4.4 and 13.2 remain unchecked; compiler default remains LEGACY and Cache
V2 remains default-disabled.
