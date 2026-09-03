/**
 * An attribute set whose current-value accessor is driven from script. The
 * observers cover the null handle, a base-value write followed by a current-value
 * read, and the NAME_None rejection.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TryGetCurrentValueFromSelf
 * @Harness UClass
 * @Tag Optional.GAS.AttributeSetTryGetCurrentValueFromSelf
 * @Provenance Theme: Optional.GAS. WorldStory: UTestSelfGetAttributes Intelligence current 55 from self.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::AttributeSetTryGetCurrentValueFromSelf
 * @Provenance Oracle: TryGetAttributeCurrentValue Intelligence OutValue 55.f after TrySet 55.
 * @Provenance Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.
 */

UCLASS()
class UTestSelfGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Intelligence;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueFromSelf
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestSelfGetAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the base write followed by the current read on this set.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueFromSelf
	 * @Inputs the Intelligence attribute written to 55 then read back
	 * @Return true when both operations succeed and the value is 55
	 */
	UFUNCTION()
	bool SetAndGetIntelligence()
	{
		if (this == nullptr)
		{
			return false;
		}
		if (!TrySetAttributeBaseValue(n"Intelligence", 55.0f))
		{
			return false;
		}
		float OutValue = 0.0f;
		if (!TryGetAttributeCurrentValue(n"Intelligence", OutValue))
		{
			return false;
		}
		return OutValue == 55.0f;
	}

	/**
	 * Observe that NAME_None is rejected by the current-value read.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetCurrentValueFromSelf
	 * @Inputs an unset attribute name
	 * @Return true when the read reports failure
	 * @Param AttributeName the name to reject, expected to be NAME_None
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(FName AttributeName)
	{
		if (this == nullptr)
		{
			return false;
		}
		float OutValue = 0.0f;
		return !TryGetAttributeCurrentValue(AttributeName, OutValue);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TryGetCurrentValueFromSelf
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestSelfGetAttributesEmpty : UAngelscriptAttributeSet
{
}
