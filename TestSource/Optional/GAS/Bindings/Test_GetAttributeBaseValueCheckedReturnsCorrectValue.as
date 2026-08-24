// Theme: Optional.GAS. WorldStory TryGetAttributeBaseValue on Intelligence.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::GetAttributeBaseValueCheckedReturnsCorrectValue
// Keep UPROPERTY Intelligence. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestGetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Intelligence;
}

int Observe_TestGetBaseAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestGetBaseAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
