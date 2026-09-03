/**
 * ReplicatedUsing, BlueprintGetter and BlueprintSetter round-trip on TrackedValue.
 * GetTrackedValue after SetTrackedValue(42) is 42. The default is 0.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.PropertyCallbackMetadataRoundTrip
 * @Harness UClass
 * @Tag Definitions.Meta.PropertyCallbackMetadataRoundTrip
 * @Provenance Theme: Definitions.Meta. Positive: ReplicatedUsing / BlueprintGetter / BlueprintSetter round-trip.
 * @Provenance C++: AngelscriptCompilerPropertyMetadataTests.cpp::PropertyCallbackMetadataRoundTrip
 * @Provenance Oracle: Entry() == 42; GetTrackedValue after SetTrackedValue(42) is 42.
 * @Provenance Extra: default TrackedValue 0; SetTrackedValue(0) stays 0. DefaultSafe.
 */

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue, BlueprintGetter=GetTrackedValue, BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	/**
	 * The ReplicatedUsing callback; a no-op that still has to exist for the specifier.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION()
	void OnRep_TrackedValue()
	{
	}

	/**
	 * The BlueprintPure getter for TrackedValue.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return TrackedValue
	 */
	UFUNCTION(BlueprintPure)
	int GetTrackedValue() const
	{
		return TrackedValue;
	}

	/**
	 * The BlueprintSetter for TrackedValue.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs the value to store
	 * @Return nothing; TrackedValue is written
	 * @Param Value the value to store
	 */
	UFUNCTION()
	void SetTrackedValue(int Value)
	{
		TrackedValue = Value;
	}

	/**
	 * Return the Entry oracle of 42.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return 42;
	}

	/**
	 * Observe the default TrackedValue through the getter.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return 0
	 * @Boundary default TrackedValue
	 */
	UFUNCTION()
	int DefaultTrackedValue()
	{
		return GetTrackedValue();
	}

	/**
	 * Observe that SetTrackedValue(0) stays 0.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int SetZeroBoundary()
	{
		SetTrackedValue(0);
		return GetTrackedValue();
	}

	/**
	 * Observe that SetTrackedValue(42) then OnRep reports 42.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int SetNominal()
	{
		SetTrackedValue(42);
		OnRep_TrackedValue();
		return GetTrackedValue();
	}

	/**
	 * Observe that writing this instance leaves another instance at the default.
	 *
	 * @Kind Observe
	 * @Covers Meta.PropertyCallbackMetadataRoundTrip
	 * @Inputs a second carrier
	 * @Return true when this reads 42 and the other still reads 0
	 * @Param Second the other carrier, expected to keep TrackedValue 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UPropertyCallbackCarrier Second)
	{
		if (Second is null)
		{
			throw("PropertyCallbackMetadataRoundTrip setup: required Second is null");
		}
		SetTrackedValue(42);
		if (GetTrackedValue() != 42)
		{
			return false;
		}
		return Second.GetTrackedValue() == 0;
	}
}
