# Canonical VALUE-`this` lvalue address gate（2026-08-26）

## Scope

This AST-first gate advances Tasks `0.2`, `5.3`, `9.4`, `9.5`, `13.2`, and
`13.6` for the current StaticJIT generation fail-closed token:

```text
Canonical staged CodeGen failed code=-7 line=4363:
unsupported lvalue address
function=FJITGenerationOnlySignal_*::BindUFunction(UObject,const FName&)
expr=* kind=22 literal=this
typeKey=FJITGenerationOnlySignal_*
resolvedDecl=0
```

`kind=22` is `asAST_EXPR_THIS`. The sealed graph already has a VALUE-typed
ThisExpr used as the `?&` argument of `__DelegateSignature(this)` inside the
generated `BindUFunction` method. `EmitLValueAddress` handled Sequence,
wrappers, Call results, string literals, DeclRef, and MemberRef, but not
This.

New tests live in sibling files:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaValueThisLValueTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionValueThisLValueTests.cpp`

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test | `ValueStructThisToWildcardRefRemainsSealedThisArgument` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.ValueThisLValue` |
| Fixture | script `struct FHost { int Value; void Touch() { Observe(this); } }` with native `void Observe(?& Value)` |
| Required sealed facts | ThisExpr typed `FHost` VALUE_OBJECT, lvalue, no handle; resolved `Observe` Call whose argument is that This; formal `asAST_TYPE_WILDCARD` `?` with reference and without handle |
| CodeGen test | `ValueStructThisToWildcardRefPassesLiveObjectAddress` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.ValueThisLValue` |
| CodeGen RED | CANONICAL `Build()` fail-closed: `unsupported lvalue address function=FHost::Touch() ... kind=22 literal=this typeKey=FHost` |
| CodeGen GREEN | publisher `CANONICAL_CODEGEN`; zero legacy compiler invocations; `CALLSYS` on `Touch`; observer sees `Value=7` then writes `41` through `GetArgAddress(0)`; `F()` returns `41` |
| Production probe | `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine` |

## Design decision

```text
EmitLValueAddress(This)
      |
      v
thisOffset is valid (method frame slot 0)
      |
      v
return thisOffset   (object-pointer slot; callers PshVPtr)
      |
      v
never PSF(0) as the VALUE object identity
```

VALUE `this` is a reference variable at frame offset 0, matching
`PushThisObject`. PSF of that slot would address the pointer variable
instead of the caller-owned object. REF `this` stores the same pointer
form.

## Evidence log

- Generation token: `Saved/Tests/cta-generation-after-wildcard-value-arg/20260826_173749_710_e08286a1` — **12/32 PASS, 20/32 FAIL**, common `unsupported lvalue address` / `kind=22 literal=this`
- AST GREEN: `Saved/Tests/cta-value-this-lvalue-ast/20260826_175039_783_5eda289b` — **1/1 PASS**
- CodeGen RED: `Saved/Tests/cta-value-this-lvalue-codegen-red/20260826_175120_113_3a749ba3` — **0/1 FAIL**
- Build GREEN: `Saved/Build/build/20260826_175214_128_1110bf10`
- Sema GREEN: `Saved/Tests/cta-value-this-lvalue-green-sema/20260826_175240_166_74a12aa4` — **1/1 PASS**
- CodeGen GREEN: `Saved/Tests/cta-value-this-lvalue-green/20260826_175310_105_351f6dec` — **1/1 PASS**
- Production probe after the fix: `Saved/Tests/cta-generation-after-value-this-lvalue/20260826_175409_830_d7ed69a1` — **30/32 PASS, 2/32 FAIL**. The previous `unsupported lvalue address` / `kind=22 literal=this` token is gone. Remaining failures are no longer Canonical CodeGen fail-closed:

  1. `FoldedGlobalKeepsStableHardValueDependencyThroughTypedASTEmission` — snapshot freeze lost Cache hard-value rows (`AngelscriptStaticJITGenerationEngineTests.cpp:1407`)
  2. `LiteralAssetRolesUseAuthoritativePostInitPairs` — Sema `unresolved-callee:__CreateLiteralAsset` in the isolated generation fixture

  Do not treat those two as a regression of this `this`-address route.
