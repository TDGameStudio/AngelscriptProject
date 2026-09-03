/**
 * A script attribute set exposing Focus, whose callback fires even when the
 * base value is set to the value it already holds. The observers cover the null
 * handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.CallbackOnBaseValueApplied
 * @Harness UClass
 * @Tag Optional.GAS.CallbackFiredWhenBaseValueIsApplied
 * @Provenance Theme: Optional.GAS. WorldStory: UTestUnchangedAttributes Focus same-value setter.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::CallbackFiredWhenBaseValueIsApplied
 * @Provenance Oracle: FireCount == 1; OldValue == NewValue after set 60 then 60 again.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns trampoline and same-value set.
 */

UCLASS()
class UTestUnchangedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Focus;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.CallbackOnBaseValueApplied
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestUnchangedAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.CallbackOnBaseValueApplied
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
	 * @Covers GAS.CallbackOnBaseValueApplied
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestUnchangedAttributes First, UTestUnchangedAttributes Second)
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
 * @Covers GAS.CallbackOnBaseValueApplied
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestUnchangedAttributesEmpty : UAngelscriptAttributeSet
{
}
