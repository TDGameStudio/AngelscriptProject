/**
 * A script attribute set exposing Strength and Agility for subclass-based
 * attribute lookup. The observers cover the null handle, the named lookup with
 * its NAME_None rejection, and both attributes resolving as valid.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GetGameplayAttributeFromSubclass
 * @Harness UClass
 * @Tag Optional.GAS.GetGameplayAttributeFromScriptSubclass
 * @Provenance Theme: Optional.GAS. WorldStory: UTestUtilAttributes Strength and Agility lookup.
 * @Provenance C++: AngelscriptGASAttributeSetUtilityTests.cpp::GetGameplayAttributeFromScriptSubclass
 * @Provenance Oracle: GetGameplayAttribute Strength and Agility both IsValid().
 * @Provenance Extra: nullptr handle; FName AttributeName None is invalid; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.
 */

UCLASS()
class UTestUtilAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetGameplayAttributeFromSubclass
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestUtilAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that attribute lookup follows the supplied name.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetGameplayAttributeFromSubclass
	 * @Inputs an attribute name to look up
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param AttributeName the attribute to look up
	 */
	UFUNCTION()
	bool NamedIsValid(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, AttributeName, OutAttr);

		if (AttributeName.IsNone())
		{
			if (bFound)
			{
				return false;
			}
			return !OutAttr.IsValid();
		}

		if (!bFound)
		{
			return false;
		}
		return OutAttr.IsValid();
	}

	/**
	 * Observe that both attributes resolve as valid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GetGameplayAttributeFromSubclass
	 * @Inputs the Strength and Agility attributes resolved by name
	 * @Return true when both report valid
	 */
	UFUNCTION()
	bool StrengthAndAgility()
	{
		FGameplayAttribute StrengthAttr;
		FGameplayAttribute AgilityAttr;

		if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, n"Strength", StrengthAttr))
		{
			return false;
		}
		if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, n"Agility", AgilityAttr))
		{
			return false;
		}
		if (!StrengthAttr.IsValid())
		{
			return false;
		}
		return AgilityAttr.IsValid();
	}
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.GetGameplayAttributeFromSubclass
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestUtilAttributesEmpty : UAngelscriptAttributeSet
{
}
