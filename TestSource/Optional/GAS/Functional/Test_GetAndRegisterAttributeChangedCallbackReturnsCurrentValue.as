// Theme: Optional.GAS. WorldStory: UTestGetRegChangedAttributes Spirit current 88 then 99.
// C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterAttributeChangedCallbackReturnsCurrentValue
// Oracle: OutValue == 88.f; later set 99 fires the provided UFunction.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns get-and-register UFunction bind.

UCLASS()
class UTestGetRegChangedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Spirit;
}

UCLASS()
class UTestGetRegChangedAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestGetRegChangedAttributes_NullDefault()
{
	UTestGetRegChangedAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestGetRegChangedAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestGetRegChangedAttributes_TwoHandlesIndependent(UTestGetRegChangedAttributes First, UTestGetRegChangedAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
