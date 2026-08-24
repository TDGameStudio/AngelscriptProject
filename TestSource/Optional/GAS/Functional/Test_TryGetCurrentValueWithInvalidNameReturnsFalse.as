// Theme: Optional.GAS. C++ compiles UTestInvalidGetAttributes then TryGet "NonExistent"
// returns false. CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestFalse
// is a value oracle, not a compile failure.
// C++: AngelscriptGASAttributeSetOverrideTests.cpp::TryGetCurrentValueWithInvalidNameReturnsFalse
// Extra: nullptr handle; FName AttributeName None/invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Runner owns registered set instance.

UCLASS()
class UTestInvalidGetAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Valid;
}

UCLASS()
class UTestInvalidGetAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestInvalidGetAttributes_NullDefault()
{
	UTestInvalidGetAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestInvalidGetAttributes_NonExistentReturnsFalse(UTestInvalidGetAttributes Set)
{
	if (Set == nullptr)
	{
		return false;
	}
	float OutValue = 0.0f;
	return !Set.TryGetAttributeCurrentValue(n"NonExistent", OutValue);
}

bool Observe_UTestInvalidGetAttributes_EmptyNameReturnsFalse(UTestInvalidGetAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	float OutValue = 0.0f;
	return !Set.TryGetAttributeCurrentValue(AttributeName, OutValue);
}
