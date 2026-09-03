/**
 * A script attribute set exposing Energy, whose OnAttributeChanged trampoline
 * must broadcast the old and new values. The observers cover the null handle, the
 * empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.OnAttributeChangedTrampolineData
 * @Harness UClass
 * @Tag Optional.GAS.OnAttributeChangedTrampolineBroadcastsCorrectData
 * @Provenance Theme: Optional.GAS. WorldStory: UTestCallbackDataAttributes Energy old 20 new 35.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::OnAttributeChangedTrampolineBroadcastsCorrectData
 * @Provenance Oracle: CapturedAttributeChange.Name == Energy; OldValue 20; NewValue 35.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns trampoline bind and set 20 -> 35.
 */

UCLASS()
class UTestCallbackDataAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeChangedTrampolineData
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestCallbackDataAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeChangedTrampolineData
	 * @Inputs a default-constructed attribute data
	 * @Return true when the attribute name is none
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyAttributeData()
	{
		FAngelscriptGameplayAttributeData EmptyData;
		return EmptyData.AttributeName.IsNone();
	}

	/**
	 * Observe that two runner-supplied handles refer to different objects.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeChangedTrampolineData
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestCallbackDataAttributes First, UTestCallbackDataAttributes Second)
	{
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.OnAttributeChangedTrampolineData
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestCallbackDataAttributesEmpty : UAngelscriptAttributeSet
{
}
