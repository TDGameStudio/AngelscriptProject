/**
 * @version v1
 * @summary A harness that walks a UCharacterMovementComponent through every movement mode and records whether each one read back. C++ spawns the native character and runs the harness, expecting 1. A null movement component is the.
 * @topic World
 */
/**
 * @version root
 * @summary A harness that walks a UCharacterMovementComponent through every movement mode and records whether each one read back. C++ spawns the native character and runs the harness, expecting 1. A null movement component is the.
 * @topic Baseline
 */
UCLASS()
class UCoveragePhysicsCharacterMovementModeQueryHarness : UObject
{
	UPROPERTY()
	bool WalkingStateMatched = false;

	UPROPERTY()
	bool FallingStateMatched = false;

	UPROPERTY()
	bool SwimmingStateMatched = false;

	UPROPERTY()
	bool FlyingStateMatched = false;

	UPROPERTY()
	bool CustomStateMatched = false;

	/**
	 * Walk the movement component through every movement mode and record which ones
	 * read back.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
	 * @Inputs a character movement component
	 * @Return 1 when all five modes read back, 0 when the movement component is null
	 * or any mode failed
	 * @Param Movement the movement component to drive
	 */
	UFUNCTION()
	int Run(UCharacterMovementComponent Movement)
	{
		if (Movement == nullptr)
		{
			return 0;
		}

		Movement.SetMovementMode(EMovementMode::MOVE_Walking);
		WalkingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Walking;

		Movement.SetMovementMode(EMovementMode::MOVE_Falling);
		FallingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Falling;

		Movement.SetMovementMode(EMovementMode::MOVE_Swimming);
		SwimmingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Swimming;

		Movement.SetMovementMode(EMovementMode::MOVE_Flying);
		FlyingStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Flying;

		Movement.SetMovementMode(EMovementMode::MOVE_Custom);
		CustomStateMatched =
			Movement.MovementMode == EMovementMode::MOVE_Custom;

		if (!WalkingStateMatched)
		{
			return 0;
		}
		if (!FallingStateMatched)
		{
			return 0;
		}
		if (!SwimmingStateMatched)
		{
			return 0;
		}
		if (!FlyingStateMatched)
		{
			return 0;
		}
		if (!CustomStateMatched)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that a fresh harness has matched nothing.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
	 * @Inputs a harness that has not been run
	 * @Return true when all five flags are clear
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (WalkingStateMatched)
		{
			return false;
		}
		if (FallingStateMatched)
		{
			return false;
		}
		if (SwimmingStateMatched)
		{
			return false;
		}
		if (FlyingStateMatched)
		{
			return false;
		}
		return !CustomStateMatched;
	}

	/**
	 * Observe that driving the harness with a null movement component reports failure.
	 *
	 * @Kind Observe
	 * @Covers Actor.CharacterMovementModeQueryStates
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
