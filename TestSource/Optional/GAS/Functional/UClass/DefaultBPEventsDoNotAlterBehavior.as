/**
 * A script attribute set exposing Strength without any BP_ event overrides, so the
 * default events must leave behavior unchanged. The observers cover the null
 * handle, the empty attribute data and handle independence.
 *
 * @Theme Optional.GAS
 * @Subject GAS.DefaultBPEvents
 * @Harness UClass
 * @Tag Optional.GAS.DefaultBPEventsDoNotAlterBehavior
 * @Provenance Theme: Optional.GAS. WorldStory: UTestDefaultBPAttributes Strength without BP_ overrides.
 * @Provenance C++: AngelscriptGASAttributeSetBPEventTests.cpp::DefaultBPEventsDoNotAlterBehavior
 * @Provenance Oracle: GetAttributeCurrentValue Strength == 50.f after TrySet 50.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns TrySetAttributeBaseValue.
 */

UCLASS()
class UTestDefaultBPAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.DefaultBPEvents
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestDefaultBPAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.DefaultBPEvents
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
	 * @Covers GAS.DefaultBPEvents
	 * @Inputs two attribute set handles
	 * @Return true when both are non-null and differ
	 * @Param First the first handle
	 * @Param Second the second handle
	 * @Boundary handle independence
	 */
	UFUNCTION()
	bool TwoHandlesIndependent(UTestDefaultBPAttributes First, UTestDefaultBPAttributes Second)
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
 * @Covers GAS.DefaultBPEvents
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestDefaultBPAttributesEmpty : UAngelscriptAttributeSet
{
}
