// Theme: Optional.GAS. WorldStory ClearAbility then HasAbility is false.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::ClearAbilityRemovesAbility
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestClearAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestClearAbility : UAngelscriptGASAbility
{
}

int Observe_TestClearAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestClearAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
