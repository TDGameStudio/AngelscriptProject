// Theme: Gameplay.FTransform. Positive &in parameter oracle.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionParametersIn
// Oracle: AcceptTransformIn((50,100,150)) Equals (50,100,150).
// Extra: default Identity location Zero. DefaultSafe.

FVector AcceptTransformIn(FTransform&in t)
{
	return t.GetLocation();
}

bool Observe_AcceptTransformIn_Nominal()
{
	FTransform Input = FTransform(FVector(50, 100, 150));
	return AcceptTransformIn(Input).Equals(FVector(50, 100, 150), 0.01);
}

bool Observe_AcceptTransformIn_DefaultEmpty()
{
	FTransform Empty = FTransform();
	return AcceptTransformIn(Empty).Equals(FVector::ZeroVector, 0.01);
}

bool Observe_AcceptTransformIn_CopyIndependence()
{
	FTransform Input = FTransform(FVector(50, 100, 150));
	FVector Result = AcceptTransformIn(Input);
	Result.X = 0.0;
	return Input.GetLocation().Equals(FVector(50, 100, 150), 0.01);
}
