// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=3e7f73cab08462b57539981bd227e20ef3d0d76f07187ba8b5245a33be827b0b; lines 226-228.
// Expected compile failure: "Bitwise AND on float".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	float X = 1.0f & 2.0f;
}
