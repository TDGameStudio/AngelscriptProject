// Theme: Optional.GAS. WorldStory: UTestNoASCAttributes TrySet fails without owning ASC.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::TrySetBaseValueFailsWithoutASC
// Oracle: NewObject set TrySetAttributeBaseValue Fortitude 10 returns false.
// Extra: nullptr handle; NAME_None AttributeName also false; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns unowned NewObject set.

UCLASS()
class UTestNoASCAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Fortitude;
}

UCLASS()
class UTestNoASCAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNoASCAttributes_NullDefault()
{
	UTestNoASCAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNoASCAttributes_UnownedSetFails(UTestNoASCAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(n"Fortitude", 10.0f);
}

bool Observe_UTestNoASCAttributes_EmptyNameReturnsFalse(UTestNoASCAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(AttributeName, 0.0f);
}
