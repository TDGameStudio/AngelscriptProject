// Theme: Optional.GAS. WorldStory IsAbilityActive is false when given but not activated.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::IsAbilityActiveReturnsFalseWhenNotActivated
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestInactiveAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestInactiveAbility : UAngelscriptGASAbility
{
}

int Observe_TestInactiveAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestInactiveAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
