// Theme: Language.ControlFlow.Jump. Positive value oracle from FunctionReturnValues.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionReturnValues
// sha256=8c1bda041340a39e21ca14e985743c8aaee9f203da601d3be3a6c733f1fcf57e; lines 199-209.
// Oracle: ReturnTrue is true; ReturnFalse is false.
// Extra: the two returns stay distinct; false is the empty/default bool.
// DefaultSafe. Source owns locals.

bool ReturnTrue()
{
	return true;
}

bool ReturnFalse()
{
	return false;
}

bool Observe_FunctionReturnValues_Nominal()
{
	return ReturnTrue() == true && ReturnFalse() == false;
}

bool Observe_FunctionReturnValues_FalseDefault()
{
	bool Empty;
	return Empty == false && ReturnFalse() == Empty;
}

bool Observe_FunctionReturnValues_DistinctBoundary()
{
	return ReturnTrue() != ReturnFalse();
}
