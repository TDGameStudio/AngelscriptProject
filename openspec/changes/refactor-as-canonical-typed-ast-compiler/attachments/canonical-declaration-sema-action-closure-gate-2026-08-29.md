# CTA-S55 — Canonical declaration Sema action closure gate

Date: 2026-08-29
Worktree: `D:\as-cta`
Scope: OpenSpec Task 4.2 only; Standalone excluded by the approved deferral.

## Outcome

Task 4.2 is complete at the current maintained-language boundary. Every
supported declaration family reaches Canonical Sema through a typed,
pointer-free action or an explicit declaration-start API. Canonical Sema does
not reconstruct declaration meaning by walking `asCScriptNode`.

This is an umbrella completion reconciliation over the previously recorded
CTA-S09 through CTA-S54 RED/GREEN gates. It does not add production code and
therefore does not invent a retrospective RED. The underlying declaration
slices each have their own AST-first RED, focused GREEN, and backend
regression evidence in the attachments named below.

## Declaration-family inventory

| Maintained declaration family | Canonical producer boundary | Permanent evidence |
|---|---|---|
| translation unit | `asCBuilder::AttachCanonicalSemaIfNeeded -> asCSema::ActOnTranslationUnit` before any section Parser action | all compile/seal SemaAuthority fixtures |
| namespace | copied ordered `asSNamespaceDeclActionSegment` payload through `ActOnNamespacePath` | `ParserNamespaceUsesTypedActionPayloadWithoutScriptNodeReplay`, `ParserActOnQualifiedNamespacePreservesEverySegment` |
| typedef | `asSTypedefDeclAction -> ActOnTypedefAction` | `ParserTypedefUsesTypedActionWithoutTypedefNodeReplay` |
| enum/enumerator | copied enum/enumerator name/range plus exact initializer ExprId | `ParserEnumUsesTypedNameActionsWithoutEnumNodeReplay`, `ParserEnumeratorInitializerUsesTypedActionAndExactIdentity` |
| funcdef | `asSFuncDefSignatureAction -> ActOnFuncDefSignatureAction` | `SemaFuncDefSignatureActionRecordsTypedCallableWithoutScriptNode`, retained parser rejection/host registration gates |
| class/struct/interface | `asSRecordHeaderAction`, ordered qualified bases, explicit finish action | `ParserRecordFamiliesUseTypedHeaderBaseAndFinishActionsWithoutReplay` |
| global function/method/mixin/constructor/destructor/interface method | `asSFunctionSignatureAction`, exact parameter context, typed traits and body action | `ParserFunctionFamilyUsesTypedActionsWithoutOrdinaryFunctionReplay` |
| global/field/local/for/foreach variable | `asSVariableHeaderAction` plus exact initializer/declarator action | global/field and local/loop variable typed-action gates |
| import | typed signature, parameter owner and origin action | `ParserImportUsesTypedStartAndOriginActionsWithoutImportNodeReplay` |
| parameter/default ownership boundary | `asSParameterDeclAction`; the optional default uses a separately typed ExprId/text action | `ParserParameterListUsesTypedActionWithoutParsedNodeTuple`, `ParserParameterDefaultUsesTypedActionAndExactIdentity` |
| named access declaration/membership | pointer-free specifier/permission payload and exact member edges | `ParserAccessSpecifierUsesTypedActionsWithoutNodeReplay` |
| lambda declaration header | `asSLambdaHeaderAction`, exact owner and typed parameters; body receives exact DeclId | lambda header/expression typed-action gates |

The historical `PropertyDecl` wording does not restore the removed virtual
property/autoaccessor dialect. The maintained fork intentionally diagnoses
that syntax. `PropertyAccessorGetSet` in the current Parser declaration matrix
passes by asserting rejection. Field declarations remain real `VarDecl`
facts, while generated accessor/default behavior stays tracked by Tasks 4.4,
4.5, 5.9, 9.5 and 13.6.

## Native-tree boundary audit

The native syntax tree is deliberately retained for grammar, recovery,
LEGACY, reference and differential testing. The completion criterion here is
that Canonical Sema does not receive or traverse it for declaration meaning.

Current `as_sema*` scan:

```text
firstChild = 0
lastChild = 0
->next = 0
ActOnParsedExpr = 0
ActOnExprFromNode = 0
ActOnParsedStatement = 0
ActOnParsedDeclaration = 0
ActOnQualTypeFromNode = 0
asCScriptNode production declarations/uses = 0
```

