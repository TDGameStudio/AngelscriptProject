/**
 * Soft body update: GetValue 1 -> 2. Generated class identity stays.
 *
 * Regular .as + comment markers. @change is the next snapshot; the unified
 * diff is generated from it for C++ import.
 *
 * @Theme HotReload
 * @Subject HotReload.FunctionBody
 * @Harness SourceHistory
 * @Tag HotReload.FunctionBody.AddModifyLookupFlow
 * @Module HotReloadModifyLookupFlow.as
 * @Identity UHotReloadModifyLookupFlow
 * @Provenance C++: AngelscriptHotReloadFunctionTests.cpp::AddModifyLookupFlow
 */

UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}


/*
@version root
@compile Initial
@expect compile-ok

@version body-update
@parent root
@compile SoftReloadOnly
@expect compile-ok
@retain UClass, GetValue
@oracle execute UHotReloadModifyLookupFlow.GetValue == 2
@change
UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
@end
*/
