// Theme: Optional.GAS. WorldStory TrySetAttributeBaseValue on Vitality.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::TrySetAttributeBaseValueReturnsTrueOnSuccess
// Keep UPROPERTY Vitality. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestSetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vitality;
}

int Observe_TestSetBaseAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestSetBaseAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
