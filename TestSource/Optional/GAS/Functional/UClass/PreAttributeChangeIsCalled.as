/**
 * A script attribute set exposing Health, whose PreAttributeChange override must
 * run on current-value writes. The observers cover the null handle, the empty
 * attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.PreAttributeChange
 * @Harness UClass
 * @Tag Optional.GAS.PreAttributeChangeIsCalled
 * @Provenance Theme: Optional.GAS. WorldStory: UTestPreChangeAttributes Health PreAttributeChange pipeline.
 * @Provenance C++: AngelscriptGASAttributeSetBPEventTests.cpp::PreAttributeChangeIsCalled
 * @Provenance Oracle: TryGetAttributeBaseValue Health == 100.f after TrySet 100.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns TrySet then TryGet base.
 */

UCLASS()
class UTestPreChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.PreAttributeChange
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestPreChangeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.PreAttributeChange
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
	 * @Covers GAS.PreAttributeChange
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestPreChangeAttributes First, UTestPreChangeAttributes Second)
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
 * @Covers GAS.PreAttributeChange
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestPreChangeAttributesEmpty : UAngelscriptAttributeSet
{
}
