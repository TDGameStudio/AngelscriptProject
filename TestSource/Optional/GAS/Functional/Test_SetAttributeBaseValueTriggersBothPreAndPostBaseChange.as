// Theme: Optional.GAS. WorldStory: UTestBothBaseAttributes Wisdom Pre/Post base change.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::SetAttributeBaseValueTriggersBothPreAndPostBaseChange
// Oracle: BaseValue 42.f and CurrentValue 42.f after SetAttributeBaseValue Wisdom 42.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns SetAttributeBaseValue.

UCLASS()
class UTestBothBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Wisdom;
}

UCLASS()
class UTestBothBaseAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestBothBaseAttributes_NullDefault()
{
	UTestBothBaseAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestBothBaseAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestBothBaseAttributes_TwoHandlesIndependent(UTestBothBaseAttributes First, UTestBothBaseAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
