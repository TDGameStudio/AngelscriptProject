// Theme: Optional.GAS. WorldStory CanActivateAbilitySpec is true for a granted spec.
// C++: AngelscriptGASAbilityActivationTests.cpp::CanActivateAbilitySpecReturnsTrueForValidSpec
// Keep UTestValidSpecAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestValidSpecAbility : UAngelscriptGASAbility
{
}

int Observe_TestValidSpecAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestValidSpecAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
