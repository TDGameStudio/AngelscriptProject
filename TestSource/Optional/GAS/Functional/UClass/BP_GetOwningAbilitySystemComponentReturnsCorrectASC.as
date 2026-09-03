/**
 * An attribute set whose BP_GetOwningAbilitySystemComponent resolves back to the
 * ASC that registered it. The observers cover the null handle, the resolved ASC
 * and the empty attribute data.
 *
 * @Theme Optional.GAS
 * @Subject GAS.BPGetOwningASC
 * @Harness UClass
 * @Tag Optional.GAS.BP_GetOwningAbilitySystemComponentReturnsCorrectASC
 * @Provenance Theme: Optional.GAS. WorldStory: UTestASCRefAttributes BP_GetOwningAbilitySystemComponent.
 * @Provenance C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningAbilitySystemComponentReturnsCorrectASC
 * @Provenance Oracle: BP_GetOwningAbilitySystemComponent() == the ASC that registered the set.
 * @Provenance Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
 * @Provenance Isolation=none. Optional GAS plugin fixture. Runner owns ASC register.
 */

UCLASS()
class UTestASCRefAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASC
	 * @Inputs an unset attribute set handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool NullDefault()
	{
		UTestASCRefAttributes Set = nullptr;
		return Set == nullptr;
	}

	/**
	 * Observe the owning ASC reported by this set.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASC
	 * @Inputs this set's owning ASC and the runner-supplied baseline
	 * @Return true when the owning ASC matches
	 * @Param BaselineASC the ASC that registered the set
	 */
	UFUNCTION()
	bool OwningASC(UAngelscriptAbilitySystemComponent BaselineASC)
	{
		return BP_GetOwningAbilitySystemComponent() == BaselineASC;
	}

	/**
	 * Observe that empty attribute data carries no attribute name.
	 *
	 * @Kind Observe
	 * @Covers GAS.BPGetOwningASC
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
}

/**
 * The empty sibling set that C++ also compiles alongside the populated one.
 *
 * @Covers GAS.BPGetOwningASC
 * @Inputs none
 * @Return a declared but empty attribute set
 */
UCLASS()
class UTestASCRefAttributesEmpty : UAngelscriptAttributeSet
{
}
