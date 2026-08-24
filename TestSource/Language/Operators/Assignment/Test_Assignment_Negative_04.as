// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=396d900cae29aecba4a637d3db4b1bd4a8331dde103f4368f3e856b24798eadd; lines 511-513.
// Expected compile failure: "Add-assign string to int".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 0;
	X += "hello";
}
