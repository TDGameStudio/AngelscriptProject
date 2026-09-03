/**
 * An ability whose spec source object was never set, so GetAbilitySpecSourceObject
 * reports null. The observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.AbilitySpecSourceObjectNull
 * @Harness UClass
 * @Tag Optional.GAS.GetAbilitySpecSourceObjectReturnsNullWhenNotSet
 * @Provenance Theme: Optional.GAS. WorldStory GetAbilitySpecSourceObject is null when not set.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::GetAbilitySpecSourceObjectReturnsNullWhenNotSet
 * @Provenance Keep UTestNoSrcAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestNoSrcAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.AbilitySpecSourceObjectNull
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
	 * @Covers GAS.AbilitySpecSourceObjectNull
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
