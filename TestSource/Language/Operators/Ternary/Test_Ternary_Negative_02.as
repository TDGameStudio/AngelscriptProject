// Theme: Language.Operators.Ternary. Isolated compile-fail: branch type mismatch.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_TypeMismatch; lines 601-603;
// sha256=213c16aa99ff857e8a9133ffc09fdebbf075d8638bb1669f208b6d1518d08138.
// Expected diagnostic: ternary branch type mismatch (int vs string).
// Do not cast or drop either branch to make this compile.
// DiagnosticOnly.

void Test()
{
	auto X = true ? 1 : "hello";
}
