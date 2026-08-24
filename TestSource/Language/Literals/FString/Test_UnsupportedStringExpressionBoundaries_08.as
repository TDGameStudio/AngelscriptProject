// Theme: Language.Literals.FString. NegativeDiagnostic: FText ordering operator.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 8
// sha256 from TS-LANG-0138; lines 741-748.
// Expected compile failure: "No matching operator".
// Isolate the failing program. DiagnosticOnly.

bool TryTextOrdering()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("B");
	return Left < Right;
}
