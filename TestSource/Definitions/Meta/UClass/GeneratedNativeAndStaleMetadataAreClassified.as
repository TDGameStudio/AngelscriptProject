/**
 * Generated UASFunction and WorldContext property classification. ComputeValue(0)
 * is 12 from StoredValue. CheckMetadataWorldContext still returns Value when the
 * world context is null.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.GeneratedNativeAndStaleMetadataAreClassified
 * @Harness UClass
 * @Tag Definitions.Meta.GeneratedNativeAndStaleMetadataAreClassified
 * @Provenance Theme: Definitions.Meta. Positive: generated UASFunction / WorldContext property classification fixture.
 * @Provenance C++: AngelscriptASFunctionMetadataTests.cpp::GeneratedNativeAndStaleMetadataAreClassified
 * @Provenance Oracle: ComputeValue(0) == 12; CheckMetadataWorldContext(_, 7) == 7.
 * @Provenance Extra: ComputeValue with 0; null WorldContext still returns Value. DefaultSafe.
 */

UCLASS()
class UASFunctionMetadataClassification : UObject
{
	UPROPERTY()
	int StoredValue = 12;

	/**
	 * Add StoredValue to the incoming value.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs an addend
	 * @Return Value + StoredValue
	 * @Param Value the addend
	 */
	UFUNCTION()
	int ComputeValue(int Value)
	{
		return Value + StoredValue;
	}

	/**
	 * Observe that ComputeValue(0) reports the stored default.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs none
	 * @Return 12
	 * @Boundary stored default
	 */
	UFUNCTION()
	int ComputeDefaultStored()
	{
		return ComputeValue(0);
	}

	/**
	 * Observe that ComputeValue(5) reports 17.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs none
	 * @Return 17
	 */
	UFUNCTION()
	int ComputeNominal()
	{
		return ComputeValue(5);
	}

	/**
	 * Observe that a null WorldContext still returns the Value argument.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs none
	 * @Return 0
	 * @Boundary null WorldContext
	 */
	UFUNCTION()
	int WorldContextNullBoundary()
	{
		UObject Missing;
		return CheckMetadataWorldContext(Missing, 0);
	}

	/**
	 * Observe that a live WorldContext still returns the Value argument.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int WorldContextNominal()
	{
		return CheckMetadataWorldContext(this, 7);
	}

	/**
	 * Observe that writing this instance leaves another instance at the stored default.
	 *
	 * @Kind Observe
	 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
	 * @Inputs a second carrier
	 * @Return true when this ComputeValue(0) is 1 and the other is 12
	 * @Param Second the other carrier, expected to keep StoredValue 12
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UASFunctionMetadataClassification Second)
	{
		if (Second is null)
		{
			throw("GeneratedNativeAndStaleMetadataAreClassified setup: required Second is null");
		}
		StoredValue = 1;
		if (ComputeValue(0) != 1)
		{
			return false;
		}
		return Second.ComputeValue(0) == 12;
	}
}

/**
 * A global WorldContext function whose metadata classification C++ inspects.
 *
 * @Kind Observe
 * @Covers Meta.GeneratedNativeAndStaleMetadataAreClassified
 * @Inputs a world context object and a value
 * @Return Value unchanged
 * @Param WorldContextObject the world context, which may be null
 * @Param Value the value to echo
 */
UFUNCTION(BlueprintCallable, meta = (WorldContext = "WorldContextObject"))
int CheckMetadataWorldContext(UObject WorldContextObject, int Value)
{
	return Value;
}
