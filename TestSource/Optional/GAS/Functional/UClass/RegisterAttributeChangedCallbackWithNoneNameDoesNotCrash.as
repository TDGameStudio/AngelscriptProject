/**
 * A script attribute set exposing Resolve, used to check that registering a
 * callback under NAME_None does not crash. The observers cover the null handle,
 * the empty attribute data and the unset function name.
 *
 * @Theme Optional.GAS
 * @Subject GAS.RegisterCallbackWithNoneName
 * @Harness UClass
 * @Tag Optional.GAS.RegisterAttributeChangedCallbackWithNoneNameDoesNotCrash
 * @Provenance Theme: Optional.GAS. WorldStory: UTestNoneNameAttributes Resolve NAME_None function.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterAttributeChangedCallbackWithNoneNameDoesNotCrash
 * @Provenance Oracle: RegisterAttributeChangedCallback(..., NAME_None) does not crash.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FName / empty attribute data.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns NAME_None function argument.
 */

UCLASS()
class UTestNoneNameAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Resolve;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithNoneName
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestNoneNameAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithNoneName
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
	 * Observe the unset function name used by the registration.
	 *
	 * @Kind Observe
	 * @Covers GAS.RegisterCallbackWithNoneName
	 * @Inputs the NAME_None function name
	 * @Return true when the name reports none
	 * @Boundary empty function name
	 */
	UFUNCTION()
	bool NoneFunctionName()
	{
		FName FunctionName = NAME_None;
		return FunctionName.IsNone();
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.RegisterCallbackWithNoneName
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestNoneNameAttributesEmpty : UAngelscriptAttributeSet
{
}
