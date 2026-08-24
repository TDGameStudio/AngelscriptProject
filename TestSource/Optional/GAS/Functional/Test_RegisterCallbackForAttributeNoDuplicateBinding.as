// Theme: Optional.GAS. WorldStory: UTestNoDupAttributes Armor duplicate register.
// C++: AngelscriptGASAttributeCallbackTests.cpp::RegisterCallbackForAttributeNoDuplicateBinding
// Oracle: duplicate RegisterCallbackForAttribute still FireCount == 1.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns double register then set 10 -> 25.

UCLASS()
class UTestNoDupAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;
}

UCLASS()
class UTestNoDupAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoDupAttributes_NullDefault()
{
	UTestNoDupAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoDupAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestNoDupAttributes_TwoHandlesIndependent(UTestNoDupAttributes First, UTestNoDupAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
