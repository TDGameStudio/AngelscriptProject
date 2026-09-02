# CTA-S34: Canonical initializer-list expression typed-action gate

Date: 2026-08-28

Status: `green / expression-authority closed`

RED evidence: the standard Development Editor build failed only when the new
tests first referenced the deliberately absent `asSInitListExprAction`,
`asSInitListElementAction`, element-kind enum, and
`asCSema::ActOnInitListExprAction`. No prior production failure masked the gate.
Metadata:
`Saved/Build/cta-s34-init-list-typed-action-red/20260828_021504_182_3eb43e0c/RunMetadata.json`.

This card gates the final generic Parser expression callbacks. It is a bounded
Parser-to-Sema authority migration for expression-form initializer lists; it is
not evidence that Canonical CodeGen already implements every native AngelScript
list-pattern grammar.

## Scope and authority contract

Parser keeps `snInitList` and `ParseInitList()` for the retained native AST,
LEGACY compilation, syntax recovery, differential comparison, and future syntax
reference. While Parser owns those transient nodes it must publish one copied,
pointer-free `asSInitListExprAction` containing:

- the optional explicit target `asCQualType` for `TYPE = {...}`;
- the ordered exact expression identities of ordinary and nested elements;
- explicit omitted-element entries with copied half-open source offsets;
- an explicit trailing-separator fact rather than treating Parser's final
  `snUndefined` recovery sentinel as a semantic value;
- the complete expression range and an explicit recovery flag.

No `asCScriptNode*`, token-buffer pointer, Runtime object pointer, numeric
Runtime `typeId`, dump text, HIR object, or durable snapshot-local ID may cross
that action boundary. Sema owns validation, exact structural interning, target
type/list-factory selection, and construction of the durable Canonical AST.

## Required AST facts

1. A direct action test, with no `asCScriptNode`, proves explicit target type,
   ordered nested-list identity, and exact-child interning. Reusing the same
   range with a different child vector must not alias the first Construct.
2. Parser tests prove both anonymous `{...}` and explicit `TYPE = {...}` terms
   bind exact initializer-list identities. Nested lists remain nested Construct
   children; they must not be flattened or wrapped in Sequence.
3. An explicit typed list Construct immediately owns the target QualType and
   selected native list factory. An anonymous list stays contextual and the
   assignment route supplies its target/list factory.
4. Empty lists and trailing commas are represented without an invalid ExprId.
   A middle omitted element is not silently dropped: until Canonical CodeGen has
   a durable default-element representation, Sema must diagnose
   `initializer-list-omitted-element-unsupported` and fail that action closed.
5. Missing-`}` recovery retains only the completed prefix already published by
   child actions, sets the recovery fact, and never reparses native child
   semantics. Existing `ParserActOnListPatternBeforeBlockCloseFails` must keep
   observing `literal=list-pattern` and `args=1,2`.
6. `ActOnExprFromNode(snInitList)` becomes exact-identity-only and diagnoses
   `initializer-list-expression-action-missing` if Parser failed to publish.
   `InternParsedExprTerm` must likewise reuse the exact identity for this family.
7. `asCParser::ParseExprTerm()` contains zero calls to
   `sema->ActOnParsedExpr(node, script);`. If repository-wide callers are zero,
   the generic public `ActOnParsedExpr` declaration and implementation are
   physically removed; a renamed generic replay adapter is forbidden.

## Native compatibility and fail-closed boundaries

- Do not remove or simplify `ParseInitList`, `snInitList`, `asCScriptNode`,
  `asCBuilder`, `asCCompiler`, or explicit LEGACY selection in this change.
- Do not add HIR, AST dumps, serialized replay, or CANONICAL-to-LEGACY fallback.
- Native list patterns support nested patterns, default/omitted values,
  repeat/repeat-same shapes, wildcard type slots, and default constructors.
  Current Canonical `EmitListFactoryInto` is a flat repeat-element emitter. This
  gate may retain nested structure and fail unsupported lowering closed; it may
  not claim those CodeGen shapes complete or silently flatten/default them.

## RED tests

The following tests are added or strengthened before production changes:

