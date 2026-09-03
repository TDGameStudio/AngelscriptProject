/**
 * A script-implemented native parent keeps PointerOffset 0. C++ verifies
 * bSelfCastSucceeded, DispatchedValue and NativeMarker, so those UPROPERTY names are part
 * of the contract and are kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.ScriptClassStillZeroOffset
 * @Harness UClass
 * @Tag Definitions.UInterface.ScriptClassStillZeroOffset
 * @Provenance Theme: Definitions.UInterface. WorldStory: script-implemented native parent keeps PointerOffset 0.
 * @Provenance C++: bSelfCastSucceeded 1; DispatchedValue 321; NativeMarker FromSelf.
 * @Provenance Extra: null self-object leaves bSelfCastSucceeded 0. FixtureIsolated.
 */

UCLASS()
class ATestInterfaceNativePointerOffsetScriptZero : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 321;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int bSelfCastSucceeded = 0;

	UPROPERTY()
	int DispatchedValue = 0;

	/**
	 * Return the native value for the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.ScriptClassStillZeroOffset
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Write the native marker for the parent interface.
	 *
	 * @Kind Action
	 * @Covers UInterface.ScriptClassStillZeroOffset
	 * @Inputs a marker name
	 * @Return NativeMarker written
	 * @Param Marker the marker to store
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Add Delta to an in-out integer for the parent interface.
	 *
	 * @Kind Action
	 * @Covers UInterface.ScriptClassStillZeroOffset
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
	 * WorldStory: BeginPlay self-casts to the native parent interface and records success.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.ScriptClassStillZeroOffset
	 * @Inputs none
	 * @Return bSelfCastSucceeded 1, DispatchedValue 321, NativeMarker FromSelf
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			bSelfCastSucceeded = 1;
			DispatchedValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromSelf");
		}
	}

	/**
	 * Observe that casting a null object does not succeed.
	 *
	 * @Kind Observe
	 * @Covers UInterface.ScriptClassStillZeroOffset
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null self-object
	 */
	UFUNCTION()
	bool NullSelfDoesNotCast()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that an empty integer plus five is five.
	 *
	 * @Kind Observe
	 * @Covers UInterface.ScriptClassStillZeroOffset
	 * @Inputs none
	 * @Return 5
	 * @Boundary zero start
	 */
	UFUNCTION()
	int AdjustNativeValueZeroStart()
	{
		int Value = 0;
		Value += 5;
		return Value;
	}
}
