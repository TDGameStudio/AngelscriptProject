# Canonical import typed-action gate — 2026-08-27

## Gate card

| Field | Value |
|---|---|
| Slice | CTA-S-10 — import declaration typed start/origin finish actions |
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Source fixtures | two-parameter import missing `from`; import with origin missing `;`; complete import followed by a function |
| Sealed-AST assertion | start action preserves name, return type and every parameter before `from`; origin action preserves module dependency before `;`; complete import is unique with exact key and origin |
| Architecture assertion | `ParseImport()` publishes typed signature/origin actions, never calls `NotifySema(node)`, the generic completed callback excludes `snImport`, and `WalkOne` has no `case snImport` |
| Expected RED | current Parser notifies the same growing `snImport` two or three times and `WalkOne` rediscovers name, return type, params and origin from its children |
| Production edit allowed after RED | yes, limited to import declaration start/finish ownership and the parameter-owner selection needed for multiple incremental params |

## Locked design

Parser publishes an import in two semantic phases:

1. after return type, name and before parsing the parameter list, publish a
   typed start action and push the exact import DeclContext so parameter
   actions attach incrementally;
2. after recognizing the quoted module string and before `;`, publish an
   origin finish action that records the import origin/dependency and finalizes
   its stable signature.

The action payloads contain recognized value facts and half-open source
offsets; they never contain an `asCScriptNode*`. Parser continues to construct
`snImport` and its function shell for the explicit LEGACY oracle and recovery.

## Transitional dependency made explicit

This slice removes import declaration replay, not the general type/parameter
migration. The Parser obtains the import return `asCQualType` through the
existing `ActOnQualTypeFromNode` adapter, and each parameter still uses the
existing `ActOnParsedParam` adapter. Those are named Task 4.3/4.4/13.2 debt and
must be replaced by general typed type/parameter payloads later. They may not
be hidden inside an `snImport` replay after this slice.

## Required evidence

1. focused source-architecture RED before production edits;
2. two-parameter early-action, origin-before-semicolon and complete unique
   behavior gates;
3. Runtime/Editor build, focused architecture GREEN;
4. full SemaAuthority and ProductionCodeGen GREEN;
5. source scans, strict OpenSpec validation, parent/plugin `diff --check`;
6. issue/progress/task ledgers updated without checking umbrella tasks.

## TDD and implementation record

The permanent source-architecture test is
`ParserImportUsesTypedStartAndOriginActionsWithoutImportNodeReplay` in
`AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`. Its test-only build
passed at
`Saved/Build/cta-import-typed-action-red-test-build/20260827_085912_047_df9ac09b/RunMetadata.json`,
then the focused run produced the intended **0/1 RED** at
`Saved/Tests/cta-import-typed-action-red/20260827_085930_436_2640d507/Report/index.json`.
The exact missing contract was `ActOnImportSignatureAction`; this was a valid
RED against the pre-edit production source, not a runner or compile failure.

The bounded production change adds:

- `asSImportSignatureAction {name, returnType, beginOffset, endOffset}` and
  `ActOnImportSignatureAction`;
- `asSImportOriginAction {origin, beginOffset, endOffset}` and
  `ActOnImportOriginAction`;
- an import-aware `ParseFunctionDefinition(asASTDeclId*)` path that publishes
  the signature before parsing parameters and pushes the exact import context;
- incremental parameter attachment, including fallback to the current
  declaration context when `lastActedDecl` is the preceding parameter;
- origin publication after the quoted module and before the semicolon;
- exclusion of `snImport` from the generic completed callback and removal of
  `case snImport` from `WalkOne`.

Parser continues to build the legacy `snImport` shell for the explicit LEGACY
oracle and recovery, but Canonical Sema no longer decodes declaration meaning
from that shell.

## Invalid assertion run

