# Canonical handle pointer-equality CodeGen gate（2026-08-26）

## Scope

This AST-first gate advances Tasks `0.2`, `5.2`, `9.4`, `13.2`, and `13.6`
for the StaticJIT production failure:

```text
int StaticWorldContextCheck(UObject, const int)
Assertion failed: Context.VArg_IsNumeric(0)  // asBC_CMPi
leftType=7 rightType=7  // pointer frame slots
```

The source form is a non-null object-handle inequality such as
`__WorldContext() != WorldContextObject`. Value-object `opEquals` remains a
Call, not this Binary path.

New tests live in sibling files so the large SemaAuthority /
ProductionCodeGen translation units do not keep growing:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaHandleCompareTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionHandleCompareTests.cpp`

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test | `HandleInequalityRemainsBuiltinBinaryNotOpEquals` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.HandleCompare` |
| Fixture | `CObj Left = nullptr; CObj Right = nullptr; if (Left != Right) return 1;` with a host `asOBJ_REF` type |
| Required sealed facts | exactly one `Binary` with `literal=!=`; operands are `CObj` `ReferenceObject` (this fork's implicit-handle form may omit `asAST_QUAL_HANDLE`); `resolvedDecl` empty; no `opEquals` callee |
| CodeGen test | `CanonicalHandleInequalityEmitsCmpPtrNotCMPi` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.HandleCompare` |
| CodeGen RED | sealed Binary `!=` is present, then bytecode contains `CMPi` and not `CmpPtr` |
| CodeGen GREEN | bytecode contains `CmpPtr`, not `CMPi`; publisher `CANONICAL_CODEGEN`; zero legacy compiler invocations; `null != null` executes as `0` |
| Regression | existing `CanonicalHandleNullCheckBuildPublishesCodeGenAndExecutes` still emits `CmpPtrNull` |

## Design decision

```text
is / !is
== / != of NullLiteral
== / != of object-handle or funcdef operands
      |
      v
CmpPtrNull or CmpPtr  +  TZ/TNZ
      |
      v
never EmitCompare -> CMPi on pointer slots
```

Value types that Sema rewrites to `opEquals` stay Calls. Integer `==` / `!=`
still use `EmitCompare`.

## Evidence log

- AST GREEN: `Saved/Tests/cta-handle-compare-ast/20260826_171131_642_1fbf5353` — **1/1 PASS**
- CodeGen RED: `Saved/Tests/cta-handle-compare-codegen-red/20260826_171210_346_604956ad` — **0/1 FAIL** (`CmpPtr` missing)
- Build GREEN: `Saved/Build/cta-handle-compare-cmpptr-build/20260826_171330_154_c6a51260`
- CodeGen + AST + null-check GREEN: `Saved/Tests/cta-handle-compare-codegen-green/20260826_171347_601_af20ee38` — **3/3 PASS**
- Real StaticJIT probe: `Saved/Tests/cta-staticjit-after-handle-cmpptr/20260826_171429_962_aa3b7e7c` — **1/1 PASS** (`RecordsFirstVersionHirGenerationAndExecutionTimings`)
