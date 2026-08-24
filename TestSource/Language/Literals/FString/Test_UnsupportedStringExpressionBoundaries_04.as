// Theme: Language.Literals.FString. NegativeDiagnostic: FCString::Atoi is unsupported.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 4
// sha256 from TS-LANG-0134; lines 671-677.
// Expected compile failure: "Namespace 'FCString' doesn't exist".
// Isolate the failing program. DiagnosticOnly.

int TryFCStringAtoi()
{
	FString Value = "42";
	return FCString::Atoi(Value);
}
