// Theme: Optional.GAS. WorldStory SetAbilitySpecSourceObject updates an existing spec.
// C++: AngelscriptGASAbilityActivationTests.cpp::SetAbilitySpecSourceObjectUpdatesExistingSpec
// Keep UTestSetSrcAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestSetSrcAbility : UAngelscriptGASAbility
{
}

int Observe_TestSetSrcAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestSetSrcAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
