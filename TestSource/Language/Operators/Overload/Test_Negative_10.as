// Theme: Language.Operators.Overload. Isolated compile-fail: opNeg with param.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative
// ASSyntaxOONegWithParam; lines 350-357;
// sha256=39e871dfeb3d8e8c8fc49788cca968008d657a2c2f36b8707c12710e4f3fe191.
// Expected diagnostic: opNeg with parameter should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FVecNegParam
{
	int X = 0;

	FVecNegParam opNeg(int Dummy) const
	{
		return FVecNegParam();
	}
}
