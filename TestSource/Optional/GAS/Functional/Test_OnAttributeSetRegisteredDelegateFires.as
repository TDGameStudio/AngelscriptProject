// Theme: Optional.GAS. WorldStory: UTestDelegateRegAttributes registers on an ASC.
// C++: AngelscriptGASASCDelegateTests.cpp::OnAttributeSetRegisteredDelegateFires
// Oracle: OnAttributeSetRegistered fires; CapturedAttributeSet == RegisteredSet.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ASC register.

UCLASS()
class UTestDelegateRegAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Vigor;
}

UCLASS()
class UTestDelegateRegAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestDelegateRegAttributes_NullDefault()
{
	UTestDelegateRegAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestDelegateRegAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestDelegateRegAttributes_TwoHandlesIndependent(UTestDelegateRegAttributes First, UTestDelegateRegAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
