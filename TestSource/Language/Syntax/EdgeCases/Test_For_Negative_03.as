// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: for without parentheses.
// C++: AngelscriptSyntaxControlFlowTests.cpp::For_Negative ForN_NoParen
// sha256=093c2bc494cafeff1cd0201c32926d5ef9feea5c9a57c012f42161de0e466c57; lines 184-186.
// Expected diagnostic: "For without parentheses".
// Isolate this failing program; do not add declarations that would compile it away.
// DiagnosticOnly.

void Test()
{
	for int I = 0; I < 10; ++I
	{
	}
}
