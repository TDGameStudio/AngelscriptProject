/**
 * A script attribute set exposing Mana, whose get-and-register call returns the
 * current value. The observers cover the null handle, the empty attribute data
 * and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetAndRegisterReturnsCurrentValue
 * @Harness UClass
 * @Tag Optional.GAS.GetAndRegisterCallbackForAttributeReturnsCurrentValue
 * @Provenance Theme: Optional.GAS. WorldStory: UTestGetRegAttributes Mana current value is 42.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterCallbackForAttributeReturnsCurrentValue
 * @Provenance Oracle: GetAndRegisterCallbackForAttribute OutValue == 42.f after TrySet Mana 42.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns register and get-and-register.
 */

UCLASS()
class UTestGetRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterReturnsCurrentValue
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestGetRegAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterReturnsCurrentValue
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
	 * @Covers GAS.GetAndRegisterReturnsCurrentValue
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestGetRegAttributes First, UTestGetRegAttributes Second)
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
 * @Covers GAS.GetAndRegisterReturnsCurrentValue
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestGetRegAttributesEmpty : UAngelscriptAttributeSet
{
}
