// Theme: Optional.GAS. WorldStory: UTestTryGetAttributes TryGetGameplayAttribute Mana.
// C++: AngelscriptGASAttributeSetUtilityTests.cpp::TryGetGameplayAttributeSuccess
// Oracle: TryGetGameplayAttribute Mana returns true and OutAttr.IsValid().
// Extra: nullptr handle; FName AttributeName None is invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.

UCLASS()
class UTestTryGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;
}

UCLASS()
class UTestTryGetAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestTryGetAttributes_NullDefault()
{
	UTestTryGetAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestTryGetAttributes_ManaIsValid()
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetAttributes, n"Mana", OutAttr);
	return bFound && OutAttr.IsValid();
}

bool Observe_UTestTryGetAttributes_Named(FName AttributeName)
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetAttributes, AttributeName, OutAttr);
	if (AttributeName.IsNone())
	{
		return !bFound && !OutAttr.IsValid();
	}
	return bFound && OutAttr.IsValid();
}
