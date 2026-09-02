# Canonical Lambda-to-funcdef overload viability gate (CTA-S63)

Date: 2026-08-29

## Scope

This gate advances Tasks 0.2, 4.4, 5.2, 5.3, 5.9 and 13.2 by moving
Lambda-to-funcdef candidate viability into Canonical overload ranking. CTA-S61
and CTA-S62 already make the selected contextual conversion authoritative for
the Lambda signature, omitted formal types and reachable body facts. CTA-S63
closes the earlier decision point: an incompatible funcdef formal must not
remain an overload candidate merely because the argument declaration is a
Lambda-shaped function.

Standalone remains explicitly deferred by user direction and is neither
changed nor run. The product default remains `LEGACY`; native
`asCScriptNode`/Builder/Compiler storage remains available for the independent
LEGACY, syntax/recovery, reference/differential and rollback paths. HIR is
physically absent and must not be recreated.

## AST-first gate card

Test source:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

### `ParserOmittedLambdaAritySelectsOnlyViableFuncdefOverload`

Host funcdefs:

```angelscript
funcdef bool UnaryCallback(int);
funcdef bool PairCallback(int, int);
```

Source call:

```angelscript
Choose(function(Value)
{
    return Value > 0;
});
```

Required sealed facts:

- the one-formal Lambda makes only `Choose(UnaryCallback)` viable;
- the selected Call resolves to that exact overload;
- its argument is an explicit conversion to stable funcdef type
  `UnaryCallback` whose child resolves to the exact Lambda declaration;
- contextualization then gives the Lambda parameter source-level `int`, gives
  the Lambda return `bool`, and records the exact `UnaryCallback` dependency;
- `PairCallback` is not published as a Lambda dependency and no overload or
  unresolved-callee diagnostic remains.

### `ParserExplicitLambdaTypeSelectsOnlyViableFuncdefOverload`

Host funcdefs have equal arity but distinct formal types:

```angelscript
funcdef bool IntCallback(int);
funcdef bool BoolArgCallback(bool);
```

The source Lambda explicitly authors `int Value`. Required sealed facts:

- only `Choose(IntCallback)` remains viable;
- the selected Call/conversion/dependency use exact stable key `IntCallback`;
- `BoolArgCallback` is not accepted merely because the argument is a Lambda;
- the explicit Lambda formal remains unchanged and the graph seals without
  diagnostics.

### `ParserAllOmittedLambdaFuncdefCandidatesRemainAmbiguousWithoutMutation`

Host funcdefs have equal arity and distinct formal types, while the source
Lambda omits its only formal type and its body does not constrain that formal.
Required candidate-isolation facts:

- both candidates remain equally viable and Sema reports exactly
  `ambiguous-overload` rather than selecting registration order;
- no `Choose` overload becomes the resolved Call;
- the omitted Lambda formal remains invalid/uninferred because no candidate
  won;
- neither `IntCallback` nor `BoolCallback` becomes a Lambda dependency.

This review-added characterization dynamically guards the non-claim below and
proves that read-only candidate exploration does not commit the first viable
funcdef's type, dependency or bound-target state.

### `ParserLambdaRejectsAllIncompatibleFuncdefOverloadsWithoutAmbiguity`

Host funcdefs have zero and two formals while the Lambda has one omitted
formal. Required fail-closed facts:

- neither overload is selected or contextually applied;
- Sema reports the ordinary unresolved-callee result for zero viable
  candidates and does not report `ambiguous-overload`;
- neither funcdef stable key becomes a Lambda dependency;
- the construction-only omitted formal remains uninferred; the pointer-free
  graph still seals structurally with an unresolved/error Call, while Sema's
  diagnostic makes compilation fail closed rather than inventing a type or
  selecting an arbitrary candidate.

## Intended implementation boundary

1. Overload ranking performs a read-only Lambda-to-funcdef viability query.
2. The query validates exact authored formal count and explicitly typed formal
   types against the candidate funcdef. Omitted formals are wildcards only for
   their corresponding positions; they do not erase the arity requirement.
