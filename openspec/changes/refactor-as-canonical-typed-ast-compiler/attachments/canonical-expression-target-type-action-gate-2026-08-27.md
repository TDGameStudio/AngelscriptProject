# Canonical expression target-type action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-20 — Parser-resolved cast/construct target types with no Sema node-type decoding |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | authored primitive functional cast `double(...)` and object construct `C()` on the parse→seal path |
| Construction/sealed-AST assertion | conversion/construct nodes retain the exact local canonical target QualType selected from the pointer-free syntax action |
| Architecture assertion | Parser binds each completed cast/construct syntax node to the already-resolved local QualType; `as_sema_expr.cpp` and the incremental `ActOnParsedExpr` cast route contain no `ActOnQualTypeFromNode` call |
| Expected RED | behavior is already mostly green, but expression lowering still asks Sema to decode each `snDataType`; the source-architecture test must fail before production edits |
| Production edit allowed after RED | one explicitly transitional exact node/section/offset-to-local-QualType binding, Parser publication from `BuildQualTypeSyntaxAction`, fail-closed lookup in cast/construct lowering, and deletion of the duplicated node-to-type calls |

## Locked design

1. Reuse `asSQualTypeSyntaxAction`; do not introduce a second durable type
   identity or persist numeric Runtime TypeId.
2. Parser resolves the target through `ActOnQualTypeAction` immediately after
   parsing the cast/construct type, then binds the transient expression syntax
   identity to that local QualType before any incremental expression callback.
3. The binding is migration-only Parser recovery state. It may retain the
   Parser-node identity plus exact section/offset, but it is not exposed by
   AST/public snapshots, detached artifacts, providers, relocations or cache.
4. Sema expression lowering must fail closed when a cast/construct produced by
   the Canonical Parser has no bound type. It must not silently re-decode the
   type node or select a permissive first-name fallback.
5. Preserve scalar functional-cast versus object-construction semantics,
   argument evaluation order, cleanup ownership and existing diagnostics.

## Required evidence

1. add semantic and source-architecture tests before production edits;
2. test-only Runtime/Editor build and valid focused RED;
3. production repair and Runtime/Editor build;
4. focused tests plus complete SemaAuthority GREEN;
5. ProductionCodeGen, Frontend Type and expression/conversion regressions;
6. source scans proving no node-to-type decode in expression lowering;
7. strict OpenSpec validation and parent/plugin `git diff --check`;
8. record every failure, runner issue, fix, evidence and non-claim.

## Mutation checks

Permanent tests must fail if a future change:

- removes either Parser target-type binding;
- restores `ActOnQualTypeFromNode` in `as_sema_expr.cpp` or the incremental
  cast route;
- carries an Engine type pointer or numeric TypeId in the transient binding;
- converts a scalar functional cast into an unresolved object construct;
- claims that general expression actions or lambda types are also complete.

## Non-claims

- The expression tree itself still uses transitional Parser-node lowering.
- Lambda parameter/signature types remain on their residual node route.
- Default/property/lambda/body/statement/lifetime action authority remains
  open.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation result

The first RED fixture used `cast<double>(40)`. This fork deliberately reserves
`cast<T>` for reference casts, so that fixture failed before reaching the
target-type assertion and could not serve as semantic evidence for primitive
conversion. The corrected fixture uses the supported functional-cast spelling
`double(40)` beside `C()`. This is a test-dialect correction, not a production
repair; the source-architecture assertion remains the intended RED until the
Parser-bound target-type route is implemented.

The test-only Runtime/Editor build passed before any production edit:

`Saved/Build/cta-expression-target-type-red-test-build/20260827_150238_096_3c4c8ce4/RunMetadata.json`.

The first complete SemaAuthority run was a valid **333/335 PASS, 2 FAIL**:

`Saved/Tests/cta-expression-target-type-red/20260827_150256_294_a8aed27a/RunMetadata.json`.

One failure was the intended architecture RED: neither cast nor construct had
the Parser-bound typed route. The other was the unsupported primitive
`cast<double>` fixture described above. After correcting only that test
spelling, the architecture assertion remained red and continued to authorize
the production change.

