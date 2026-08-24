// Theme: Language.Preprocessor. Isolated compile-fail: UPROPERTY inside
// #ifndef UNKNOWN_FLAG (not EDITOR / not a config flag).
// C++: AngelscriptPreprocessorFunctionMacroTests.cpp::RejectUnsupportedConditionalPlacement
// AssertPreprocessFailed; lines 74-83;
// sha256=f17472c9a5e7fb427e312509680cf12f905e3d47186a7053b13336f7bcd25e18.
// Expected diagnostic: "Cannot put a UPROPERTY or UFUNCTION inside preprocessor
// conditions other than EDITOR or flags declared in configuration."
// Do not move BadValue outside the #ifndef.
// DiagnosticOnly.

UCLASS()
class UBadPropertyConditionalCarrier : UObject
{
#ifndef UNKNOWN_FLAG
	UPROPERTY()
	int BadValue;
#endif
}
