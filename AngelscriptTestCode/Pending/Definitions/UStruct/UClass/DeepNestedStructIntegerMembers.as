/**
 * @version v1
 * @summary Three-level Root.Middle.Inner integer defaults. C++ reads those nested paths on the actor. Keep the UPROPERTY names on FInnermost, FMiddleLayer, and FOutermost.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Three-level Root.Middle.Inner integer defaults. C++ reads those nested paths on the actor. Keep the UPROPERTY names on FInnermost, FMiddleLayer, and FOutermost.
 * @topic Baseline
 */
USTRUCT()
struct FInnermost
{
	UPROPERTY()
	int8 Int8Value = 7;

	UPROPERTY()
	uint64 UInt64Value = 999999999;
}

USTRUCT()
struct FMiddleLayer
{
	UPROPERTY()
	FInnermost Inner;

	UPROPERTY()
	int16 Int16Value = 777;
}

USTRUCT()
struct FOutermost
{
	UPROPERTY()
	FMiddleLayer Middle;

	UPROPERTY()
	int Int32Value = 12345;
}

UCLASS()
class ACoverageDeepNestedActor : AActor
{
	UPROPERTY()
	FOutermost Root;

	/**
	 * Observe three-level nested defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.DeepNestedStructIntegerMembers
	 * @Inputs a default-constructed FOutermost
	 * @Return true when Inner, Middle, and Root defaults match
	 * @Boundary default values
	 */
	UFUNCTION()
	bool DeepNestedDefaults()
	{
		FOutermost LocalRoot;
		if (LocalRoot.Middle.Inner.Int8Value != 7)
		{
			return false;
		}
		if (LocalRoot.Middle.Inner.UInt64Value != 999999999)
		{
			return false;
		}
		if (LocalRoot.Middle.Int16Value != 777)
		{
			return false;
		}
		return LocalRoot.Int32Value == 12345;
	}

	/**
	 * Observe that copying the outermost struct does not alias nested members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.DeepNestedStructIntegerMembers
	 * @Inputs a copy whose Inner.Int8Value and Int32Value were mutated
	 * @Return true when the original keeps 7/12345 and the copy holds -100/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool DeepNestedCopyIndependence()
	{
		FOutermost Original;
		FOutermost Copy = Original;
		Copy.Middle.Inner.Int8Value = -100;
		Copy.Int32Value = 0;
		if (Original.Middle.Inner.Int8Value != 7)
		{
			return false;
		}
		if (Original.Int32Value != 12345)
		{
			return false;
		}
		if (Copy.Middle.Inner.Int8Value != -100)
		{
			return false;
		}
		return Copy.Int32Value == 0;
	}
}
/** @end */
