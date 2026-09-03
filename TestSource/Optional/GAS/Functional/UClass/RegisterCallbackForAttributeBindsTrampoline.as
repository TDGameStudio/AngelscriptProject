/**
 * A script attribute set exposing Stamina, whose RegisterCallbackForAttribute call
 * must bind the trampoline so OnAttributeChanged fires. The observers cover the
 * null handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterCallbackBindsTrampoline
 * @Harness UClass
 * @Tag Optional.GAS.RegisterCallbackForAttributeBindsTrampoline
 * @Provenance Theme: Optional.GAS. WorldStory: UTestTrampolineAttributes Stamina callback trampoline.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForAttributeBindsTrampoline
 * @Provenance Oracle: OnAttributeChanged fires after RegisterCallbackForAttribute then set 50 -> 75.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns register and callback bind.
 */

UCLASS()
class UTestTrampolineAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackBindsTrampoline
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestTrampolineAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackBindsTrampoline
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
	 * @Covers GAS.RegisterCallbackBindsTrampoline
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestTrampolineAttributes First, UTestTrampolineAttributes Second)
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
 * @Covers GAS.RegisterCallbackBindsTrampoline
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestTrampolineAttributesEmpty : UAngelscriptAttributeSet
{
}
