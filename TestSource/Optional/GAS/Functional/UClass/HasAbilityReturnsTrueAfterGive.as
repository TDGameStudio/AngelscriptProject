/**
 * An ability that has been granted, so HasAbility reports true. The observers
 * cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.HasAbilityAfterGive
 * @Harness UClass
 * @Tag Optional.GAS.HasAbilityReturnsTrueAfterGive
 * @Provenance Theme: Optional.GAS. WorldStory HasAbility is true after GiveAbility.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::HasAbilityReturnsTrueAfterGive
 * @Provenance Keep UTestHasAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestHasAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.HasAbilityAfterGive
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
	 * @Covers GAS.HasAbilityAfterGive
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
