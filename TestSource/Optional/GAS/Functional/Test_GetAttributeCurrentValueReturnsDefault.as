// Theme: Optional.GAS. WorldStory GetAttributeCurrentValue on fresh Energy is 0.
// C++: AngelscriptGASAbilitySystemComponentTests.cpp::GetAttributeCurrentValueReturnsDefault
// Keep UPROPERTY Energy. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UASCGetValAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;
}

int Observe_ASCGetValAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_ASCGetValAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
