// Theme: Optional.GAS. WorldStory CanActivateAbilityByClass is true after GiveAbility.
// C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilityByClassReturnsTrueWhenGranted
// Keep UTestGrantedAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestGrantedAbility : UAngelscriptGASAbility
{
}

int Observe_TestGrantedAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestGrantedAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
