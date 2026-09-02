# CTA-S61: contextual lambda-to-funcdef signature gate

Date: 2026-08-29
OpenSpec: `refactor-as-canonical-typed-ast-compiler`
Primary tasks: 4.3, 4.4, 13.2
Status: closed slice; plugin commit `d25eea0`; parent closure record ready

## Scope

This slice removes one remaining LEGACY-only semantic decision from an
explicitly typed lambda. Lambda syntax has no authored return type. The current
Canonical Parser uses its first explicit parameter type, or `int` for an empty
parameter list, as `recoveryReturnType`; only the retained
`asCCompiler::ImplicitConvLambdaToFunc` later receives the exact funcdef and
knows the real signature.

Canonical Sema must instead bind an exact lambda declaration to the target
funcdef at a typed conversion boundary. The first gate covers two existing
language contexts:

- local initialization: `BoolCallback Stored = function(int Value) ...`;
- call argument conversion: `Invoke(function(int Value) ..., 1)` where the
  first formal is `BoolCallback`.

The target signature may come from an exact Canonical funcdef declaration or
from the current Engine's exact host funcdef through `asCRuntimeTypeBridge`.
Only Canonical return/parameter `asCQualType` facts and stable dependency
identity may be published. Parser nodes, Builder decisions, Runtime pointers
and numeric TypeIds remain outside the AST.

## AST-first gate card

Test source:
`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`

Test methods:

- `ParserLocalInitializerContextuallyBindsLambdaToExactFuncdefSignature`
- `ParserCallArgumentContextuallyBindsLambdaToExactFuncdefSignature`
- `SemaCanonicalFuncdefContextuallyBindsLambdaWithoutRuntimeTypeLookup`
- `ParserExplicitLambdaParameterCountMismatchFailsClosedInCanonicalSema`
- `SemaHostFuncdefRejectsExplicitLambdaParameterDirectionMismatch`

Shared host declaration:

```angelscript
funcdef bool BoolCallback(int);
```

Required sealed facts for each lambda:

1. exactly one lambda declaration is selected by the contextual conversion;
2. its return QualType is primitive `bool`, not the provisional first-formal
   `int`;
3. its explicit formal remains primitive `int` with the exact direction and
   qualifier set;
4. its stable key remains the exact owner/signature/source-offset identity;
5. the conversion has target type `FUNCDEF` with stable key `BoolCallback` and
   its child resolves to that exact lambda declaration;
6. the graph seals without publishing a Runtime pointer or numeric TypeId.

Expected RED before implementation:

- Parser creates the lambda declaration before its enclosing initializer or
  call supplies a target funcdef;
- `asSLambdaHeaderAction::recoveryReturnType` receives the explicit `int`
  parameter type;
- `ActOnConversion` creates a `BoolCallback` conversion but does not revise or
  validate the referenced lambda signature;
- the conversion-shape assertions remain valid while the exact lambda return
  type assertion fails as `int` instead of `bool`.

## Boundaries and following slices

This gate does not infer omitted lambda formal types. Those names currently do
not create Canonical parameter declarations and require a separate deferred
formal-constraint slice. It also does not make template declaration/instance
authority fully AST-local, change the retained LEGACY compiler, enable a
production dual path, restore HIR, adapt Standalone, or switch the product
default to CANONICAL.

RED/GREEN results, implementation details, regressions, static scans and every
encountered issue will be appended as the gate advances.

## RED evidence

The first build attempt was not a valid semantic RED. The new assertion used
the nonexistent `asCString::Find` API and therefore failed while compiling the
test carrier. This was a test-authoring issue, not evidence about Canonical
Sema, and is excluded from the semantic gate:

- label: `cta-s61-contextual-lambda-red-build`;
- evidence: `Saved/Build/cta-s61-contextual-lambda-red-build/20260829_105618_889_9ea50e90`;
- issue: `asCString` has no `Find` member;
- correction: use `std::strstr(Lambda->stableKey.AddressOf(), ...)` for the
  stable-key substring assertion.

The corrected test carrier then built successfully:

- label: `cta-s61-contextual-lambda-red-build-corrected`;
- evidence: `Saved/Build/cta-s61-contextual-lambda-red-build-corrected/20260829_105637_777_e6c3ffad`.

The exact two-method semantic RED run is valid and failed for the intended
authority gap:

- label: `cta-s61-contextual-lambda-red`;
- evidence: `Saved/Tests/cta-s61-contextual-lambda-red/20260829_105659_715_f2890086`;
- result: `0/2 PASS`, `2/2 FAIL`, zero skips;
- local-initializer lambda: stable declaration key contains
  `Entry()::<lambda>(int)@37`, but its return type is still provisional `int`;
