/**
 * An ability whose spec source object is stored through
 * SetAbilitySpecSourceObject. The observers cover the empty tag and empty
 * container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.SetAbilitySpecSourceObjectStores
 * @Harness UClass
 * @Tag Optional.GAS.SetAbilitySpecSourceObjectStoresObject
 * @Provenance Theme: Optional.GAS. WorldStory SetAbilitySpecSourceObject stores the object.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::SetAbilitySpecSourceObjectStoresObject
 * @Provenance Keep UTestSrcObjAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestSrcObjAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAbilitySpecSourceObjectStores
	 * @Inputs a default-constructed tag
	 * @Return 1
	 * @Boundary empty tag
	 */
	UFUNCTION()
	int EmptyTag()
	{
		FGameplayTag EmptyTag;
		return EmptyTag.IsValid() ? 0 : 1;
	}

	/**
	 * Observe that a default container reports empty.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAbilitySpecSourceObjectStores
	 * @Inputs a default-constructed container
	 * @Return 1
	 * @Boundary empty container
	 */
	UFUNCTION()
	int EmptyContainer()
	{
		FGameplayTagContainer EmptyContainer;
		return EmptyContainer.IsEmpty() ? 1 : 0;
	}
}
