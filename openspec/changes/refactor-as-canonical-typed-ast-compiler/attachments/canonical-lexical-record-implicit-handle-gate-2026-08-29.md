# CTA-S58 — lexical record implicit-handle QualType gate

Date: 2026-08-29
Worktree: `D:\as-cta`
Scope: OpenSpec Task 4.3 script-declared class/interface type semantics only;
Standalone remains excluded by the approved deferral.

## Gate card

| Field | Value |
|---|---|
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| RED method | `ParserScriptClassAndInterfaceTypesBecomeCanonicalImplicitHandlesFromLexicalDecls` |
| Real source path | parse complete script `class`, `interface` and `struct` declarations followed by ordinary global declarations through `asCParser -> typed record/type actions -> asCSema -> asCASTContext` |
| Required Canonical fact | script class/interface record declarations and uses are `REFERENCE_OBJECT + HANDLE`; the struct declaration/use remains `VALUE_OBJECT` without handle; all keep exact stable keys despite no authored `@` |
| Expected RED | record headers and lexical `ActOnQualType` currently classify non-value records as `REFERENCE_OBJECT` but preserve only authored qualifier bits; construct-expression helpers mask this gap by manufacturing owning temporary qualifiers on a separate path |
| Production change | make the Canonical declaration environment publish script reference records as implicit-handle QualTypes and derive lexical uses from that declaration semantic fact |
| Downstream gates | focused method, complete SemaAuthority, Parser declaration group, Frontend Type/TypeIdentity/TypeSema, ProductionCodeGen, Module Snapshot and TypedASTJIT |

## Evidence-backed gap

LEGACY `asCBuilder` creates every non-struct script class with
`asOBJ_IMPLICIT_HANDLE`; later `CreateDataTypeFromNode` observes that flag and
calls `MakeHandle(true)`. CANONICAL CodeGen likewise publishes script classes
as `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_NOCOUNT |
asOBJ_IMPLICIT_HANDLE`.

Canonical `ActOnRecordHeaderAction`, however, currently sets a class/interface
declaration type to `REFERENCE_OBJECT` with zero qualifiers. Both lexical lookup
loops in `ActOnQualType` return the same reference kind with the caller's
authored qualifiers only. A bare script class/interface declaration can
therefore reach variables, fields, parameters and return types without its
language-level implicit handle.

Existing construct-expression helpers are not sufficient evidence: they add
`HANDLE | AUTO_HANDLE` to an owning temporary independently of the declaration
type. CTA-S58 gates the ordinary declaration type path instead.

## Locked design

1. Script `struct` remains `VALUE_OBJECT` and never receives an implicit
   handle.
2. Script `class` and `interface` declarations publish
   `REFERENCE_OBJECT + HANDLE` in the Canonical declaration environment.
3. Lexical type lookup derives effective qualifiers from the matched Canonical
   declaration, not from Runtime registry publication or Builder state.
4. Ordinary implicit-handle declarations receive `HANDLE`, not
   `AUTO_HANDLE`; the latter remains specific to ownership-transfer surfaces
   such as construct/call results and explicit `+` syntax.
5. Parser actions remain source facts only and contain no record pointer,
   Runtime pointer or numeric TypeId.
6. Runtime projections retain the exact bridge-produced qualifiers; this
   slice must not rewrite native value/reference type semantics.
7. Native Parser AST, Builder and `asCCompiler` remain intact for LEGACY,
   syntax/recovery, reference, differential and rollback use. HIR remains
   physically absent.

## Mutation checks

The permanent test must fail if a later change:

- drops `HANDLE` from a script class or interface declaration;
- drops it from an ordinary lexical variable type;
- adds `AUTO_HANDLE` to an ordinary declaration;
- turns a script struct into a reference/handle type;
- changes any stable key while applying the effective qualifier;
- depends on Runtime publication, dynamic TypeId or Builder semantic replay;
- requires an authored `@` token.

## Required evidence ledger

- [x] gate card written before production edits;
- [x] test-only build passes and focused semantic RED is observed;
- [x] declaration-owned lexical implicit-handle derivation implemented;
- [x] focused and complete SemaAuthority GREEN;
- [x] Parser declaration, Frontend Type and downstream consumer regressions
  GREEN;
- [x] source-boundary scans, parent/plugin `git diff --check`, and strict
  OpenSpec validation pass;
- [x] all build/runner/design issues and final non-claims are recorded.

## Non-claims

- This slice does not close Task 4.3. Complete namespace/parent-type lookup,
  template-bearing scope segments, contextual lambda/funcdef inference,
  AST-local template declaration authority and final Builder reconciliation
  remain.
- It does not close Tasks 4.4-4.6, 5.x, 6.x, 13.2 or default cutover.
- Standalone is not adapted or run. Default remains LEGACY; there is no
  production `dual` backend or silent LEGACY fallback.

## TDD / issue ledger

### RED and implementation

