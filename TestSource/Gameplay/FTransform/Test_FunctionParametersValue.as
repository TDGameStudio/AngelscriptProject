// Theme: Gameplay.FTransform. Positive value-parameter oracles.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionParametersValue
// Oracle: AcceptTransform((10,20,30)) location (110,20,30);
// AcceptTwoTransforms((100,0,0),(400,0,0)) Equals (300,0,0).
// Extra: AcceptTransform of Identity location (100,0,0); copy independence. DefaultSafe.

FTransform AcceptTransform(FTransform t)
{
	FTransform Modified = t;
	Modified.AddToTranslation(FVector(100, 0, 0));
	return Modified;
}

FVector AcceptTwoTransforms(FTransform a, FTransform b)
{
	FVector PosA = a.TransformPosition(FVector::ZeroVector);
	FVector PosB = b.TransformPosition(FVector::ZeroVector);
	return PosB - PosA;
}

bool Observe_AcceptTransform_Nominal()
{
	FTransform Input = FTransform(FVector(10, 20, 30));
	return AcceptTransform(Input).GetLocation().Equals(FVector(110, 20, 30), 0.01);
}

bool Observe_AcceptTwoTransforms_Nominal()
{
	FTransform A = FTransform(FVector(100, 0, 0));
	FTransform B = FTransform(FVector(400, 0, 0));
	return AcceptTwoTransforms(A, B).Equals(FVector(300, 0, 0), 0.01);
}

bool Observe_AcceptTransform_DefaultIdentity()
{
	return AcceptTransform(FTransform()).GetLocation().Equals(FVector(100, 0, 0), 0.01);
}

bool Observe_AcceptTransform_CopyIndependence()
{
	FTransform Input = FTransform(FVector(10, 20, 30));
	FTransform Result = AcceptTransform(Input);
	Result.SetLocation(FVector::ZeroVector);
	return Input.GetLocation().Equals(FVector(10, 20, 30), 0.01);
}
