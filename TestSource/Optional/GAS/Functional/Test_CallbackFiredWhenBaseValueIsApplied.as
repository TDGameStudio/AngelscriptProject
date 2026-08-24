// Theme: Optional.GAS. WorldStory: UTestUnchangedAttributes Focus same-value setter.
// C++: AngelscriptGASAttributeCallbackTests.cpp::CallbackFiredWhenBaseValueIsApplied
// Oracle: FireCount == 1; OldValue == NewValue after set 60 then 60 again.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns trampoline and same-value set.

UCLASS()
class UTestUnchangedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Focus;
}

UCLASS()
class UTestUnchangedAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestUnchangedAttributes_NullDefault()
{
	UTestUnchangedAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestUnchangedAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestUnchangedAttributes_TwoHandlesIndependent(UTestUnchangedAttributes First, UTestUnchangedAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
