// Theme: Optional.GAS. WorldStory: UTestPreChangeAttributes Health PreAttributeChange pipeline.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::PreAttributeChangeIsCalled
// Oracle: TryGetAttributeBaseValue Health == 100.f after TrySet 100.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns TrySet then TryGet base.

UCLASS()
class UTestPreChangeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;
}

UCLASS()
class UTestPreChangeAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestPreChangeAttributes_NullDefault()
{
	UTestPreChangeAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestPreChangeAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestPreChangeAttributes_TwoHandlesIndependent(UTestPreChangeAttributes First, UTestPreChangeAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
