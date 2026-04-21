/**
 * Enhanced Input example: PlayerController with full BindAction workflow.
 *
 * PlayerController is the most common place to handle input because it
 * naturally owns the input subsystem for the local player.
 * This example gets the UEnhancedInputComponent from the controlled Pawn,
 * then binds actions using FEnhancedInputActionHandlerDynamicSignature delegates.
 */
class AExampleEIPlayerController : APlayerController
{
	UPROPERTY(Category = "Enhanced Input")
	UInputMappingContext DefaultMappingContext;

	UPROPERTY(Category = "Enhanced Input")
	UInputAction LookAction;

	UPROPERTY(Category = "Enhanced Input")
	UInputAction InteractAction;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		APawn ControlledPawn = GetPawn();
		if (ControlledPawn == nullptr)
			return;

		UEnhancedInputComponent EIC = Cast<UEnhancedInputComponent>(ControlledPawn.GetInputComponent());
		if (EIC == nullptr)
			return;

		if (LookAction != nullptr)
		{
			FEnhancedInputActionHandlerDynamicSignature LookDelegate;
			LookDelegate.BindUFunction(this, n"OnLook");
			EIC.BindAction(LookAction, ETriggerEvent::Triggered, LookDelegate);
		}

		if (InteractAction != nullptr)
		{
			FEnhancedInputActionHandlerDynamicSignature InteractDelegate;
			InteractDelegate.BindUFunction(this, n"OnInteract");
			EIC.BindAction(InteractAction, ETriggerEvent::Started, InteractDelegate);
		}
	}

	UFUNCTION()
	void OnLook(FInputActionValue ActionValue, float ElapsedTime, FInputActionInstance ActionInstance, UInputAction SourceAction)
	{
		Print("Look input received", Duration=0.0);
	}

	UFUNCTION()
	void OnInteract(FInputActionValue ActionValue, float ElapsedTime, FInputActionInstance ActionInstance, UInputAction SourceAction)
	{
		Print("Interact pressed!", Duration=3.0);
	}
};
