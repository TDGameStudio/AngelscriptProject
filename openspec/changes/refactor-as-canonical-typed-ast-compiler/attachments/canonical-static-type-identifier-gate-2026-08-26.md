# Canonical type-identifier-as-value (`__StaticType_<Name>`) gate（2026-08-26）

## Scope

This AST-first gate advances Tasks `0.2`, `5.3`, `9.4`, `9.5`, `13.2`, and
`13.6` for the remaining generation compile failure:

```text
unresolved-callee:__CreateLiteralAsset
```

Preprocessor-generated `asset Name of Type` lowers to
`__CreateLiteralAsset(Type, "Name")`. Legacy
`CompileVariableAccess` rewrites a type identifier used as a value to the host
global `__StaticType_<Type>` (`const TSubclassOf<UObject>`). Canonical
`ActOnDeclRefExpr` previously treated `Type` as an unresolved identifier (dummy
`int`) and left the call unresolved.

New tests live in sibling files:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaStaticTypeIdentifierTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionStaticTypeIdentifierTests.cpp`

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test | `TypeIdentifierArgumentResolvesThroughStaticTypeGlobal` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.StaticTypeIdentifier` |
| Fixture | host `CClass` / `CObj` REF+NOCOUNT+IMPLICIT_HANDLE; `CClass __StaticType_CObj`; `void Observe(CClass Cls)`; `Observe(CObj)` |
| Required sealed facts | resolved `Observe` Call; argument is DeclRef named `__StaticType_CObj`; argument type `CClass` |
| CodeGen test | `TypeIdentifierArgumentPassesStaticTypeGlobal` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.StaticTypeIdentifier` |
| CodeGen RED | unresolved Call / dummy-int DeclRef `CObj` (Sema dump before the rewrite) |
| CodeGen GREEN | publisher `CANONICAL_CODEGEN`; zero legacy compiler invocations; `CALLSYS`; observer receives the live `__StaticType_CObj` pointer |
| Production probe | `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine` |

## Design decision

```text
identifier Name has no VAR
AND host global __StaticType_<Name> exists
      |
      v
intern that native global as a sealed VAR
      |
      v
DeclRef that VAR (typed as the host property)
      |
      v
never treat the type name as a dummy int identifier
```

CodeGen binds interned native globals by origin
`canonical-native-global-property` to `registeredGlobalProps`; it does not
publish a second module-owned copy.

## Evidence log

- Generation token: `Saved/Tests/cta-generation-after-value-this-lvalue/20260826_175409_830_d7ed69a1` — **30/32 PASS, 2/32 FAIL**, `unresolved-callee:__CreateLiteralAsset`
- AST RED: `Saved/Tests/cta-static-type-id-ast-red/20260826_191258_162_565f0d72` — **0/1 FAIL**, unresolved `Observe` / dummy-int `CObj`
- AST GREEN: `Saved/Tests/cta-static-type-id-ast-green/20260826_191558_766_3fbc40b4` — **1/1 PASS**
- CodeGen GREEN: `Saved/Tests/cta-static-type-id-codegen-green/20260826_191628_426_50079d8b` — **1/1 PASS**
- Production probe after the fix: recorded with the generation re-run of this slice
