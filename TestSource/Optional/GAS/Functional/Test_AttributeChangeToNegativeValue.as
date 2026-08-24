// Theme: Optional.GAS. C++ compiles UTestNegativeAttributes then sets Temperature -10.
// CSV NegativeDiagnostic is a heuristic; CompileScriptModule + TestEqual(-10) is a
// value oracle, not a compile failure.
// C++: AngelscriptGASAttributeSetBPEventTests.cpp::AttributeChangeToNegativeValue
// Oracle: GetAttributeCurrentValue Temperature == -10.f.
// Extra: nullptr handle; empty sibling set; empty FAngelscriptGameplayAttributeData.
// Isolation=none. Optional GAS plugin fixture. Runner owns TrySet negative value.

UCLASS()
class UTestNegativeAttributes : UAngelscriptAttributeSet
{
	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	FAngelscriptGameplayAttributeData Temperature;
}

UCLASS()
class UTestNegativeAttributesEmpty : UAngelscriptAttributeSet
{
}

bool Observe_UTestNegativeAttributes_NullDefault()
{
	UTestNegativeAttributes Set = nullptr;
	return Set == nullptr;
}

bool Observe_UTestNegativeAttributes_EmptyAttributeData()
{
	FAngelscriptGameplayAttributeData EmptyData;
	return EmptyData.AttributeName.IsNone();
}

bool Observe_UTestNegativeAttributes_TwoHandlesIndependent(UTestNegativeAttributes First, UTestNegativeAttributes Second)
{
	return First != nullptr && Second != nullptr && First != Second;
}
