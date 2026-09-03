/**
 * A script attribute set exposing Health and Shield, each of which gets its own
 * callback. The observers cover the null handle, the empty attribute data and
 * handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.MultipleAttributesOwnCallback
 * @Harness UClass
 * @Tag Optional.GAS.MultipleAttributesEachGetOwnCallback
 * @Provenance Theme: Optional.GAS. WorldStory: UTestMultiCallbackAttributes Health and Shield.
 * @Provenance C++: AngelscriptGASAttributeCallbackTests.cpp::MultipleAttributesEachGetOwnCallback
 * @Provenance Oracle: two callbacks; names Health then Shield after 100/50 -> 80/30.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns two callback binds.
 */

UCLASS()
class UTestMultiCallbackAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Shield;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributesOwnCallback
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestMultiCallbackAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.MultipleAttributesOwnCallback
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
	 * @Covers GAS.MultipleAttributesOwnCallback
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestMultiCallbackAttributes First, UTestMultiCallbackAttributes Second)
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
 * @Covers GAS.MultipleAttributesOwnCallback
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestMultiCallbackAttributesEmpty : UAngelscriptAttributeSet
{
}
