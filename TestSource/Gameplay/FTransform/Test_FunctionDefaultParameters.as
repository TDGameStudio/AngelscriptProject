// Theme: Gameplay.FTransform. Positive default-parameter compose oracles.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionDefaultParameters
// Oracle: ComposeWithDefault((100,0,0),(0,100,0)) Equals A*B;
// ComposeUsingDefault((100,200,300)) Equals A*Identity.
// Extra: Identity default leaves location unchanged; copy independence of Arg1.
// DefaultSafe.

FTransform ComposeWithDefault(FTransform a, FTransform b = FTransform::Identity)
{
	return a * b;
}

FTransform ComposeUsingDefault(FTransform a)
{
	return ComposeWithDefault(a);
}

bool Observe_ComposeWithDefault_Explicit()
{
	FTransform Arg1 = FTransform(FVector(100, 0, 0));
	FTransform Arg2 = FTransform(FVector(0, 100, 0));
	FTransform Expected = Arg1 * Arg2;
	return ComposeWithDefault(Arg1, Arg2).Equals(Expected, 0.01);
}

bool Observe_ComposeUsingDefault()
{
	FTransform Arg1 = FTransform(FVector(100, 200, 300));
	FTransform Expected = Arg1 * FTransform::Identity;
	return ComposeUsingDefault(Arg1).Equals(Expected, 0.01);
}

bool Observe_ComposeUsingDefault_IdentityEmpty()
{
	FTransform Empty = FTransform::Identity;
	return ComposeUsingDefault(Empty).Equals(FTransform::Identity, 0.01)
		&& ComposeUsingDefault(Empty).GetLocation().Equals(FVector::ZeroVector, 0.01);
}

bool Observe_ComposeUsingDefault_CopyIndependence()
{
	FTransform Arg1 = FTransform(FVector(100, 200, 300));
	FTransform Result = ComposeUsingDefault(Arg1);
	Result.SetLocation(FVector::ZeroVector);
	return Arg1.GetLocation().Equals(FVector(100, 200, 300), 0.01);
}
