// Theme: World.Actor. WorldStory: UCharacterMovementComponent MovementMode round-trip.
// C++: AngelscriptCoveragePhysicsTests.cpp::CharacterMovementModeQueryStates
// Oracle: Run returns 1; VerifyByPath Walking/Falling/Swimming/FlyingStateMatched true.
// Extra: all matched flags default false; Run(nullptr) returns 0 (null movement).
// C++ spawns the native character and instantiates the harness. FixtureIsolated.

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

		return WalkingStateMatched
			&& FallingStateMatched
			&& SwimmingStateMatched
			&& FlyingStateMatched
			&& CustomStateMatched ? 1 : 0;
	}
}
