/**
 * An ability whose already-granted spec is updated through
 * SetAbilitySpecSourceObject. The observers cover the empty tag and empty
 * container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.SetAbilitySpecSourceObjectUpdates
 * @Harness UClass
 * @Tag Optional.GAS.SetAbilitySpecSourceObjectUpdatesExistingSpec
 * @Provenance Theme: Optional.GAS. WorldStory SetAbilitySpecSourceObject updates an existing spec.
 * @Provenance C++: AngelscriptGASAbilityActivationTests.cpp::SetAbilitySpecSourceObjectUpdatesExistingSpec
 * @Provenance Keep UTestSetSrcAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestSetSrcAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.SetAbilitySpecSourceObjectUpdates
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
	 * @Covers GAS.SetAbilitySpecSourceObjectUpdates
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
