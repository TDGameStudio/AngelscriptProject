// Theme: Optional.GAS. WorldStory: UTestNoneNameAttributes Resolve NAME_None function.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterAttributeChangedCallbackWithNoneNameDoesNotCrash
// Oracle: RegisterAttributeChangedCallback(..., NAME_None) does not crash.
// Extra: nullptr handle; empty sibling set; empty FName / empty attribute data.
// Isolation=none. Optional GAS plugin fixture. Runner owns NAME_None function argument.

UCLASS()
class UTestNoneNameAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Resolve;
}

UCLASS()
class UTestNoneNameAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoneNameAttributes_NullDefault()
{
	UTestNoneNameAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoneNameAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestNoneNameAttributes_NoneFunctionName()
{
	FName FunctionName = NAME_None;
	return FunctionName.IsNone();
}
