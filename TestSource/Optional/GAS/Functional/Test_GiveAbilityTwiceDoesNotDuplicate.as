// Theme: Optional.GAS. WorldStory second GiveAbility still returns a valid handle.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityTwiceDoesNotDuplicate
// Keep UTestDupAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestDupAbility : UAngelscriptGASAbility
{
}

int Observe_TestDupAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestDupAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
