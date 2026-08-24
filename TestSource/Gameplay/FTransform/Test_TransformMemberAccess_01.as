// Theme: Gameplay.FTransform. Positive accessor/mutator oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformMemberAccess (compiling block)
// CSV Positive; C++ compiles GetLocation/GetScale/SetLocation/SetScale/SetRotation.
// Direct members are a separate CompileAndExpectFailure file (_02).
// Oracle: GetLocation (100,200,300); GetScale (2,3,4);
// SetLocation (10,20,30); SetScale Identity+(5,5,5); SetRotation yaw-90.
// Extra: default GetLocation Zero; copy independence of SetLocation. DefaultSafe.

FVector GetLocation()
{
	FTransform T = FTransform(FVector(100, 200, 300));
	return T.GetLocation();
}

FVector GetScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 3, 4));
	return T.GetScale3D();
}

FTransform SetLocation()
{
	FTransform T = FTransform::Identity;
	T.SetLocation(FVector(10, 20, 30));
	return T;
}

FTransform SetScale()
{
	FTransform T = FTransform::Identity;
	T.SetScale3D(FVector(5, 5, 5));
	return T;
}

FTransform SetRotation()
{
	FTransform T = FTransform::Identity;
	T.SetRotation(FQuat(FRotator(0, 90, 0)));
	return T;
}

bool Observe_GetLocation()
{
	return GetLocation() == FVector(100, 200, 300);
}

bool Observe_GetScale()
{
	return GetScale() == FVector(2, 3, 4);
}

bool Observe_SetLocation()
{
	return SetLocation().Equals(FTransform(FVector(10, 20, 30)), 0.001);
}

bool Observe_SetScale()
{
	return SetScale().Equals(FTransform(FQuat::Identity, FVector::ZeroVector, FVector(5, 5, 5)), 0.001);
}

bool Observe_SetRotation()
{
	return SetRotation().Equals(FTransform(FRotator(0, 90, 0), FVector::ZeroVector), 0.001);
}

bool Observe_GetLocation_DefaultEmpty()
{
	return FTransform().GetLocation().Equals(FVector::ZeroVector, 0.001);
}

bool Observe_SetLocation_CopyIndependence()
{
	FTransform T = FTransform::Identity;
	FTransform Mutated = T;
	Mutated.SetLocation(FVector(10, 20, 30));
	return T.GetLocation().Equals(FVector::ZeroVector, 0.001)
		&& Mutated.GetLocation().Equals(FVector(10, 20, 30), 0.001);
}
