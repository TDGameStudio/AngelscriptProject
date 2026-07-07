# Haze Macro Audit And Implementation Status

Initial audit date: 2026-06-26

Implementation update: 2026-07-06

This file records the source state used to refresh the OpenSpec plan and the final implementation status after applying the change.

## Initial Commands Run

- `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source`
- `rg -n "WITH_ANGELSCRIPT_HAZE|HAZE|Haze|Hazelight" Plugins\Angelscript\Source -g "*.Build.cs" -g "*.Target.cs"`
- `rg -n "bUseAngelscriptHaze|PP_NAME_NetFunction|PP_NAME_CrumbFunction|PP_NAME_DevFunction|FUNC_NetFunction|FUNC_DevFunction|HazeFunctionFlags|HAZEFUNC_CrumbFunction|NetFunction|CrumbFunction|DevFunction" Plugins\Angelscript\Source`

## Initial Macro References

Before implementation, `rg -n "WITH_ANGELSCRIPT_HAZE" Plugins\Angelscript\Source` reported 24 lines across 17 files:

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

The initial `*.Build.cs` / `*.Target.cs` search found no build-layer definition that enabled `WITH_ANGELSCRIPT_HAZE`.

## Additional Haze-Only Metadata To Remove

The macro guarded branches also left related metadata that was removed with the same change:

- `FAngelscriptFunctionDesc::bNetFunction`
- `FAngelscriptFunctionDesc::bDevFunction`
- StaticJIT `PrecompiledData` storage/serialization for those fields
- `AngelscriptStateDump` output column/value for `bNetFunction`
- `FAngelscriptDebugDatabaseSettings::bUseAngelscriptHaze`
- `FUNCMETA_CrumbFunction`

## Explicit Non-Removal

Do not remove generic UE RPC helpers just because their names contain `NetFunction`. In particular, the UHT tool's `IsRpcNetFunction` helpers describe standard UE network UFunctions and are outside the Haze macro removal scope.

## Implementation Status

The implementation removed active `WITH_ANGELSCRIPT_HAZE` source references, deleted Haze-only RPC specifiers and metadata, removed the debugger Haze flag, and restored the UE-canonical actor instigator names.

Focused verification completed:

- `Tools\RunBuild.ps1 -Label haze-precommit -TimeoutMs 900000`
- `Tools\RunBuild.ps1 -Label haze-after-actor-test-fix -TimeoutMs 900000`
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Actor.PropertyInterface" -Label haze-precommit-actor -TimeoutMs 900000` (`7/7`)
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UFunction" -Label haze-precommit-ufunction -TimeoutMs 900000` (`44/44`)
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Networking" -Label haze-precommit-networking -TimeoutMs 900000` (`27/27`)
- `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Debugger.Database" -Label haze-precommit-debugger -TimeoutMs 900000` (`1/1`)
- `openspec validate refactor-as-audit-remove-with-angelscript-haze --strict --json`

The full Functional suite was not run in this implementation turn; the verification scope was narrowed to the touched actor, UFUNCTION, networking, debugger database, build, and OpenSpec gates.
