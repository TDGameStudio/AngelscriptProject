/**
 * Script casts a C++ native implementer and dispatches Get/Adjust/Set. C++ verifies
 * bCastSucceeded, ReadValue, AdjustedValue and NativeMarker, so those UPROPERTY names are
 * part of the contract and are kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.CppImplementerScriptCall
 * @Harness UClass
 * @Tag Definitions.UInterface.CppImplementerScriptCall
 * @Provenance Theme: Definitions.UInterface. WorldStory: script casts a C++ native implementer and dispatches Get/Adjust/Set.
 * @Provenance C++: bCastSucceeded 1; ReadValue 123; AdjustedValue 15; NativeMarker FromScript; LastAdjustmentDelta 5.
 * @Provenance Extra: null Target leaves bCastSucceeded/ReadValue/AdjustedValue at 0. FixtureIsolated.
 */

UCLASS()
class ATestInterfaceNativeCppImplementerBridge : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bCastSucceeded = 0;

	UPROPERTY()
	int ReadValue = 0;

	UPROPERTY()
	int AdjustedValue = 0;

	/**
	 * WorldStory: BeginPlay casts Target to the native parent interface and records Get/Adjust/Set.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.CppImplementerScriptCall
	 * @Inputs none
	 * @Return bCastSucceeded 1, ReadValue from GetNativeValue, AdjustedValue 15, marker FromScript
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef == nullptr)
		{
			return;
		}

		bCastSucceeded = 1;
		ReadValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		AdjustedValue = Value;

		ParentRef.SetNativeMarker(n"FromScript");
	}

	/**
	 * Observe that casting a null target does not succeed.
	 *
	 * @Kind Observe
	 * @Covers UInterface.CppImplementerScriptCall
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null Target
	 */
	UFUNCTION()
	bool NullTargetDoesNotCast()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that ten plus five is fifteen.
	 *
	 * @Kind Observe
	 * @Covers UInterface.CppImplementerScriptCall
	 * @Inputs none
	 * @Return 15
	 */
	UFUNCTION()
	int AdjustFromTenPlusFive()
	{
		int Value = 10;
		Value += 5;
		return Value;
	}
}
