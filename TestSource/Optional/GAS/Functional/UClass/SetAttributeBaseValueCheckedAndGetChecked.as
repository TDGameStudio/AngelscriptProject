/**
 * A script attribute set exposing Focus for the checked base-value set and get
 * pair. The observers cover the null handle, the write-then-read round trip and
 * the NAME_None rejection.
 *
 * @Theme Optional.GAS
 * @Subject GAS.SetAttributeBaseValueCheckedAndGetChecked
 * @Harness UClass
 * @Tag Optional.GAS.SetAttributeBaseValueCheckedAndGetChecked
 * @Provenance Theme: Optional.GAS. WorldStory: UTestCheckedAttributes Focus checked set/get 99.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::SetAttributeBaseValueCheckedAndGetChecked
 * @Provenance Oracle: GetAttributeBaseValueChecked Focus 99.f; GetAttributeCurrentValueChecked 99.f.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns ASC SetAttributeBaseValue.
 */

UCLASS()
class UTestCheckedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Focus;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueCheckedAndGetChecked
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestCheckedAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the base write followed by both checked reads.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueCheckedAndGetChecked
	 * @Inputs a registered attribute set written to 99 then read twice
	 * @Return true when both reads report 99
	 * @Param Set the instance to write and read
	 */
	UFUNCTION()
	bool SetAndGetFocus(UTestCheckedAttributes Set)
	{
		if (Set == nullptr)
		{
			return false;
		}
		if (!Set.TrySetAttributeBaseValue(n"Focus", 99.0f))
		{
			return false;
		}
		float OutValue = 0.0f;
		if (!Set.TryGetAttributeBaseValue(n"Focus", OutValue))
		{
			return false;
		}
		if (OutValue != 99.0f)
		{
			return false;
		}
		float OutCurrent = 0.0f;
		if (!Set.TryGetAttributeCurrentValue(n"Focus", OutCurrent))
		{
			return false;
		}
		return OutCurrent == 99.0f;
	}

	/**
	 * Observe that an unset attribute name is rejected by the write.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAttributeBaseValueCheckedAndGetChecked
	 * @Inputs a registered set and an unset attribute name
	 * @Return true when the write reports failure
	 * @Param Set the instance to write against
	 * @Param AttributeName the name to reject, expected to be NAME_None
	 * @Boundary empty name
	 */
	UFUNCTION()
	bool EmptyNameReturnsFalse(UTestCheckedAttributes Set, FName AttributeName)
	{
		if (Set == nullptr)
		{
			return false;
		}
		return !Set.TrySetAttributeBaseValue(AttributeName, 0.0f);
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.SetAttributeBaseValueCheckedAndGetChecked
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestCheckedAttributesEmpty : UAngelscriptAttributeSet
{
}
