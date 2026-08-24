// Theme: Gameplay.FVector. Positive value-parameter oracles.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersValue
// Oracle: AcceptVector((1,2,3)) == (2,4,6); AcceptTwoVectors((0,0,0),(3,4,0)) == 5.0.
// Extra: empty ZeroVector *2 stays zero; copy independence of AcceptVector input.
// DefaultSafe.

FVector AcceptVector(FVector v)
{
	return v * 2.0;
}

float AcceptTwoVectors(FVector a, FVector b)
{
	return a.Distance(b);
}

bool Observe_AcceptVector()
{
	return AcceptVector(FVector(1, 2, 3)).Equals(FVector(2, 4, 6));
}

bool Observe_AcceptTwoVectors()
{
	return Math::IsNearlyEqual(AcceptTwoVectors(FVector(0, 0, 0), FVector(3, 4, 0)), 5.0, 0.001);
}

bool Observe_AcceptVector_DefaultEmpty()
{
	return AcceptVector(FVector()).Equals(FVector::ZeroVector);
}

bool Observe_AcceptVector_CopyIndependence()
{
	FVector Input = FVector(1, 2, 3);
	FVector Result = AcceptVector(Input);
	Result.X = 0.0;
	return Input.Equals(FVector(1, 2, 3));
}