- call-argument lambda: stable declaration key contains
  `Entry()::<lambda>(int)@105`, but its return type is still provisional `int`;
- both graphs already contain the correct `BoolCallback` conversion shape and
  seal successfully, proving that the missing rule is specifically contextual
  signature binding in Canonical Sema rather than parsing or conversion-node
  construction.

## Expanded RED and fixture corrections

The gate was expanded before the production change to cover both exact
Canonical funcdef declarations and a fail-closed parameter-count mismatch:

- `SemaCanonicalFuncdefContextuallyBindsLambdaWithoutRuntimeTypeLookup`;
- `ParserExplicitLambdaParameterCountMismatchFailsClosedInCanonicalSema`.

The first expanded fixture initially attempted to parse a script-authored
`funcdef bool ScriptCallback(int);`. That is not accepted by the tokenizer in
this maintained fork even though the retained implementation still contains
the internal Parser funcdef family. This was a fixture-boundary error rather
than the intended Sema RED and is excluded:

- build: `Saved/Build/cta-s61-contextual-lambda-expanded-red-build/20260829_110753_862_99c32839`;
- test: `Saved/Tests/cta-s61-contextual-lambda-expanded-red/20260829_110817_031_1fd9704f`;
- correction: construct the exact `FuncDefDecl`, lambda header, parameter and
  conversion directly through Canonical Sema.

The corrected expanded RED was valid:

- build: `Saved/Build/cta-s61-contextual-lambda-expanded-red-build-corrected/20260829_110944_011_6f8ff1e2`;
- test: `Saved/Tests/cta-s61-contextual-lambda-expanded-red-corrected/20260829_111006_841_82022485`;
- result: `0/4 PASS`, `4/4 FAIL`, zero skips;
- the two host-context lambdas retained provisional `int` returns;
- the direct Canonical funcdef lambda retained its provisional `int` return
  and published no stable funcdef dependency;
- the explicit one-parameter lambda converted to a two-parameter funcdef
  without the required `lambda-funcdef-parameter-count-mismatch` diagnostic.

## Production implementation

The production path now contextualizes an exact lambda declaration from
`asCSema::ActOnConversion` when the destination is a funcdef:

1. `ParseLambda` records the authored formal count and explicitly typed formal
   count in `asSLambdaHeaderAction`.
2. `ActOnLambdaHeaderAction` stores only short-lived Canonical syntax facts:
   lambda identity, the two counts and the stable bound-funcdef key.
3. `ContextualizeLambdaToFuncdef` resolves an exact Canonical `FuncDefDecl`
   first, with an exact current-Engine host funcdef bridge as the compatibility
   source when no Canonical declaration exists.
4. Explicit formal count, source type, direction and qualifiers are validated;
   a conflicting second target or ambiguous declaration fails closed.
5. The lambda declaration and its reference expression receive the target
   return QualType, `FinishDecl` recomputes the stable declaration facts, and
   only the stable funcdef dependency is published.
6. Runtime pointers, numeric TypeIds, `asCScriptNode`, Builder state and ABI
   const/reference normalization remain outside the Canonical AST.

Lambdas with omitted formal types deliberately defer contextualization in this
slice. They need a separate deferred-formal inference and body-retyping gate;
guessing a signature here would make the graph look typed without semantic
proof.

## GREEN investigation and ABI correction

The first production build succeeded:

- `Saved/Build/cta-s61-contextual-lambda-green-build/20260829_111255_643_9de774cf`.

The first four-method GREEN attempt produced `2/4 PASS`, `2/4 FAIL`:

- `Saved/Tests/cta-s61-contextual-lambda-focused-green/20260829_111326_266_9678883a`;
- the exact Canonical declaration case and fail-closed count mismatch passed;
- the two host-funcdef cases failed with
  `lambda-funcdef-parameter-type-mismatch`.

Root cause: the Runtime funcdef shell ABI-normalizes primitive by-value `int`
to `const int`. Directly comparing that Runtime data type with the authored AST
QualType incorrectly treated ABI `const` as source-semantic `const`.

The corrected boundary keeps two distinct comparisons:

- exact Canonical `FuncDefDecl`: compare source QualTypes directly;
- host fallback: lower each authored Canonical formal through
  `asCRuntimeTypeBridge::NormalizeScriptParameterABI`, then compare the exact
  Runtime parameter data type and `inOutFlags`.

The ABI-normalized implementation rebuilt successfully:

- `Saved/Build/cta-s61-contextual-lambda-green-build-abi-normalized/20260829_111655_401_c6b4f9ce`.

An attempted short-name alternation filter did not execute tests because the
runner prefixes the whole expression with `^`; the four alternatives were not
full Automation paths. It is excluded from semantic evidence and recorded as
a harness-command issue:

