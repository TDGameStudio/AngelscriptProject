// Theme: Language.Preprocessor. Isolated compile-fail: UFUNCTION inside
// #ifndef UNKNOWN_FLAG (not EDITOR / not a config flag).
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::RejectUnsupportedConditionalPlacement
// AssertPreprocessFailed; lines 56-68;
// sha256=7d0882728538baa6c56ef9e162ba42de3f46af72c2b0c1d6ad245bef5cb09da1.
// Expected diagnostic: "Cannot put a UPROPERTY or UFUNCTION inside preprocessor
// conditions other than EDITOR or flags declared in configuration."
// Do not move BadFunction outside the #ifndef.
// DiagnosticOnly.

UCLASS()
class UBadFunctionConditionalCarrier : UObject
{
#ifndef UNKNOWN_FLAG
	UFUNCTION()
	int BadFunction()
	{
		return 1;
	}
#endif
}
