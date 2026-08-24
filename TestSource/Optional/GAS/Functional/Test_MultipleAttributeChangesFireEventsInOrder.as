// Theme: Optional.GAS. WorldStory: UTestMultiChangeAttributes Attack and Defense.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::MultipleAttributeChangesFireEventsInOrder
// Oracle: Attack current 30.f; Defense current 20.f after 10/20/30 sequence.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ordered TrySet calls.

UCLASS()
class UTestMultiChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Attack;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Defense;
}

UCLASS()
class UTestMultiChangeAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestMultiChangeAttributes_NullDefault()
{
	UTestMultiChangeAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestMultiChangeAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestMultiChangeAttributes_TwoHandlesIndependent(UTestMultiChangeAttributes First, UTestMultiChangeAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
