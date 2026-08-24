// Theme: Language.Preprocessor. CSV SourceShape is NegativeDiagnostic, but the
// C++ method AssertPreprocessSucceeded for #if EDITOR members with editor scripts.
// Follow the C++ method: value/lifecycle oracle.
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::RejectUnsupportedConditionalPlacement
// EditorConditionalMembers.as; lines 114-129;
// sha256=460d4aa4ca311766d517a42d5aae3c40e598e0f2b065df653089b1fbc7c4928a.
// Oracle: ReadEditorValue() == 7; EditorValue default 0; both have EditorOnly meta.
// Extra: default EditorValue is 0; assigned EditorValue is independent of the function.
// DefaultSafe under EDITOR. Keep EditorValue / ReadEditorValue.

UCLASS()
class UEditorConditionalCarrier : UObject
{
#if EDITOR
	UPROPERTY()
	int EditorValue;

	UFUNCTION()
	int ReadEditorValue()
	{
		return 7;
	}
#endif
}

bool Observe_ReadEditorValue_Nominal(UEditorConditionalCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_RejectUnsupportedConditionalPlacement_03 setup: required Carrier is null");
	}
	return Carrier.ReadEditorValue() == 7;
}

bool Observe_EditorValue_DefaultZero(UEditorConditionalCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_RejectUnsupportedConditionalPlacement_03 setup: required Carrier is null");
	}
	return Carrier.EditorValue == 0;
}

bool Observe_EditorValue_AssignedIndependent(UEditorConditionalCarrier Carrier)
{
	if (Carrier is null)
	{
		throw("Test_RejectUnsupportedConditionalPlacement_03 setup: required Carrier is null");
	}
	Carrier.EditorValue = 4;
	return Carrier.ReadEditorValue() == 7 && Carrier.EditorValue == 4;
}
