// Theme: Language.Syntax.EdgeCases. Isolated compile-fail: missing semicolon.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Negative block 4 AssertFailsToCompile.
// sha256=a5f857d294cad8efbb4ff024788d4a0a218e9d21a9e9926d0fae7d31a3028bb4; lines 298-300.
// Expected diagnostic: missing semicolon between int X = 1 and int Y = 2.
// DiagnosticOnly. Do not insert the omitted semicolon.

void Test()
{
	int X = 1 int Y = 2;
}
