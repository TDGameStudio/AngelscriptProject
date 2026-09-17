/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Baseline
 */
// CompileScriptModule + Run(Movement)==1. VerifyByPath MovementModes/Parameters/QueriesCovered true.
// Extra: Run(nullptr)==0; a second harness starts with flags false.
// DefaultSafe. Movement component is runner-owned.

UCLASS()
class UCoveragePhysicsCharacterMovementHarness : UObject
{
	UPROPERTY()
	bool MovementModesCovered = false;

	UPROPERTY()
	bool MovementParametersCovered = false;

	UPROPERTY()
	bool MovementQueriesCovered = false;

	UFUNCTION()
	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		Movement.MaxWalkSpeed = 700.0f;
		Movement.MaxAcceleration = 2048.0f;
		Movement.BrakingDecelerationWalking = 1024.0f;
		Movement.GroundFriction = 4.0f;
		Movement.JumpZVelocity = 500.0f;
		Movement.AirControl = 0.35f;
		Movement.GravityScale = 1.25f;

		MovementParametersCovered =
			Movement.MaxWalkSpeed > 699.0f
			&& Movement.GetMaxAcceleration() > 2047.0f
			&& Movement.GetMaxBrakingDeceleration() > 1023.0f
			&& Movement.GroundFriction > 3.9f
			&& Movement.JumpZVelocity > 499.0f
			&& Movement.AirControl > 0.34f
			&& Movement.GravityScale > 1.24f;

		bool bWalkingValueReadable = int(EMovementMode::MOVE_Walking) >= 0;
		bool bNavWalkingValueReadable = int(EMovementMode::MOVE_NavWalking) >= 0;
		bool bFallingValueReadable = int(EMovementMode::MOVE_Falling) >= 0;
		bool bSwimmingValueReadable = int(EMovementMode::MOVE_Swimming) >= 0;
		bool bFlyingValueReadable = int(EMovementMode::MOVE_Flying) >= 0;
		bool bCustomValueReadable = int(EMovementMode::MOVE_Custom) >= 0;

		Movement.SetMovementMode(EMovementMode::MOVE_Flying);
		bool bFlyingSet = Movement.MovementMode == EMovementMode::MOVE_Flying;
		Movement.SetMovementMode(EMovementMode::MOVE_Falling);
		bool bFallingSet = Movement.MovementMode == EMovementMode::MOVE_Falling;
		Movement.SetMovementMode(EMovementMode::MOVE_Swimming);
		bool bSwimmingQueryCallable = Movement.IsSwimming() || !Movement.IsSwimming();
		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		bool bWalkingSet = Movement.MovementMode == EMovementMode::MOVE_Walking;

		MovementModesCovered =
			bWalkingValueReadable
			&& bNavWalkingValueReadable
			&& bFallingValueReadable
			&& bSwimmingValueReadable
			&& bFlyingValueReadable
			&& bCustomValueReadable
			&& bFlyingSet
			&& bFallingSet
			&& bWalkingSet;

		FVector CurrentAcceleration = Movement.GetCurrentAcceleration();
		bool bWalkingQueryCallable = Movement.IsWalking() || !Movement.IsWalking();
		bool bFallingQueryCallable = Movement.IsFalling() || !Movement.IsFalling();
		bool bFlyingQueryCallable = Movement.IsFlying() || !Movement.IsFlying();
		MovementQueriesCovered =
			bWalkingQueryCallable
			&& bFallingQueryCallable
			&& bSwimmingQueryCallable
			&& bFlyingQueryCallable
			&& CurrentAcceleration.SizeSquared() >= 0.0f;

		return MovementModesCovered && MovementParametersCovered && MovementQueriesCovered ? 1 : 0;
	}
}

int Observe_CharacterMovement_NullDefault(UCoveragePhysicsCharacterMovementHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CharacterMovementPhysicsSettings setup: required Harness is null");
	}
	return Harness.Run(nullptr);
}

int Observe_CharacterMovement_Nominal(UCharacterMovementComponent Movement, UCoveragePhysicsCharacterMovementHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CharacterMovementPhysicsSettings setup: required Harness is null");
	}
	if (Movement == nullptr)
	{
		throw("TS-CONT-0056 setup: required movement component is null");
	}
	return Harness.Run(Movement);
}

bool Observe_CharacterMovement_CopyIndependence(UCoveragePhysicsCharacterMovementHarness First, UCoveragePhysicsCharacterMovementHarness Second)
{
	if (First is null)
	{
		throw("Test_CharacterMovementPhysicsSettings setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_CharacterMovementPhysicsSettings setup: required Second is null");
	}
	First.MovementModesCovered = true;
	return First.MovementModesCovered == true
		&& Second.MovementModesCovered == false
		&& Second.MovementParametersCovered == false
		&& Second.MovementQueriesCovered == false;
}
/** @end */
