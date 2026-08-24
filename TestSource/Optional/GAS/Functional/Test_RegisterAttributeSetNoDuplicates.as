// Theme: Optional.GAS. WorldStory second RegisterAttributeSet returns the same instance.
// C++: AngelscriptGASAbilitySystemComponentTests.cpp::RegisterAttributeSetNoDuplicates
// Keep UPROPERTY Stamina. Extra: empty tag/container helpers.
// FixtureIsolated.

UCLASS()
class UASCNoDupAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;
}

int Observe_ASCNoDupAttributes_EmptyTag()
{
	FGameplayTag EmptyTag;
	return EmptyTag.IsValid() ? 0 : 1;
}

int Observe_ASCNoDupAttributes_EmptyContainer()
{
	FGameplayTagContainer EmptyContainer;
	return EmptyContainer.IsEmpty() ? 1 : 0;
}
