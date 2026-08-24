// Theme: Language.Literals.FString. NegativeDiagnostic: FName ordering operator.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 6
// sha256 from TS-LANG-0136; lines 705-712.
// Expected compile failure: "No matching operator".
// Isolate the failing program. DiagnosticOnly.

bool TryNameOrdering()
{
	FName Left = n"Alpha";
	FName Right = n"Beta";
	return Left < Right;
}
