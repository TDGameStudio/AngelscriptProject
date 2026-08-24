// Theme: Gameplay.FVector. Positive &out write oracles.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersOut
// Oracle: WriteVector -> (10,20,30); WriteMultipleVectors A ForwardVector
// (1,0,0) B UpVector (0,0,1). Extra: empty ZeroVector before write;
// copy independence of two out values. DefaultSafe.

void WriteVector(FVector&out v)
{
	v = FVector(10, 20, 30);
}

void WriteMultipleVectors(FVector&out a, FVector&out b)
{
	a = FVector::ForwardVector;
	b = FVector::UpVector;
}

bool Observe_WriteVector()
{
	FVector OutValue;
	WriteVector(OutValue);
	return OutValue.Equals(FVector(10, 20, 30));
}

bool Observe_WriteMultipleVectors()
{
	FVector OutA;
	FVector OutB;
	WriteMultipleVectors(OutA, OutB);
	return OutA.Equals(FVector::ForwardVector) && OutB.Equals(FVector::UpVector);
}

bool Observe_WriteVector_DefaultEmpty()
{
	FVector Empty;
	return Empty.Equals(FVector::ZeroVector);
}

bool Observe_WriteMultipleVectors_CopyIndependence()
{
	FVector OutA;
	FVector OutB;
	WriteMultipleVectors(OutA, OutB);
	OutA.X = 0.0;
	return OutB.Equals(FVector::UpVector);
}
