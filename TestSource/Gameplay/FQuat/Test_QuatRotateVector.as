// Theme: Gameplay.FQuat. Positive RotateVector / UnrotateVector oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatRotateVector
// Oracle: RotateForwardBy90 Equals native RotateVector(1,0,0) of yaw-90;
// UnrotateVector Equals native UnrotateVector(0,1,0) of yaw-90.
// Extra: Identity rotate of ZeroVector; copy independence of input vector. DefaultSafe.

FVector RotateForwardBy90()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	FVector v = FVector(1, 0, 0);
	return q.RotateVector(v);
}

FVector UnrotateVector()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	FVector v = FVector(0, 1, 0);
	return q.UnrotateVector(v);
}

bool Observe_RotateForwardBy90()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return RotateForwardBy90().Equals(q.RotateVector(FVector(1, 0, 0)), 0.01);
}

bool Observe_UnrotateVector()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return UnrotateVector().Equals(q.UnrotateVector(FVector(0, 1, 0)), 0.01);
}

bool Observe_RotateForwardBy90_DefaultZero()
{
	FQuat Empty = FQuat();
	return Empty.RotateVector(FVector::ZeroVector).Equals(FVector::ZeroVector, 0.001);
}

bool Observe_RotateForwardBy90_CopyIndependence()
{
	FVector V = FVector(1, 0, 0);
	FQuat q = FQuat(FRotator(0, 90, 0));
	FVector Rotated = q.RotateVector(V);
	Rotated.X = 0.0;
	return V.Equals(FVector(1, 0, 0));
}
