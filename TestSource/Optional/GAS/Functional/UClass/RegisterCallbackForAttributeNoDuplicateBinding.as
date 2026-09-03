/**
 * A script attribute set exposing Armor, whose duplicate callback registration
 * must not produce a second binding. The observers cover the null handle, the
 * empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterCallbackNoDuplicateBinding
 * @Harness UClass
 * @Tag Optional.GAS.RegisterCallbackForAttributeNoDuplicateBinding
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNoDupAttributes Armor duplicate register.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForAttributeNoDuplicateBinding
 * @Provenance Oracle: duplicate RegisterCallbackForAttribute still FireCount == 1.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns double register then set 10 -> 25.
 */

UCLASS()
class UTestNoDupAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackNoDuplicateBinding
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoDupAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackNoDuplicateBinding
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
	 * @Covers GAS.RegisterCallbackNoDuplicateBinding
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestNoDupAttributes First, UTestNoDupAttributes Second)
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
 * @Covers GAS.RegisterCallbackNoDuplicateBinding
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoDupAttributesEmpty : UAngelscriptAttributeSet
{
}
