// Theme: Optional.GAS. WorldStory: UTestMultiCallbackAttributes Health and Shield.
// C++: AngelscriptGASAttributeCallbackTests.cpp::MultipleAttributesEachGetOwnCallback
// Oracle: two callbacks; names Health then Shield after 100/50 -> 80/30.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns two callback binds.

UCLASS()
class UTestMultiCallbackAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Shield;
}

UCLASS()
class UTestMultiCallbackAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestMultiCallbackAttributes_NullDefault()
{
	UTestMultiCallbackAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestMultiCallbackAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestMultiCallbackAttributes_TwoHandlesIndependent(UTestMultiCallbackAttributes First, UTestMultiCallbackAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
