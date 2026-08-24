// Theme: Language.Literals.FString. NegativeDiagnostic: mutable module-level FString.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 1
// sha256 from TS-LANG-0131; lines 619-626.
// Expected compile failure: "Global variable 'GMutable' must be const. Mutable global variables are not supported."
// Isolate the failing program. DiagnosticOnly.

FString GMutable = "Mutable";

FString ReadMutable()
{
	return GMutable;
}
