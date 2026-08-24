// Theme: Optional.GAS. WorldStory TryActivateAbilitySpec returns true on success.
// C++: AngelscriptGASAbilityActivationTests.cpp::TryActivateAbilitySpecReturnsTrueOnSuccess
// Keep UTestActivateSuccessAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestActivateSuccessAbility : UAngelscriptGASAbility
{
}

int Observe_TestActivateSuccessAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestActivateSuccessAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
