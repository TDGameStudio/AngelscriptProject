// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=5aae85ebeacb4c1da4700bf3c39ada5eeea1beea69f2532161efa1f16701f20e; lines 263-265.
// Expected compile failure: "Bitwise XOR on bool".
// C++ currently #if 0 this case (#as-engine-behavior: bool bitwise is allowed).
// DiagnosticOnly. Isolated failing program.

void Test()
{
	bool A = true;
	bool B = false;
	int X = A ^ B;
}
