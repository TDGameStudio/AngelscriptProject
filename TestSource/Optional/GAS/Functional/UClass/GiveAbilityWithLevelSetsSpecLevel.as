/**
 * An ability granted with an explicit Level, which must land on the spec. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GiveAbilityWithLevel
 * @Harness UClass
 * @Tag Optional.GAS.GiveAbilityWithLevelSetsSpecLevel
 * @Provenance Theme: Optional.GAS. WorldStory GiveAbility Level 5 sets Spec.Level.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityWithLevelSetsSpecLevel
 * @Provenance Keep UTestLevelAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestLevelAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GiveAbilityWithLevel
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
	 * @Covers GAS.GiveAbilityWithLevel
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
