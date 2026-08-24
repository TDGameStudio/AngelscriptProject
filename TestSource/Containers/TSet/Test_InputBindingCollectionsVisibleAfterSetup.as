// Theme: Containers.TSet. Positive: BindAction / BindAxis / BindKey on UInputComponent.
// C++: AngelscriptCoverageInputTests.cpp::InputBindingCollectionsVisibleAfterSetup
// CompileScriptModule + SetupInput invoker. Oracle: SetupCallCount=1, 2 action / 2 axis / 2 key.
// Extra: default SetupCallCount=0; second pawn stays 0 after the first SetupInput.
// DefaultSafe. Input component is runner-owned.

UCLASS()
class AInputBindingVisibilityPawn : APawn
{
	UPROPERTY()
	int SetupCallCount = 0;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		SetupCallCount++;

		FInputActionHandlerDynamicSignature JumpPressedDelegate;
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Pressed, JumpPressedDelegate);

		FInputActionHandlerDynamicSignature JumpReleasedDelegate;
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Released, JumpReleasedDelegate);

		FInputAxisHandlerDynamicSignature MoveForwardDelegate;
		PlayerInputComponent.BindAxis(n"MoveForward", MoveForwardDelegate);

		FInputAxisHandlerDynamicSignature TurnDelegate;
		PlayerInputComponent.BindAxis(n"Turn", TurnDelegate);

		FInputActionHandlerDynamicSignature SpacePressedDelegate;
		PlayerInputComponent.BindKey(EKeys::SpaceBar, EInputEvent::IE_Pressed, SpacePressedDelegate);

		FInputActionHandlerDynamicSignature LeftMouseReleasedDelegate;
		PlayerInputComponent.BindKey(EKeys::LeftMouseButton, EInputEvent::IE_Released, LeftMouseReleasedDelegate);
	}
}

int Observe_SetupInput_DefaultCount(AInputBindingVisibilityPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_InputBindingCollectionsVisibleAfterSetup setup: required Pawn is null");
	}
	return Pawn.SetupCallCount;
}

int Observe_SetupInput_Nominal(UInputComponent PlayerInputComponent, AInputBindingVisibilityPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_InputBindingCollectionsVisibleAfterSetup setup: required Pawn is null");
	}
	if (PlayerInputComponent == nullptr)
	{
		throw("TS-CONT-0046 setup: required input component is null");
	}
	Pawn.SetupInput(PlayerInputComponent);
	return Pawn.SetupCallCount;
}

bool Observe_SetupInput_CopyIndependence(UInputComponent PlayerInputComponent, AInputBindingVisibilityPawn First, AInputBindingVisibilityPawn Second)
{
	if (First is null)
	{
		throw("Test_InputBindingCollectionsVisibleAfterSetup setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_InputBindingCollectionsVisibleAfterSetup setup: required Second is null");
	}
	if (PlayerInputComponent == nullptr)
	{
		throw("TS-CONT-0046 setup: required input component is null");
	}
	First.SetupInput(PlayerInputComponent);
	return First.SetupCallCount == 1 && Second.SetupCallCount == 0;
}
