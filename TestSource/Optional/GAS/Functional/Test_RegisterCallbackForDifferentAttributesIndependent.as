// Theme: Optional.GAS. WorldStory: UTestIndepAttributes Strength registered, Dexterity not.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForDifferentAttributesIndependent
// Oracle: Dexterity change FireCount names 0; Strength change names 1.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns one-attribute trampoline.

UCLASS()
class UTestIndepAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Dexterity;
}

UCLASS()
class UTestIndepAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestIndepAttributes_NullDefault()
{
	UTestIndepAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestIndepAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestIndepAttributes_TwoHandlesIndependent(UTestIndepAttributes First, UTestIndepAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
