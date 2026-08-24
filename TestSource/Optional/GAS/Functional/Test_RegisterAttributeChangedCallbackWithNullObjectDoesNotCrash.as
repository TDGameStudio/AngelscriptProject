// Theme: Optional.GAS. WorldStory: UTestNullObjAttributes Willpower null-object register.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterAttributeChangedCallbackWithNullObjectDoesNotCrash
// Oracle: RegisterAttributeChangedCallback(..., nullptr, "SomeFunc") does not crash.
// Extra: nullptr handle is the empty vector; empty sibling set; empty attribute data.
// Isolation=none. Optional GAS plugin fixture. Runner owns null Object argument.

UCLASS()
class UTestNullObjAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Willpower;
}

UCLASS()
class UTestNullObjAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNullObjAttributes_NullDefault()
{
	UTestNullObjAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNullObjAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestNullObjAttributes_TwoHandlesIndependent(UTestNullObjAttributes First, UTestNullObjAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
