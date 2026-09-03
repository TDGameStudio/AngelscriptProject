/**
 * Static delta and relative helpers on FQuat, FRotator and FTransform: every
 * get-delta/apply-delta and get-relative/apply-relative pair round-trips back to
 * the target, including an angular-velocity conversion.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.StaticDeltaAndRelativeHelpers
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.StaticDeltaAndRelativeHelpers
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptMathOrientationFunctionLibraryTests.cpp::StaticDeltaAndRelativeHelpers
 * @Provenance sha256=044792e1e9229c4654feb263ac27fcf32c2dc0b1ad3c7b95a2ad15bae59f3498; lines 412-468.
 * @Provenance Oracle: each *RoundTrips() returns 1.
 * @Provenance Extra: identity FQuat delta/apply stays identity; zero-duration angular path is the empty vector.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace SyntaxTest
{
	/**
	 * Round-trips an FQuat through GetDelta and ApplyDelta.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two distinct orientations
	 * @Return 1 when the round trip restores the target
	 */
	int QuatDeltaRoundTrips()
	{
		const FQuat Origin = FQuat(FRotator(0.0f, 15.0f, 0.0f));
		const FQuat Target = FQuat(FRotator(10.0f, 75.0f, 5.0f));
		const FQuat Delta = FQuat::GetDelta(Origin, Target);
		return FQuat::ApplyDelta(Origin, Delta).Equals(Target, 0.001f) ? 1 : 0;
	}

	/**
	 * Round-trips an FQuat through GetRelative and ApplyRelative.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a parent and child orientation
	 * @Return 1 when the round trip restores the child
	 */
	int QuatRelativeRoundTrips()
	{
		const FQuat Parent = FQuat(FRotator(0.0f, 45.0f, 0.0f));
		const FQuat Child = FQuat(FRotator(20.0f, 90.0f, 0.0f));
		const FQuat Relative = FQuat::GetRelative(Parent, Child);
		return FQuat::ApplyRelative(Parent, Relative).Equals(Child, 0.001f) ? 1 : 0;
	}

	/**
	 * Round-trips an angular velocity through delta rotation and back.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an angular velocity and a half-second duration
	 * @Return 1 when the round trip restores the velocity
	 */
	int QuatAngularVelocityRoundTrips()
	{
		const FVector AngularVelocity = FVector(0.0f, 0.0f, 2.0f);
		const FQuat Delta = FQuat::MakeDeltaRotationFromAngularVelocity(AngularVelocity, 0.5f);
		const FVector RoundTrip = FQuat::MakeAngularVelocityFromDeltaRotation(Delta, 0.5f);
		return RoundTrip.Equals(AngularVelocity, 0.001f) ? 1 : 0;
	}

	/**
	 * Round-trips an FRotator through GetDelta and ApplyDelta.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two distinct rotators
	 * @Return 1 when the round trip restores the target
	 */
	int RotatorDeltaRoundTrips()
	{
		const FRotator Origin = FRotator(0.0f, 15.0f, 0.0f);
		const FRotator Target = FRotator(10.0f, 75.0f, 5.0f);
		const FRotator Delta = FRotator::GetDelta(Origin, Target);
		return FRotator::ApplyDelta(Origin, Delta).Equals(Target, 0.05f) ? 1 : 0;
	}

	/**
	 * Round-trips an FRotator through GetRelative and ApplyRelative.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a parent and child rotator
	 * @Return 1 when the round trip restores the child
	 */
	int RotatorRelativeRoundTrips()
	{
		const FRotator Parent = FRotator(0.0f, 45.0f, 0.0f);
		const FRotator Child = FRotator(20.0f, 90.0f, 0.0f);
		const FRotator Relative = FRotator::GetRelative(Parent, Child);
		return FRotator::ApplyRelative(Parent, Relative).Equals(Child, 0.05f) ? 1 : 0;
	}

	/**
	 * Round-trips an FTransform through GetDelta and ApplyDelta.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two distinct transforms
	 * @Return 1 when the round trip restores the target
	 */
	int TransformDeltaRoundTrips()
	{
		const FTransform Origin = FTransform(FRotator(0.0f, 15.0f, 0.0f), FVector(10.0f, 0.0f, 0.0f), FVector::OneVector);
		const FTransform Target = FTransform(FRotator(10.0f, 75.0f, 5.0f), FVector(25.0f, -5.0f, 2.0f), FVector::OneVector);
		const FTransform Delta = FTransform::GetDelta(Origin, Target);
		return FTransform::ApplyDelta(Origin, Delta).Equals(Target, 0.01f) ? 1 : 0;
	}

	/**
	 * Round-trips an FTransform through GetRelative and ApplyRelative.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a parent and child transform
	 * @Return 1 when the round trip restores the child
	 */
	int TransformRelativeRoundTrips()
	{
		const FTransform Parent = FTransform(FRotator(0.0f, 45.0f, 0.0f), FVector(100.0f, 0.0f, 0.0f), FVector::OneVector);
		const FTransform Child = FTransform(FRotator(20.0f, 90.0f, 0.0f), FVector(150.0f, 40.0f, 10.0f), FVector(1.0f, 2.0f, 1.0f));
		const FTransform Relative = FTransform::GetRelative(Parent, Child);
		return FTransform::ApplyRelative(Parent, Relative).Equals(Child, 0.01f) ? 1 : 0;
	}

	/**
	 * Observe all seven round trips.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all seven round-trip helpers
	 * @Return true when all seven report 1
	 */
	UFUNCTION()
	bool StaticDeltaRelativeNominal()
	{
		if (QuatDeltaRoundTrips() != 1)
		{
			return false;
		}

		if (QuatRelativeRoundTrips() != 1)
		{
			return false;
		}

		if (QuatAngularVelocityRoundTrips() != 1)
		{
			return false;
		}

		if (RotatorDeltaRoundTrips() != 1)
		{
			return false;
		}

		if (RotatorRelativeRoundTrips() != 1)
		{
			return false;
		}

		if (TransformDeltaRoundTrips() != 1)
		{
			return false;
		}

		return TransformRelativeRoundTrips() == 1;
	}

	/**
	 * Observe the identity boundary of the FQuat delta.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs identity orientations
	 * @Return 1 when the round trip stays identity
	 * @Boundary identity transform
	 */
	UFUNCTION()
	int QuatDeltaIdentityEmpty()
	{
		const FQuat Origin = FQuat::Identity;
		const FQuat Delta = FQuat::GetDelta(Origin, Origin);
		return FQuat::ApplyDelta(Origin, Delta).Equals(Origin, 0.001f) ? 1 : 0;
	}
}
