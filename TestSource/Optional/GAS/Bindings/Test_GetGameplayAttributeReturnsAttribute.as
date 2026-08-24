// Theme: Optional.GAS. WorldStory script attribute set Luck for mixin GetGameplayAttribute.
// C++: AngelscriptGASAttributeChangedDataMixinTests.cpp::GetGameplayAttributeReturnsAttribute
// C++ CompileScriptModule UTestMixinAttrSet, GetGameplayAttribute("Luck") IsValid.
// Extra: empty tag/container helpers. Keep UPROPERTY Luck.
// FixtureIsolated.

UCLASS()
class UTestMixinAttrSet : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;
}

int Observe_TestMixinAttrSet_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestMixinAttrSet_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