Parser now calls `BuildQualTypeSyntaxAction` and `ActOnQualTypeAction` directly
after parsing the target type in `ParseCast` and `ParseConstructCall`, then
publishes the resulting local QualType through `BindParsedExpressionType`.
The migration-only binding keeps only transient node identity, exact source
section/offset and the local `asCQualType`; it contains no `asITypeInfo*`,
numeric TypeId, stable external identity or snapshot-local AST reference.
Lookup first requires the exact node and then allows one unambiguous exact
section/offset match. Missing or ambiguous bindings fail closed with
`expression-target-type-unbound`.

`as_sema_expr.cpp` now obtains construct/cast destinations only through
`FindParsedExpressionType`. The incremental `ActOnParsedExpr` cast branch also
uses the shared expression route, so there is no second node-type decoder.
The remaining `ActOnQualTypeFromNode` production calls are three separately
named declaration/lambda-related adapters in `as_sema_decl.cpp`; none is in
Parser or expression target-type lowering.

## Build issue and disposition

The corrected-fixture build and the first production build both compiled and
linked `UnrealEditor-AngelscriptRuntime.dll`, but the test module stopped in the
clean, out-of-slice file
`AngelscriptNativeContextReturnValueTests.cpp`: it uses `ASTEST_AS_ANSI`
without including `AngelscriptTestMacros.h`. Exact records:

- `Saved/Build/cta-expression-target-type-red-fixture-correction-build/20260827_150554_992_0dd064aa/RunMetadata.json`;
- `Saved/Build/cta-expression-target-type-first-fix-build/20260827_151005_493_21b7ba9b/RunMetadata.json`.

This is an independent current-worktree clean-build blocker, not a Canonical
AST Runtime compile failure. To verify the changed test module, the missing
include was added transiently, the supported build runner was executed, and
the include was immediately removed. The final file has no logical content
diff from that validation workaround. The full build then passed at:

`Saved/Build/cta-expression-target-type-first-fix-test-module-build/20260827_151048_461_a9e83c24/RunMetadata.json`.

The workaround is not counted as implementation and this gate does not claim
that an untouched clean build from the current dirty aggregate is free of the
independent missing-include problem.

## Final evidence

| Gate | Result | Evidence |
|---|---:|---|
| SemaAuthority | **335/335 PASS** | `Saved/Tests/cta-expression-target-type-sema-green/20260827_151114_175_0b6031eb/RunMetadata.json` |
| ProductionCodeGen | **114/114 PASS** | `Saved/Tests/cta-expression-target-type-production-codegen-green/20260827_151224_854_556ceeca/RunMetadata.json` |
| Parser declarations | **18/18 PASS** | `Saved/Tests/cta-expression-target-type-parser-declarations-green/20260827_151305_977_e46c5ea4/RunMetadata.json` |
| Frontend CanonicalAST Type | **20/20 PASS** | `Saved/Tests/cta-expression-target-type-frontend-type-green/20260827_151450_953_7e06f64d/RunMetadata.json` |
| Language Conversions | **17/17 PASS** | `Saved/Tests/cta-expression-target-type-language-conversions-green/20260827_151527_750_95ebaf72/RunMetadata.json` |
| Expression Chain | **1/1 PASS** | `Saved/Tests/cta-expression-target-type-expression-chain-green/20260827_151620_271_b1c9dc7a/RunMetadata.json` |

Final static evidence finds exactly two Parser target-type publications, zero
`ActOnQualTypeFromNode` calls in Parser or `as_sema_expr.cpp`, and zero such
call in the incremental cast slice. The direct line-bearing Parser-node
inventory is now declaration **80**, expression **41**, statement **20** and
core Sema **5**. The core increase from three to five is the explicitly named
transient expression-binding API, not semantic type decoding.

`openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` passes.
Parent `git diff --check` and plugin `git diff --check HEAD` both exit zero;
they emit only existing LF→CRLF conversion notices. This closes CTA-S-20 only.
It does not close Tasks
`4.2`, `4.3`, `4.4`, `5.2`–`5.9`, or `13.2`; general expression trees,
defaults, properties, lambdas, bodies, statements and lifetime plans still
have Parser-node semantic adapters. Compiler default remains LEGACY and Cache
V2 remains default-disabled.
