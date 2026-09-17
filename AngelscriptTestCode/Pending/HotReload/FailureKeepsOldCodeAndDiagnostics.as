/**
 * @version v1
 * @summary Failed soft reload must keep last-good code. Root GetValue returns 5; broken-type does not compile; live result stays 5.
 * @topic HotReload
 */
/**
 * @version root
 * @summary Failed soft reload must keep last-good code. Root GetValue returns 5; broken-type does not compile; live result stays 5.
 * @topic Baseline
 */
UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 5;
	}
}


/*
@version root
@compile Initial
@expect compile-ok

@version broken-type
@parent root
@compile SoftReloadOnly
@expect compile-fail "MissingType"
@retain UClass, GetValue
@oracle execute UHotReloadFailureKeepsOldCode.GetValue == 5
@change
UCLASS()
class UHotReloadFailureKeepsOldCode : UObject
{
	UFUNCTION()
	MissingType GetValue()
	{
		MissingType Value;
		return Value;
	}
}
@end
*/
/** @end */
