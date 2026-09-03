/**
 * A script attribute set exposing Strength and Dexterity, where only the
 * registered attribute fires its callback. The observers cover the null handle,
 * the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterCallbackDifferentAttributesIndependent
 * @Harness UClass
 * @Tag Optional.GAS.RegisterCallbackForDifferentAttributesIndependent
 * @Provenance Theme: Optional.GAS. WorldStory: UTestIndepAttributes Strength registered, Dexterity not.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForDifferentAttributesIndependent
 * @Provenance Oracle: Dexterity change FireCount names 0; Strength change names 1.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns one-attribute trampoline.
 */

UCLASS()
class UTestIndepAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Dexterity;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackDifferentAttributesIndependent
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestIndepAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackDifferentAttributesIndependent
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
	 * @Covers GAS.RegisterCallbackDifferentAttributesIndependent
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestIndepAttributes First, UTestIndepAttributes Second)
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
 * @Covers GAS.RegisterCallbackDifferentAttributesIndependent
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestIndepAttributesEmpty : UAngelscriptAttributeSet
{
}
