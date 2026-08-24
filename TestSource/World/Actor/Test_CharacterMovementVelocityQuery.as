// Theme: World.Actor. WorldStory: UCharacterMovementComponent Velocity write/read and
// GetCurrentAcceleration zero without movement input.
// C++: AngelscriptCoveragePhysicsTests.cpp::CharacterMovementVelocityQuery
// Oracle: Run returns 1; VerifyByPath VelocityRoundTripped and CurrentAccelerationQueried true.
// Extra: flags default false; Run(nullptr) returns 0. FixtureIsolated.

UCLASS()
class UCoveragePhysicsCharacterMovementVelocityQueryHarness : UObject
{
	UPROPERTY()
	bool VelocityRoundTripped = false;

	UPROPERTY()
	bool CurrentAccelerationQueried = false;

	UFUNCTION()
	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		FVector TargetVelocity = FVector(120.0f, -30.0f, 45.0f);
		Movement.Velocity = TargetVelocity;
		FVector QueriedVelocity = Movement.Velocity;
		VelocityRoundTripped =
			QueriedVelocity.X > 119.99f
			&& QueriedVelocity.X < 120.01f
			&& QueriedVelocity.Y > -30.01f
			&& QueriedVelocity.Y < -29.99f
			&& QueriedVelocity.Z > 44.99f
			&& QueriedVelocity.Z < 45.01f;

		FVector CurrentAcceleration = Movement.GetCurrentAcceleration();
		CurrentAccelerationQueried = CurrentAcceleration.Equals(FVector::ZeroVector, 0.01f);
		return VelocityRoundTripped && CurrentAccelerationQueried ? 1 : 0;
	}
}
