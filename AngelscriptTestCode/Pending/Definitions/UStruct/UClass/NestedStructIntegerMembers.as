/**
 * @version v1
 * @summary Nested FInnerIntData defaults reached through FOuterIntData. C++ reads Data.Inner.* and Data.OuterValue by path. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Nested FInnerIntData defaults reached through FOuterIntData. C++ reads Data.Inner.* and Data.OuterValue by path. Keep those UPROPERTY names.
 * @topic Baseline
 */
USTRUCT()
struct FInnerIntData
{
	UPROPERTY()
	int8 Int8Value = -42;

	UPROPERTY()
	int16 Int16Value = -12345;

	UPROPERTY()
	int Int32Value = -987654;

	UPROPERTY()
	int64 Int64Value = -9000000000;

	UPROPERTY()
	uint8 UInt8Value = 200;

	UPROPERTY()
	uint16 UInt16Value = 54321;

	UPROPERTY()
	uint UInt32Value = 3000000000;

	UPROPERTY()
	uint64 UInt64Value = 12000000000;
}

USTRUCT()
struct FOuterIntData
{
	UPROPERTY()
	FInnerIntData Inner;

	UPROPERTY()
	int OuterValue = 999;
}

UCLASS()
class ACoverageNestedStructActor : AActor
{
	UPROPERTY()
	FOuterIntData Data;

	/**
	 * Observe nested integer-width defaults through Inner.
	 *
	 * @Kind Observe
	 * @Covers UStruct.NestedStructIntegerMembers
	 * @Inputs a default-constructed FOuterIntData
	 * @Return true when every nested width and OuterValue match
	 * @Boundary default values
	 */
	UFUNCTION()
	bool NestedIntDefaults()
	{
		FOuterIntData LocalData;
		if (LocalData.Inner.Int8Value != -42)
		{
			return false;
		}
		if (LocalData.Inner.Int16Value != -12345)
		{
			return false;
		}
		if (LocalData.Inner.Int32Value != -987654)
		{
			return false;
		}
		if (LocalData.Inner.Int64Value != -9000000000)
		{
			return false;
		}
		if (LocalData.Inner.UInt8Value != 200)
		{
			return false;
		}
		if (LocalData.Inner.UInt16Value != 54321)
		{
			return false;
		}
		if (LocalData.Inner.UInt32Value != 3000000000)
		{
			return false;
		}
		if (LocalData.Inner.UInt64Value != 12000000000)
		{
			return false;
		}
		return LocalData.OuterValue == 999;
	}

	/**
	 * Observe that copying the outer struct does not alias nested members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.NestedStructIntegerMembers
	 * @Inputs a copy whose Inner.Int32Value and OuterValue were set to 0
	 * @Return true when the original keeps -987654/999 and the copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool NestedIntCopyIndependence()
	{
		FOuterIntData Original;
		FOuterIntData Copy = Original;
		Copy.Inner.Int32Value = 0;
		Copy.OuterValue = 0;
		if (Original.Inner.Int32Value != -987654)
		{
			return false;
		}
		if (Original.OuterValue != 999)
		{
			return false;
		}
		if (Copy.Inner.Int32Value != 0)
		{
			return false;
		}
		return Copy.OuterValue == 0;
	}
}
/** @end */
