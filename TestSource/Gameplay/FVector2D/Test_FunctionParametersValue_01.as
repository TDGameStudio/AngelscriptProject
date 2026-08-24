// Theme: Gameplay.FVector2D. Positive value-parameter oracles.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersValue
// Oracle: AcceptVector((5,10)) == (10,20); AcceptTwoVectors((0,0),(3,4)) == 5.0.
// Extra: empty ZeroVector *2 stays zero; copy independence of AcceptVector input.
// DefaultSafe.

FVector2D AcceptVector(FVector2D v)
{
	return v * 2.0;
}

float AcceptTwoVectors(FVector2D a, FVector2D b)
{
	return a.Distance(b);
}

bool Observe_AcceptVector()
{
	return AcceptVector(FVector2D(5, 10)).Equals(FVector2D(10, 20));
}

bool Observe_AcceptTwoVectors()
{
	return Math::IsNearlyEqual(AcceptTwoVectors(FVector2D(0, 0), FVector2D(3, 4)), 5.0, 0.001);
}

bool Observe_AcceptVector_DefaultEmpty()
{
	return AcceptVector(FVector2D()).Equals(FVector2D::ZeroVector);
}

bool Observe_AcceptVector_CopyIndependence()
{
	FVector2D Input = FVector2D(5, 10);
	FVector2D Result = AcceptVector(Input);
	Result.X = 0.0;
	return Input.Equals(FVector2D(5, 10));
}
