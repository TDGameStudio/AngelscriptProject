// Theme: Optional.GAS. WorldStory GiveAbility returns a valid handle.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityFromScriptReturnsValidHandle
// Keep UTestLifecycleAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestLifecycleAbility : UAngelscriptGASAbility
{
}

int Observe_TestLifecycleAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestLifecycleAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
