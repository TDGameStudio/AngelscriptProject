// Theme: Language.Syntax.EdgeCases. Positive UCLASS compiles BindAxis handlers.
// C++: AngelscriptCoverageInputTests.cpp::AxisBinding CompileScriptModule.
// sha256=edc815051c4d5d134f5556ea689755108c82910e2c320e6c92be770bbef9aa90; lines 205-272.
// Oracle: AAxisBindingPawn class compiles. Extra: axis values 0 and AxisCallCount 0.
// DefaultSafe. Handlers take float32; n"MoveForward"/MoveRight/LookUp/Turn.

UCLASS()
class AAxisBindingPawn : APawn
{
	UPROPERTY()
	float MoveForwardValue = 0.0f;

	UPROPERTY()
	float MoveRightValue = 0.0f;

	UPROPERTY()
	float LookUpValue = 0.0f;

	UPROPERTY()
	float TurnValue = 0.0f;

	UPROPERTY()
	int AxisCallCount = 0;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		FInputAxisHandlerDynamicSignature MoveForwardDelegate;
		MoveForwardDelegate.BindUFunction(this, n"OnMoveForward");
		PlayerInputComponent.BindAxis(n"MoveForward", MoveForwardDelegate);

		FInputAxisHandlerDynamicSignature MoveRightDelegate;
		MoveRightDelegate.BindUFunction(this, n"OnMoveRight");
		PlayerInputComponent.BindAxis(n"MoveRight", MoveRightDelegate);

		FInputAxisHandlerDynamicSignature LookUpDelegate;
		LookUpDelegate.BindUFunction(this, n"OnLookUp");
		PlayerInputComponent.BindAxis(n"LookUp", LookUpDelegate);

		FInputAxisHandlerDynamicSignature TurnDelegate;
		TurnDelegate.BindUFunction(this, n"OnTurn");
		PlayerInputComponent.BindAxis(n"Turn", TurnDelegate);
	}

	UFUNCTION()
	void OnMoveForward(float32 Value)
	{
		MoveForwardValue = Value;
		AxisCallCount++;
	}

	UFUNCTION()
	void OnMoveRight(float32 Value)
	{
		MoveRightValue = Value;
		AxisCallCount++;
	}

	UFUNCTION()
	void OnLookUp(float32 Value)
	{
		LookUpValue = Value;
		AxisCallCount++;
	}

	UFUNCTION()
	void OnTurn(float32 Value)
	{
		TurnValue = Value;
		AxisCallCount++;
	}
}

bool Observe_AxisBinding_DefaultEmpty(AAxisBindingPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_AxisBinding setup: required Pawn is null");
	}
	return Math::IsNearlyEqual(Pawn.MoveForwardValue, 0.0) && Math::IsNearlyEqual(Pawn.MoveRightValue, 0.0) && Math::IsNearlyEqual(Pawn.LookUpValue, 0.0) && Math::IsNearlyEqual(Pawn.TurnValue, 0.0) && Pawn.AxisCallCount == 0;
}

bool Observe_AxisBinding_HandlerBoundary(AAxisBindingPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_AxisBinding setup: required Pawn is null");
	}
	Pawn.OnMoveForward(float32(1.0));
	Pawn.OnMoveRight(float32(-1.0));
	return Math::IsNearlyEqual(Pawn.MoveForwardValue, 1.0) && Math::IsNearlyEqual(Pawn.MoveRightValue, -1.0) && Pawn.AxisCallCount == 2;
}
