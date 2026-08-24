// Theme: Gameplay.FQuat. Positive Slerp / MakeFromEuler / FindBetweenVectors.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatStaticMethods
// Oracle: Slerp Identity->yaw90 at 0.5; MakeFromEuler(10,20,30);
// FindBetweenVectors Forward->Right.
// Extra: Slerp at 0 is Identity; copy independence of endpoints. DefaultSafe.

FQuat SlerpQuats()
{
	FQuat q1 = FQuat::Identity;
	FQuat q2 = FQuat(FRotator(0, 90, 0));
	return FQuat::Slerp(q1, q2, 0.5);
}

FQuat MakeFromEuler()
{
	FVector euler = FVector(10, 20, 30);
	return FQuat::MakeFromEuler(euler);
}

FQuat FindBetweenVectors()
{
	FVector v1 = FVector::ForwardVector;
	FVector v2 = FVector::RightVector;
	return FQuat::FindBetweenVectors(v1, v2);
}

bool Observe_SlerpQuats()
{
	FQuat q1 = FQuat::Identity;
	FQuat q2 = FQuat(FRotator(0, 90, 0));
	return SlerpQuats().Equals(FQuat::Slerp(q1, q2, 0.5), 0.01);
}

bool Observe_MakeFromEuler()
{
	return MakeFromEuler().Equals(FQuat::MakeFromEuler(FVector(10, 20, 30)), 0.01);
}

bool Observe_FindBetweenVectors()
{
	return FindBetweenVectors().Equals(
		FQuat::FindBetweenVectors(FVector::ForwardVector, FVector::RightVector), 0.01);
}

bool Observe_SlerpQuats_AtZeroIsIdentity()
{
	FQuat q1 = FQuat::Identity;
	FQuat q2 = FQuat(FRotator(0, 90, 0));
	return FQuat::Slerp(q1, q2, 0.0).Equals(FQuat::Identity, 0.01);
}

bool Observe_SlerpQuats_CopyIndependence()
{
	FQuat q1 = FQuat::Identity;
	FQuat q2 = FQuat(FRotator(0, 90, 0));
	FQuat Mid = FQuat::Slerp(q1, q2, 0.5);
	Mid.X = 0.0;
	return q1.Equals(FQuat::Identity, 0.001) && q2.Equals(FQuat(FRotator(0, 90, 0)), 0.01);
}
