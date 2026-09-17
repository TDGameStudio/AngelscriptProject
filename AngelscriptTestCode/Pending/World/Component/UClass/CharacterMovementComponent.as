/**
 * @version v1
 * @summary An actor whose UCharacterMovementComponent BeginPlay writes and reads MaxWalkSpeed, JumpZVelocity and GravityScale. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary An actor whose UCharacterMovementComponent BeginPlay writes and reads MaxWalkSpeed, JumpZVelocity and GravityScale. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay reads all three movement values, writes new ones, then
	 * reads them back.
	 *
	 * @Kind WorldStory
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs a default-attached UCharacterMovementComponent
	 * @Return NewMaxWalkSpeed == 800, NewJumpVelocity == 500, NewGravityScale == 1.5
	 */
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

	/**
	 * Observe that a locally constructed actor has all three new values at zero.
	 *
	 * @Kind Observe
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all three new values are 0 and MovementComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (NewMaxWalkSpeed != 0.0f)
		{
			return false;
		}
		if (NewJumpVelocity != 0.0f)
		{
			return false;
		}
		if (NewGravityScale != 0.0f)
		{
			return false;
		}
		return MovementComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.CharacterMovementComponent
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds 800/500 and the other stays at zero
	 * @Param Second the other actor, expected to stay at zero
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageSpecialCharacterMovementActor Second)
	{
		if (Second is null)
		{
			throw("CharacterMovementComponent setup: required Second is null");
		}
		NewMaxWalkSpeed = 800.0f;
		NewJumpVelocity = 500.0f;

		if (NewMaxWalkSpeed != 800.0f)
		{
			return false;
		}
		if (NewJumpVelocity != 500.0f)
		{
			return false;
		}
		if (Second.NewMaxWalkSpeed != 0.0f)
		{
			return false;
		}
		return Second.NewJumpVelocity == 0.0f;
	}
}
/** @end */
