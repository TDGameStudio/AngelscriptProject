# Cooked Reflection Fallback Signature Type Design

## Context

`AS_USE_BIND_DB` is enabled outside editor builds. In this path, `BindBlueprintCallable()` constructs `FAngelscriptFunctionSignature` with:

```cpp
Signature.InitFromDB(InType, Function, DBBind, /* bInitTypes= */ false);
```

That is appropriate for the direct-bind fast path because the generated declaration is enough to register a direct native pointer. It is not enough for the reflection fallback path because `BindBlueprintCallableReflectionFallback()` requires:

- `Signature.bAllTypesValid == true`
- populated `Signature.ArgumentTypes`
- populated `Signature.ReturnType` when the UFunction returns a value

When the function-table entry is a stub/no-direct-pointer entry, cooked binding can reach the fallback with `bAllTypesValid=false` and empty type arrays, then reject an otherwise valid reflective call.

## Approach

Add a helper on `FAngelscriptFunctionSignature` that mirrors the type-population branch currently embedded in `InitFromDB(..., bInitTypes=true)`:

1. Reset `ArgumentTypes`, `ArgumentNames`, and `ReturnType`.
2. Set `bAllTypesValid = true`.
3. Iterate UFunction parameters via `TFieldIterator<FProperty>`.
4. Convert each property with `FAngelscriptTypeUsage::FromProperty(Property)`.
5. Mark the signature invalid and stop if any property cannot be represented.
6. Store return type for `CPF_ReturnParm`, otherwise append argument type and argument name.

Then call this helper only in the cooked no-direct-pointer branch immediately before `BindBlueprintCallableReflectionFallback(...)`.

This keeps the direct bind path cheap and unchanged while giving the fallback the data it already expects in editor builds.

## Test Plan

Preferred coverage:

- Identify an existing generated function-table stub entry that is eligible for `BlueprintCallableReflectiveFallback`.
- Add a test that exercises the signature/fallback decision and asserts the entry becomes fallback-bound or no longer rejects due to missing type data.

If cooked-only `AS_USE_BIND_DB` cannot be toggled in the editor test binary:

- Add a unit-level helper test for the new signature type-population method using a representative `UFunction`.
- Add a generated table/fallback assertion documenting the cooked-only branch.
- Require Shipping/package validation before closing implementation.

Exact validation commands:

- `Tools\RunBuild.ps1 -Label cooked-reflection-fallback-build -TimeoutMs 1800000 -NoXGE`
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Core" -Label cooked-reflection-fallback-core -TimeoutMs 900000`
- `Tools\RunBuild.ps1 -Label cooked-reflection-fallback-shipping -Configuration Shipping -TimeoutMs 1800000 -NoXGE`
- Package/cooked command if available in local tooling.
