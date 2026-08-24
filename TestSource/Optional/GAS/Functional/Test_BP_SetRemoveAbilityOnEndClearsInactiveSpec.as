// Theme: Optional.GAS. WorldStory BP_SetRemoveAbilityOnEnd on an inactive spec.
// C++: AngelscriptGASAbilityActivationTests.cpp::BP_SetRemoveAbilityOnEndClearsInactiveSpec
// Keep UTestRemoveEndAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestRemoveEndAbility : UAngelscriptGASAbility
{
}

int Observe_TestRemoveEndAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestRemoveEndAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
