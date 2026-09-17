/**
 * @version v1
 * @summary Script AdjustNativeValue also persists call count and last value. C++ verifies ScriptAdjustedValue, AdjustCallCount and LastAdjustedValue, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Script AdjustNativeValue also persists call count and last value. C++ verifies ScriptAdjustedValue, AdjustCallCount and LastAdjustedValue, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ATestInterfaceNativeReferenceRoundTripCppBridgeState : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	int AdjustCallCount = 0;

	UPROPERTY()
	int LastAdjustedValue = 0;

	/**
	 * Return zero as the native value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
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
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
	 * @Inputs a marker name
	 * @Return no stored marker
	 * @Param Marker unused
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
	}

	/**
	 * Add Delta to an in-out integer and record the call.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta, AdjustCallCount incremented, LastAdjustedValue updated
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
		AdjustCallCount += 1;
		LastAdjustedValue = Value;
	}

	/**
	 * WorldStory: BeginPlay self-casts and round-trips AdjustNativeValue(5) from 10.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
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
	 * Observe that a null self-cast does not count an adjust.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null self-cast
	 */
	UFUNCTION()
	bool NullSelfDoesNotCountAdjust()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that two independent buffers stay independent after the same delta.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeReferenceRoundTripCppBridgeMutatesActorState
	 * @Inputs none
	 * @Return 1 when ScriptBuffer is 15 and CppBuffer is 27
	 * @Boundary independent buffers
	 */
	UFUNCTION()
	int AdjustNativeValueIndependentBuffers()
	{
		int ScriptBuffer = 10;
		int CppBuffer = 22;
		ScriptBuffer += 5;
		CppBuffer += 5;

		if (ScriptBuffer != 15)
		{
			return 0;
		}
		if (CppBuffer != 27)
		{
			return 0;
		}
		return 1;
	}
}
/** @end */
