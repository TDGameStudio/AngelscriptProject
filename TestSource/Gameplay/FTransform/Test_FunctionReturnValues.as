// Theme: Gameplay.FTransform. Positive return-value oracles.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::FunctionReturnValues
// Oracle: ReturnIdentity Equals Identity; ReturnCustomTransform location
// (50,100,150); ReturnComputedTransform Equals A*B of (100,0,0)*(0,100,0);
// ReturnInverse Equals Inverse of (10,20,30). Extra: empty Identity;
// copy independence of ReturnCustomTransform. DefaultSafe.

FTransform ReturnIdentity()
{
	return FTransform::Identity;
}

FTransform ReturnCustomTransform()
{
	return FTransform(FVector(50, 100, 150));
}

FTransform ReturnComputedTransform()
{
	FTransform A = FTransform(FVector(100, 0, 0));
	FTransform B = FTransform(FVector(0, 100, 0));
	return A * B;
}

FTransform ReturnInverse()
{
	FTransform T = FTransform(FVector(10, 20, 30));
	return T.Inverse();
}

bool Observe_ReturnIdentity()
{
	return ReturnIdentity().Equals(FTransform::Identity, 0.01);
}

bool Observe_ReturnCustomTransform()
{
	return ReturnCustomTransform().GetLocation().Equals(FVector(50, 100, 150), 0.01);
}

bool Observe_ReturnComputedTransform()
{
	FTransform A = FTransform(FVector(100, 0, 0));
	FTransform B = FTransform(FVector(0, 100, 0));
	FTransform Expected = A * B;
	return ReturnComputedTransform().Equals(Expected, 0.01);
}

bool Observe_ReturnInverse()
{
	FTransform T = FTransform(FVector(10, 20, 30));
	FTransform Expected = T.Inverse();
	return ReturnInverse().Equals(Expected, 0.01);
}

bool Observe_ReturnIdentity_DefaultEmpty()
{
	FTransform Empty = FTransform();
	return Empty.Equals(FTransform::Identity, 0.01)
		&& ReturnIdentity().Equals(Empty, 0.01);
}

bool Observe_ReturnCustomTransform_CopyIndependence()
{
	FTransform Original = ReturnCustomTransform();
	FTransform Copy = Original;
	Copy.SetLocation(FVector::ZeroVector);
	return Original.GetLocation().Equals(FVector(50, 100, 150), 0.01)
		&& Copy.GetLocation().Equals(FVector::ZeroVector, 0.01);
}
