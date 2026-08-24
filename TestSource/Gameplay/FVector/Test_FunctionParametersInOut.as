// Theme: Gameplay.FVector. Positive &inout scale oracle.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersInOut
// Oracle: ScaleVector((1,2,3), 2.0) -> (2,4,6). Extra: empty ZeroVector stays
// zero; copy independence of a separate vector. DefaultSafe.

void ScaleVector(FVector&inout v, float scale)
{
	v = v * scale;
}

bool Observe_ScaleVector()
{
	FVector Value = FVector(1, 2, 3);
	ScaleVector(Value, 2.0);
	return Value.Equals(FVector(2, 4, 6), 0.001);
}

bool Observe_ScaleVector_DefaultEmpty()
{
	FVector Empty = FVector();
	ScaleVector(Empty, 2.0);
	return Empty.Equals(FVector::ZeroVector, 0.001);
}

bool Observe_ScaleVector_CopyIndependence()
{
	FVector Value = FVector(1, 2, 3);
	FVector Other = Value;
	ScaleVector(Value, 2.0);
	return Value.Equals(FVector(2, 4, 6), 0.001) && Other.Equals(FVector(1, 2, 3), 0.001);
}
