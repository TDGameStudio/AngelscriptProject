// Theme: Optional.GAS. WorldStory: UTestZeroPosAttributes Energy 0 then 100.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::AttributeChangeFromZeroToPositive
// Oracle: initial current 0.f; after TrySet 100 current 100.f.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns register then TrySet.

UCLASS()
class UTestZeroPosAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Energy;
}

UCLASS()
class UTestZeroPosAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestZeroPosAttributes_NullDefault()
{
	UTestZeroPosAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestZeroPosAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestZeroPosAttributes_TwoHandlesIndependent(UTestZeroPosAttributes First, UTestZeroPosAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
