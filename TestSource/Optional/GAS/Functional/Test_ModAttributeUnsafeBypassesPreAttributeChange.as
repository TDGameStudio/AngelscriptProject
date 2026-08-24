// Theme: Optional.GAS. WorldStory: UTestModUnsafeBPAttributes Rage ModAttributeUnsafe override.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::ModAttributeUnsafeBypassesPreAttributeChange
// Oracle: Rage GetGameplayAttribute is valid; current 200.f after override from 50.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ModAttributeUnsafe.

UCLASS()
class UTestModUnsafeBPAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Rage;
}

UCLASS()
class UTestModUnsafeBPAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestModUnsafeBPAttributes_NullDefault()
{
	UTestModUnsafeBPAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestModUnsafeBPAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestModUnsafeBPAttributes_RageAttributeValid(FName AttributeName)
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestModUnsafeBPAttributes, AttributeName, OutAttr);
	if (AttributeName.IsNone())
	{
		return !bFound && !OutAttr.IsValid();
	}
	return bFound && OutAttr.IsValid();
}
