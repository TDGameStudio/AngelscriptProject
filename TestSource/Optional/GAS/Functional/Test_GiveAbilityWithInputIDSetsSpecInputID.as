// Theme: Optional.GAS. WorldStory GiveAbility InputID 3 sets Spec.InputID.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityWithInputIDSetsSpecInputID
// Keep UTestInputIDAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestInputIDAbility : UAngelscriptGASAbility
{
}

int Observe_TestInputIDAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestInputIDAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
