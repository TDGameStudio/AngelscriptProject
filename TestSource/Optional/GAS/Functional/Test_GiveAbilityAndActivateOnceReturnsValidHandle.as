// Theme: Optional.GAS. WorldStory GiveAbilityAndActivateOnce returns a valid handle.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityAndActivateOnceReturnsValidHandle
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestActivateOnceAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestActivateOnceAbility : UAngelscriptGASAbility
{
}

int Observe_TestActivateOnceAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestActivateOnceAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
