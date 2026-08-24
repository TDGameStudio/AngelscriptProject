// Theme: Language.Operators.Logical. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Logical_Negative
// sha256=345606aba8265f0434788a1c64dee62af4162f1fba2385e49f8e2b66c4f79437; lines 352-354.
// Expected compile failure: "Logical AND on floats".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool X = 1.0f && 2.0f;
}
