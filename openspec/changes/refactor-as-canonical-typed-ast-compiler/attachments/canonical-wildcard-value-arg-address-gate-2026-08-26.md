# Canonical wildcard value-object call-argument address gate（2026-08-26）

## Scope

This AST-first gate advances Tasks `0.2`, `5.3`, `9.4`, `9.5`, `13.2`, and
`13.6` for the current StaticJIT generation fail-closed token:

```text
Canonical staged CodeGen failed code=-7 line=5994:
unclassified value-object call argument
function=FJITGenerationOnlySignal_*::Execute(FJITGenerationOnlyPayload_*) const
argumentType=FJITGenerationOnlyPayload_* argumentRef=0
sealedFormal=const ?& sealedRef=1
runtimeFormal=const ?& runtimeRef=1
```

The sealed graph already has a Call with a VALUE-object argument and a
wildcard reference formal. CodeGen previously required the *formal pointee*
to be a named value object before taking an lvalue address, so `const ?&`
fell through to fail-closed.

New tests live in sibling files:

- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaWildcardValueArgTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionWildcardValueArgTests.cpp`

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test | `ValueObjectArgumentToConstWildcardRefRemainsSealedCall` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority.WildcardValueArg` |
| Fixture | native `FPayload` VALUE/POD + `void Observe(const ?&in Value)`; `FPayload Payload; Payload.Value = 41; Observe(Payload);` |
| Required sealed facts | resolved `Observe` Call; argument type `FPayload` without handle; formal `asAST_TYPE_WILDCARD` `?` with reference and without handle |
| CodeGen test | `PreparedValueObjectToConstWildcardRefPassesLValueAddress` |
| Prefix | `Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen.WildcardValueArg` |
| CodeGen RED | CANONICAL `Build()` fail-closed: `unclassified value-object call argument ... sealedFormal=const ?&` |
| CodeGen GREEN | publisher `CANONICAL_CODEGEN`; zero legacy compiler invocations; `CALLSYS`; observer sees `41` through `GetArgAddress(0)` |
| Production probe | `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine` |

## Design decision

```text
argument is non-primitive VALUE object
AND (sealed formal is object reference OR runtime formal is reference)
      |
      v
EmitLValueAddress  (same as named T& / const T&)
      |
      v
never fail-closed just because the formal pointee is wildcard ?
```

By-value object copy/transfer paths are unchanged. Handle formals stay out.

## Evidence log

- Generation token: `Saved/Tests/cta-generation-next-token/20260826_172232_563_3abdd2cc` — **12/32 PASS, 20/32 FAIL**, common `unclassified value-object call argument` / `const ?&`
- AST GREEN: `Saved/Tests/cta-wildcard-value-arg-ast/20260826_173435_906_d93a1711` — **1/1 PASS**
- CodeGen RED: `Saved/Tests/cta-wildcard-value-arg-codegen-red/20260826_173518_953_fd6b96bc` — **0/1 FAIL**
- Build GREEN: `Saved/Build/canonical-ast-continue/20260826_173624_607_dc8a8aad`
- Sema + CodeGen GREEN: `Saved/Tests/cta-wildcard-value-arg-green/20260826_173643_917_ae02c79f` — **2/2 PASS**
- Production probe after the fix: `Saved/Tests/cta-generation-after-wildcard-value-arg/20260826_173749_710_e08286a1` — still **12/32 PASS, 20/32 FAIL**. The previous `unclassified value-object call argument` / `const ?&` token is gone. The common remaining fail-closed token is now:

```text
unsupported lvalue address
function=FJITGenerationOnlySignal_*::BindUFunction(UObject,const FName&)
kind=22 literal=this typeKey=FJITGenerationOnlySignal_*
```

That is a new slice (`EmitLValueAddress` of `asAST_EXPR_THIS`), not a regression of this wildcard-address route.
