/**
 * Script AdjustNativeValue round-trips the int& payload. C++ verifies ScriptAdjustedValue
 * 15, so that UPROPERTY name is part of the contract and is kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.NativeReferenceRoundTrip
 * @Harness UClass
 * @Tag Definitions.UInterface.NativeReferenceRoundTrip
 * @Provenance Theme: Definitions.UInterface. WorldStory: script AdjustNativeValue round-trips the int& payload.
 * @Provenance C++: ScriptAdjustedValue 15; C++ Execute_ later writes 27 into a separate buffer.
 * @Provenance Extra: null self-cast leaves ScriptAdjustedValue 0. FixtureIsolated.
 */

UCLASS()
class ATestInterfaceNativeReferenceRoundTrip : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	/**
	 * Return zero as the native value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	/**
	 * Ignore a marker write; this implementer has no marker field.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs a marker name
	 * @Return no stored marker
	 * @Param Marker unused
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
	}

	/**
	 * Add Delta to an in-out integer.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * WorldStory: BeginPlay self-casts and round-trips AdjustNativeValue(5) from 10.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs none
	 * @Return ScriptAdjustedValue 15
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef == nullptr)
		{
			return;
		}

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;
	}

	/**
	 * Observe that a null self-cast does not adjust.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null self-cast
	 */
	UFUNCTION()
	bool NullSelfDoesNotAdjust()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that an empty integer plus five is five.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTrip
	 * @Inputs none
	 * @Return 5
	 * @Boundary empty start
	 */
	UFUNCTION()
	int AdjustNativeValueEmptyStart()
	{
		int Value = 0;
		Value += 5;
		return Value;
	}
}
