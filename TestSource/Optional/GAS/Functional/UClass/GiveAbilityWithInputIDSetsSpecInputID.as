/**
 * An ability granted with an explicit InputID, which must land on the spec. The
 * observers cover the empty tag and empty container vectors.
 *
 * @Theme Optional.GAS
 * @Subject GAS.GiveAbilityWithInputID
 * @Harness UClass
 * @Tag Optional.GAS.GiveAbilityWithInputIDSetsSpecInputID
 * @Provenance Theme: Optional.GAS. WorldStory GiveAbility InputID 3 sets Spec.InputID.
 * @Provenance C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityWithInputIDSetsSpecInputID
 * @Provenance Keep UTestInputIDAbility. Extra: empty tag/container helpers.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class UTestInputIDAbility : UAngelscriptGASAbility
{
	/**
	 * Observe that a default tag reports invalid.
	 *
	 * @Kind Observe
	 * @Covers GAS.GiveAbilityWithInputID
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
	 * @Covers GAS.GiveAbilityWithInputID
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
