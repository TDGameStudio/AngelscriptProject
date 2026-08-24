// Theme: Language.Operators.Overload. Isolated compile-fail: opAdd returns void.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative ASSyntaxOOAddVoid
// lines 310-317;
// sha256=ccc60c65ff957b82613f71bed6f53157dae5a1aaa4addd342fb94f021c8c33b7.
// Expected diagnostic: opAdd returning void should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FVecAddVoid
{
	int X = 0;

	void opAdd(const FVecAddVoid& Other) const
	{
	}
}
