// Theme: Optional.GAS. WorldStory GetAbilitySpecSourceObject is null when not set.
// C++: AngelscriptGASAbilityActivationTests.cpp::GetAbilitySpecSourceObjectReturnsNullWhenNotSet
// Keep UTestNoSrcAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestNoSrcAbility : UAngelscriptGASAbility
{
}

int Observe_TestNoSrcAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestNoSrcAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
