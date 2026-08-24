// Theme: Gameplay.FTransform. Positive &out parameter oracles.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionParametersOut
// Oracle: WriteTransform location (100,200,300); WriteMultipleTransforms A (10,0,0) B (0,20,0).
// Extra: default out before write is Identity/Zero location. DefaultSafe.

void WriteTransform(FTransform&out t)
{
	t = FTransform(FVector(100, 200, 300));
}

void WriteMultipleTransforms(FTransform&out a, FTransform&out b)
{
	a = FTransform(FVector(10, 0, 0));
	b = FTransform(FVector(0, 20, 0));
}

bool Observe_WriteTransform_Nominal()
{
	FTransform OutValue;
	WriteTransform(OutValue);
	return OutValue.GetLocation().Equals(FVector(100, 200, 300), 0.01);
}

bool Observe_WriteMultipleTransforms_Nominal()
{
	FTransform OutA;
	FTransform OutB;
	WriteMultipleTransforms(OutA, OutB);
	return OutA.GetLocation().Equals(FVector(10, 0, 0), 0.01)
		&& OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
}

bool Observe_WriteTransform_DefaultEmptyBeforeWrite()
{
	FTransform OutValue;
	return OutValue.GetLocation().Equals(FVector::ZeroVector, 0.01);
}

bool Observe_WriteMultipleTransforms_CopyIndependence()
{
	FTransform OutA;
	FTransform OutB;
	WriteMultipleTransforms(OutA, OutB);
	OutA.SetLocation(FVector::ZeroVector);
	return OutB.GetLocation().Equals(FVector(0, 20, 0), 0.01);
}