1. The first test-only build was not a semantic RED. It failed with C4002
   because the new CQTest assertion accidentally passed `*Evidence` as a
   second `ASSERT_THAT` argument instead of as the message argument to
   `IsTrue`. This test-authoring error is excluded from the TDD RED:
   `Saved/Build/cta-s58-lexical-record-implicit-handle-red-build/20260829_093505_806_7160411c`.
2. After correcting only the assertion form, the unchanged-production build
   passed:
   `Saved/Build/cta-s58-lexical-record-implicit-handle-red-build-correct/20260829_093532_663_8ef6b089`.
3. The focused method then produced a valid semantic **0/1 RED**. Parsing
   completed and the Runtime registry remained empty, but class/interface
   record declarations and their ordinary global uses all dumped `quals=0`;
   the struct control also remained `quals=0`. The first class-record
   `REFERENCE_OBJECT + HANDLE` assertion failed:
   `Saved/Tests/cta-s58-lexical-record-implicit-handle-red/20260829_093552_836_fc3495a3`.
4. `ActOnRecordHeaderAction` now publishes script class/interface declarations
   as `REFERENCE_OBJECT + HANDLE` while script structs remain `VALUE_OBJECT`
   with no handle. `DeclaredEffectiveQualifiers` merges only this
   declaration-owned `HANDLE` bit into lexical uses; it deliberately does not
   infer reference direction or `AUTO_HANDLE` and does not inspect Builder,
   Runtime publication, pointers or numeric TypeIds.
5. The first-fix build passed and the focused test became **1/1 GREEN**:
   `Saved/Build/cta-s58-lexical-record-implicit-handle-first-fix-build/20260829_093749_085_3014d149`,
   `Saved/Tests/cta-s58-lexical-record-implicit-handle-focused-green/20260829_093800_218_fb3ab558`.

### Regression investigation

The first complete SemaAuthority run was **404/408**, with four failures:

- `DeclarationSemaOwnsSignaturesMixinLambdaAndBasesOnCompileSealPath`;
- `DerivedReferenceArgumentBindsBaseFormalBeforeCodeGen`;
- `InheritedClassBodySeesBaseBeforeExpressionSema`;
- `MixinCallBindsReceiverNotFreeGlobal`.

Artifact:
`Saved/Tests/cta-s58-lexical-record-implicit-handle-sema-authority/20260829_093834_467_e7554b96`.

The dumps proved these were stale textual expectations, not production
resolution/conversion regressions. The derived-to-base calls still contained
explicit `Conversion` nodes and resolved to `ReadBase(BaseValue@)`; mixin calls
still carried the receiver and resolved to `MixHelper(T@,int)`. The old tests
expected the semantically incomplete `ReadBase(BaseValue)` and
`MixHelper(T,int)` keys. Only those expectations were updated; production did
not normalize away the corrected handle qualifier.

The expectation-fix build passed, and the four focused regressions became
**4/4 PASS**:

- `Saved/Build/cta-s58-lexical-record-implicit-handle-regression-fixes-build/20260829_094144_852_6fdcd866`;
- `Saved/Tests/cta-s58-lexical-record-implicit-handle-four-regressions-green/20260829_094227_033_9b813091`.

### Final regression evidence

| Gate | Result | Artifact |
|---|---:|---|
| focused lexical class/interface/struct gate | 1/1 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-focused-green/20260829_093800_218_fb3ab558` |
| corrected signature regressions | 4/4 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-four-regressions-green/20260829_094227_033_9b813091` |
| complete SemaAuthority | 408/408 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-sema-authority-green/20260829_094304_876_f2646e3d` |
| Frontend Parser Declarations | 18/18 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-parser-declarations/20260829_094402_525_2d695b45` |
| Frontend Type/TypeIdentity/TypeSema | 20/20 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-frontend-types/20260829_094437_112_9620e4e9` |
| ProductionCodeGen + Module Snapshot + TypedASTJIT | 186/186 PASS | `Saved/Tests/cta-s58-lexical-record-implicit-handle-consumer-regression/20260829_094518_629_24baf48a` |

UE emitted optional `aqProf.dll`/VTune profiler-loader warnings and some
`https://www.google.com/generate_204` connectivity-probe timeouts. All affected
tests passed; these are environment warnings, not Canonical AST product
failures or hidden skips.

### Boundary and document validation

- Plugin `git diff --name-only` contains only `as_sema_decl.cpp` and the
  SemaAuthority test translation unit for this slice.
- `DeclaredEffectiveQualifiers` has one definition and exactly two production
  call sites, both in exact lexical Canonical declaration lookup. Runtime
  projections and the Runtime type bridge were not rewritten.
- `as_parser.cpp/.h` have zero matches for `typeId`, `TypeId`, `GetTypeId`,
  `asCObjectType`, `asCTypeInfo` or `asCDataType`; the two modified files have
  zero HIR matches.
- Plugin and parent `git diff --check` pass. Git reports only the repository's
  existing LF-to-CRLF checkout warning, not whitespace errors.
- `openspec validate "refactor-as-canonical-typed-ast-compiler" --strict`
  exits 0 with `Change 'refactor-as-canonical-typed-ast-compiler' is valid`.
