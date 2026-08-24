// Theme: Optional.GAS. WorldStory: UTestGetRegAttributes Mana current value is 42.
// C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterCallbackForAttributeReturnsCurrentValue
// Oracle: GetAndRegisterCallbackForAttribute OutValue == 42.f after TrySet Mana 42.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns register and get-and-register.

UCLASS()
class UTestGetRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;
}

UCLASS()
class UTestGetRegAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestGetRegAttributes_NullDefault()
{
	UTestGetRegAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestGetRegAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestGetRegAttributes_TwoHandlesIndependent(UTestGetRegAttributes First, UTestGetRegAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
