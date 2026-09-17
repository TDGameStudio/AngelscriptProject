/**
 * @version v1
 * @summary Production dispatch bridge routes Get/Adjust/Set to the implementing UFunction. C++ verifies ScriptObservedValue 55, ScriptAdjustedValue 15 and ScriptObservedMarker BridgeHit, so those UPROPERTY names are part of the.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Production dispatch bridge routes Get/Adjust/Set to the implementing UFunction. C++ verifies ScriptObservedValue 55, ScriptAdjustedValue 15 and ScriptObservedMarker BridgeHit, so those UPROPERTY names are part of the.
 * @topic Baseline
 */
UCLASS()
class AInterfaceDispatchBridgeCarrier : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptObservedValue = 0;

	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	FName ScriptObservedMarker = NAME_None;

	/**
	 * Return the native value for the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
	 * @Inputs none
	 * @Return 55
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return 55;
	}

	/**
	 * Write the observed marker for the parent interface.
	 *
	 * @Kind Action
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
	 * @Inputs a marker name
	 * @Return ScriptObservedMarker written
	 * @Param Marker the marker to store
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		ScriptObservedMarker = Marker;
	}

	/**
	 * Add Delta to an in-out integer for the parent interface.
	 *
	 * @Kind Action
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
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
	 * WorldStory: BeginPlay self-casts and records Get/Adjust/Set through the parent interface.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
	 * @Inputs none
	 * @Return ScriptObservedValue 55, ScriptAdjustedValue 15, ScriptObservedMarker BridgeHit
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

		ScriptObservedValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;

		ParentRef.SetNativeMarker(n"BridgeHit");
	}

	/**
	 * Observe that casting a null object does not dispatch.
	 *
	 * @Kind Observe
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null self-cast
	 */
	UFUNCTION()
	bool NullSelfDoesNotDispatch()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that an empty integer plus five is five.
	 *
	 * @Kind Observe
	 * @Covers UInterface.CallInterfaceMethodDispatchesToImplementingUFunction
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
/** @end */