- `Saved/Tests/cta-s61-contextual-lambda-focused-green-abi-normalized/20260829_111719_613_ea6590ef`;
- result: no tests matched; no implementation assertions ran.

The authoritative full Sema regression is green:

- `Saved/Tests/cta-s61-contextual-lambda-sema-authority-green-abi-normalized/20260829_111757_621_0f3f2a26`;
- result: `415/415 PASS`, zero failures, zero skips;
- this covers all four new CTA-S61 tests plus the prior `411/411` SemaAuthority
  baseline.

## Review refinement: prove host parameter direction ABI

Final diff review found that a newly added direction-mismatch test initially
used two directly constructed Canonical QualTypes (`int &in` versus
`int &out`). That test passed, but it only proved source QualType inequality;
it did not exercise the host-funcdef path where the earlier ABI normalization
bug occurred:

- build: `Saved/Build/cta-s61-direction-mismatch-build/20260829_112243_347_c62a70f4`;
- focused test: `Saved/Tests/cta-s61-direction-mismatch-focused/20260829_112304_176_00ab6d0f`;
- result: `1/1 PASS`, zero failures and skips;
- disposition: useful but insufficient as the final ABI-direction gate, so the
  fixture was replaced before commit rather than counted as closure evidence.

The replacement registers the exact host declaration
`bool HostInCallback(int &in)`, constructs a Canonical Lambda with an explicit
`int &out` parameter, and requires the Runtime bridge comparison to reject the
conversion without changing the provisional Lambda return or recording the
rejected funcdef dependency:

- build: `Saved/Build/cta-s61-host-direction-build/20260829_112920_336_850b59b2`;
- focused test: `Saved/Tests/cta-s61-host-direction-focused/20260829_112943_685_5c675a1e`;
- result: `1/1 PASS`, zero failures and skips;
- exact diagnostic: `lambda-funcdef-parameter-type-mismatch`.

The final current-tree SemaAuthority run passed after this review refinement:

- `Saved/Tests/cta-s61-sema-authority-host-direction-final/20260829_113031_633_d69421a5`;
- result: `416/416 PASS`, zero failures and skips;
- coverage: the prior `411` baseline plus five CTA-S61 tests.

## Downstream regressions and static boundary evidence

The cross-surface regression matrix passed on the unchanged production patch:

- `Saved/Tests/cta-s61-contextual-lambda-cross-surface/20260829_112458_621_921e12b4`;
- Parser Declarations + Frontend Canonical Type/TypeIdentity/TypeSema +
  Canonical ProductionCodeGen + Module Snapshot + all TypedASTJIT prefixes;
- result: `224/224 PASS`, zero failures and skips;
- this includes the real Canonical Lambda Build/Execute CodeGen test, rather
  than relying only on dump shape.

Static boundary checks on the final production diff establish:

- plugin and parent `git diff --check` pass; line-ending notices are warnings,
  not whitespace errors;
- Canonical `as_sema*.h/.cpp` sources do not include `as_compiler.h`;
- `asSLambdaHeaderAction` and `asSLambdaSyntaxFact` contain no
  `asCScriptNode`, `asCBuilder`, Engine/Runtime pointer or numeric TypeId field;
- BytecodeCodeGen and StaticJIT contain no reference to
  `ContextualizeLambdaToFuncdef` or `lambdaSyntaxFacts`, so they cannot replay
  the contextual semantic decision;
- CTA-S61 introduces no HIR or `TypedSemanticIR` adapter.

OpenSpec strict validation passes:

```text
openspec validate refactor-as-canonical-typed-ast-compiler --strict
Change 'refactor-as-canonical-typed-ast-compiler' is valid
```

## Remaining closure work

CTA-S61 has passed its focused, full Sema, downstream and static authority
gates. The plugin implementation is committed first as required:

- `d25eea0 [CanonicalAST] Fix: bind contextual lambda funcdef signatures`.

The parent closure consists only of the updated plugin gitlink and this issue /
evidence attachment. Tasks 4.3, 4.4 and 13.2 are intentionally not checked by
this commit because each remains broader than the explicitly typed Lambda
slice.

The next Lambda slice must infer omitted formal types, create the missing
Canonical ParamDecls and re-type the complete body. A later overload gate must
also prove that incompatible Lambda/funcdef candidates lose viability during
ranking rather than only diagnosing at the selected conversion boundary.

Tasks 4.3, 4.4 and 13.2 remain unchecked because each describes a broader
semantic family than this one explicitly typed lambda slice. The formal change
progress therefore remains `101/136 = 74.3%` until a complete checklist item is
actually closed.
