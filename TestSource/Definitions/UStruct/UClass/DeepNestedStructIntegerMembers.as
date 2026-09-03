/**
 * Three-level Root.Middle.Inner integer defaults. C++ reads those nested paths
 * on the actor. Keep the UPROPERTY names on FInnermost, FMiddleLayer, and
 * FOutermost.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.DeepNestedStructIntegerMembers
 * @Harness UClass
 * @Tag Definitions.UStruct.DeepNestedStructIntegerMembers
 * @Provenance Theme: Definitions.UStruct. WorldStory: three-level Root.Middle.Inner integer defaults.
 * @Provenance C++: AngelscriptCoverageUStructMemberTests.cpp::DeepNestedStructIntegerMembers
 * @Provenance lines 376-416;
 * @Provenance sha256=62c97317d9d64712f54f82e9649bef2bb0cdc56c76d824d8854bf4f14593a695.
 * @Provenance Oracle: Root.Middle.Inner.Int8Value=7, UInt64Value=999999999,
 * @Provenance Root.Middle.Int16Value=777, Root.Int32Value=12345.
 * @Provenance Extra: local FOutermost carries those defaults; copy-independence after mutate.
 * @Provenance FixtureIsolated.
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
