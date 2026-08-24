// Theme: Language.Operators.Arithmetic. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Arithmetic_Negative
// sha256=2a08aa3a58b040cf26588ad9930f93bf4110cbf3d648c55e19893d59410ba150; lines 160-162.
// Expected compile failure: "Assign to expression result".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int A = 1;
	int B = 2;
	(A + B) = 5;
}
