// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=0a5fe6846d56036ca14cace52ae6789aec2af74f5cec5114ca3e88e9e087d2f7; lines 533-535.
// Expected compile failure: "Assign to expression".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 0;
	int Y = 0;
	(X + Y) = 5;
}
