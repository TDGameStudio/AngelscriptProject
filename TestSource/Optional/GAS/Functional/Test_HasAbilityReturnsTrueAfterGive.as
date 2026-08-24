// Theme: Optional.GAS. WorldStory HasAbility is true after GiveAbility.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::HasAbilityReturnsTrueAfterGive
// Keep UTestHasAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestHasAbility : UAngelscriptGASAbility
{
}

int Observe_TestHasAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestHasAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
