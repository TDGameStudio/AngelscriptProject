// Theme: Gameplay.FTransform. Positive construction oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformConstruction
// Oracle: default Identity; Identity; Location (100,200,300);
// Full (Identity, (10,20,30), (2,2,2)); Rotator+Location (0,90,0)+(50,100,150).
// Extra: default GetLocation Zero; copy independence of location ctor. DefaultSafe.

FTransform ConstructDefault()
{
	return FTransform();
}

FTransform ConstructIdentity()
{
	return FTransform::Identity;
}

FTransform ConstructLocation()
{
	return FTransform(FVector(100, 200, 300));
}

FTransform ConstructFull()
{
	return FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2));
}

FTransform ConstructRotationAndLocation()
{
	FRotator Rot = FRotator(0, 90, 0);  // Yaw 90 degrees
	return FTransform(Rot, FVector(50, 100, 150));
}

bool Observe_ConstructDefault()
{
	return ConstructDefault().Equals(FTransform::Identity, 0.001);
}

bool Observe_ConstructIdentity()
{
	return ConstructIdentity().Equals(FTransform::Identity, 0.001);
}

bool Observe_ConstructLocation()
{
	return ConstructLocation().Equals(FTransform(FVector(100, 200, 300)), 0.001);
}

bool Observe_ConstructFull()
{
	return ConstructFull().Equals(FTransform(FQuat::Identity, FVector(10, 20, 30), FVector(2, 2, 2)), 0.001);
}

bool Observe_ConstructRotationAndLocation()
{
	FRotator Rot = FRotator(0, 90, 0);
	return ConstructRotationAndLocation().Equals(FTransform(Rot, FVector(50, 100, 150)), 0.001);
}

bool Observe_ConstructDefault_EmptyLocation()
{
	return ConstructDefault().GetLocation().Equals(FVector::ZeroVector, 0.001);
}

bool Observe_ConstructLocation_CopyIndependence()
{
	FTransform Original = ConstructLocation();
	FTransform Copy = Original;
	Copy.SetLocation(FVector::ZeroVector);
	return Original.GetLocation().Equals(FVector(100, 200, 300), 0.001);
}
