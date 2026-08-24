// Theme: Gameplay.FVector. Positive return-value oracles.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionReturnValues
// Oracle: ReturnForwardVector ForwardVector; ReturnCustomVector (5,10,15);
// ReturnComputedVector (5,7,9). Extra: empty ZeroVector; copy independence of
// custom return. DefaultSafe.

FVector ReturnForwardVector()
{
	return FVector::ForwardVector;
}

FVector ReturnCustomVector()
{
	return FVector(5, 10, 15);
}

FVector ReturnComputedVector()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(4, 5, 6);
	return a + b;
}

bool Observe_ReturnForwardVector()
{
	return ReturnForwardVector().Equals(FVector::ForwardVector);
}

bool Observe_ReturnCustomVector()
{
	return ReturnCustomVector().Equals(FVector(5, 10, 15));
}

bool Observe_ReturnComputedVector()
{
	return ReturnComputedVector().Equals(FVector(5, 7, 9));
}

bool Observe_ReturnCustomVector_DefaultEmpty()
{
	FVector Empty = FVector();
	return Empty.Equals(FVector::ZeroVector);
}

bool Observe_ReturnCustomVector_CopyIndependence()
{
	FVector Original = ReturnCustomVector();
	FVector Copy = Original;
	Copy.X = 0.0;
	return Original.Equals(FVector(5, 10, 15)) && Copy.X == 0.0;
}
