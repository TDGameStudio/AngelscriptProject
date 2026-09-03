/**
 * An ability granted twice, where the second GiveAbility still returns a valid
 * handle without duplicating the grant. The observers cover the empty tag and
 * empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GiveAbilityTwice
 * @Harness UClass
 * @Tag Optional.GAS.GiveAbilityTwiceDoesNotDuplicate
 * @Provenance Theme: Optional.GAS. WorldStory second GiveAbility still returns a valid handle.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityTwiceDoesNotDuplicate
 * @Provenance Keep UTestDupAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestDupAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GiveAbilityTwice
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
	 * @Covers GAS.GiveAbilityTwice
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
