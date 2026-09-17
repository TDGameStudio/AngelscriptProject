/**
 * @version v1
 * @summary FBoundaryIntData fields default to 0 so C++ can SetByPath then VerifyByPath min/max for every integer width. Keep the UPROPERTY names on FBoundaryIntData.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FBoundaryIntData fields default to 0 so C++ can SetByPath then VerifyByPath min/max for every integer width. Keep the UPROPERTY names on FBoundaryIntData.
 * @topic Baseline
 */
USTRUCT()
struct FBoundaryIntData
{
	UPROPERTY()
	int8 Int8Min = 0;

	UPROPERTY()
	int8 Int8Max = 0;

	UPROPERTY()
	int16 Int16Min = 0;

	UPROPERTY()
	int16 Int16Max = 0;

	UPROPERTY()
	int Int32Min = 0;

	UPROPERTY()
	int Int32Max = 0;

	UPROPERTY()
	int64 Int64Min = 0;

	UPROPERTY()
	int64 Int64Max = 0;

	UPROPERTY()
	uint8 UInt8Max = 0;

	UPROPERTY()
	uint16 UInt16Max = 0;

	UPROPERTY()
	uint UInt32Max = 0;

	UPROPERTY()
	uint64 UInt64Max = 0;
}

UCLASS()
class ACoverageBoundaryStructActor : AActor
{
	UPROPERTY()
	FBoundaryIntData Data;

	/**
	 * Observe that every boundary field defaults to 0 before C++ writes min/max.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructIntegerBoundaryValues
	 * @Inputs a default-constructed FBoundaryIntData
	 * @Return true when every min/max field is 0
	 * @Boundary default zeros
	 */
	UFUNCTION()
	bool BoundaryIntEmptyDefaults()
	{
		FBoundaryIntData LocalData;
		if (LocalData.Int8Min != 0)
		{
			return false;
		}
		if (LocalData.Int8Max != 0)
		{
			return false;
		}
		if (LocalData.Int16Min != 0)
		{
			return false;
		}
		if (LocalData.Int16Max != 0)
		{
			return false;
		}
		if (LocalData.Int32Min != 0)
		{
			return false;
		}
		if (LocalData.Int32Max != 0)
		{
			return false;
		}
		if (LocalData.Int64Min != 0)
		{
			return false;
		}
		if (LocalData.Int64Max != 0)
		{
			return false;
		}
		if (LocalData.UInt8Max != 0)
		{
			return false;
		}
		if (LocalData.UInt16Max != 0)
		{
			return false;
		}
		if (LocalData.UInt32Max != 0)
		{
			return false;
		}
		return LocalData.UInt64Max == 0;
	}

	/**
	 * Observe that copying the boundary struct does not alias int8 min/max.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StructIntegerBoundaryValues
	 * @Inputs a copy whose Int8Min/Max were set to -128/127
	 * @Return true when the original stays 0/0 and the copy holds -128/127
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BoundaryIntCopyIndependence()
	{
		FBoundaryIntData Original;
		FBoundaryIntData Copy = Original;
		Copy.Int8Min = -128;
		Copy.Int8Max = 127;
		if (Original.Int8Min != 0)
		{
			return false;
		}
		if (Original.Int8Max != 0)
		{
			return false;
		}
		if (Copy.Int8Min != -128)
		{
			return false;
		}
		return Copy.Int8Max == 127;
	}
}
/** @end */
