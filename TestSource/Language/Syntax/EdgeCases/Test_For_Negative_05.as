// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: loop variable after the for-scope.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_VarAfterLoop
// sha256=4f728ff3ee60900e47b754b12130e4cc201995a0e2afd879c3b40727615f01f8; lines 198-200.
// Expected diagnostic: "Access loop var after loop".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
