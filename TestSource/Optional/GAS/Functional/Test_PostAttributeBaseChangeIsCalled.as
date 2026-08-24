// Theme: Optional.GAS. WorldStory: UTestPostBaseAttributes Shield PostAttributeBaseChange.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::PostAttributeBaseChangeIsCalled
// Oracle: GetAttributeBaseValueChecked Shield == 40.f after 20 then 40.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns two SetAttributeBaseValue calls.

UCLASS()
class UTestPostBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Shield;
}

UCLASS()
class UTestPostBaseAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestPostBaseAttributes_NullDefault()
{
	UTestPostBaseAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestPostBaseAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestPostBaseAttributes_TwoHandlesIndependent(UTestPostBaseAttributes First, UTestPostBaseAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
