/**
 * A script attribute set exposing Armor, whose PreAttributeBaseChange override
 * must run on base-value writes. The observers cover the null handle, the empty
 * attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.PreAttributeBaseChange
 * @Harness UClass
 * @Tag Optional.GAS.PreAttributeBaseChangeIsCalled
 * @Provenance Theme: Optional.GAS. WorldStory: UTestPreBaseAttributes Armor PreAttributeBaseChange.
 * @Provenance C++: AngelscriptGASAttributeSetBPEventTests.cpp::PreAttributeBaseChangeIsCalled
 * @Provenance Oracle: GetAttributeBaseValueChecked Armor == 75.f after SetAttributeBaseValue 75.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns SetAttributeBaseValue.
 */

UCLASS()
class UTestPreBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.PreAttributeBaseChange
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestPreBaseAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.PreAttributeBaseChange
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
	 * @Covers GAS.PreAttributeBaseChange
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestPreBaseAttributes First, UTestPreBaseAttributes Second)
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
 * @Covers GAS.PreAttributeBaseChange
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestPreBaseAttributesEmpty : UAngelscriptAttributeSet
{
}
