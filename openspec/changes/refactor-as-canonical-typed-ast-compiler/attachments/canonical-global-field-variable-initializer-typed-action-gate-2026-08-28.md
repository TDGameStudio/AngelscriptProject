# CTA-S37: Canonical global/field variable-initializer typed-action gate

Date: 2026-08-28

Status: `GREEN`

Variable headers already cross `asSVariableHeaderAction`, but global and field
initialization still crosses `ActOnVariableInitializerFromNode`. Declaration
Sema unwraps an `snAssignment`, re-enters `ActOnExprFromNode`, and walks native
nodes through `IntegerInitText`. CTA-S37 removes that authority while retaining
the native Parser/AST/compiler and explicit LEGACY path.

## Action contract

`asSVariableInitializerAction` explicitly distinguishes:

- no authored initializer;
- one exact action-published initializer expression;
- direct construction with ordered exact argument expressions.

It also carries the exact variable DeclId, copied half-open declarator range and
recovery state. It contains no Parser/token/source-buffer pointer, Runtime
object pointer, numeric Runtime `typeId`, HIR object, dump or replay payload.

Sema owns parent validation, default-global value-object policy, constant
evaluation, direct construction, field init attachment and idempotent/conflict
rules. A global constant retains both its normalized evaluated value/text and
the exact source expression identity. A field retains the exact init expression
and does not use `defaultArg` as a second expression representation.

## Required AST facts

1. A direct pointer-free action binds exact Binary roots to global and field
   variables. The global freezes value 41 and the field owns one exact init.
2. Identical repeat publication is idempotent; a conflicting ExprId cannot
   overwrite an existing initializer.
3. Parser binary global/field initializers retain their Binary roots; comma
   declarators remain independent and ordered.
4. A no-initializer non-primitive global retains the sealed default-
   initialization trait.
5. Direct construction uses ordered exact argument IDs; unsupported global
   dynamic/non-scalar initialization continues to fail closed.
6. `ActOnVariableInitializerFromNode`, `IntegerInitText` and its node-search
   helper are physically removed from production. Native `ParseDeclaration`,
   `snDeclaration`, Builder, `asCCompiler` and LEGACY remain.

## RED tests

- `SemaGlobalFieldVariableInitializerTypedActionOwnsExactExprWithoutScriptNode`
- `ParserGlobalFieldInitializerUsesTypedActionAndExactIdentity`
- strengthen `ParserGlobalFieldVariableFamiliesUseTypedActionsWithoutWholeDeclarationReplay`.

Expected RED is a missing action type/API compile failure and a source-contract
failure while the old node adapter/helper remain.

## Required GREEN evidence

Development Editor build; focused direct/Parser/default-global/source tests;
full SemaAuthority; ProductionCodeGen + Semantics + retained ScriptNode;
production source scan; strict OpenSpec validation; parent/plugin diff checks.
Every unexpected issue or unsupported shape is recorded before GREEN.

## GREEN implementation

Parser now publishes one `asSVariableInitializerAction` per exact global/field
DeclId. The action explicitly represents no initializer, one exact expression,
or direct construction with ordered exact argument IDs. Assignment/list forms
use only the exact previously published expression identity. Parenthesized
forms are fully parsed under CANONICAL and cross copied arguments rather than a
superficial native node.

Sema validates the copied range and owner, applies the default-global value-
object policy, evaluates global scalar constants, constructs direct forms, and
attaches field init expressions. Global constants now retain the normalized
constant value/text and the exact source expression ID. Exact repeats are
idempotent; conflicting explicit initializers are rejected before mutation.

`ActOnVariableInitializerFromNode`, `IntegerInitText`, `FindConstantNode` and
the now-unused `CanonicalNodeText` helper are physically gone. Native
`ParseDeclaration`, `snDeclaration`, Builder, `asCCompiler` and LEGACY remain.

## Encountered issue

The deleted field helper recursively selected the first integer token and put
it in `Decl::defaultArg`. For `Field = 40 + 1`, that could record `"40"` beside
the real Binary init whose value is 41. No production field consumer needs this
second expression representation. Fields now keep only the exact init ExprId;
global scalar `defaultArg` remains the normalized evaluated presentation (`41`)
paired with `constantValue` and the exact init.

Direct non-scalar/dynamic global initialization remains a backend breadth gap:
the action and Construct AST are explicit, but current global publication only
supports scalar constants or the no-initializer value-object lifecycle.
Unsupported direct global forms continue to fail closed.

## Verified evidence

- expected missing-action RED build:
  `Saved/Build/cta-s37-global-field-initializer-action-red/20260828_034018_054_f81e5a74/RunMetadata.json`;
- GREEN implementation/test build:
  `Saved/Build/cta-s37-global-field-initializer-action-build-1/20260828_034552_765_b67da432/RunMetadata.json`;
- focused direct action, Parser exact identity, comma declarators, source
  contract and default-global policy: **5/5 PASS** at
  `Saved/Tests/cta-s37-global-field-initializer-focused-1/20260828_034621_430_e881b7ab/RunMetadata.json`;
- full SemaAuthority: **374/374 PASS** at
  `Saved/Tests/cta-s37-sema-authority-full/20260828_034801_064_994333d8/RunMetadata.json`;
- ProductionCodeGen + Canonical Semantics + retained native ScriptNode:
  **158/158 PASS** at
  `Saved/Tests/cta-s37-secondary-gates/20260828_034910_266_235b8461/RunMetadata.json`;
- production source scan, strict OpenSpec validation and parent/plugin diff
  checks pass; diff checks report only existing line-ending warnings.

No umbrella row closes, so mechanical progress remains **87/125 (69.6%)**.
The medium declaration-authority closure advances the conservative weighted
estimate to **about 69%** and safe default readiness to **about 41%**.
