// Theme: Optional.GAS. WorldStory CanActivateAbilityByClass is false when not granted.
// C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilityByClassReturnsFalseWhenNotGranted
// Keep UTestNotGrantedAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestNotGrantedAbility : UAngelscriptGASAbility
{
}

int Observe_TestNotGrantedAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestNotGrantedAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
