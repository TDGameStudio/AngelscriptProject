// Theme: Gameplay.FTransform. Positive Inverse / InverseTransform oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformInverse
// Oracle: Inverse of (100,200,300); InverseTransformPosition (110)->native;
// InverseTransformVector (20,0,0) under scale 2; InverseRoundTrip (10,20,30).
// Extra: Identity Inverse; copy independence of Original. DefaultSafe.

FTransform GetInverse()
{
	FTransform T = FTransform(FVector(100, 200, 300));
	return T.Inverse();
}

FVector InverseTransformPosition()
{
	FTransform T = FTransform(FVector(100, 0, 0));
	FVector WorldPoint = FVector(110, 0, 0);
	return T.InverseTransformPosition(WorldPoint);
}

FVector InverseTransformVector()
{
	FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
	FVector WorldVec = FVector(20, 0, 0);
	return T.InverseTransformVector(WorldVec);
}

FVector InverseRoundTrip()
{
	FTransform T = FTransform(FVector(100, 200, 300));
	FVector Original = FVector(10, 20, 30);
	FVector World = T.TransformPosition(Original);
	return T.InverseTransformPosition(World);
}

bool Observe_GetInverse()
{
	FTransform T = FTransform(FVector(100, 200, 300));
	return GetInverse().Equals(T.Inverse(), 0.001);
}

bool Observe_InverseTransformPosition()
{
	FTransform T = FTransform(FVector(100, 0, 0));
	return InverseTransformPosition().Equals(T.InverseTransformPosition(FVector(110, 0, 0)), 0.001);
}

bool Observe_InverseTransformVector()
{
	FTransform T = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
	return InverseTransformVector().Equals(T.InverseTransformVector(FVector(20, 0, 0)), 0.001);
}

bool Observe_InverseRoundTrip()
{
	return InverseRoundTrip().Equals(FVector(10, 20, 30), 0.01);
}

bool Observe_GetInverse_DefaultIdentity()
{
	return FTransform().Inverse().Equals(FTransform::Identity, 0.001);
}

bool Observe_InverseRoundTrip_CopyIndependence()
{
	FVector Original = FVector(10, 20, 30);
	FTransform T = FTransform(FVector(100, 200, 300));
	FVector World = T.TransformPosition(Original);
	World.X = 0.0;
	return Original.Equals(FVector(10, 20, 30));
}
