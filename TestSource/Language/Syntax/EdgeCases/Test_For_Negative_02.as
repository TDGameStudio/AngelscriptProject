// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: non-bool for condition.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NonBoolCond
// sha256=e33bc0ecce0ef65afc67fba7331f9ce5594de336fcf9cab4cb77516379805a3c; lines 177-179.
// Expected diagnostic: "Non-bool condition".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	for (int I = 0; I; ++I)
	{
	}
}
