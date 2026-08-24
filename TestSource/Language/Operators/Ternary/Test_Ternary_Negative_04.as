// Theme: Language.Operators.Ternary. Isolated compile-fail: missing true branch.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_NoTrue; lines 615-617;
// sha256=1101146b037362d36e678fea9ddc885f3021eaed1a1ed20996e3997877d0dfca.
// Expected diagnostic: ternary without true branch.
// Do not insert a true-branch expression that would make this compile.
// DiagnosticOnly.

void Test()
{
	int X = true ? : 0;
}
