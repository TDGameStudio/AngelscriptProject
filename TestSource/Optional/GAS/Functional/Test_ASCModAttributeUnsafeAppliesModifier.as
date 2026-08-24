// Theme: Optional.GAS. WorldStory: UTestModUnsafeAttributes Rage additive ModAttributeUnsafe.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::ASCModAttributeUnsafeAppliesModifier
// Oracle: Rage attribute valid; current 15.f after base 10 plus additive 5.
// Extra: nullptr handle; FName AttributeName None is invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns ModAttributeUnsafe Additive.

UCLASS()
class UTestModUnsafeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Rage;
}

UCLASS()
class UTestModUnsafeAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestModUnsafeAttributes_NullDefault()
{
	UTestModUnsafeAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestModUnsafeAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestModUnsafeAttributes_RageAttributeValid(FName AttributeName)
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestModUnsafeAttributes, AttributeName, OutAttr);
	if (AttributeName.IsNone())
	{
		return !bFound && !OutAttr.IsValid();
	}
	return bFound && OutAttr.IsValid();
}
