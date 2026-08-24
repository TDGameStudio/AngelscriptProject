// Theme: Language.Operators.Assignment. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Assignment_Negative
// sha256=bd1ea25508b13031efc6cf5d33b3dbe394d9a49197fd89498bd3b01662202049; lines 526-528.
// Expected compile failure: "Assign to undeclared variable".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	UndeclaredVar = 5;
}
