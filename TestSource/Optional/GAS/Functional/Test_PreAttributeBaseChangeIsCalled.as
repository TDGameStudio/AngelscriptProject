// Theme: Optional.GAS. WorldStory: UTestPreBaseAttributes Armor PreAttributeBaseChange.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::PreAttributeBaseChangeIsCalled
// Oracle: GetAttributeBaseValueChecked Armor == 75.f after SetAttributeBaseValue 75.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns SetAttributeBaseValue.

UCLASS()
class UTestPreBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;
}

UCLASS()
class UTestPreBaseAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestPreBaseAttributes_NullDefault()
{
	UTestPreBaseAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestPreBaseAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestPreBaseAttributes_TwoHandlesIndependent(UTestPreBaseAttributes First, UTestPreBaseAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
