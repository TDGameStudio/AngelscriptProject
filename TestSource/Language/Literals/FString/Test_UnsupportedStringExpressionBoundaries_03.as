// Theme: Language.Literals.FString. NegativeDiagnostic: FString.ToFloat is unsupported.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 3
// sha256 from TS-LANG-0133; lines 655-661.
// Expected compile failure: "ToFloat".
// Isolate the failing program. DiagnosticOnly.

float TryStringToFloatMethod()
{
	FString Value = "3.14";
	return Value.ToFloat();
}
