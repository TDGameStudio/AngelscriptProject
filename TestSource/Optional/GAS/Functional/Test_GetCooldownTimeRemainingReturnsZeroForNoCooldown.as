// Theme: Optional.GAS. WorldStory GetCooldownTimeRemaining is 0 with no cooldown tags.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GetCooldownTimeRemainingReturnsZeroForNoCooldown
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestNoCooldownAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestNoCooldownAbility : UAngelscriptGASAbility
{
}

int Observe_TestNoCooldownAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestNoCooldownAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
