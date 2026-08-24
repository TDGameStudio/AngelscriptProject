// Theme: Language.Syntax.EdgeCases. Positive const&in float/double parameters.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersIn
// sha256=83a16b441bebf3384acb18cc392912c420691448520e2533996c8dc183cb2f04; lines 95-105.
// Oracle: AcceptFloatIn(5.5) ~= 11.0; AcceptDoubleIn(10.5) ~= 31.5.
// Extra: zero yields zero; input is not mutated. DefaultSafe.

float AcceptFloatIn(const float&in X)
{
	return X * 2.0f;
}

double AcceptDoubleIn(const double&in X)
{
	return X * 3.0;
}

bool Observe_AcceptFloatIn_Nominal()
{
	return Math::IsNearlyEqual(AcceptFloatIn(5.5f), 11.0, 0.001) && Math::IsNearlyEqual(AcceptDoubleIn(10.5), 31.5, 0.001);
}

bool Observe_AcceptFloatIn_ZeroDefault()
{
	return Math::IsNearlyEqual(AcceptFloatIn(0.0f), 0.0, 0.001) && Math::IsNearlyEqual(AcceptDoubleIn(0.0), 0.0, 0.001);
}

bool Observe_AcceptFloatIn_CopyIndependence()
{
	float F = 5.5f;
	double D = 10.5;
	float FResult = AcceptFloatIn(F);
	double DResult = AcceptDoubleIn(D);
	return Math::IsNearlyEqual(F, 5.5, 0.001) && Math::IsNearlyEqual(D, 10.5, 0.001) && Math::IsNearlyEqual(FResult, 11.0, 0.001) && Math::IsNearlyEqual(DResult, 31.5, 0.001);
}
