# Current Haze Macro Audit

Date: 2026-06-26

This file records the source state used to refresh the OpenSpec plan. It is not an implementation log; no source files are changed by this record-only update.

## Commands Run

- `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source`
- `rg -n "WITH_ANGELSCRIPT_HAZE|HAZE|Haze|Hazelight" Plugins\Angelscript\Source -g "*.Build.cs" -g "*.Target.cs"`
- `rg -n "bUseAngelscriptHaze|PP_NAME_NetFunction|PP_NAME_CrumbFunction|PP_NAME_DevFunction|FUNC_NetFunction|FUNC_DevFunction|HazeFunctionFlags|HAZEFUNC_CrumbFunction|NetFunction|CrumbFunction|DevFunction" Plugins\Angelscript\Source`

## Current Macro References

`rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` currently reports 24 lines across 17 files:

- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_AActor.cpp:163`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_AActor.cpp:350`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_APlayerController.cpp:11`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_APlayerController.cpp:72`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_APlayerController.cpp:104`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_BlueprintType.cpp:784`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_BlueprintType.cpp:1281`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_FCollisionShape.cpp:34`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_Subsystems.cpp:154`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_UGameInstance.cpp:9`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_ULocalPlayer.cpp:6`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_UObject.cpp:53`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_UObject.cpp:568`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_UWorld.cpp:48`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Binds\Bind_WorldCollision.cpp:358`
- `Plugins\Angelscript\Source\AngelscriptRuntime\ClassGenerator\AngelscriptClassGenerator.cpp:3589`
- `Plugins\Angelscript\Source\AngelscriptRuntime\ClassGenerator\ASClass.cpp:32`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Core\AngelscriptEngine.cpp:6010`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Core\AngelscriptEngine.h:30`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Core\AngelscriptEngine.h:31`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Debugging\AngelscriptDebugServer.cpp:1913`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Preprocessor\AngelscriptPreprocessor.cpp:1668`
- `Plugins\Angelscript\Source\AngelscriptRuntime\Preprocessor\AngelscriptPreprocessor.cpp:2663`
- `Plugins\Angelscript\Source\AngelscriptTest\Debugger\AngelscriptDebuggerDatabaseTests.cpp:114`

## Build-Layer Status

The current `*.Build.cs` / `*.Target.cs` search found no build-layer definition that enables `WITH_ANGELSCRIPT_HAZE`.

## Additional Haze-Only Metadata To Remove

The macro guarded branches also leave related metadata that should be removed with the same change:

- `FAngelscriptFunctionDesc::bNetFunction`
- `FAngelscriptFunctionDesc::bDevFunction`
- StaticJIT `PrecompiledData` storage/serialization for those fields
- `AngelscriptStateDump` output column/value for `bNetFunction`
- `FAngelscriptDebugDatabaseSettings::bUseAngelscriptHaze`
- `FUNCMETA_CrumbFunction`

## Explicit Non-Removal

Do not remove generic UE RPC helpers just because their names contain `NetFunction`. In particular, the UHT tool's `IsRpcNetFunction` helpers describe standard UE network UFunctions and are outside the Haze macro removal scope.
