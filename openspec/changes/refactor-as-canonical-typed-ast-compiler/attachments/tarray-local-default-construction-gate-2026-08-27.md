# Canonical local `TArray` default-construction gate — 2026-08-27

Worktree: `D:\as-cta`

OpenSpec change: `refactor-as-canonical-typed-ast-compiler`

This gate closes only issue `CTA-B-02`: a real UE-bound `TArray<int>` local
must acquire an exact zero-argument constructor in the sealed Canonical AST,
publish through Canonical CodeGen, and execute with its scope cleanup intact.
It advances Tasks `5.2`, `5.5`, `5.7`, `5.8`, `5.9`, `9.5` and their cutover
umbrellas, but does not complete any of those full-language tasks.

## 1. Source fact under test

```angelscript
UFUNCTION()
int LocalTArrayDefaultConstructionValue()
{
	TArray<int> LocalIntArray;
	return 2;
}
```

The intentionally unused local isolates default construction and end-of-scope
cleanup from `Add`, indexing, overload resolution, or a container method call.

## 2. Required sealed-AST contract

Before backend execution is considered, the retained sealed graph must prove:

- the local has stable semantic type `TArray<int>`;
- its initializer contains `asAST_EXPR_CONSTRUCT` of that exact type;
- the construct has a valid `resolvedDecl`;
- the resolved declaration is `asAST_DECL_CONSTRUCTOR` and has no formal
  parameters;
- the graph seals successfully, so materialization/cleanup references cannot
  contain a dangling declaration ID.

## 3. Required production contract

- the source-generation Engine compiles successfully under an explicitly
  selected Canonical pipeline;
- the module records `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`, never a legacy
  compiler publication laundered through the fixture;
- StaticJIT generation retains the source function and consumes the same
  sealed generation snapshot;
- VM execution returns `2`; construction and scope-exit cleanup therefore run
  through the installed Canonical artifact without a compile-time or runtime
  failure.

TypedASTJIT may still select an explicit safe fallback for this value-object
lifetime. That backend capability is outside this narrow gate and must not be
confused with Canonical compiler/VM construction support.

## 4. Existing RED and causal hypothesis

The historical real-UE fixture failed before publication with:

```text
VERIFY category=DANGLING_ID detail=construct-decl kind=Construct
```

Evidence:
`Saved/Tests/cta-typedastjit-script-fallback-green/20260827_060804_555_6dbf659d/Report/index.json`.

Static tracing shows the zero-argument path is:

```text
asCSema::ActOnConstruct
  -> InternNativeZeroArgCallablesForType
  -> asCRuntimeTypeBridge::Resolve
  -> asCRuntimeTypeBindingTable::ResolveCanonicalType
  -> import TArray<T>::void f()
  -> SelectConstructor
  -> Construct.resolvedDecl
```

That RED predates the type-identity gate's target-local nominal-array repair,
which lets stable `TArray<int>` resolve against AngelScript's registered
default-array presentation `int[]`. The current hypothesis is therefore that
`CTA-T-04` already repaired the constructor-import prerequisite indirectly.
No second production workaround should be added unless the permanent test
still fails on the current implementation.

## 5. TDD verification plan

1. Add a permanent real-UE regression in the TypedASTJIT script corpus with
   explicit Canonical Engine selection and retained sealed-AST inspection.
2. Build and run only that method.
3. If it is green because `CTA-T-04` is already present, mutation-check the
   test by temporarily removing only the nominal default-array candidate from
   target-generation matching. Record the expected RED, restore the repair,
   rebuild, and record the final GREEN.
4. Run the owning ScriptCorpus group plus SemaAuthority, ProductionCodeGen,
   Frontend Type and complete TypedASTJIT regression groups.
5. Update `CTA-B-02`, task progress and this gate with exact reports and
   non-claims. Do not check any umbrella task from this one language slice.

## 6. Status

First implementation checkpoint: **RED reproduced; repair not yet verified**.

Permanent focused RED: **0/1 PASS** at
`Saved/Tests/cta-tarray-local-current-green/20260827_070509_629_816a476d/Report/index.json`.
The retained verifier diagnostic is the expected
`DANGLING_ID detail=construct-decl` for `TArray<int>`.

