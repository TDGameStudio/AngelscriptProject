// Theme: Optional.GAS. WorldStory: UTestValidParamsAttributes Charisma valid params.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterAttributeChangedCallbackWithValidParamsDoesNotCrash
// Oracle: RegisterAttributeChangedCallback with NonExistentFunc does not crash.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns missing-function name.

UCLASS()
class UTestValidParamsAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Charisma;
}

UCLASS()
class UTestValidParamsAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestValidParamsAttributes_NullDefault()
{
	UTestValidParamsAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestValidParamsAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestValidParamsAttributes_TwoHandlesIndependent(UTestValidParamsAttributes First, UTestValidParamsAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
