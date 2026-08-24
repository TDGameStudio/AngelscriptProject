// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=3db5b63caf0e99c536af231745c9cf1921aa6cb54a840541a275c5240ce42860; lines 152-154.
// Expected compile failure: "Double operator in expression".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 1 ++ 2;
}
