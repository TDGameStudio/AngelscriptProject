// Theme: Optional.GAS. WorldStory RegisterAttributeSet creates a Health/MaxHealth instance.
// C++: AngelscriptGASAbilitySystemComponentTests.cpp::RegisterAttributeSetCreatesInstance
// Keep UPROPERTY Health and MaxHealth. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UASCTestAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData MaxHealth;
}

int Observe_ASCTestAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_ASCTestAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
