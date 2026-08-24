// Theme: Optional.GAS. WorldStory: UTestUtilAttributes Strength and Agility lookup.
// C++: AngelscriptGASAttributeSetUtilityTests.cpp::GetGameplayAttributeFromScriptSubclass
// Oracle: GetGameplayAttribute Strength and Agility both IsValid().
// Extra: nullptr handle; FName AttributeName None is invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.

UCLASS()
class UTestUtilAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Strength;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Agility;
}

UCLASS()
class UTestUtilAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestUtilAttributes_NullDefault()
{
	UTestUtilAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestUtilAttributes_NamedIsValid(FName AttributeName)
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, AttributeName, OutAttr);
	if (AttributeName.IsNone())
	{
		return !bFound && !OutAttr.IsValid();
	}
	return bFound && OutAttr.IsValid();
}

bool Observe_UTestUtilAttributes_StrengthAndAgility()
{
	FGameplayAttribute StrengthAttr;
	FGameplayAttribute AgilityAttr;
	if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, n"Strength", StrengthAttr))
	{
		return false;
	}
	if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestUtilAttributes, n"Agility", AgilityAttr))
	{
		return false;
	}
	return StrengthAttr.IsValid() && AgilityAttr.IsValid();
}
