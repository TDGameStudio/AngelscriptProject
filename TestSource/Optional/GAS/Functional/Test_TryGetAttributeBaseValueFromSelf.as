// Theme: Optional.GAS. WorldStory: UTestGetBaseAttributes Endurance base 66 from self.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::TryGetAttributeBaseValueFromSelf
// Oracle: TryGetAttributeBaseValue Endurance OutValue 66.f after TrySet 66.
// Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.

UCLASS()
class UTestGetBaseAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Endurance;
}

UCLASS()
class UTestGetBaseAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestGetBaseAttributes_NullDefault()
{
	UTestGetBaseAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestGetBaseAttributes_SetAndGetEndurance(UTestGetBaseAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	if (!Set.TrySetAttributeBaseValue(n"Endurance", 66.0f))
	{
		return false;
	}
	float OutValue = 0.0f;
	if (!Set.TryGetAttributeBaseValue(n"Endurance", OutValue))
	{
		return false;
	}
	return OutValue == 66.0f;
}

bool Observe_UTestGetBaseAttributes_EmptyNameReturnsFalse(UTestGetBaseAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	float OutValue = 0.0f;
	return !Set.TryGetAttributeBaseValue(AttributeName, OutValue);
}
