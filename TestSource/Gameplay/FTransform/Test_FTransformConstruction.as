// Theme: Gameplay.FTransform. Positive construction and accessor oracles.
// C++: AngelscriptCoverageMathGeometricStructs.cpp::FTransformConstruction
// Oracle: default/Identity Equals Identity; location-only (100,200,300);
// full construction location (100,200,300) scale (2,2,2); GetLocation
// (100,200,300); GetRotation != Identity; GetScale (2,3,4);
// SetLocation (50,100,150); SetScale (3,3,3). Extra: empty Identity;
// copy independence of location-only. DefaultSafe.

FTransform TestDefaultConstruction()
{
	return FTransform();
}

FTransform TestIdentity()
{
	return FTransform::Identity;
}

FTransform TestLocationOnly()
{
	return FTransform(FVector(100, 200, 300));
}

FTransform TestFullConstruction()
{
	FQuat rot = FQuat(FRotator(0, 90, 0));
	FVector loc = FVector(100, 200, 300);
	FVector scale = FVector(2, 2, 2);
	return FTransform(rot, loc, scale);
}

FVector TestGetLocation()
{
	FTransform t = FTransform(FVector(100, 200, 300));
	return t.GetLocation();
}

FQuat TestGetRotation()
{
	FQuat rot = FQuat(FRotator(0, 90, 0));
	FTransform t = FTransform(rot, FVector::ZeroVector, FVector(1,1,1));
	return t.GetRotation();
}

FVector TestGetScale()
{
	FTransform t = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 3, 4));
	return t.GetScale3D();
}

FTransform TestSetLocation()
{
	FTransform t = FTransform::Identity;
	t.SetLocation(FVector(50, 100, 150));
	return t;
}

FTransform TestSetScale()
{
	FTransform t = FTransform::Identity;
	t.SetScale3D(FVector(3, 3, 3));
	return t;
}

bool Observe_TestDefaultConstruction()
{
	return TestDefaultConstruction().Equals(FTransform::Identity, 0.001);
}

bool Observe_TestIdentity()
{
	return TestIdentity().Equals(FTransform::Identity, 0.001);
}

bool Observe_TestLocationOnly()
{
	return TestLocationOnly().GetLocation().Equals(FVector(100, 200, 300), 0.001);
}

bool Observe_TestFullConstruction()
{
	FTransform Result = TestFullConstruction();
	return Result.GetLocation().Equals(FVector(100, 200, 300), 0.001)
		&& Result.GetScale3D().Equals(FVector(2, 2, 2), 0.001);
}

bool Observe_TestGetLocation()
{
	return TestGetLocation().Equals(FVector(100, 200, 300), 0.001);
}

bool Observe_TestGetRotation()
{
	return !TestGetRotation().Equals(FQuat::Identity, 0.001);
}

bool Observe_TestGetScale()
{
	return TestGetScale().Equals(FVector(2, 3, 4), 0.001);
}

bool Observe_TestSetLocation()
{
	return TestSetLocation().GetLocation().Equals(FVector(50, 100, 150), 0.001);
}

bool Observe_TestSetScale()
{
	return TestSetScale().GetScale3D().Equals(FVector(3, 3, 3), 0.001);
}

bool Observe_TestDefaultConstruction_EmptyIdentity()
{
	FTransform Empty = FTransform();
	return Empty.Equals(FTransform::Identity, 0.001)
		&& Empty.GetLocation().Equals(FVector::ZeroVector, 0.001);
}

bool Observe_TestLocationOnly_CopyIndependence()
{
	FTransform Original = TestLocationOnly();
	FTransform Copy = Original;
	Copy.SetLocation(FVector::ZeroVector);
	return Original.GetLocation().Equals(FVector(100, 200, 300), 0.001)
		&& Copy.GetLocation().Equals(FVector::ZeroVector, 0.001);
}
