// Theme: Language.Literals.FString. NegativeDiagnostic: FCString::Atof is unsupported.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 5
// sha256 from TS-LANG-0135; lines 688-694.
// Expected compile failure: "Namespace 'FCString' doesn't exist".
// Isolate the failing program. DiagnosticOnly.

float TryFCStringAtof()
{
	FString Value = "3.14";
	return FCString::Atof(Value);
}
