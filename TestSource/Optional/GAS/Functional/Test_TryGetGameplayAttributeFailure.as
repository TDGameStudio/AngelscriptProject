// Theme: Optional.GAS. C++ compiles UTestTryGetFailAttributes then TryGet
// "NonExistentAttribute" returns false. CSV NegativeDiagnostic is a heuristic;
// CompileScriptModule + TestFalse is a value oracle, not a compile failure.
// C++: AngelscriptGASAttributeSetUtilityTests.cpp::TryGetGameplayAttributeFailure
// Extra: nullptr handle; FName AttributeName None/invalid; empty sibling set.
// Isolation=none. Optional GAS plugin fixture. Static lookup; runner supplies names.

UCLASS()
class UTestTryGetFailAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Health;
}

UCLASS()
class UTestTryGetFailAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestTryGetFailAttributes_NullDefault()
{
	UTestTryGetFailAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestTryGetFailAttributes_NonExistentReturnsFalse()
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetFailAttributes, n"NonExistentAttribute", OutAttr);
	return !bFound && !OutAttr.IsValid();
}

bool Observe_UTestTryGetFailAttributes_EmptyName(FName AttributeName)
{
	FGameplayAttribute OutAttr;
	bool bFound = UAngelscriptAttributeSet::TryGetGameplayAttribute(UTestTryGetFailAttributes, AttributeName, OutAttr);
	return !bFound && !OutAttr.IsValid();
}