The first test build failed because the new assertion incorrectly assumed a
generic `asCDecl::parameters` member. Parameters are declaration children of
kind `asAST_DECL_PARAM`; the test was corrected to inspect those children.
That runner failure is test-authoring evidence only and is excluded from the
semantic RED:
`Saved/Build/cta-tarray-local-regression-build/20260827_070417_665_64ecb406/RunMetadata.json`.
The corrected test build passed at
`Saved/Build/cta-tarray-local-regression-build-2/20260827_070447_644_10245365/RunMetadata.json`.

The RED disproved the initial alias-only hypothesis. The Runtime type resolves,
but `InternNativeBehaviourList` discarded any instantiated-template behaviour
whose `asCScriptFunction::objectType` remained the template base. AngelScript
deliberately reuses that base function when its signature does not depend on
`T`; the concrete instance's `beh.constructors` list still contains the valid
behaviour ID. UE's zero-argument `TArray<T>::void f()` has exactly this shape,
so the filter imported no constructor and `SelectConstructor` returned an
invalid declaration.

A first repair that imported the base-owned behaviour moved the test past AST
verification, proving that diagnosis, but exposed a second precise RED during
detached relocation capture: the constructor's Runtime owner was still bare
`TArray<T>` while the source graph contained concrete `TArray<int>`. Evidence:
**0/1 PASS** at
`Saved/Tests/cta-tarray-local-green/20260827_070851_400_e9df8c8f/Report/index.json`.
The failure was `missing canonical type for runtime datatype` with canonical
types `{int,TArray<int>,void}`.

The corrected repair materializes the instance-local template function shell
with `GenerateTemplateFunction(objectType, func)` before importing the
behaviour. This gives Sema an exact constructor and gives detached relocation
capture the same concrete `TArray<int>` owner. Parameter substitution remains
in place for signatures that depend on `T`; a later lookup sees the rewritten
instance behaviour ID and does not create another shell.

Status: **GREEN — bounded slice repaired and verified**.

Build after the complete repair:

- PASS:
  `Saved/Build/cta-tarray-instantiated-behaviour-build/20260827_071046_007_92fa937f/RunMetadata.json`.

Focused and owning-prefix execution:

- permanent focused test: **1/1 PASS** at
  `Saved/Tests/cta-tarray-local-instantiated-green/20260827_071058_450_f9fbe3e2/Report/index.json`;
- complete ScriptCorpus: **5/5 PASS** at
  `Saved/Tests/cta-tarray-script-corpus-green/20260827_071252_550_ce6ec6be/Report/index.json`.

Compiler and backend regression radius:

- Frontend CanonicalAST Type: **20/20 PASS** at
  `Saved/Tests/cta-tarray-frontend-type-green/20260827_071349_941_486c42f7/Report/index.json`;
- SemaAuthority: **301/301 PASS** at
  `Saved/Tests/cta-tarray-sema-authority-green/20260827_071425_792_0032fb2f/Report/index.json`;
- ProductionCodeGen: **111/111 PASS** at
  `Saved/Tests/cta-tarray-production-codegen-green/20260827_071505_738_6f86c4cb/Report/index.json`;
- complete TypedASTJIT: **71/71 PASS** at
  `Saved/Tests/cta-tarray-typedastjit-green/20260827_071539_837_7538782a/Report/index.json`.

The permanent test proves the sealed `Construct` names an exact zero-argument
constructor, the production module publisher is Canonical CodeGen, the
StaticJIT generation retains the function, and VM execution returns `2`.

## 7. Non-claims

- This closes issue `CTA-B-02`; it does not complete the umbrella language
  matrices in Tasks `5.2`, `5.5`, `5.7`, `5.8`, `5.9`, or `9.5`.
- It proves one real UE `TArray<int>` local/default-construction family. It does
  not prove every container constructor, list factory, mutation, exceptional
  cleanup, suspend/resume lifetime, or generated lifecycle form.
- No reverse mapper aliases bare `TArray<T>` to `TArray<int>`; doing so without
  the owning instance would conflate template identities.
- The compiler default remains `LEGACY`, and Cache V2 remains product-default
  disabled.
