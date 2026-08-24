// Theme: Language.Syntax.EdgeCases. Positive bool value parameter.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersValue
// sha256=5ad1d5d67ce622408ded3b625c2614b743f5b6f8d3f64af8906bf51ecffe98b6; lines 56-61.
// Oracle: Negate(true) is false. Extra: Negate(false) is true. DefaultSafe.

bool Negate(bool b)
{
	return !b;
}

bool Observe_Negate_Nominal()
{
	return Negate(true) == false;
}

bool Observe_Negate_FalseBoundary()
{
	return Negate(false) == true;
}
