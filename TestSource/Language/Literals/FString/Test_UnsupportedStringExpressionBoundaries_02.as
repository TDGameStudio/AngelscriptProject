// Theme: Language.Literals.FString. NegativeDiagnostic: FString.ToInt is unsupported.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 2
// sha256 from TS-LANG-0132; lines 637-643.
// Expected compile failure: "ToInt".
// Isolate the failing program. DiagnosticOnly.

int TryStringToIntMethod()
{
	FString Value = "42";
	return Value.ToInt();
}
