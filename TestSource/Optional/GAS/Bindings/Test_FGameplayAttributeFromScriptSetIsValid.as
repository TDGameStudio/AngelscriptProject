// Theme: Optional.GAS. WorldStory script attribute set Power is a valid FGameplayAttribute.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeFromScriptSetIsValid
// Keep UPROPERTY Power. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestFGAValidAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;
}

int Observe_TestFGAValidAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestFGAValidAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
