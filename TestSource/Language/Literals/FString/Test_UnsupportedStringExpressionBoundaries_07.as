// Theme: Language.Literals.FString. NegativeDiagnostic: FText equality operator.
// C++: AngelscriptCoverageFStringExpressionTests.cpp::UnsupportedStringExpressionBoundaries block 7
// sha256 from TS-LANG-0137; lines 723-730.
// Expected compile failure: "No matching operator".
// Isolate the failing program. DiagnosticOnly.

bool TryTextEqualsOperator()
{
	FText Left = FText::FromString("A");
	FText Right = FText::FromString("A");
	return Left == Right;
}
