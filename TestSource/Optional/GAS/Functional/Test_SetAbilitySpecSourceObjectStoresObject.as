// Theme: Optional.GAS. WorldStory SetAbilitySpecSourceObject stores the object.
// C++: AngelscriptGASAbilityActivationTests.cpp::SetAbilitySpecSourceObjectStoresObject
// Keep UTestSrcObjAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestSrcObjAbility : UAngelscriptGASAbility
{
}

int Observe_TestSrcObjAbility_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestSrcObjAbility_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
