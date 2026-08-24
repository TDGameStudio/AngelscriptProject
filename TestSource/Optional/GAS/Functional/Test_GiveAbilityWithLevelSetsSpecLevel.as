// Theme: Optional.GAS. WorldStory GiveAbility Level 5 sets Spec.Level.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityWithLevelSetsSpecLevel
// Keep UTestLevelAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestLevelAbility : UAngelscriptGASAbility
{
}

int Observe_TestLevelAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestLevelAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
