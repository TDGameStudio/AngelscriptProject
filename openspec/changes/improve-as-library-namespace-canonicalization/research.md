# Math Namespace Current-State Evidence

## Active naming sources

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h:25-31,62-64` defines `EAngelscriptMathNamespace` and the default `MathNamespace = Math` backwards-compatibility setting.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp:776-780` selects the manual namespace string `Math` or `FMath` from that setting.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMath.cpp:1343-1352` performs an editor-only UClass metadata mutation from `Math` to `FMath`.
- `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h:13` declares `UAngelscriptMathLibrary` with `ScriptName="Math"`.
- Unreal Engine 5.8 `Engine/Source/Runtime/Engine/Classes/Kismet/KismetMathLibrary.h:188` declares `UKismetMathLibrary` with `ScriptName="MathLibrary"`. The plugin must not patch this engine header.
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h:182-195` currently uses a class-level `ScriptName` before falling back to the registered AS type name.

## Related behavior that is not another public Math alias

- `UKismetMathLibrary` functions carrying compatible `ScriptMethod` metadata are transformed into receiver methods. The relevant placement logic is in `Helper_FunctionSignature.h:320-417`.
- `Bind_FRotator.cpp:200-208` calls `UKismetMathLibrary::MakeRotFrom*` as its native implementation while deliberately publishing `FRotator` static helpers.
- `Bind_FMath_Functions.cpp` wraps selected `UKismetMathLibrary` implementations for signatures that need local glue; it does not select an AS namespace.
- `StaticJIT/StaticJITHeader.h` includes `KismetMathLibrary.h`, while Static JIT namespace identity is captured generically from `asIScriptFunction::GetNamespace()` in `StaticJIT/PrecompiledData.cpp`. No active Static JIT `Math -> FMath` rewrite was found.
- The offline symbol exporter reads `Function.GetNamespace()` in `Dump/AngelscriptOfflineSymbolExporter.cpp:437`; it is an observer of the registered surface, not an independent naming policy.

## Existing specification conflict

`openspec/specs/as-library-full-namespaces/spec.md` currently requires full registered AS type names for reflected Blueprint libraries and explicitly rejects class-`ScriptName` shortening. Its archived source change was motivated by AI coding ambiguity. The current signature implementation later restored class `ScriptName` for mixin/static-factory needs, so this change must separate intentional internal type-static placement from ordinary Blueprint-library shortening and update the shared spec explicitly.

The active `openspec/changes/improve-as-runtime-function-libraries/` record preserves `Math::` spellings, including `Math::WrapIndex`, and touches `Helper_FunctionSignature.h` plus the FunctionLibraries tests. It overlaps implementation files but not the goal of this change; it must be sequenced or reconciled before implementation.

## Migration surface

- `AngelscriptCoverageMathNamespaceFunctions.cpp` alone contains more than two hundred script-side `Math::` references.
- Repository-owned call sites also occur in Math binding/function-library tests, syntax/coverage fixtures, hot-reload fixtures, `Script/Examples/Core/Example_Math.as`, `Script/Examples/Extended/Example_InterfaceDispatch.as`, and `Script/Tests/Test_MathNamespace.as`.
- Current Chinese guides and the example README contain user-facing `Math::` examples. Archived OpenSpec evidence and dated audit reports are historical records and should not be mass-rewritten.

## Implementation inventory required before registration changes

Generate a one-time evidence table from the initialized engine and relevant UFunctions with these columns:

```text
source_owner,class_path,source_function,placement,canonical_namespace,as_declaration,classification
```

Allowed `classification` values are `receiver-method`, `unique-static`, `valid-overload`, `exact-duplicate`, and `incompatible-collision`. The table belongs under this change directory as implementation evidence; it is not a runtime allowlist.
