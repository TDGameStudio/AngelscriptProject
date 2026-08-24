// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: for-header missing semicolons.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NoSemicolon
// sha256=ec1e173f198261790dc29f694ebdb2d27e6d75d6cf7b6889fd3df52bb010739f; lines 170-172.
// Expected diagnostic: "For without semicolons".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	for (int I = 0 I < 10 ++I)
	{
	}
}
