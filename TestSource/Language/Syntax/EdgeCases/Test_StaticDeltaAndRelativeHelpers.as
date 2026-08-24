// Theme: Language.Syntax.EdgeCases. Positive static delta/relative round-trips.
// C++: AngelscriptMathOrientationFunctionLibraryTests.cpp::StaticDeltaAndRelativeHelpers
// sha256=044792e1e9229c4654feb263ac27fcf32c2dc0b1ad3c7b95a2ad15bae59f3498; lines 412-468.
// Oracle: each *RoundTrips() returns 1.
// Extra: identity FQuat delta/apply stays identity; zero-duration angular path is the empty vector.
// DefaultSafe. Source owns locals.

int QuatDeltaRoundTrips()
{
	const FQuat Origin = FQuat(FRotator(0.0f, 15.0f, 0.0f));
	const FQuat Target = FQuat(FRotator(10.0f, 75.0f, 5.0f));
	const FQuat Delta = FQuat::GetDelta(Origin, Target);
	return FQuat::ApplyDelta(Origin, Delta).Equals(Target, 0.001f) ? 1 : 0;
}

int QuatRelativeRoundTrips()
{
	const FQuat Parent = FQuat(FRotator(0.0f, 45.0f, 0.0f));
	const FQuat Child = FQuat(FRotator(20.0f, 90.0f, 0.0f));
	const FQuat Relative = FQuat::GetRelative(Parent, Child);
	return FQuat::ApplyRelative(Parent, Relative).Equals(Child, 0.001f) ? 1 : 0;
}

int QuatAngularVelocityRoundTrips()
{
	const FVector AngularVelocity = FVector(0.0f, 0.0f, 2.0f);
	const FQuat Delta = FQuat::MakeDeltaRotationFromAngularVelocity(AngularVelocity, 0.5f);
	const FVector RoundTrip = FQuat::MakeAngularVelocityFromDeltaRotation(Delta, 0.5f);
	return RoundTrip.Equals(AngularVelocity, 0.001f) ? 1 : 0;
}

int RotatorDeltaRoundTrips()
{
	const FRotator Origin = FRotator(0.0f, 15.0f, 0.0f);
	const FRotator Target = FRotator(10.0f, 75.0f, 5.0f);
	const FRotator Delta = FRotator::GetDelta(Origin, Target);
	return FRotator::ApplyDelta(Origin, Delta).Equals(Target, 0.05f) ? 1 : 0;
}

int RotatorRelativeRoundTrips()
{
	const FRotator Parent = FRotator(0.0f, 45.0f, 0.0f);
	const FRotator Child = FRotator(20.0f, 90.0f, 0.0f);
	const FRotator Relative = FRotator::GetRelative(Parent, Child);
	return FRotator::ApplyRelative(Parent, Relative).Equals(Child, 0.05f) ? 1 : 0;
}

int TransformDeltaRoundTrips()
{
	const FTransform Origin = FTransform(FRotator(0.0f, 15.0f, 0.0f), FVector(10.0f, 0.0f, 0.0f), FVector::OneVector);
	const FTransform Target = FTransform(FRotator(10.0f, 75.0f, 5.0f), FVector(25.0f, -5.0f, 2.0f), FVector::OneVector);
	const FTransform Delta = FTransform::GetDelta(Origin, Target);
	return FTransform::ApplyDelta(Origin, Delta).Equals(Target, 0.01f) ? 1 : 0;
}

int TransformRelativeRoundTrips()
{
	const FTransform Parent = FTransform(FRotator(0.0f, 45.0f, 0.0f), FVector(100.0f, 0.0f, 0.0f), FVector::OneVector);
	const FTransform Child = FTransform(FRotator(20.0f, 90.0f, 0.0f), FVector(150.0f, 40.0f, 10.0f), FVector(1.0f, 2.0f, 1.0f));
	const FTransform Relative = FTransform::GetRelative(Parent, Child);
	return FTransform::ApplyRelative(Parent, Relative).Equals(Child, 0.01f) ? 1 : 0;
}

bool Observe_StaticDeltaRelative_Nominal()
{
	return QuatDeltaRoundTrips() == 1
		&& QuatRelativeRoundTrips() == 1
		&& QuatAngularVelocityRoundTrips() == 1
		&& RotatorDeltaRoundTrips() == 1
		&& RotatorRelativeRoundTrips() == 1
		&& TransformDeltaRoundTrips() == 1
		&& TransformRelativeRoundTrips() == 1;
}

int Observe_QuatDelta_IdentityEmpty()
{
	const FQuat Origin = FQuat::Identity;
	const FQuat Delta = FQuat::GetDelta(Origin, Origin);
	return FQuat::ApplyDelta(Origin, Delta).Equals(Origin, 0.001f) ? 1 : 0;
}
