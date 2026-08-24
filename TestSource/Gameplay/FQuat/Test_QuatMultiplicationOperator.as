// Theme: Gameplay.FQuat. Positive multiplication operator oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatMultiplicationOperator
// Oracle: MultiplyQuats Equals q1*q2 of two yaw-45; RotateVectorWithOperator Equals
// FQuat(FRotator(0,90,0)).RotateVector(FVector(1,0,0)).
// Extra: Identity * Identity; copy independence of q1/q2. DefaultSafe.

FQuat MultiplyQuats()
{
	FQuat q1 = FQuat(FRotator(0, 45, 0));
	FQuat q2 = FQuat(FRotator(0, 45, 0));
	return q1 * q2;
}

FVector RotateVectorWithOperator()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	FVector v = FVector(1, 0, 0);
	return q * v;
}

bool Observe_MultiplyQuats()
{
	FQuat q1 = FQuat(FRotator(0, 45, 0));
	FQuat q2 = FQuat(FRotator(0, 45, 0));
	return MultiplyQuats().Equals(q1 * q2, 0.01);
}

bool Observe_RotateVectorWithOperator()
{
	FQuat q = FQuat(FRotator(0, 90, 0));
	return RotateVectorWithOperator().Equals(q.RotateVector(FVector(1, 0, 0)), 0.01);
}

bool Observe_MultiplyQuats_DefaultIdentity()
{
	FQuat Empty = FQuat();
	return (Empty * FQuat::Identity).Equals(FQuat::Identity, 0.001);
}

bool Observe_MultiplyQuats_CopyIndependence()
{
	FQuat q1 = FQuat(FRotator(0, 45, 0));
	FQuat q2 = FQuat(FRotator(0, 45, 0));
	FQuat Product = q1 * q2;
	Product.X = 0.0;
	return q1.Equals(FQuat(FRotator(0, 45, 0)), 0.01) && q2.Equals(FQuat(FRotator(0, 45, 0)), 0.01);
}