- `SemaInitListExprTypedActionOwnsTargetNestedOrderAndExactIdentityWithoutScriptNode`
- `ParserInitListExprTermsUseTypedActionAndRetainNestedStructure`
- `ParserInitListOmittedElementFailsCanonicalActionClosed`
- `ParserInitListEmptyAndTrailingCommaPublishNoInvalidElement`
- the structural Parser source assertion is advanced from two generic callbacks
  to zero and asserts the dedicated binder is present;
- `ParserCastAndConstructTypesDoNotUseSemaNodeTypeDecoder` is changed to assert
  physical absence of the now-unused generic expression callback rather than
  slicing its implementation.

Expected RED: compile failure because `asSInitListExprAction` and
`ActOnInitListExprAction` do not exist, plus source-contract failures while the
two generic callbacks and `ActOnParsedExpr` still exist.

## Required GREEN evidence

1. Runtime/Editor development build.
2. Focused CTA-S34 methods, including the pre-existing missing-`}` recovery test.
3. Full `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority`.
4. `CanonicalAST.ProductionCodeGen`, broader Compiler CanonicalAST semantics,
   and native Frontend ScriptNode/initializer-list tests.
5. Source scans: zero generic Parser expression callbacks, zero public generic
   `ActOnParsedExpr`, identity-only `snInitList` consumer, native Parser retained.
6. `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict` and
   `git diff --check`.

Report paths and exact pass counts will be appended only after those commands
finish successfully. Any nested/default/list-pattern lowering gap found during
GREEN is recorded in the final-completion issue log and progress snapshot.

## GREEN result

- Initial compile RED: build failed only because the typed action API did not
  exist, at
  `Saved/Build/cta-s34-init-list-typed-action-red/20260828_021504_182_3eb43e0c/RunMetadata.json`.
- Final build: exit code 0 at
  `Saved/Build/cta-s34-empty-trailing-build/20260828_024521_626_841da958/RunMetadata.json`.
- Typed/nested/omitted/recovery focus: **6/6 PASS** at
  `Saved/Tests/cta-s34-init-list-typed-action-focused-green/20260828_023334_744_3f274e52/`.
- Empty/trailing separator focus: **1/1 PASS** at
  `Saved/Tests/cta-s34-empty-trailing-focused/20260828_024610_888_9d872f50/`.
- Final SemaAuthority: **367/367 PASS** at
  `Saved/Tests/cta-s34-sema-authority-final/20260828_024644_205_2744a5b8/`.
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s34-secondary-gates/20260828_023808_987_62671a34/`.
- Production scans find zero generic `ActOnParsedExpr` declarations,
  implementations or Parser calls. Native `ParseInitList`/`snInitList` remain.
- Strict OpenSpec validation passes. Parent and plugin `git diff --check` pass
  with only existing line-ending conversion warnings.

This closes the generic expression replay boundary only. Statement, control,
body, default/local initializer and lifetime action families remain open.

## Issues exposed during GREEN

- `Identifier = {...}` is syntactically ambiguous with
  `[TYPE '='] INITLIST`. The maintained native Parser gives that typed-temp
  production priority before assignment lookup, so a fixture spelling
  `Box = {4,5}` initially produced a target type named `Box` rather than an
  anonymous list assigned to variable `Box`. The anonymous assignment gate now
  uses `(Box) = {4,5}` to select the intended grammar without changing retained
  native Parser semantics. This is a source-grammar/diagnostic sharp edge, not
  evidence that the new action may consult declaration lookup to reinterpret a
  production after parsing.
- Native Parser/LEGACY accepts a middle omitted element, but Canonical AST does
  not yet have a durable default-element node and current CodeGen cannot emit
  that meaning faithfully. CTA-S34 diagnoses
  `initializer-list-omitted-element-unsupported` and fails closed rather than
  dropping the slot. This remains a CodeGen/AST breadth item.
- Nested list structure is now durable in the AST, but current
  `EmitListFactoryInto` supports only the flat repeat-element pattern. Nested,
  repeat-same, wildcard/default-constructor and default-element lowering remain
  open and block a general list-pattern completion claim.
