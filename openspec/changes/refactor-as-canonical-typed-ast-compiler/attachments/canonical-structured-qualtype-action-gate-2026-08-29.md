# CTA-S56 — structured QualType template-action gate

Date: 2026-08-29
Worktree: `D:\as-cta`
Scope: OpenSpec Task 4.3 template/qualifier slice only; Standalone excluded by
the approved deferral.

## Gate card

| Field | Value |
|---|---|
| Owning suite | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority` |
| Test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| RED method | `ParserStructuredQualTypeRejectsReadonlyTemplateSubtypeWithoutPromotingConstToOuterType` |
| Source fixture | registered `array<class T>` plus `array<const int> Values;` parsed through the real `asCParser -> asCSema -> asCASTContext` source path |
| Required sealed/public fact | syntax parsing succeeds, Canonical type Sema rejects the read-only template argument with a deterministic diagnostic, no `Values` declaration with a forged outer-`const array<int>` QualType is published, and the remaining graph seals |
| Expected RED | the current recursive qualifier collector folds the nested `const` token into the root action while the flat spelling formatter drops it, so Sema publishes `const array<int>` instead of rejecting `array<const int>` |
| Production change that makes the test green | replace the flat production type payload with a bounded pointer-free structured type action whose root and each template argument own separate spelling/token/qualifier/range facts; recursively resolve and validate template arguments in Sema before interning the complete instance |
| Downstream regression gate | complete SemaAuthority, current Frontend Parser declarations/CanonicalAST Type, ProductionCodeGen, Module Canonical Snapshot and TypedASTJIT prefixes |

## Evidence-backed root cause before RED

`asCParser::BuildQualTypeSyntaxAction` currently calls
`CollectQualTypeActionQualifiers(typeNode, action.qualifiers)`. That helper
recurses through every child `snDataType`, including template arguments. In
parallel, `FormatQualTypeActionSpelling` formats each nested type name but does
not encode its `const` token. Consequently `array<const int>` crosses the
Parser/Sema boundary as the semantically different flat pair:

```text
spelling  = array<int>
qualifiers = const
```

The legacy Builder does not accept that meaning. Its
`GetTemplateInstanceFromNode` resolves each subtype independently and rejects
`subType.IsReadOnly()` with `Template subtype must not be read-only`. The
Canonical path therefore currently loses both qualifier ownership and the
template-instantiation rejection fact.

The maintained raw-parser tests also document that bare `@` tokenization is
disabled in this fork. CTA-S56 deliberately uses the accepted `const`
template-subtype grammar rather than manufacturing a handle fixture that the
maintained Parser cannot recognize.

## Locked bounded design

1. Parser remains the only native syntax-tree reader. It copies a short-lived
   structured action and never passes an `asCScriptNode*` into Sema.
2. The action is pointer-free and contains no Runtime pointer, numeric TypeId,
   snapshot-local type reference, backend slot or Builder-owned object.
3. Root qualifiers and every template-argument qualifier are independent.
   Type modifiers (`&`, `in/out/inout`, `+`) apply only to the authored root
   passed with that declaration site.
4. Sema recursively validates each structured child, rejects read-only
   template arguments at the child range, creates the complete canonical
   template spelling from resolved child facts, and only then interns the
   template QualType.
5. Exact Runtime template lookup may use the current Engine type registry at
   Sema time, but only stable semantic identity enters the AST. No dynamic
   TypeId or Runtime pointer is retained.
6. Existing primitive, lexical, explicitly scoped and nested-template source
   forms must preserve their current Canonical stable keys and configured
   float width.
7. Native Parser AST, `asCBuilder::CreateDataTypeFromNode`, and LEGACY remain
   intact as grammar/reference/differential/rollback paths. HIR remains
   physically absent.

## Mutation checks

The permanent tests must fail if a future change:

- recursively promotes a template argument qualifier to the outer QualType;
- drops a template argument qualifier and silently accepts a different type;
- interns a template spelling before validating its child facts;
- retains a Parser node, Runtime pointer, numeric TypeId or snapshot-local
  type ref in the short-lived action;
- restores Builder/native-tree semantic replay in the CANONICAL Sema path;
- changes the accepted grammar merely to make the regression fixture pass.

## Required evidence ledger

- [x] focused test added before production edits;
- [x] valid RED observed for the semantic mismatch, not a fixture/build typo;
- [x] structured Parser action and recursive Sema resolution implemented;
- [x] focused GREEN and complete SemaAuthority GREEN;
- [x] Parser declaration and Frontend CanonicalAST Type regressions GREEN;
- [x] ProductionCodeGen + Module Snapshot + TypedASTJIT regressions GREEN;
- [x] pointer/TypeId/native-node boundary scans and `git diff --check` pass;
- [x] strict OpenSpec validation passes;
- [x] every runner/build/design issue and its disposition recorded below.

## Non-claims

- This slice does not by itself close all of Task 4.3. Contextual
  lambda/funcdef inference, the complete namespace/parent-type search matrix,
  implicit-handle parity and final CANONICAL independence reconciliation may
  remain.
- A template-bearing component inside a qualified scope, for example a future
  grammar form equivalent to `Outer<int>::Inner`, is not claimed by this
  action shape. The current Parser grammar/action copies a stable qualified
  base spelling and structures direct template arguments of the selected type;
  it does not model a template-argument list on every scope segment.
- The Runtime Engine registry remains a short-lived validation oracle for an
  exact template declaration/instance. This slice removes numeric TypeId and
  Runtime pointer persistence, but it does not yet replace every Engine lookup
  with a fully AST-local template-declaration registry.
- It does not close Tasks 4.4-4.6, expression/statement/call Tasks 5.x,
  snapshot publication, complete Bytecode lowering, Task 13.2 or default
  cutover.
- Standalone is not adapted or run. Product default stays LEGACY, Cache V2
  stays default-disabled, and there is no production `dual` or silent LEGACY
  fallback.

## TDD / implementation / issue ledger

The test-only Runtime/Editor build passed before any production edit:

`Saved/Build/cta-s56-structured-qualtype-red-build/20260829_085049_654_992c2f0e`

The first attempted single-method prefix omitted CQTest's generated class-name
segment and selected no tests:

`Saved/Tests/cta-s56-structured-qualtype-red/20260829_085113_224_fb525c9e`

That no-selection run is a runner-addressing issue and is excluded from
behavioral evidence. Inspection of the prior SemaAuthority report showed that
the registered path contains
`FCanonicalASTSemaAuthorityTests.<Method>`. The corrected exact prefix selected
one test and produced the intended valid RED:

`Saved/Tests/cta-s56-structured-qualtype-red-correct/20260829_085204_023_c00b23cc`

- total 1;
- passed 0;
- failed 1;
- skipped 0;
- the fixture parsed and the remaining AST sealed;
- failure: missing `qualtype-template-subtype-readonly` diagnostic.

This proves the current flat action accepts a semantically different type. The
later assertions that reject a published `Values` declaration and a prematurely
interned parent template remain in the same permanent test; CQTest's first
assertion stops the RED run before those assertions execute.

## Production implementation

`asSQualTypeSyntaxAction` now owns an indexed pre-order array of
`asSQualTypeSyntaxNode` values. Each value carries only owned/stable syntax
facts:

- base spelling and Parser-configured primitive token;
- qualifiers local to that type node;
- direct-template-child index/count and complete subtree size;
- half-open processed-source range.

No `asCScriptNode`, Builder/Runtime pointer, numeric TypeId, AST-local type
reference or backend slot is present in the action. Parser remains free to
retain its native tree for grammar, recovery, LEGACY and later differential
work, but that tree is not the semantic Sema input.

`asCParser::AppendQualTypeSyntaxNode` copies the root and nested template
arguments recursively. It deliberately reads the configured primitive token
from each `snDataType` root instead of rediscovering it from the lexical child;
that preserves the maintained `floatIsFloat64` configuration. Root type
modifiers are merged only into the root payload.

`asCSema::ActOnQualTypeSyntaxNode` validates the bounded tree encoding,
resolves children before parents, rejects a read-only child at the child's
range, constructs an exact stable template spelling from resolved child type
keys, asks the Engine registry whether that exact instance exists, and interns
the canonical template type only after those checks succeed. A nested handle
qualifier is represented in the lookup spelling; other unsupported template
subtype modifiers fail closed.

This is the intended dynamic-TypeId boundary: the Engine may answer an
ephemeral type-registry query during Sema, but neither its pointer nor its
numeric identity enters the AST. Downstream Bytecode, snapshot, Cache and
TypedASTJIT consumers continue to observe ASTContext-local refs backed by
stable semantic keys such as `array<int>`.

## Implementation and test issue ledger

The first production-shape compile gate intentionally failed after the RED
test was in place because the test referenced the not-yet-created structured
contract (`asSQualTypeSyntaxNode` and `action.nodes`):

`Saved/Build/cta-s56-structured-qualtype-action-api-red-build/20260829_085414_955_2bd5170c`

This was the expected API RED. After adding the payload, Parser copier and Sema
resolver, the first implementation build passed:

`Saved/Build/cta-s56-structured-qualtype-first-fix-build/20260829_090013_348_92fff47f`

The first focused GREEN attempt failed at `Context.Seal()`:

`Saved/Tests/cta-s56-structured-qualtype-focused-green/20260829_090046_015_c2270372`

- total 1;
- passed 0;
- failed 1;
- the new read-only-child diagnostic was already present;
- the failure was therefore not evidence that the production semantic fix had
  failed.

A test-only diagnostic build and run exposed verifier status `1`, detail
`translation-unit`:

- `Saved/Build/cta-s56-structured-qualtype-debug-evidence-build/20260829_090200_284_1e59f480`
- `Saved/Tests/cta-s56-structured-qualtype-debug-evidence/20260829_090229_316_86708add`

The invalid-only fixture correctly published no declaration and therefore no
translation unit to seal. Changing production code to manufacture a semantic
root for an entirely rejected file would have changed the contract. The
permanent fixture instead adds a valid `int Anchor;` before the rejected
declaration, proving that rejection neither corrupts nor prevents sealing an
otherwise normal graph. The test-fixture rebuild passed:

`Saved/Build/cta-s56-structured-qualtype-anchor-fixture-build/20260829_090313_480_e9141eca`

The corrected focused semantic gate then passed 1/1:

`Saved/Tests/cta-s56-structured-qualtype-focused-green-2/20260829_090333_874_b47a3779`

The direct no-Parser-node action test also passed 1/1 and proves structured
`array<int>` resolution plus exact outer qualifier preservation:

`Saved/Tests/cta-s56-structured-qualtype-direct-action-green/20260829_090406_886_acf73149`

The first complete SemaAuthority run selected 406 tests and failed four:

`Saved/Tests/cta-s56-structured-qualtype-sema-authority/20260829_090442_070_947069ab`

- `CompileSealDefaultFloatComparisonNormalizesOperandWidths`;
- `CompileSealDefaultFloatReturnNormalizesToSignatureWidth`;
- `CompileSealFloatGlobalConstantsFreezeResolvedStorageWidths`;
- `ParserDeclarationTypeSitesUseTypedActionWithoutNodeAdapter`.

The three float failures had one root cause: the first copier version read the
lexical `float` child token instead of the Parser-configured root token. In this
fork, authored `float` may intentionally resolve as `ttDouble`; the structured
action must preserve that already-recognized semantic width. Reading the root
token fixed all three without querying a dynamic TypeId.

The source-boundary test failure was a mutation-test false positive: its
strict action-slice scan found the literal word `TypeId` in the new explanatory
comment, not a field. The scan remains strict and the comment now says
`numeric runtime type identity`, so future real fields are still rejected.

The corrective build passed:

`Saved/Build/cta-s56-structured-qualtype-float-fix-build/20260829_090559_831_28d6e3fc`

The exact four regressions passed 4/4:

`Saved/Tests/cta-s56-structured-qualtype-regression-fixes/20260829_090629_419_87b18b6b`

## Final GREEN evidence

| Gate | Result | Artifact |
|---|---:|---|
| Complete CanonicalAST SemaAuthority | **406/406 PASS** | `Saved/Tests/cta-s56-structured-qualtype-sema-authority-green/20260829_090703_057_72346027` |
| Frontend Parser declarations | **18/18 PASS** | `Saved/Tests/cta-s56-structured-qualtype-parser-declarations/20260829_090751_284_3f8341f1` |
| ProductionCodeGen + Module CanonicalAST Snapshot + StaticJIT TypedASTJIT | **186/186 PASS** | `Saved/Tests/cta-s56-structured-qualtype-consumer-regression/20260829_090840_329_54c22e57` |
| Frontend Type + TypeIdentity + TypeSema | **20/20 PASS** | `Saved/Tests/cta-s56-structured-qualtype-frontend-types/20260829_091100_105_1e584434` |

The combined downstream run emitted the existing provider-test connectivity
warning for Google's `generate_204` probe. It did not fail, skip or weaken any
test and is not counted as positive external-network evidence.

## Final static boundaries

- The bounded `asSQualTypeSyntaxNode`/`asSQualTypeSyntaxAction` source slice
  contains no `asCScriptNode`, `asITypeInfo`, numeric TypeId field or AST-local
  type reference.
- The new Sema resolver traverses only `action.nodes`; it does not read
  `firstChild`, `lastChild` or `next` and accepts no native syntax node.
- Native `asCScriptNode` construction/traversal remains in Parser by design for
  grammar, recovery, LEGACY, reference and differential use.
- The maintained source tree still contains only the pre-existing provenance
  statement that function-owned HIR is removed; this change adds no HIR type,
  file, token or route.
- Plugin and parent `git diff --check` pass. Line-ending warnings report the
  configured LF-to-CRLF checkout policy and are not whitespace errors.
- `openspec validate refactor-as-canonical-typed-ast-compiler --strict`
  reports `Change 'refactor-as-canonical-typed-ast-compiler' is valid`.

Task 4.3 remains unchecked: this closes the structured direct-template and
qualifier-ownership slice, not the complete namespace/parent-type matrix,
contextual lambda/funcdef inference, implicit-handle parity, AST-local template
declaration authority or final Builder-adapter reconciliation.
