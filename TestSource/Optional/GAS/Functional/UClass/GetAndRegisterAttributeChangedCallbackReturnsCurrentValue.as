/**
 * A script attribute set used for the get-and-register attribute-changed
 * callback. The observers cover the null handle, the empty attribute data and
 * handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetAndRegisterChangedCallback
 * @Harness UClass
 * @Tag Optional.GAS.GetAndRegisterAttributeChangedCallbackReturnsCurrentValue
 * @Provenance Theme: Optional.GAS. WorldStory: UTestGetRegChangedAttributes Spirit current 88 then 99.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterAttributeChangedCallbackReturnsCurrentValue
 * @Provenance Oracle: OutValue == 88.f; later set 99 fires the provided UFunction.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns get-and-register UFunction bind.
 */

UCLASS()
class UTestGetRegChangedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Spirit;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterChangedCallback
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestGetRegChangedAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetAndRegisterChangedCallback
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
	 * @Covers GAS.GetAndRegisterChangedCallback
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestGetRegChangedAttributes First, UTestGetRegChangedAttributes Second)
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
 * @Covers GAS.GetAndRegisterChangedCallback
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestGetRegChangedAttributesEmpty : UAngelscriptAttributeSet
{
}
