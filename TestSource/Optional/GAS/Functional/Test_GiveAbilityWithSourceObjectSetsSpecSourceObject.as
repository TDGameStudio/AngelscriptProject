// Theme: Optional.GAS. WorldStory GiveAbility SourceObject sets Spec.SourceObject.
// C++: AngelscriptGASAbilityLifecycleScriptTests.cpp::GiveAbilityWithSourceObjectSetsSpecSourceObject
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UTestSrcObjAbility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestSrcObjAbility : UAngelscriptGASAbility
{
}

int Observe_GiveAbilitySrcObj_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_GiveAbilitySrcObj_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
