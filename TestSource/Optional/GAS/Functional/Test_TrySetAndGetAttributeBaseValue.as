// Theme: Optional.GAS. WorldStory TrySet/TryGetAttributeBaseValue Power == 42.
// C++: AngelscriptGASAbilitySystemComponentTests.cpp::TrySetAndGetAttributeBaseValue
// Trailing C++ AddExpectedError is a sibling null-class test, not this class.
// Keep UPROPERTY Power. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UASCSetGetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Power;
}

int Observe_ASCSetGetBaseAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_ASCSetGetBaseAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
