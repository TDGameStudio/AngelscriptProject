// Theme: Gameplay.FRotator. Positive MakeFromEuler oracle.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorStaticMethods
// Oracle: MakeFromEuler(10,20,30) Equals native MakeFromEuler.
// Extra: MakeFromEuler ZeroVector is ZeroRotator; copy independence of euler. DefaultSafe.

FRotator MakeFromEuler()
{
	FVector euler = FVector(10, 20, 30);
	return FRotator::MakeFromEuler(euler);
}

bool Observe_MakeFromEuler()
{
	return MakeFromEuler().Equals(FRotator::MakeFromEuler(FVector(10, 20, 30)), 0.001);
}

bool Observe_MakeFromEuler_DefaultZero()
{
	return FRotator::MakeFromEuler(FVector::ZeroVector).Equals(FRotator::ZeroRotator, 0.001);
}

bool Observe_MakeFromEuler_CopyIndependence()
{
	FVector Euler = FVector(10, 20, 30);
	FRotator Result = FRotator::MakeFromEuler(Euler);
	Result.Pitch = 0.0;
	return Euler.Equals(FVector(10, 20, 30));
}
