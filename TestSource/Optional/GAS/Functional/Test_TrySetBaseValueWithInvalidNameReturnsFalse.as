// Theme: Optional.GAS. C++ compiles UTestInvalidSetAttributes then TrySet "NonExistent"
// returns false. CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestFalse
// is a value oracle, not a compile failure.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::TrySetBaseValueWithInvalidNameReturnsFalse
// Extra: nullptr handle; FName AttributeName None/invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.

UCLASS()
class UTestInvalidSetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Valid;
}

UCLASS()
class UTestInvalidSetAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestInvalidSetAttributes_NullDefault()
{
	UTestInvalidSetAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestInvalidSetAttributes_NonExistentReturnsFalse(UTestInvalidSetAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(n"NonExistent", 10.0f);
}

bool Observe_UTestInvalidSetAttributes_EmptyNameReturnsFalse(UTestInvalidSetAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(AttributeName, 10.0f);
}
