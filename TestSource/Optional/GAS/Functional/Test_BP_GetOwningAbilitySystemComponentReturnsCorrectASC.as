// Theme: Optional.GAS. WorldStory: UTestASCRefAttributes BP_GetOwningAbilitySystemComponent.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningAbilitySystemComponentReturnsCorrectASC
// Oracle: BP_GetOwningAbilitySystemComponent() == the ASC that registered the set.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ASC register.

UCLASS()
class UTestASCRefAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;
}

UCLASS()
class UTestASCRefAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestASCRefAttributes_NullDefault()
{
	UTestASCRefAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestASCRefAttributes_OwningASC(UTestASCRefAttributes Set, UAngelscriptAbilitySystemComponent ExpectedASC)
{
	return Set.BP_GetOwningAbilitySystemComponent() == ExpectedASC;
}

bool Observe_UTestASCRefAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
