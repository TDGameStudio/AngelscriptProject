// Theme: Gameplay.FVector2D. Positive return-value oracles.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionReturnValues
// Oracle: ReturnZeroVector ZeroVector; ReturnCustomVector (50,75);
// ReturnComputedVector (15,30). Extra: empty ZeroVector; copy independence of
// custom return. DefaultSafe.

FVector2D ReturnZeroVector()
{
	return FVector2D::ZeroVector;
}

FVector2D ReturnCustomVector()
{
	return FVector2D(50, 75);
}

FVector2D ReturnComputedVector()
{
	FVector2D a = FVector2D(10, 20);
	FVector2D b = FVector2D(5, 10);
	return a + b;
}

bool Observe_ReturnZeroVector()
{
	return ReturnZeroVector().Equals(FVector2D::ZeroVector);
}

bool Observe_ReturnCustomVector()
{
	return ReturnCustomVector().Equals(FVector2D(50, 75));
}

bool Observe_ReturnComputedVector()
{
	return ReturnComputedVector().Equals(FVector2D(15, 30));
}

bool Observe_ReturnZeroVector_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	return Empty.Equals(FVector2D::ZeroVector);
}

bool Observe_ReturnCustomVector_CopyIndependence()
{
	FVector2D Original = ReturnCustomVector();
	FVector2D Copy = Original;
	Copy.X = 0.0;
	return Original.Equals(FVector2D(50, 75)) && Copy.X == 0.0;
}
