// Theme: Optional.GAS. WorldStory: UTestSelfGetAttributes Intelligence current 55 from self.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::AttributeSetTryGetCurrentValueFromSelf
// Oracle: TryGetAttributeCurrentValue Intelligence OutValue 55.f after TrySet 55.
// Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.

UCLASS()
class UTestSelfGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Intelligence;
}

UCLASS()
class UTestSelfGetAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestSelfGetAttributes_NullDefault()
{
	UTestSelfGetAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestSelfGetAttributes_SetAndGetIntelligence(UTestSelfGetAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	if (!Set.TrySetAttributeBaseValue(n"Intelligence", 55.0f))
	{
		return false;
	}
	float OutValue = 0.0f;
	if (!Set.TryGetAttributeCurrentValue(n"Intelligence", OutValue))
	{
		return false;
	}
	return OutValue == 55.0f;
}

bool Observe_UTestSelfGetAttributes_EmptyNameReturnsFalse(UTestSelfGetAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	float OutValue = 0.0f;
	return !Set.TryGetAttributeCurrentValue(AttributeName, OutValue);
}
