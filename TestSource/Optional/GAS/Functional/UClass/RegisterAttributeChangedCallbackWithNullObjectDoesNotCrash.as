/**
 * A script attribute set exposing Willpower, used to check that registering a
 * callback against a null object does not crash. The observers cover the null
 * handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterCallbackWithNullObject
 * @Harness UClass
 * @Tag Optional.GAS.RegisterAttributeChangedCallbackWithNullObjectDoesNotCrash
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNullObjAttributes Willpower null-object register.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterAttributeChangedCallbackWithNullObjectDoesNotCrash
 * @Provenance Oracle: RegisterAttributeChangedCallback(..., nullptr, "SomeFunc") does not crash.
 * @Provenance Extra: nullptr handle is the empty vector; empty sibling set; empty attribute data.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns null Object argument.
 */

UCLASS()
class UTestNullObjAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Willpower;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithNullObject
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNullObjAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithNullObject
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
	 * @Covers GAS.RegisterCallbackWithNullObject
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestNullObjAttributes First, UTestNullObjAttributes Second)
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
 * @Covers GAS.RegisterCallbackWithNullObject
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNullObjAttributesEmpty : UAngelscriptAttributeSet
{
}
