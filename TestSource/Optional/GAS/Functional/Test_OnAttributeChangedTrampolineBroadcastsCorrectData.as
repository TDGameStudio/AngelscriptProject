// Theme: Optional.GAS. WorldStory: UTestCallbackDataAttributes Energy old 20 new 35.
// C++: AngelscriptGASAttributeCallbackTests.cpp::OnAttributeChangedTrampolineBroadcastsCorrectData
// Oracle: CapturedAttributeChange.Name == Energy; OldValue 20; NewValue 35.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns trampoline bind and set 20 -> 35.

UCLASS()
class UTestCallbackDataAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;
}

UCLASS()
class UTestCallbackDataAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestCallbackDataAttributes_NullDefault()
{
	UTestCallbackDataAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestCallbackDataAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestCallbackDataAttributes_TwoHandlesIndependent(UTestCallbackDataAttributes First, UTestCallbackDataAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
