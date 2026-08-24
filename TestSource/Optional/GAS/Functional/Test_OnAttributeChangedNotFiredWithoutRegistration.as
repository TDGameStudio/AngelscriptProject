// Theme: Optional.GAS. WorldStory: UTestNoRegAttributes Luck without trampoline.
// C++: AngelscriptGASAttributeCallbackTests.cpp::OnAttributeChangedNotFiredWithoutRegistration
// Oracle: FireCount == 0 when Luck is set 5 -> 10 without RegisterCallbackForAttribute.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns unbound OnAttributeChanged.

UCLASS()
class UTestNoRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Luck;
}

UCLASS()
class UTestNoRegAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoRegAttributes_NullDefault()
{
	UTestNoRegAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoRegAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestNoRegAttributes_TwoHandlesIndependent(UTestNoRegAttributes First, UTestNoRegAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
