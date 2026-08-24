// Theme: Optional.GAS. WorldStory: UTestSelfSetAttributes TrySet/Get Dexterity 77 from self.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::AttributeSetTrySetBaseValueFromSelf
// Oracle: TrySetAttributeBaseValue Dexterity 77 true; TryGetAttributeBaseValue OutValue 77.f.
// Extra: nullptr handle; NAME_None AttributeName returns false; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.

UCLASS()
class UTestSelfSetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Dexterity;
}

UCLASS()
class UTestSelfSetAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestSelfSetAttributes_NullDefault()
{
	UTestSelfSetAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestSelfSetAttributes_SetAndGetDexterity(UTestSelfSetAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	if (!Set.TrySetAttributeBaseValue(n"Dexterity", 77.0f))
	{
		return false;
	}
	float OutValue = 0.0f;
	if (!Set.TryGetAttributeBaseValue(n"Dexterity", OutValue))
	{
		return false;
	}
	return OutValue == 77.0f;
}

bool Observe_UTestSelfSetAttributes_EmptyNameReturnsFalse(UTestSelfSetAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(AttributeName, 0.0f);
}
