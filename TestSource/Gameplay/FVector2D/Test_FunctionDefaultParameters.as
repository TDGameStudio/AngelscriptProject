// Theme: Gameplay.FVector2D. Positive default-parameter add oracles.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionDefaultParameters
// Oracle: AddWithDefault((10,20),(5,10)) == (15,30);
// AddUsingDefault((10,20)) == (11,21) via UnitVector default.
// Extra: empty ZeroVector + UnitVector; copy independence of Arg1. DefaultSafe.

FVector2D AddWithDefault(FVector2D a, FVector2D b = FVector2D::UnitVector)
{
	return a + b;
}

FVector2D AddUsingDefault(FVector2D a)
{
	return AddWithDefault(a);
}

bool Observe_AddWithDefault_Explicit()
{
	return AddWithDefault(FVector2D(10, 20), FVector2D(5, 10)).Equals(FVector2D(15, 30));
}

bool Observe_AddUsingDefault()
{
	return AddUsingDefault(FVector2D(10, 20)).Equals(FVector2D(11, 21));
}

bool Observe_AddUsingDefault_EmptyZero()
{
	return AddUsingDefault(FVector2D()).Equals(FVector2D::UnitVector);
}

bool Observe_AddUsingDefault_CopyIndependence()
{
	FVector2D Arg1 = FVector2D(10, 20);
	FVector2D Result = AddUsingDefault(Arg1);
	Result.X = 0.0;
	return Arg1.Equals(FVector2D(10, 20));
}
