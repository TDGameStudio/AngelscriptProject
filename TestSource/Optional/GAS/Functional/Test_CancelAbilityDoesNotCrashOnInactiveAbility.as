// Theme: Optional.GAS. WorldStory CancelAbility on an inactive granted ability.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::CancelAbilityDoesNotCrashOnInactiveAbility
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestCancelInactiveAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestCancelInactiveAbility : UAngelscriptGASAbility
{
}

int Observe_TestCancelInactiveAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestCancelInactiveAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
