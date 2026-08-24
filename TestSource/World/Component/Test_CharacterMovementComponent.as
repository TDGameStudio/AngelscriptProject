// Theme: World.Component. WorldStory: MaxWalkSpeed / JumpZVelocity / GravityScale.
// C++: AngelscriptCoverageSpecialComponentTests.cpp::CharacterMovementComponent
// sha256=f6d0690c347d1421c8690d3140d59d59d6deef120163a8d7fdc46b53b4e94a91; lines 149-196.
// Oracle NewMaxWalkSpeed=800, NewJumpVelocity=500, NewGravityScale=1.5.
// Extra: local construct all floats 0, MovementComp null. FixtureIsolated.

UCLASS()
class ACoverageSpecialCharacterMovementActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCharacterMovementComponent MovementComp;

	UPROPERTY()
	float InitialMaxWalkSpeed = 0.0f;

	UPROPERTY()
	float NewMaxWalkSpeed = 0.0f;

	UPROPERTY()
	float InitialJumpVelocity = 0.0f;

	UPROPERTY()
	float NewJumpVelocity = 0.0f;

	UPROPERTY()
	float InitialGravityScale = 0.0f;

	UPROPERTY()
	float NewGravityScale = 0.0f;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (MovementComp != nullptr)
		{
			// Read initial values
			InitialMaxWalkSpeed = MovementComp.MaxWalkSpeed;
			InitialJumpVelocity = MovementComp.JumpZVelocity;
			InitialGravityScale = MovementComp.GravityScale;

			// Set new values
			MovementComp.MaxWalkSpeed = 800.0f;
			MovementComp.JumpZVelocity = 500.0f;
			MovementComp.GravityScale = 1.5f;

			// Read back
			NewMaxWalkSpeed = MovementComp.MaxWalkSpeed;
			NewJumpVelocity = MovementComp.JumpZVelocity;
			NewGravityScale = MovementComp.GravityScale;
		}
	}
}

bool Observe_CharacterMovement_DefaultEmpty(ACoverageSpecialCharacterMovementActor Actor)
{
	if (Actor is null)
	{
		throw("Test_CharacterMovementComponent setup: required Actor is null");
	}
	return Actor.NewMaxWalkSpeed == 0.0f
		&& Actor.NewJumpVelocity == 0.0f
		&& Actor.NewGravityScale == 0.0f
		&& Actor.MovementComp == nullptr;
}

bool Observe_CharacterMovement_CopyIndependence(ACoverageSpecialCharacterMovementActor First, ACoverageSpecialCharacterMovementActor Second)
{
	if (First is null)
	{
		throw("Test_CharacterMovementComponent setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_CharacterMovementComponent setup: required Second is null");
	}
	First.NewMaxWalkSpeed = 800.0f;
	First.NewJumpVelocity = 500.0f;
	return First.NewMaxWalkSpeed == 800.0f
		&& First.NewJumpVelocity == 500.0f
		&& Second.NewMaxWalkSpeed == 0.0f
		&& Second.NewJumpVelocity == 0.0f;
}
