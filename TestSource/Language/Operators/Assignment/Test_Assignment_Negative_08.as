// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=74a0aaa31ac31a604361725725a7875758d563cbca3937a648ede4bc48a9d31e; lines 540-542.
// Expected compile failure: "Shift-assign on float".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 1.0f;
	X <<= 2;
}
