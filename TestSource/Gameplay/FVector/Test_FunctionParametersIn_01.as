// Theme: Gameplay.FVector. Positive &in Size() oracle.
// C++: AngelscriptCoverageFVectorFunctionTests.cpp::FunctionParametersIn
// Oracle: AcceptVectorIn((3,4,0)) == 5.0. Extra: empty ZeroVector Size 0;
// copy independence of the &in argument. DefaultSafe.

float AcceptVectorIn(FVector&in v)
{
	return v.Size();
}

bool Observe_AcceptVectorIn()
{
	FVector Input = FVector(3, 4, 0);
	return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
}

bool Observe_AcceptVectorIn_DefaultEmpty()
{
	FVector Empty = FVector();
	return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
}

bool Observe_AcceptVectorIn_CopyIndependence()
{
	FVector Input = FVector(3, 4, 0);
	float Size = AcceptVectorIn(Input);
	return Input.Equals(FVector(3, 4, 0)) && Math::IsNearlyEqual(Size, 5.0, 0.001);
}