3. An exact Canonical `FuncDefDecl` is authoritative. A host funcdef is compared
   through the same deterministic Runtime ABI normalization already used by
   CTA-S61/S62, without writing inferred types during candidate exploration.
4. Candidate exploration must not mutate Lambda declarations, body
   expressions, diagnostics, dependencies, stable keys or bound-funcdef state.
5. Only after a unique overload is selected may
   `ContextualizeLambdaToFuncdef` perform the CTA-S62 write/reconciliation pass.
6. Bytecode, TypedASTJIT, Snapshot and Cache consume the selected sealed facts
   mechanically and never perform overload viability or contextual inference.

## RED expectation

The current `RankArgument` gives every function-valued declaration rank 1 for
every funcdef formal. Because a Lambda is represented by a Canonical Function
declaration, all same-call funcdef overloads remain viable regardless of
signature. The two positive tests should therefore fail with
`ambiguous-overload`, while the negative test should expose the same false
ambiguity instead of the required zero-viable-candidate result.

## Required downstream evidence

- test-only Runtime/Editor build;
- focused RED for all three exact methods with the expected false-ambiguity
  evidence;
- focused GREEN;
- complete `SemaAuthority` prefix;
- Parser declarations, Frontend Canonical type surface, Canonical
  ProductionCodeGen, Module Snapshot and TypedASTJIT regression matrix;
- final Runtime/Editor build;
- static scans proving the viability query is read-only, does not request or
  publish numeric TypeId/Runtime pointer identity, has no Parser
  node/Builder/compiler/HIR/backend consumer, and does not invoke the
  contextual write pass while ranking;
- strict OpenSpec validation and plugin/parent `git diff --check`;
- plugin commit first, followed by the parent gitlink and this attachment.

## Non-claims

- This gate does not use Lambda body constraints or return-type context to
  choose between otherwise indistinguishable funcdef candidates. Equal-arity
  candidates whose formal types are all omitted remain ambiguous.
- It does not remove the LEGACY compiler or native AngelScript AST.
- It does not make CANONICAL the product default or add a production `dual`
  mode/fallback.
- It does not by itself complete any broad task listed above.

## Evidence log

### Test-only build

- Result: PASS.
- Evidence:
  `Saved/Build/cta-s63-lambda-funcdef-viability-red-build/20260829_121754_363_c1e90510`
- The build compiled the new test surface before any production source was
  changed.

### Initial focused RED and oracle correction

- Result: expected RED, `0/3 PASS`, `3/3 FAIL`, no skips or timeout.
- Evidence:
  `Saved/Tests/cta-s63-lambda-funcdef-viability-red/20260829_121817_900_d00f5e1c/Summary.json`
- `ParserOmittedLambdaAritySelectsOnlyViableFuncdefOverload` and
  `ParserExplicitLambdaTypeSelectsOnlyViableFuncdefOverload` both failed
  because the old candidate ranking retained both funcdef overloads and Sema
  emitted `ambiguous-overload` instead of selecting the sole structurally
  compatible target.
- `ParserLambdaRejectsAllIncompatibleFuncdefOverloadsWithoutAmbiguity` failed
  because the same old rule retained the zero- and two-formal funcdefs for a
  one-formal Lambda, producing false ambiguity instead of zero viable
  candidates.
- The two positive tests were causally RED and the real Parser/Sema path
  reached their false-ambiguity assertions, so their result was not a fixture
  parse, host registration, build, launch or discovery failure.
- The first implementation run made both positive tests GREEN and exposed an
  independent oracle error in the negative test: it expected
  `asCASTContext::Seal()` to fail. Existing SemaAuthority architecture and the
  established ambiguous-call test prove that Seal is the pointer-free graph
  verifier, not the semantic-acceptance result; unresolved/error Calls remain
  structurally sealable while Sema diagnostics reject compilation. The
  negative test and the gate statement were corrected to require successful
  structural seal plus exact unresolved-callee/no-ambiguity evidence.
- Because that incorrect first assertion also failed under the old behavior,
  the corrected three-test gate must be rerun against a local old-rule
  mutation before the final GREEN. This preserves a causally distinguishing
  RED for every exact method instead of treating the confounded initial result
  as sufficient evidence.

