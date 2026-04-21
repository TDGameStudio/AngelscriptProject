/**
 * Enhanced Input example: binding input actions on a Pawn.
 *
 * This example shows how to bind Input Actions to script functions
 * using UEnhancedInputComponent::BindAction with a delegate.
 * The Pawn retrieves its own InputComponent via the newly bound
 * GetInputComponent() accessor.
 */
class AExampleEIPawn : APawn
{
	UPROPERTY(Category = "Enhanced Input")
	UInputAction MoveAction;

	UPROPERTY(Category = "Enhanced Input")
	UInputAction JumpAction;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UEnhancedInputComponent EIC = Cast<UEnhancedInputComponent>(GetInputComponent());
		if (EIC == nullptr)
			return;

		if (MoveAction != nullptr)
		{
			FEnhancedInputActionHandlerDynamicSignature MoveDelegate;
			MoveDelegate.BindUFunction(this, n"OnMove");
			EIC.BindAction(MoveAction, ETriggerEvent::Triggered, MoveDelegate);
		}

		if (JumpAction != nullptr)
		{
			FEnhancedInputActionHandlerDynamicSignature JumpStartedDelegate;
			JumpStartedDelegate.BindUFunction(this, n"OnJumpStarted");
			EIC.BindAction(JumpAction, ETriggerEvent::Started, JumpStartedDelegate);

			FEnhancedInputActionHandlerDynamicSignature JumpCompletedDelegate;
			JumpCompletedDelegate.BindUFunction(this, n"OnJumpCompleted");
			EIC.BindAction(JumpAction, ETriggerEvent::Completed, JumpCompletedDelegate);
		}
	}

	UFUNCTION()
	void OnMove(FInputActionValue ActionValue, float ElapsedTime, FInputActionInstance ActionInstance, UInputAction SourceAction)
	{
		FVector2D MoveInput = ActionValue.GetAxis2D();
		AddMovementInput(FVector(MoveInput.X, MoveInput.Y, 0.0), 1.0);
	}

	UFUNCTION()
	void OnJumpStarted(FInputActionValue ActionValue, float ElapsedTime, FInputActionInstance ActionInstance, UInputAction SourceAction)
	{
		Print("Jump started!", Duration=3.0);
	}

	UFUNCTION()
	void OnJumpCompleted(FInputActionValue ActionValue, float ElapsedTime, FInputActionInstance ActionInstance, UInputAction SourceAction)
	{
		Print("Jump completed!", Duration=3.0);
	}
};
