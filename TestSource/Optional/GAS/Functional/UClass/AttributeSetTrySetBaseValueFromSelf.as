/**
 * An attribute set whose base-value setter and getter are driven from script. The
 * observers cover the null handle, a base write followed by a base read, and the
 * NAME_None rejection.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TrySetBaseValueFromSelf
 * @Harness UClass
 * @Tag Optional.GAS.AttributeSetTrySetBaseValueFromSelf
 * @Provenance Theme: Optional.GAS. WorldStory: UTestSelfSetAttributes TrySet/Get Dexterity 77 from self.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::AttributeSetTrySetBaseValueFromSelf
 * @Provenance Oracle: TrySetAttributeBaseValue Dexterity 77 true; TryGetAttributeBaseValue OutValue 77.f.
 * @Provenance Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.
 */

UCLASS()
class UTestSelfSetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Dexterity;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFromSelf
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestSelfSetAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the base write followed by the base read on this set.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFromSelf
	 * @Inputs the Dexterity attribute written to 77 then read back
	 * @Return true when both operations succeed and the value is 77
	 */
	UFUNCTION()
	bool SetAndGetDexterity()
	{
		if (this == nullptr)
		{
			return false;
		}
		if (!TrySetAttributeBaseValue(n"Dexterity", 77.0f))
		{
			return false;
		}
		float OutValue = 0.0f;
		if (!TryGetAttributeBaseValue(n"Dexterity", OutValue))
		{
			return false;
		}
		return OutValue == 77.0f;
	}

	/**
	 * Observe that NAME_None is rejected by the base-value write.
	 *
	 * @Kind Observe
	 * @Covers GAS.TrySetBaseValueFromSelf
	 * @Inputs an unset attribute name
	 * @Return true when the write reports failure
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
		return !TrySetAttributeBaseValue(AttributeName, 0.0f);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TrySetBaseValueFromSelf
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestSelfSetAttributesEmpty : UAngelscriptAttributeSet
{
}