### Corrected mutation RED

- Local mutation: the Lambda branch of `RankArgument` temporarily returned
  rank `1` for every funcdef, exactly reproducing the pre-CTA-S63 rule. The
  mutation was used only to prove the corrected tests and was then removed.
- Mutation build: PASS.
- Build evidence:
  `Saved/Build/cta-s63-lambda-funcdef-viability-mutation-red-build/20260829_122504_940_1b3135d3`
- Test result: expected RED, `0/3 PASS`, `3/3 FAIL`, no skips or timeout.
- Test evidence:
  `Saved/Tests/cta-s63-lambda-funcdef-viability-mutation-red/20260829_122528_311_87542a86/Summary.json`
- Every method now distinguishes the old and intended behavior. Both positive
  calls remain falsely ambiguous, and the negative call still reports
  `ambiguous-overload` instead of only the required unresolved-callee result.

### Test-assertion build issue

- After the first GREEN, the gate was strengthened to assert the selected
  Lambda return type and to exercise the read-only query directly against an
  exact Canonical FuncDefDecl and a host direction mismatch.
- The first rebuild failed in the test translation unit with MSVC `C4002`
  because two new CQTest assertions passed the message as a second
  `ASSERT_THAT` macro argument. This repository's matcher form is
  `ASSERT_THAT(IsTrue/IsFalse(condition, message))`.
- Evidence:
  `Saved/Build/cta-s63-lambda-funcdef-viability-final-build-2/20260829_123228_167_ee68c49d`
- The issue was confined to the new test assertion syntax. The production
  Runtime objects had already built successfully, and the two assertions were
  corrected to the established local form before rerunning verification.

### Implemented authority boundary

- `asCSema::IsLambdaViableForFuncdef` is a `const`, ID/`QualType`-based query.
  It accepts only an exact Lambda `DeclRef`, validates the construction-only
  Lambda syntax fact, exact authored arity, omitted-formal identity set and any
  already-bound funcdef stable key, then compares one candidate signature.
- Omitted formals are candidate-local wildcards at their exact positions.
  Explicit formals must match exactly. A duplicate or malformed transient
  syntax state fails closed without publishing diagnostics or repairs.
- An exact Canonical `FuncDefDecl` with the target stable key is preferred. If
  no Canonical declaration exists, a host funcdef is resolved by stable
  `QualType` through `asCRuntimeTypeBridge` and explicit formals are compared
  after the maintained script-parameter ABI normalization, including
  reference direction.
- `RankArgument` receives the active Sema instance. Only Lambda declarations
  take the new viability branch; ordinary function/method/import values retain
  their existing funcdef rank. Both candidate selection and unresolved-call
  rank evidence invoke the same query.
- Candidate exploration performs no inference. After one overload wins,
  `ConvertCallArgumentsToFormalTypes` and `ActOnConversion` still invoke the
  existing `ContextualizeLambdaToFuncdef` write/reconciliation pass. No backend
  consumer calls the query.

### Final GREEN and regression evidence

- Initial strengthened build: PASS.
- Initial build evidence:
  `Saved/Build/cta-s63-lambda-funcdef-viability-final-build-3/20260829_123257_498_a114e203`
- Initial exact gate: `3/3 PASS`, zero failures, skips and timeout.
- Initial focused evidence:
  `Saved/Tests/cta-s63-lambda-funcdef-viability-strengthened-green/20260829_123320_246_24f723c5/Summary.json`
- Initial complete `SemaAuthority`: `421/421 PASS`, zero failures, skips and
  timeout.
- Initial Sema evidence:
  `Saved/Tests/cta-s63-sema-authority-strengthened-final/20260829_123353_963_5c5c3ad7/Summary.json`
- Read-only review found no Critical or implementation blocker. It requested
  one additional candidate-isolation characterization for the declared
  equal-arity/all-omitted ambiguity boundary and one wording correction about
  transient pointer reads. No reviewer modified the working tree.
- Review-closure build: PASS.
- Review-closure build evidence:
  `Saved/Build/cta-s63-review-ambiguity-build/20260829_124217_936_25ff01df`
