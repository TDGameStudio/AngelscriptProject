/**
 * @version v1
 * @summary Soft body update: GetValue 1 -> 2. Generated class identity stays. Regular .as + comment markers. @change is the next snapshot; the unified diff is generated from it for C++ import.
 * @topic HotReload
 */
/**
 * @version root
 * @summary Soft body update: GetValue 1 -> 2. Generated class identity stays. Regular .as + comment markers. @change is the next snapshot; the unified diff is generated from it for C++ import.
 * @topic Baseline
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
/** @end */
