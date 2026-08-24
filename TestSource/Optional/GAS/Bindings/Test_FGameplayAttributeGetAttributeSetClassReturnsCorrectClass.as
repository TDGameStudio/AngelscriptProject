// Theme: Optional.GAS. WorldStory GetAttributeSetClass matches the script set.
// C++: AngelscriptGASFGameplayAttributeBindingsTests.cpp::FGameplayAttributeGetAttributeSetClassReturnsCorrectClass
// Keep UPROPERTY Agility. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UTestFGAClassAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;
}

int Observe_TestFGAClassAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_TestFGAClassAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
