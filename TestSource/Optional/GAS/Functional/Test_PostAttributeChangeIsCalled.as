// Theme: Optional.GAS. WorldStory: UTestPostChangeAttributes Mana PostAttributeChange pipeline.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::PostAttributeChangeIsCalled
// Oracle: GetAttributeCurrentValue Mana == 60.f after 30 then 60.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns two TrySet calls.

UCLASS()
class UTestPostChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;
}

UCLASS()
class UTestPostChangeAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestPostChangeAttributes_NullDefault()
{
	UTestPostChangeAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestPostChangeAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestPostChangeAttributes_TwoHandlesIndependent(UTestPostChangeAttributes First, UTestPostChangeAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
