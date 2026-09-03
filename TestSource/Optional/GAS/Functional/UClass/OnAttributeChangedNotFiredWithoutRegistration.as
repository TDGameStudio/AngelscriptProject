/**
 * A script attribute set exposing Luck, whose OnAttributeChanged must not fire
 * while no callback is registered. The observers cover the null handle, the empty
 * attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.OnAttributeChangedUnregistered
 * @Harness UClass
 * @Tag Optional.GAS.OnAttributeChangedNotFiredWithoutRegistration
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNoRegAttributes Luck without trampoline.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::OnAttributeChangedNotFiredWithoutRegistration
 * @Provenance Oracle: FireCount == 0 when Luck is set 5 -> 10 without RegisterCallbackForAttribute.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns unbound OnAttributeChanged.
 */

UCLASS()
class UTestNoRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeChangedUnregistered
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoRegAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeChangedUnregistered
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
	 * @Covers GAS.OnAttributeChangedUnregistered
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestNoRegAttributes First, UTestNoRegAttributes Second)
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
 * @Covers GAS.OnAttributeChangedUnregistered
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoRegAttributesEmpty : UAngelscriptAttributeSet
{
}