One `as_sema_expr.cpp` comment contains the text `asCScriptNode` only to state
that a path does not revisit it. It is not a type declaration, parameter,
field, include or dereference.

CTA-S54 additionally removed the last raw parse-node identity storage. The
remaining Parser/Builder association is copied build-local
`section + nodeKind + offset + length`, with idempotent same-value binding and
deterministic fail-closed conflicts.

## Fresh verification

Complete Canonical SemaAuthority:

`Saved/Tests/cta-s55-declaration-sema-closure/20260829_083224_231_df3c3613`

- total 405;
- passed 405;
- failed 0;
- skipped 0;
- exit 0.

Current Parser declaration matrix:

`Saved/Tests/cta-s55-parser-declaration-families-correct/20260829_083359_858_c04e37a0`

- exact prefix:
  `Angelscript.TestModule.AngelScriptSDK.Frontend.Parser.Declarations`;
- total 18;
- passed 18;
- failed 0;
- skipped 0;
- exit 0.

The latest unchanged-code downstream regression remains:

`Saved/Tests/cta-s54-parse-action-identity-consumer-final/20260829_082157_915_0b7f61b9`

- ProductionCodeGen + Module Canonical Snapshot + TypedASTJIT;
- total 186;
- passed 186;
- failed 0;
- skipped 0.

## Encountered issue: stale Parser prefix

The first Parser matrix command used the stale prefix:

`Angelscript.TestModule.AngelScriptSDK.Parser.Declarations`

Artifact:

`Saved/Tests/cta-s55-parser-declaration-families/20260829_083303_978_499b009c`

It selected no tests and exited non-zero. The current registration in
`AngelscriptNativeParserDeclarationsTests.cpp` includes the `Frontend`
segment. The no-selection run is excluded from behavioral evidence; no source
change was needed. The corrected exact prefix produced the 18/18 result above.

## Prior TDD cards that make the umbrella claim valid

The relevant production migrations and their original RED/GREEN evidence are
recorded in:

- `canonical-namespace-typed-action-gate-2026-08-27.md`;
- `canonical-enum-typed-action-gate-2026-08-27.md`;
- `canonical-typedef-typed-action-gate-2026-08-27.md`;
- `canonical-import-typed-action-gate-2026-08-27.md`;
- `canonical-function-typed-action-gate-2026-08-27.md`;
- `canonical-record-typed-action-gate-2026-08-27.md`;
- `canonical-global-field-variable-typed-action-gate-2026-08-27.md`;
- `canonical-local-loop-variable-typed-action-gate-2026-08-27.md`;
- `canonical-class-default-typed-action-gate-2026-08-27.md`;
- `canonical-funcdef-typed-action-gate-2026-08-27.md`;
- `canonical-access-specifier-typed-action-gate-2026-08-27.md`;
- `canonical-parameter-typed-action-gate-2026-08-27.md`;
- `canonical-declaration-qualtype-typed-action-gate-2026-08-27.md`;
- `canonical-lambda-header-typed-action-gate-2026-08-27.md`;
- `canonical-declaration-replay-retirement-gate-2026-08-27.md`;
- `canonical-pointer-free-parse-action-identity-gate-2026-08-29.md`.

## Non-claims and remaining work

Closing 4.2 means declaration creation is action-driven and Sema no longer
reconstructs declaration meaning from the native tree. It does **not** claim:

- Task 4.3 type resolution/template-instance parity is complete;
- Task 4.4 default/named-argument, property, lambda inference or list-pattern
  behavior is complete;
- Task 4.5 dependency/diagnostic/registration parity is complete;
- Task 4.6 has a deterministic isolated shadow-mismatch oracle;
- expression, statement, call, control and lifetime Tasks 5.x are complete;
- Task 13.2's complete Sema environment and backend-mechanical-only condition
  is complete;
- Canonical Runtime registration/Bytecode publication is independent from the
  prepared Builder shell;
- CANONICAL is the default, or that LEGACY may be deleted;
- Standalone was adapted or tested.

HIR remains physically absent. The native Parser tree and explicit LEGACY
Builder/Compiler remain intentionally available. The formal checklist moves
from **100/136 (73.5%)** to **101/136 (74.3%)**; 35 tasks remain open.
