/**
 * @version v1
 * @summary A self-cast native parent interface dispatches Get/Set/Adjust. C++ verifies SelfCastWorked, SelfDispatchWorked, AdjustedValue and NativeMarker, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A self-cast native parent interface dispatches Get/Set/Adjust. C++ verifies SelfCastWorked, SelfDispatchWorked, AdjustedValue and NativeMarker, so those UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ACoverageNativeSingleInterfaceActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 64;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int AdjustedValue = 0;

	UPROPERTY()
	bool SelfCastWorked = false;

	UPROPERTY()
	bool SelfDispatchWorked = false;

	/**
	 * Return the native value for the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
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
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
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
	 * Add Delta plus NativeValue to an in-out integer and store AdjustedValue.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta + NativeValue
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta + NativeValue;
		AdjustedValue = Value;
	}

	/**
	 * WorldStory: BeginPlay self-casts and records Get/Set/Adjust through the parent interface.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
	 * @Inputs none
	 * @Return SelfCastWorked true, AdjustedValue 72, NativeMarker FromSingleInterfaceCast
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject SelfObject = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		SelfCastWorked = ParentRef != nullptr;
		if (ParentRef == nullptr)
		{
			return;
		}

		int Value = 3;
		ParentRef.AdjustNativeValue(5, Value);
		ParentRef.SetNativeMarker(n"FromSingleInterfaceCast");
		SelfDispatchWorked = ParentRef.GetNativeValue() == 64 && Value == 72;
	}

	/**
	 * Observe that a null self-object does not cast.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary failed self-cast
	 */
	UFUNCTION()
	bool NullSelfObjectDoesNotCast()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that an empty start plus five plus NativeValue matches the adjust formula.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeSingleInterfaceMetadataAndReflectedDispatch
	 * @Inputs a native value
	 * @Return 5 + NativeValue
	 * @Param NativeValue the native value used in the formula
	 * @Boundary empty start
	 */
	UFUNCTION()
	int AdjustNativeValueEmptyStart(int NativeValue)
	{
		int Value = 0;
		Value += 5 + NativeValue;
		return Value;
	}
}
/** @end */
