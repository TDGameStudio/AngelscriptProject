/**
 * A script attribute set exposing Endurance, whose base value is read back from
 * the set itself. The observers cover the null handle, the write-then-read round
 * trip and the NAME_None rejection.
 *
 * @Theme Optional.GAS
 * @Subject GAS.TryGetAttributeBaseValueFromSelf
 * @Harness UClass
 * @Tag Optional.GAS.TryGetAttributeBaseValueFromSelf
 * @Provenance Theme: Optional.GAS. WorldStory: UTestGetBaseAttributes Endurance base 66 from self.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::TryGetAttributeBaseValueFromSelf
 * @Provenance Oracle: TryGetAttributeBaseValue Endurance OutValue 66.f after TrySet 66.
 * @Provenance Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.
 */

UCLASS()
class UTestGetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Endurance;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetAttributeBaseValueFromSelf
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestGetBaseAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the base write followed by the base read on this set.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetAttributeBaseValueFromSelf
	 * @Inputs a registered set written to 66 then read back
	 * @Return true when the read reports 66
	 * @Param Set the instance to write and read
	 */
	UFUNCTION()
	bool SetAndGetEndurance(UTestGetBaseAttributes Set)
	{
		if (Set == nullptr)
		{
			return false;
		}
		if (!Set.TrySetAttributeBaseValue(n"Endurance", 66.0f))
		{
			return false;
		}
		float OutValue = 0.0f;
		if (!Set.TryGetAttributeBaseValue(n"Endurance", OutValue))
		{
			return false;
		}
		return OutValue == 66.0f;
	}

	/**
	 * Observe that an unset attribute name is rejected by the read.
	 *
	 * @Kind Observe
	 * @Covers GAS.TryGetAttributeBaseValueFromSelf
	 * @Inputs a registered set and an unset attribute name
	 * @Return true when the read reports failure
	 * @Param Set the instance to read against
	 * @Param AttributeName the name to reject, expected to be NAME_None
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(UTestGetBaseAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		float OutValue = 0.0f;
		return !Set.TryGetAttributeBaseValue(AttributeName, OutValue);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.TryGetAttributeBaseValueFromSelf
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestGetBaseAttributesEmpty : UAngelscriptAttributeSet
{
}
