// Theme: Optional.GAS. WorldStory: UTestCompareAttributes Speed vs Armor compare.
// C++: AngelscriptGASAttributeSetUtilityTests.cpp::CompareGameplayAttributesEqual
// Oracle: CompareGameplayAttributes(Speed, Speed) true; (Speed, Armor) false.
// Extra: two default FGameplayAttribute compare; FName AttributeName None is invalid.
// Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.

UCLASS()
class UTestCompareAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Speed;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Armor;
}

UCLASS()
class UTestCompareAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestCompareAttributes_NullDefault()
{
	UTestCompareAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestCompareAttributes_SameAndDifferent()
{
	FGameplayAttribute SpeedA;
	FGameplayAttribute SpeedB;
	FGameplayAttribute ArmorAttr;
	if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Speed", SpeedA))
	{
		return false;
	}
	if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Speed", SpeedB))
	{
		return false;
	}
	if (!UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestCompareAttributes, n"Armor", ArmorAttr))
	{
		return false;
	}
	if (!UAngelscriptAttributeSet::CompareGameplayAttributes(SpeedA, SpeedB))
	{
		return false;
	}
	return !UAngelscriptAttributeSet::CompareGameplayAttributes(SpeedA, ArmorAttr);
}

bool Observe_UTestCompareAttributes_EmptyDefaults()
{
	FGameplayAttribute First;
	FGameplayAttribute Second;
	return !First.IsValid() && !Second.IsValid()
		&& UAngelscriptAttributeSet::CompareGameplayAttributes(First, Second);
}
