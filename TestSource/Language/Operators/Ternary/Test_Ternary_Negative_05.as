// Theme: Language.Operators.Ternary. Isolated compile-fail: float condition.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Negative AssertFailsToCompile
// TernN_FloatCond; lines 622-624;
// sha256=b9640d4f2b52feb6fc94892395fa86bd0cdbf7ff64be1a0eb701db98374f35e9.
// Expected diagnostic: float as ternary condition.
// Do not compare the float to make this compile.
// DiagnosticOnly.

void Test()
{
	int X = 1.0f ? 1 : 0;
}
