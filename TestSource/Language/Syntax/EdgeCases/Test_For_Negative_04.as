// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: for with only two clauses.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_TooFew
// sha256=d5d43ed123396e2c84bbcca89cde6cde56794debfe90d5d57783ccc6d9cce2b5; lines 191-193.
// Expected diagnostic: "For with only two clauses".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	for (int I = 0; I < 10)
	{
	}
}
