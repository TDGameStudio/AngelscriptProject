// Theme: Optional.GAS. WorldStory HasAbility is false before GiveAbility.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::HasAbilityReturnsFalseBeforeGive
// Keep UTestNoGiveAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestNoGiveAbility : UAngelscriptGASAbility
{
}

int Observe_TestNoGiveAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestNoGiveAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
