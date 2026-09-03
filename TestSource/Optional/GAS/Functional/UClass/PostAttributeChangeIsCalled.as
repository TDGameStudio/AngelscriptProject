/**
 * A script attribute set exposing Mana, whose PostAttributeChange override must
 * run on current-value writes. The observers cover the null handle, the empty
 * attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.PostAttributeChange
 * @Harness UClass
 * @Tag Optional.GAS.PostAttributeChangeIsCalled
 * @Provenance Theme: Optional.GAS. WorldStory: UTestPostChangeAttributes Mana PostAttributeChange pipeline.
 * @Provenance C++: AngelscriptGASAttributeSetBPEventTests.cpp::PostAttributeChangeIsCalled
 * @Provenance Oracle: GetAttributeCurrentValue Mana == 60.f after 30 then 60.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns two TrySet calls.
 */

UCLASS()
class UTestPostChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.PostAttributeChange
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestPostChangeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.PostAttributeChange
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
	 * @Covers GAS.PostAttributeChange
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestPostChangeAttributes First, UTestPostChangeAttributes Second)
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
 * @Covers GAS.PostAttributeChange
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestPostChangeAttributesEmpty : UAngelscriptAttributeSet
{
}
