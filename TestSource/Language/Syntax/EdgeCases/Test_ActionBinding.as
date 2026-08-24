// Theme: Language.Syntax.EdgeCases. Positive UCLASS compiles BindAction handlers.
// C++: AngelscriptCoverageInputTests.cpp::ActionBinding CompileScriptModule.
// sha256=8b8c57181b635cb787cebfe1280a35a04b1ee82f1792ab198c2c90e15b7a6ae9; lines 121-181.
// Oracle: AActionBindingPawn class compiles. Extra: default counts stay 0 until input fires.
// DefaultSafe. BindUFunction uses n"" handler names; IE_Pressed/Released/Repeat/DoubleClick.

UCLASS()
class AActionBindingPawn : APawn
{
	UPROPERTY()
	int JumpPressedCount = 0;

	UPROPERTY()
	int JumpReleasedCount = 0;

	UPROPERTY()
	int FireRepeatCount = 0;

	UPROPERTY()
	int SelectDoubleClickCount = 0;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		FInputActionHandlerDynamicSignature JumpPressedDelegate;
		JumpPressedDelegate.BindUFunction(this, n"OnJumpPressed");
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Pressed, JumpPressedDelegate);

		FInputActionHandlerDynamicSignature JumpReleasedDelegate;
		JumpReleasedDelegate.BindUFunction(this, n"OnJumpReleased");
		PlayerInputComponent.BindAction(n"Jump", EInputEvent::IE_Released, JumpReleasedDelegate);

		FInputActionHandlerDynamicSignature FireRepeatDelegate;
		FireRepeatDelegate.BindUFunction(this, n"OnFireRepeat");
		PlayerInputComponent.BindAction(n"Fire", EInputEvent::IE_Repeat, FireRepeatDelegate);

		FInputActionHandlerDynamicSignature SelectDoubleClickDelegate;
		SelectDoubleClickDelegate.BindUFunction(this, n"OnSelectDoubleClick");
		PlayerInputComponent.BindAction(n"Select", EInputEvent::IE_DoubleClick, SelectDoubleClickDelegate);
	}

	UFUNCTION()
	void OnJumpPressed(FKey Key)
	{
		JumpPressedCount++;
	}

	UFUNCTION()
	void OnJumpReleased(FKey Key)
	{
		JumpReleasedCount++;
	}

	UFUNCTION()
	void OnFireRepeat(FKey Key)
	{
		FireRepeatCount++;
	}

	UFUNCTION()
	void OnSelectDoubleClick(FKey Key)
	{
		SelectDoubleClickCount++;
	}
}

bool Observe_ActionBinding_DefaultEmpty(AActionBindingPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_ActionBinding setup: required Pawn is null");
	}
	return Pawn.JumpPressedCount == 0 && Pawn.JumpReleasedCount == 0 && Pawn.FireRepeatCount == 0 && Pawn.SelectDoubleClickCount == 0;
}
