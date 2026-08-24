// Theme: Language.ControlFlow.Jump. Positive value oracle from FunctionReturnValues.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionReturnValues
// sha256=5e6099558618051d82c84a64cee01daab63c31ffc8f951191186248278ee0283; lines 301-311.
// Oracle: ReturnFloat 42.25; ReturnDouble 84.5 (tolerance 0.001).
// Extra: default float/double are 0; values stay distinct.
// DefaultSafe. Source owns locals.

float ReturnFloat()
{
	return 42.25f;
}

double ReturnDouble()
{
	return 84.5;
}

bool Observe_FloatReturnValues_Nominal()
{
	return Math::IsNearlyEqual(ReturnFloat(), 42.25, 0.001)
		&& Math::IsNearlyEqual(ReturnDouble(), 84.5, 0.001);
}

bool Observe_FloatReturnValues_ZeroDefault()
{
	float EmptyFloat;
	double EmptyDouble;
	return Math::IsNearlyEqual(EmptyFloat, 0.0, 0.001)
		&& Math::IsNearlyEqual(EmptyDouble, 0.0, 0.001)
		&& !Math::IsNearlyEqual(ReturnFloat(), 0.0, 0.001);
}

bool Observe_FloatReturnValues_DistinctBoundary()
{
	return !Math::IsNearlyEqual(ReturnFloat(), ReturnDouble(), 0.001);
}
