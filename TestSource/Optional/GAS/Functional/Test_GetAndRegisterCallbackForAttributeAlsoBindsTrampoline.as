// Theme: Optional.GAS. WorldStory: UTestGetRegBindAttributes Agility get-and-register trampoline.
// C++: AngelscriptGASAttributeCallbackTests.cpp::GetAndRegisterCallbackForAttributeAlsoBindsTrampoline
// Oracle: OnAttributeChanged fires after get-and-register then set 10 -> 20.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns get-and-register then set.

UCLASS()
class UTestGetRegBindAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;
}

UCLASS()
class UTestGetRegBindAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestGetRegBindAttributes_NullDefault()
{
	UTestGetRegBindAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestGetRegBindAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestGetRegBindAttributes_TwoHandlesIndependent(UTestGetRegBindAttributes First, UTestGetRegBindAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
