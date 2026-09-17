/**
 * @version v1
 * @summary A flat USTRUCT holding all eight integer widths as UPROPERTY members. C++ reads StructData.* by path. Keep the UPROPERTY names on FFlatIntData.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A flat USTRUCT holding all eight integer widths as UPROPERTY members. C++ reads StructData.* by path. Keep the UPROPERTY names on FFlatIntData.
 * @topic Baseline
 */
USTRUCT()
struct FFlatIntData
{
	UPROPERTY()
	int8 Int8Value = 10;

	UPROPERTY()
	int16 Int16Value = 1000;

	UPROPERTY()
	int Int32Value = 100000;

	UPROPERTY()
	int64 Int64Value = 10000000000;

	UPROPERTY()
	uint8 UInt8Value = 255;

	UPROPERTY()
	uint16 UInt16Value = 65000;

	UPROPERTY()
	uint UInt32Value = 4000000000;

	UPROPERTY()
	uint64 UInt64Value = 18000000000000000000;
}

UCLASS()
class ACoverageFlatStructActor : AActor
{
	UPROPERTY()
	FFlatIntData StructData;

	/**
	 * Observe the eight integer-width defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FlatStructIntegerMembers
	 * @Inputs a default-constructed FFlatIntData
	 * @Return true when every width matches its oracle default
	 * @Boundary default values
	 */
	UFUNCTION()
	bool FlatIntDefaults()
	{
		FFlatIntData LocalData;
		if (LocalData.Int8Value != 10)
		{
			return false;
		}
		if (LocalData.Int16Value != 1000)
		{
			return false;
		}
		if (LocalData.Int32Value != 100000)
		{
			return false;
		}
		if (LocalData.Int64Value != 10000000000)
		{
			return false;
		}
		if (LocalData.UInt8Value != 255)
		{
			return false;
		}
		if (LocalData.UInt16Value != 65000)
		{
			return false;
		}
		if (LocalData.UInt32Value != 4000000000)
		{
			return false;
		}
		return LocalData.UInt64Value == 18000000000000000000;
	}

	/**
	 * Observe that copying the flat struct does not alias selected widths.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FlatStructIntegerMembers
	 * @Inputs a copy whose Int32Value and UInt8Value were set to 0
	 * @Return true when the original keeps 100000/255 and the copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FlatIntCopyIndependence()
	{
		FFlatIntData Original;
		FFlatIntData Copy = Original;
		Copy.Int32Value = 0;
		Copy.UInt8Value = 0;
		if (Original.Int32Value != 100000)
		{
			return false;
		}
		if (Original.UInt8Value != 255)
		{
			return false;
		}
		if (Copy.Int32Value != 0)
		{
			return false;
		}
		return Copy.UInt8Value == 0;
	}
}
/** @end */