- Final exact gate including the review characterization: `4/4 PASS`, zero
  failures, skips and timeout.
- Final focused evidence:
  `Saved/Tests/cta-s63-review-ambiguity-green/20260829_124246_891_19eb2eaf/Summary.json`
- Final complete `SemaAuthority`: `422/422 PASS`, zero failures, skips and
  timeout. The prior CTA-S62 baseline was `418/418`; the delta is exactly the
  four CTA-S63 methods.
- Final Sema evidence:
  `Saved/Tests/cta-s63-sema-authority-review-final/20260829_124322_850_89b7428d/Summary.json`
- Parser declarations + Frontend Canonical type + ProductionCodeGen + Module
  Snapshot + TypedASTJIT matrix: `224/224 PASS`, zero failures and skips.
- Cross-surface evidence:
  `Saved/Tests/cta-s63-cross-surface-final/20260829_122805_980_5ec817de/Summary.json`
- The later strengthened and review-closure edits affected only assertions and
  one new characterization in the SemaAuthority test translation unit; the
  production Runtime revision covered by the `224/224` cross-surface run did
  not change afterward.

### Static architecture evidence

- The exact viability body has zero occurrences of `context.Set`,
  `lambdaSyntaxFacts.PushLast`, `RecordDependency`, `AddDiagnostic`,
  `ContextualizeLambdaToFuncdef`, `FromDataType` or
  `FromScriptParameterABI`. It uses only local arrays, Canonical getters and
  the read-only Runtime bridge `Resolve` path.
- The exact body has zero `asCScriptNode`, `asCBuilder`, `asCCompiler`, numeric
  `TypeId`/`typeId` or HIR references. Its live Runtime pointers are transient
  bridge results and are never stored in a Canonical node, syntax fact,
  snapshot, provider, relocation or cache artifact.
- Whole-source consumer scan finds exactly three locations: public declaration,
  Sema definition and the `RankArgument` call. There is no Bytecode,
  ProductionCodeGen, Snapshot, Cache or TypedASTJIT consumer.
- Plugin HIR path count remains zero. Native `as_scriptnode`, `as_parser`,
  `as_builder` and `as_compiler` sources remain present for LEGACY,
  syntax/recovery, reference/differential and rollback use.
- `ep.canonicalCompilerPipeline` still initializes to `false`; the pipeline
  getter therefore returns LEGACY by default. The setter accepts only LEGACY
  and CANONICAL, and explicitly has no registered dual mode.
- Plugin and parent `git diff --check` pass; only line-ending conversion
  notices are emitted for the maintained Windows checkout.

### Non-blocking architecture follow-ups

- Canonical funcdef discovery currently walks the declaration table for every
  Lambda/funcdef candidate. This preserves stable-key identity and matches the
  existing bounded Sema lookup style, but its theoretical cost is candidate
  count multiplied by declaration count. No regression or observed hotspot
  appears in the current verification. If profiling later identifies it, the
  safe optimization is a generation-local stable-key declaration index in
  `asCASTContext`, not Runtime numeric TypeId identity.
- The read-only viability query and diagnostic write pass intentionally repeat
  some target-signature projection. Folding them together by calling the write
  pass during ranking would violate candidate isolation. A future cleanup may
  share an immutable signature-view helper, but must retain separate query and
  commit phases and preserve the writer's exact diagnostics.

### OpenSpec closure evidence

- `openspec validate refactor-as-canonical-typed-ast-compiler --strict` passes.
- `openspec status --change refactor-as-canonical-typed-ast-compiler` reports
  all four required artifacts complete.
- Plugin implementation commit:
  `e280e0f [CanonicalAST] Fix: rank lambda funcdef overload viability`.
- The formal task ledger remains `101/136` (`74.3%`). This bounded gate advances
  the implementation evidence for tasks `0.2`, `4.4`, `5.2`, `5.3`, `5.9` and
  `13.2`, but none of those broad task texts is fully closed by this slice, so
  their checkboxes remain unchanged.

Implementation, GREEN, downstream regression and static-boundary evidence are
now recorded above. Broad tasks remain unchecked until their complete task
text is proven.
