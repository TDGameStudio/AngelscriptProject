// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=37fb3bb1f74ff72e5ae82993351cc06f74ec1630886346dd63b9b0ff9bc92eac; lines 518-521.
// Expected compile failure: "Assign to function return".
// DiagnosticOnly. Isolated failing program.

int Foo()
{
	return 1;
}

void Test()
{
	Foo() = 5;
}
