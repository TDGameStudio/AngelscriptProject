/**
 * @version v1
 * @summary A harness that writes and reads a character movement component's velocity, then queries the current acceleration. C++ runs the harness and expects 1. A null movement component is the early-out vector.
 * @topic World
 */
/**
 * @version root
 * @summary A harness that writes and reads a character movement component's velocity, then queries the current acceleration. C++ runs the harness and expects 1. A null movement component is the early-out vector.
 * @topic Baseline
 */
UCLASS()
class UCoveragePhysicsCharacterMovementVelocityQueryHarness : UObject
{
	UPROPERTY()
	bool VelocityRoundTripped = false;

	UPROPERTY()
	bool CurrentAccelerationQueried = false;

	/**
	 * Write a velocity, read it back within a tolerance, then query the current
	 * acceleration.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a character movement component
	 * @Return 1 when the velocity read back and the acceleration was queried, 0 when the
	 * movement component is null or either step failed
	 * @Param Movement the movement component to drive
	 */
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

		if (!VelocityRoundTripped)
		{
			return 0;
		}
		if (!CurrentAccelerationQueried)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh harness has queried nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a harness that has not been run
	 * @Return true when both flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VelocityRoundTripped)
		{
			return false;
		}
		return !CurrentAccelerationQueried;
	}

	/**
	 * Observe that driving the harness with a null movement component reports failure.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementVelocityQuery
	 * @Inputs a null movement component
	 * @Return Run(nullptr), expected to be 0
	 * @Boundary null movement
	 */
	UFUNCTION()
	int NullMovementReturnsZero()
	{
		return Run(nullptr);
	}
}
/** @end */
