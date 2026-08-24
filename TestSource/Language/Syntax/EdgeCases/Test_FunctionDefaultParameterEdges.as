// Theme: Language.Syntax.EdgeCases. C++ compiles and executes default-parameter edges.
// CSV SourceShape NegativeDiagnostic is wrong; follow FunctionDefaultParameterEdges oracles.
// C++: AngelscriptCoverageIntFunctionTests.cpp::FunctionDefaultParameterEdges
// sha256=80a21dd603da09ee085888d7d58e036908d68a3386d4356b9d2c7dba871a46fe; lines 957-992.
// Oracle: MultipleDefaultsUsingBoth(12)==42; MultipleDefaultsUsingFinal(12, 10)==42;
// NegativeDefaultUsingDefault()==-7; BoundaryDefaultUsingDefault()==2147483647.
// Extra: MultipleDefaults(0)==30 empty A; NegativeDefault(-1)==-1 explicit override.
// DefaultSafe. Source owns locals.

int MultipleDefaults(int A, int B = 10, int C = 20)
{
	return A + B + C;
}

int MultipleDefaultsUsingBoth(int A)
{
	return MultipleDefaults(A);
}

int MultipleDefaultsUsingFinal(int A, int B)
{
	return MultipleDefaults(A, B);
}

int NegativeDefault(int Value = -7)
{
	return Value;
}

int NegativeDefaultUsingDefault()
{
	return NegativeDefault();
}

int BoundaryDefault(int Value = 2147483647)
{
	return Value;
}

int BoundaryDefaultUsingDefault()
{
	return BoundaryDefault();
}

bool Observe_FunctionDefaultParameterEdges_Nominal()
{
	return MultipleDefaultsUsingBoth(12) == 42
		&& MultipleDefaultsUsingFinal(12, 10) == 42
		&& NegativeDefaultUsingDefault() == -7
		&& BoundaryDefaultUsingDefault() == 2147483647;
}

int Observe_FunctionDefaultParameterEdges_EmptyA()
{
	return MultipleDefaultsUsingBoth(0);
}

int Observe_FunctionDefaultParameterEdges_ExplicitNegative()
{
	return NegativeDefault(-1);
}
