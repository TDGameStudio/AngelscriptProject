// Theme: Gameplay.FVector2D. Positive &in Size() oracle.
// C++: AngelscriptCoverageFVector2DFunctionTests.cpp::FunctionParametersIn
// Oracle: AcceptVectorIn((3,4)) == 5.0. Extra: empty ZeroVector Size 0;
// copy independence of the &in argument. DefaultSafe.

float AcceptVectorIn(FVector2D&in v)
{
	return v.Size();
}

bool Observe_AcceptVectorIn()
{
	FVector2D Input = FVector2D(3, 4);
	return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
}

bool Observe_AcceptVectorIn_DefaultEmpty()
{
	FVector2D Empty = FVector2D();
	return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
}

bool Observe_AcceptVectorIn_CopyIndependence()
{
	FVector2D Input = FVector2D(3, 4);
	float Size = AcceptVectorIn(Input);
	return Input.Equals(FVector2D(3, 4)) && Math::IsNearlyEqual(Size, 5.0, 0.001);
}
