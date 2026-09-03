/**
 * An attribute set exposing Rage for the additive ModAttributeUnsafe modifier.
 * C++ owns the modifier application; the observers cover the null handle, the
 * empty attribute data and attribute resolution by name.
 *
 * @Theme Optional.GAS
 * @Subject GAS.ASCModAttributeUnsafe
 * @Harness UClass
 * @Tag Optional.GAS.ASCModAttributeUnsafeAppliesModifier
 * @Provenance Theme: Optional.GAS. WorldStory: UTestModUnsafeAttributes Rage additive ModAttributeUnsafe.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::ASCModAttributeUnsafeAppliesModifier
 * @Provenance Oracle: Rage attribute valid; current 15.f after base 10 plus additive 5.
 * @Provenance Extra: nullptr handle; FName AttributeName None is invalid; empty sibling set.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns ModAttributeUnsafe Additive.
 */

UCLASS()
class UTestModUnsafeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Rage;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestModUnsafeAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
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
	 * Observe that attribute resolution follows the supplied name.
	 *
	 * @Kind Observe
	 * @Covers GAS.ASCModAttributeUnsafe
	 * @Inputs an attribute name to resolve
	 * @Return true when a real name resolves and NAME_None does not
	 * @Param AttributeName the attribute to look up
	 */
	UFUNCTION()
	bool RageAttributeValid(FName AttributeName)
	{
		FGameplayAttribute OutAttr;
		bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestModUnsafeAttributes, AttributeName, OutAttr);

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
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.ASCModAttributeUnsafe
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestModUnsafeAttributesEmpty : UAngelscriptAttributeSet
{
}
