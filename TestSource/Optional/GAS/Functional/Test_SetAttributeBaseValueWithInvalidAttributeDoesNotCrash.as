// Theme: Optional.GAS. C++ compiles UASCInvalidAttrAttributes, registers it, then
// TrySetAttributeBaseValue("NonExistentAttribute") returns false and does not crash.
// CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestFalse is a
// value oracle, not a compile failure.
// Extra: nullptr handle; empty sibling set; FName AttributeName None/invalid.
// Isolation=none. Optional GAS plugin fixture. Runner owns ASC register.

UCLASS()
class UASCInvalidAttrAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Mana;
}

UCLASS()
class UASCInvalidAttrAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UASCInvalidAttrAttributes_NullDefault()
{
	UASCInvalidAttrAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UASCInvalidAttrAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UASCInvalidAttrAttributes_InvalidNameReturnsFalse(UASCInvalidAttrAttributes Set, FName AttributeName)
{
	if (Set == nullptr)
	{
		return false;
	}
	return !Set.TrySetAttributeBaseValue(AttributeName, 50.0f);
}
