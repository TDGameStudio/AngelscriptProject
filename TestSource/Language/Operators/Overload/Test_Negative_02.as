// Theme: Language.Operators.Overload. Isolated compile-fail: opEquals non-bool.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative
// ASSyntaxOOEqualsWrongReturn; lines 243-250;
// sha256=288cbce18325cff21e40de475e21b0996b59a7c072bf9ecf8cdd61978f4b44d7.
// Expected diagnostic: opEquals with non-bool return should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FVecEqWrongRet
{
	int X = 0;

	int opEquals(const FVecEqWrongRet& Other) const
	{
		return 0;
	}
}
