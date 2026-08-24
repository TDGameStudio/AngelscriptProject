// Theme: Language.Operators.Bitwise. Isolated compile-fail.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Bitwise_Negative
// sha256=27b6f684baf2d29637c2142cd223017717be507bc2fb4c581d615e2e947cfdb1; lines 254-256.
// Expected compile failure: "Missing operand in bitwise AND".
// DiagnosticOnly. Isolated failing program.

void Test()
{
	int X = 0xFF & ;
}
