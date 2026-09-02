# Canonical declaration QualType typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-19 — pointer-free type syntax action for declaration signatures and variable headers |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Semantic fixture | direct `asSQualTypeSyntaxAction` for `array<int>` with `const &in`, plus existing Parser compile/seal fixtures for primitive width, template, handle/ref/direction, qualified script types and declaration families |
| Construction/sealed-AST assertion | Sema resolves the short-lived spelling/token/qualifier action to one valid local `asCQualType` with exact template stable key and qualifier mask; no Parser node or Runtime identity crosses the action |
| Architecture assertion | all declaration-producing Parser call sites use `BuildQualTypeSyntaxAction -> ActOnQualTypeAction`; `as_parser.cpp` contains no `ActOnQualTypeFromNode` call |
| Expected RED | the action struct/API/helper do not exist and Parser still passes `snDataType`/type-modifier nodes directly into Sema at import, parameter, funcdef, ordinary/interface function, variable and foreach sites |
| Production edit allowed after RED | short-lived pointer-free action, Parser-only syntax extraction, Sema type resolution, migration of all declaration call sites, and preservation of a separately named residual FromNode boundary only for lambda/expression recovery |

## Locked design

1. `asSQualTypeSyntaxAction` contains only a complete type spelling, the
   Parser-resolved primitive token when the root is primitive, syntactic
   qualifier bits and exact half-open source offsets. It contains no
   `asCScriptNode*`, Runtime pointer, numeric Runtime TypeId or foreign
   snapshot-local type reference.
2. Parser remains the syntax recognizer. It may inspect its transient syntax
   nodes to copy one complete action, but Sema alone converts that action into
   a local `asCQualType`, resolves lexical/qualified/Runtime nominal identity,
   selects template/value/reference/enum/funcdef kind and applies qualifiers.
3. Preserve the existing configured `float`/`double` behavior and current
   template spelling normalization. This slice moves authority across the
   boundary; it does not redesign accepted type grammar or numeric widths.
4. Migrate every live declaration-site Parser call: import return, callable
   return, parameter, global/field/local/for variable and foreach variable.
   No partial mix of old and new routes is allowed in `as_parser.cpp`.
5. `ActOnQualTypeFromNode` may remain only for explicitly residual lambda and
   expression/cast/construct recovery inside Sema. It must not remain callable
   from Parser and must not be presented as final Task 4.3 closure.

## Required evidence

1. add semantic and source-architecture tests before production edits;
2. test-only Runtime/Editor build and valid RED;
3. production repair and Runtime/Editor build;
4. focused new tests plus complete SemaAuthority GREEN;
5. ProductionCodeGen, Parser declarations and Frontend Type regressions GREEN;
6. source scans for Parser `ActOnQualTypeFromNode` zero and exact migrated
   action routes;
7. strict OpenSpec validation and parent/plugin `git diff --check`;
8. record every RED/failure/runner issue/root cause/fix/evidence/non-claim in
   the final ledgers.

## Mutation checks

Permanent tests must fail if a future change:

- passes a type or modifier Parser node into Sema from declaration parsing;
- drops template spelling, const/handle/reference/direction qualifiers or
  configured primitive width;
- embeds Runtime pointers, numeric TypeIds or foreign AST refs in the action;
- restores permissive first-name type lookup outside the existing fail-closed
  Sema resolution contract;
- claims that residual lambda/expression type decoding has also been removed.

## Non-claims

- Default-expression, property/accessor, lambda/list-pattern/body and general
  expression/statement/lifetime actions remain open.
- Residual Sema `ActOnQualTypeFromNode` use for lambda/expression recovery
  remains open, so Task 4.3 and 13.2 stay unchecked.
- Builder/Runtime registration, detached backend completeness, TypedASTJIT HIR
  retirement, production-entry closure and default cutover are unchanged.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.

## TDD and implementation result

The two permanent tests were added before production edits. The test-only
Runtime/Editor compile produced the intended valid RED at
`Saved/Build/cta-declaration-qualtype-action-red-test-build/20260827_144035_331_ea2671f1/RunMetadata.json`:
the compiler failed only because `asSQualTypeSyntaxAction` and
`ActOnQualTypeAction` did not yet exist.

Production now provides a short-lived `asSQualTypeSyntaxAction` with complete
spelling, root primitive token, qualifier mask and half-open source offsets.
Parser assembles that payload while it still owns syntax, including explicit
scope and template arguments. Sema validates the payload, canonicalizes a root
primitive when present, otherwise resolves the complete spelling through its
existing exact lexical/qualified/Runtime type contract, and applies the
qualifiers. The following seven declaration routes now use
`ActOnQualTypeAction(BuildQualTypeSyntaxAction(...))`: import returns,
parameters, funcdef returns, ordinary function returns, interface-method
returns, global/field/local/`for` declarations, and `foreach` declarations.
There is no `ActOnQualTypeFromNode` call in `as_parser.cpp`.

The repair build and verification results are:

- Runtime/Editor build PASS:
  `Saved/Build/cta-declaration-qualtype-action-first-fix-build/20260827_144619_355_c3e76329/RunMetadata.json`;
- focused new tests **2/2 PASS**:
  `Saved/Tests/cta-declaration-qualtype-action-focused-first-green/20260827_144720_697_8f5e2de3/RunMetadata.json`;
- complete SemaAuthority **333/333 PASS**:
  `Saved/Tests/cta-declaration-qualtype-action-sema-green/20260827_144808_676_95784871/RunMetadata.json`;
- ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-declaration-qualtype-action-production-codegen-green/20260827_144856_587_4974dfa3/RunMetadata.json`;
- Parser declarations **18/18 PASS**:
  `Saved/Tests/cta-declaration-qualtype-action-parser-declarations-green/20260827_145041_742_1434b1c0/RunMetadata.json`;
- Frontend CanonicalAST Type prefix **20/20 PASS** (including the matching
  Type, TypeIdentity and TypeSema tests):
  `Saved/Tests/cta-declaration-qualtype-action-frontend-type-green/20260827_145116_223_12ac1673/RunMetadata.json`.

The final source scan finds exactly seven Parser declaration-type action calls,
zero Parser node-adapter calls and no `asCScriptNode`, `asITypeInfo`, numeric
`TypeId` or `asCASTTypeRef` field in the action. Direct line-bearing
`asCScriptNode` counts remain declaration **83**, expression **42**, statement
**20** and core Sema **3**. Eight `ActOnQualTypeFromNode` textual sites remain
inside Sema/header: one declaration, six uses and one declaration API across
lambda/property/expression/cast/construct recovery. They are explicitly not
claimed as complete type-Sema retirement.

One initial read-only scan used the stale guessed
`Private/AngelscriptCode/angelscript/source` path. It found no files and is not
evidence; the corrected scan targets the maintained fork under
`AngelscriptRuntime/ThirdParty/angelscript/source`. No build/test runner issue
occurred in this slice. Strict OpenSpec validation and separate parent/plugin
`git diff --check` pass; only existing LF/CRLF conversion notices are emitted.

This closes CTA-S-19 only. A QualType action's range is validated at the
Parser/Sema boundary but is not persisted on the interned type object, which
has no source-range field. Residual lambda/expression type recovery,
default/named arguments, property/accessor, lambda/list-pattern/body,
expression/statement/lifetime actions, Builder/Runtime installation,
TypedASTJIT HIR retirement and default cutover remain open. Compiler default
remains LEGACY and Cache V2 remains default-disabled.
