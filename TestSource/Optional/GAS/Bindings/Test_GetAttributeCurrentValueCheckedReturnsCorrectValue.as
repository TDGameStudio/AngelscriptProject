// Theme: Optional.GAS. WorldStory TryGetAttributeCurrentValue on Wisdom.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::GetAttributeCurrentValueCheckedReturnsCorrectValue
// Keep UPROPERTY Wisdom. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestGetCurrentAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;
}

int Observe_TestGetCurrentAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestGetCurrentAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
