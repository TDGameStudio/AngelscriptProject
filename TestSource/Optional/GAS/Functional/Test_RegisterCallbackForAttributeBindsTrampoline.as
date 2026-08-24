// Theme: Optional.GAS. WorldStory: UTestTrampolineAttributes Stamina callback trampoline.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForAttributeBindsTrampoline
// Oracle: OnAttributeChanged fires after RegisterCallbackForAttribute then set 50 -> 75.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns register and callback bind.

UCLASS()
class UTestTrampolineAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Stamina;
}

UCLASS()
class UTestTrampolineAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestTrampolineAttributes_NullDefault()
{
	UTestTrampolineAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestTrampolineAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestTrampolineAttributes_TwoHandlesIndependent(UTestTrampolineAttributes First, UTestTrampolineAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
