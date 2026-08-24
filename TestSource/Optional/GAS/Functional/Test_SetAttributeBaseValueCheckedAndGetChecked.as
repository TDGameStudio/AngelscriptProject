// Theme: Optional.GAS. WorldStory: UTestCheckedAttributes Focus checked set/get 99.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::SetAttributeBaseValueCheckedAndGetChecked
// Oracle: GetAttributeBaseValueChecked Focus 99.f; GetAttributeCurrentValueChecked 99.f.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns ASC SetAttributeBaseValue.

UCLASS()
class UTestCheckedAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Focus;
}

UCLASS()
class UTestCheckedAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestCheckedAttributes_NullDefault()
{
	UTestCheckedAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestCheckedAttributes_SetAndGetFocus(UTestCheckedAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	if (!Set.TrySetAttributeBaseValue(n"Focus", 99.0f))
	{
		return false;
	}
	float OutValue = 0.0f;
	if (!Set.TryGetAttributeBaseValue(n"Focus", OutValue))
	{
		return false;
	}
	if (OutValue != 99.0f)
	{
		return false;
	}
	float OutCurrent = 0.0f;
	if (!Set.TryGetAttributeCurrentValue(n"Focus", OutCurrent))
	{
		return false;
	}
	return OutCurrent == 99.0f;
}

bool Observe_UTestCheckedAttributes_EmptyNameReturnsFalse(UTestCheckedAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(AttributeName, 0.0f);
}
