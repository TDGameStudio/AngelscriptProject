// Theme: Gameplay.FVector2D. Positive &inout scale oracle.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersInOut
// Oracle: ScaleVector((10,20), 3.0) -> (30,60). Extra: empty ZeroVector stays
// zero; copy independence of a separate vector. DefaultSafe.

void ScaleVector(FVector2D&inout v, float scale)
{
	v = v * scale;
}

bool Observe_ScaleVector()
{
	FVector2D Value = FVector2D(10, 20);
	ScaleVector(Value, 3.0);
	return Value.Equals(FVector2D(30, 60), 0.001);
}

bool Observe_ScaleVector_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	ScaleVector(Empty, 3.0);
	return Empty.Equals(FVector2D::ZeroVector, 0.001);
}

bool Observe_ScaleVector_CopyIndependence()
{
	FVector2D Value = FVector2D(10, 20);
	FVector2D Other = Value;
	ScaleVector(Value, 3.0);
	return Value.Equals(FVector2D(30, 60), 0.001) && Other.Equals(FVector2D(10, 20), 0.001);
}