The first strengthened behavior group was **2/3 PASS** at
`Saved/Tests/cta-import-typed-action-behavior-green/20260827_090344_514_cf0a1f8d/Report/index.json`.
This was not a product RED. The dump already contained the unique declaration
`SharedValue(int,double)`, parameter `a` with `int`, and parameter `b` with
`double`. The assertion incorrectly expected source spelling `float`; this
fork is configured with `asEP_FLOAT_IS_FLOAT64=1`, so the canonical type is
`double`. The assertion-only build passed at
`Saved/Build/cta-import-canonical-float-assertion-fix-build/20260827_090442_465_27dc4ac4/RunMetadata.json`.

## Production RED and root cause

The first full ProductionCodeGen run was a valid **113/114 PASS** product RED
at
`Saved/Tests/cta-import-typed-action-production-full/20260827_090617_602_128e9cb9/Report/index.json`.
Only `PreparedImportBindsExactShellAndExecutes` failed: the Canonical import
declaration had its exact stable key, origin and resolved call route, but the
prepared Runtime import shell did not receive the producer-carried declaration
key.

Root cause: removing `NotifySema(snImport)` correctly removed semantic replay,
but that old callback had also implicitly populated the transitional
`parsedDeclBindings` pointer-to-Decl map. Later Builder registration still
hands the exact outer `snImport` shell to `BindCanonicalFunctionIdentity`; the
missing pointer association left `canonicalASTStableDeclKey` empty even though
the Canonical declaration itself was correct.

The repair adds the explicitly non-semantic
`BindParsedDeclarationIdentity(asCScriptNode*, asASTDeclId)` bridge. Parser
binds the already-created import DeclId to the legacy shell after signature
creation. The bridge copies identity only: it does not decode the import name,
return type, parameters, origin, route or dependency from the Parser node. It
must be removed with the remaining Builder/Parser mapping during Tasks
`3.4`/`13.8`/`13.2`; it is not a new semantic authority API.

## Final evidence

- initial Runtime/Editor build PASS:
  `Saved/Build/cta-import-typed-action-fix-build/20260827_090222_308_1c39e4cf/RunMetadata.json`;
- focused architecture **1/1 PASS**:
  `Saved/Tests/cta-import-typed-action-focused-green/20260827_090313_331_71b305f7/Report/index.json`;
- corrected behavior group **3/3 PASS**:
  `Saved/Tests/cta-import-typed-action-behavior-final-green/20260827_090503_457_43a4097b/Report/index.json`;
- complete SemaAuthority **313/313 PASS**:
  `Saved/Tests/cta-import-typed-action-sema-full/20260827_090536_520_a4d32fa9/Report/index.json`;
- producer-identity repair build PASS:
  `Saved/Build/cta-import-producer-identity-fix-build/20260827_090851_854_049b2ae5/RunMetadata.json`;
- focused prepared-import execution **1/1 PASS**:
  `Saved/Tests/cta-import-producer-identity-focused-green/20260827_090916_453_87251d41/Report/index.json`;
- final complete ProductionCodeGen **114/114 PASS**:
  `Saved/Tests/cta-import-typed-action-production-final-green/20260827_090951_990_d8a66d79/Report/index.json`.

Final source scans find no `case snImport`; `ParseImport()` has no
`NotifySema(node)`. Direct `asCScriptNode` occurrence inventory is now
`as_sema_decl.cpp=111`, `as_sema_expr.cpp=42`, `as_sema_stmt.cpp=27`, and
`as_sema.cpp=3`. The one additional `as_sema.cpp` occurrence is the named
identity-only bridge above. Parent and plugin `git diff --check` passed with
existing LF/CRLF notices only, and strict OpenSpec validation passed before
this record update; it is rerun after the synchronized ledgers below.

## Non-claims

- General typed type/parameter/default payloads remain open.
- Import binding/publication execution remains covered by existing
  ProductionCodeGen tests; this slice does not redesign module linking.
- Class/interface/mixin/function/variable/expression/statement replay remains.
- Compiler default remains LEGACY and Cache V2 remains default-disabled.
