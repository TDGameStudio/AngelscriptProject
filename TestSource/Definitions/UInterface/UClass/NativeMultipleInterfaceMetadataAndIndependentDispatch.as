/**
 * Parent and secondary native interfaces dispatch independently on one actor. C++ verifies
 * ParentCastWorked, SecondaryCastWorked, ParentResult and SecondaryResult, so those
 * UPROPERTY names are part of the contract and are kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
 * @Harness UClass
 * @Tag Definitions.UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
 * @Provenance Theme: Definitions.UInterface. WorldStory: parent and secondary native interfaces dispatch independently.
 * @Provenance C++: VerifyByPath ParentCastWorked/SecondaryCastWorked true; ParentResult 31; SecondaryResult 409;
 * @Provenance IndependentDispatchWorked true; NativeMarker FromParentInterface; SecondaryLabel FromSecondaryInterface.
 * @Provenance Extra: null self-object leaves both results 0. FixtureIsolated.
 */

UCLASS()
class ACoverageNativeMultipleInterfaceActor : AActor, UAngelscriptNativeParentInterface, UAngelscriptNativeSecondaryInterface
{
	UPROPERTY()
	int NativeValue = 31;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int SecondaryValue = 409;

	UPROPERTY()
	FString SecondaryLabel;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int SecondaryResult = 0;

	UPROPERTY()
	bool ParentCastWorked = false;

	UPROPERTY()
	bool SecondaryCastWorked = false;

	UPROPERTY()
	bool IndependentDispatchWorked = false;

	/**
	 * Return the native parent value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Write the native parent marker.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
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
	 * Add Delta plus NativeValue to an in-out integer.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta + NativeValue
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta + NativeValue;
	}

	/**
	 * Return the secondary value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs none
	 * @Return SecondaryValue
	 */
	UFUNCTION()
	int GetSecondaryValue() const
	{
		return SecondaryValue;
	}

	/**
	 * Write the secondary label.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs a label
	 * @Return SecondaryLabel written
	 * @Param NewLabel the label to store
	 */
	UFUNCTION()
	void SetSecondaryLabel(const FString&in NewLabel)
	{
		SecondaryLabel = NewLabel;
	}

	/**
	 * WorldStory: BeginPlay self-casts to both interfaces and records independent dispatch.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs none
	 * @Return ParentResult 31, SecondaryResult 409, both cast flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject SelfObject = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(SelfObject);

		ParentCastWorked = ParentRef != nullptr;
		SecondaryCastWorked = SecondaryRef != nullptr;
		if (ParentRef == nullptr || SecondaryRef == nullptr)
		{
			return;
		}

		ParentResult = ParentRef.GetNativeValue();
		SecondaryResult = SecondaryRef.GetSecondaryValue();
		ParentRef.SetNativeMarker(n"FromParentInterface");
		SecondaryRef.SetSecondaryLabel("FromSecondaryInterface");
		IndependentDispatchWorked = ParentResult == 31 && SecondaryResult == 409;
	}

	/**
	 * Observe that a null self-object does not cast to either interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs none
	 * @Return true when both casts of nullptr are null
	 * @Boundary null self-object
	 */
	UFUNCTION()
	bool NullSelfDoesNotCastEitherInterface()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(nullptr);

		if (ParentRef != nullptr)
		{
			return false;
		}
		return SecondaryRef == nullptr;
	}

	/**
	 * Observe that an empty secondary label has length zero.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeMultipleInterfaceMetadataAndIndependentDispatch
	 * @Inputs none
	 * @Return true when a default FString has length 0
	 * @Boundary empty label
	 */
	UFUNCTION()
	bool EmptySecondaryLabelDefault()
	{
		FString EmptyLabel;
		return EmptyLabel.Len() == 0;
	}
}
