// Theme: Optional.GAS. WorldStory: UTestDefaultBPAttributes Strength without BP_ overrides.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::DefaultBPEventsDoNotAlterBehavior
// Oracle: GetAttributeCurrentValue Strength == 50.f after TrySet 50.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns TrySetAttributeBaseValue.

UCLASS()
class UTestDefaultBPAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;
}

UCLASS()
class UTestDefaultBPAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestDefaultBPAttributes_NullDefault()
{
	UTestDefaultBPAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestDefaultBPAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestDefaultBPAttributes_TwoHandlesIndependent(UTestDefaultBPAttributes First, UTestDefaultBPAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
