# Canonical `opImplConv` argument ranking gate（2026-08-26）

## Scope

This AST-first gate advances Tasks `0.2`, `5.3`, `9.4`, `9.5`, `13.2`, and
`13.6` for the remaining generation compile failure:

```text
unresolved-callee:__CreateLiteralAsset
```

Preprocessor `asset Name of Type` lowers to `__CreateLiteralAsset(Type, "Name")`.
Canonical Sema already rewrites the type identifier to `__StaticType_<Name>`
(`TSubclassOf<UObject>` VALUE). The callee formal is a REF object (`UClass`).
Those types do not match exactly.

A previous RankArgument branch compared `param->stableKey.Equals("UClass")`
and `argType->stableKey.StartsWith("TSubclassOf")`. That is a host-type
special case in the language overlay: `UClass` / `TSubclassOf` are UE
bindings, not AngelScript primitives. Ranking must use the registered
zero-arg `opImplConv` method on the argument type — the same operator
legacy `ImplicitConvObjectValue` already consults.

New tests live in sibling files:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaImplConvCallTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionImplConvCallTests.cpp`

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test | `ValueOpImplConvMakesRefFormalCallViable` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.ImplConvCall` |
| Fixture | native VALUE `FHost` with `CClass opImplConv() const`; REF `CClass`; `void Observe(CClass Cls)`; `Observe(Host)` |
| Required sealed facts | resolved `Observe` Call; argument is `CONVERSION` to `CClass`; inner type `FHost` |
| CodeGen test | `ValueOpImplConvPassesConvertedHandleNotValueSlot` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.ImplConvCall` |
| CodeGen contract | publisher `CANONICAL_CODEGEN`; zero legacy compiler invocations; `opImplConv` runs once; Observe receives the converted handle, not the VALUE slot |
| Production probe | `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine` |

## Design decision

```text
RankArgument(formal, arg)
      |
      v
intern arg type's native `opImplConv` methods
      |
      v
zero-arg method whose return type matches the formal
      |
      v
viable (rank 1); ConvertCallArgumentsToFormalTypes wraps CONVERSION
      |
      v
never match host names such as UClass / TSubclassOf
```

`TSubclassOf<T>::opImplConv() const -> UClass` is one host use of this
operator, not a Sema special case.

## Evidence log

- AST RED (before ranking): `Saved/Tests/cta-implconv-ast-red/20260826_193046_498_3748740e` — `Observe(Host)` unresolved Call; Host is FHost VALUE
- AST GREEN: `Saved/Tests/cta-implconv-ast-green/20260826_194010_210_eba65846` — **1/1 PASS**
- CodeGen RED: `Saved/Tests/cta-implconv-codegen-red/20260826_194048_491_014a3a56` — `opImplConv must run once` (EmitConversion returned the VALUE slot)
- CodeGen GREEN: `Saved/Tests/cta-implconv-codegen-green/20260826_194430_869_fe37d4dc` — **2/2 PASS** (Sema + Production)
- Production probe: `Saved/Tests/cta-generation-after-implconv/20260826_194509_931_dfe16034` — **32/34 PASS**. StaticTypeIdentifier both green. Remaining two are unchanged: `FoldedGlobalKeepsStableHardValueDependencyThroughTypedASTEmission` (Cache HardValue freeze) and `LiteralAssetRolesUseAuthoritativePostInitPairs` (`unresolved-callee:__CreateLiteralAsset`). The old `UClass`/`TSubclassOf` name match also failed to unblock LiteralAsset, so the generation miss is not “missing a UE type special-case”.
