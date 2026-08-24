// Theme: Optional.GAS. WorldStory: UTestNoASCCompAttributes unowned NewObject.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::BP_GetOwningAbilitySystemComponentReturnsNullWithoutASC
// Oracle: BP_GetOwningAbilitySystemComponent() is null when the set has no owning ASC.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns unowned NewObject set.

UCLASS()
class UTestNoASCCompAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temp;
}

UCLASS()
class UTestNoASCCompAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoASCCompAttributes_NullDefault()
{
	UTestNoASCCompAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoASCCompAttributes_UnownedASCIsNull(UTestNoASCCompAttributes Set)
{
	return Set.BP_GetOwningAbilitySystemComponent() == nullptr;
}

bool Observe_UTestNoASCCompAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}
