/**
 * A script attribute set exposing Vigor, whose registration on an ASC must fire
 * the OnAttributeSetRegistered delegate with the registered set. The observers
 * cover the null handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.OnAttributeSetRegisteredFires
 * @Harness UClass
 * @Tag Optional.GAS.OnAttributeSetRegisteredDelegateFires
 * @Provenance Theme: Optional.GAS. WorldStory: UTestDelegateRegAttributes registers on an ASC.
 * @Provenance C++: AngelscriptGASASCDelegateTests.cpp::OnAttributeSetRegisteredDelegateFires
 * @Provenance Oracle: OnAttributeSetRegistered fires; CapturedAttributeSet == RegisteredSet.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns ASC register.
 */

UCLASS()
class UTestDelegateRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vigor;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeSetRegisteredFires
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestDelegateRegAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.OnAttributeSetRegisteredFires
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
	 * @Covers GAS.OnAttributeSetRegisteredFires
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestDelegateRegAttributes First, UTestDelegateRegAttributes Second)
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
 * @Covers GAS.OnAttributeSetRegisteredFires
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestDelegateRegAttributesEmpty : UAngelscriptAttributeSet
{
}
