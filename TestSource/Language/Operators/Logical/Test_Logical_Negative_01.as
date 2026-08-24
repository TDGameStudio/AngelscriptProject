// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=5b1733630273ecc361725d863283d485013d8b06f8e21e4d762432ff21653f6c; lines 317-319.
// Expected compile failure: "Logical AND on integers".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 1 && 2;
}
