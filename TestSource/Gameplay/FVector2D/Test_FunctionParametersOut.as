// Theme: Gameplay.FVector2D. Positive &out write oracles.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersOut
// Oracle: WriteVector -> (100,200); WriteMultipleVectors A (1,0) B (0,1).
// Extra: empty ZeroVector before write; copy independence of two out values.
// DefaultSafe.

void WriteVector(FVector2D&out v)
{
	v = FVector2D(100, 200);
}

void WriteMultipleVectors(FVector2D&out a, FVector2D&out b)
{
	a = FVector2D(1, 0);
	b = FVector2D(0, 1);
}

bool Observe_WriteVector()
{
	FVector2D OutValue;
	WriteVector(OutValue);
	return OutValue.Equals(FVector2D(100, 200));
}

bool Observe_WriteMultipleVectors()
{
	FVector2D OutA;
	FVector2D OutB;
	WriteMultipleVectors(OutA, OutB);
	return OutA.Equals(FVector2D(1, 0)) && OutB.Equals(FVector2D(0, 1));
}

bool Observe_WriteVector_DefaultEmpty()
{
	FVector2D Empty;
	return Empty.Equals(FVector2D::ZeroVector);
}

bool Observe_WriteMultipleVectors_CopyIndependence()
{
	FVector2D OutA;
	FVector2D OutB;
	WriteMultipleVectors(OutA, OutB);
	OutA.X = 0.0;
	return OutB.Equals(FVector2D(0, 1));
}
