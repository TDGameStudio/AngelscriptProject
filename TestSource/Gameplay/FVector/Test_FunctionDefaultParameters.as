// Theme: Gameplay.FVector. Positive default-parameter add oracles.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionDefaultParameters
// Oracle: AddWithDefault((1,2,3),(4,5,6)) == (5,7,9);
// AddUsingDefault((1,2,3)) == (2,3,4) via OneVector default.
// Extra: empty ZeroVector + OneVector == (1,1,1); copy independence of Arg1.
// DefaultSafe.

FVector AddWithDefault(FVector a, FVector b = FVector::OneVector)
{
	return a + b;
}

FVector AddUsingDefault(FVector a)
{
	return AddWithDefault(a);
}

bool Observe_AddWithDefault_Explicit()
{
	return AddWithDefault(FVector(1, 2, 3), FVector(4, 5, 6)).Equals(FVector(5, 7, 9));
}

bool Observe_AddUsingDefault()
{
	return AddUsingDefault(FVector(1, 2, 3)).Equals(FVector(2, 3, 4));
}

bool Observe_AddUsingDefault_EmptyZero()
{
	return AddUsingDefault(FVector()).Equals(FVector::OneVector);
}

bool Observe_AddUsingDefault_CopyIndependence()
{
	FVector Arg1 = FVector(1, 2, 3);
	FVector Result = AddUsingDefault(Arg1);
	Result.X = 0.0;
	return Arg1.Equals(FVector(1, 2, 3));
}
