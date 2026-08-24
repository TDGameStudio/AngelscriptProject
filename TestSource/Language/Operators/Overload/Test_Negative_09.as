// Theme: Language.Operators.Overload. Isolated compile-fail: opIndex returns void.
// C++: AngelscriptSyntaxOperatorOverloadTests.cpp::Negative
// ASSyntaxOOIndexBadReturn; lines 336-343;
// sha256=9b58ce1729c5ed6060a3d244bb27644c7f32d600a32ae7ec16dfadb618f33585.
// Expected diagnostic: opIndex returning void should fail.
// C++ currently #if 0 this case (#as-engine-behavior: structural-validation-absent).
// DiagnosticOnly. Isolated failing program.

struct FContainerBadRet
{
	TArray<int> Data;

	void opIndex(int Index) const
	{
	}
}
