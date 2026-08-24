// Theme: Language.Syntax.EdgeCases. Positive UCLASS compiles BindKey on EKeys.
// C++: AngelscriptCoverageInputTests.cpp::KeyDirectBinding CompileScriptModule.
// sha256=96792c2a13f7036e3adbb5515eecd4e93664de456b5fab11b6cfa920f4a3c813; lines 296-356.
// Oracle: AKeyDirectBindingPawn class compiles. Extra: key counts default 0.
// DefaultSafe. SpaceBar/W/LeftMouseButton/RightMouseButton with IE_Pressed/Released.

UCLASS()
class AKeyDirectBindingPawn : APawn
{
	UPROPERTY()
	int SpaceKeyPressedCount = 0;

	UPROPERTY()
	int WKeyPressedCount = 0;

	UPROPERTY()
	int LeftMousePressedCount = 0;

	UPROPERTY()
	int RightMouseReleasedCount = 0;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		FInputActionHandlerDynamicSignature SpacePressedDelegate;
		SpacePressedDelegate.BindUFunction(this, n"OnSpacePressed");
		PlayerInputComponent.BindKey(EKeys::SpaceBar, EInputEvent::IE_Pressed, SpacePressedDelegate);

		FInputActionHandlerDynamicSignature WPressedDelegate;
		WPressedDelegate.BindUFunction(this, n"OnWPressed");
		PlayerInputComponent.BindKey(EKeys::W, EInputEvent::IE_Pressed, WPressedDelegate);

		FInputActionHandlerDynamicSignature LeftMousePressedDelegate;
		LeftMousePressedDelegate.BindUFunction(this, n"OnLeftMousePressed");
		PlayerInputComponent.BindKey(EKeys::LeftMouseButton, EInputEvent::IE_Pressed, LeftMousePressedDelegate);

		FInputActionHandlerDynamicSignature RightMouseReleasedDelegate;
		RightMouseReleasedDelegate.BindUFunction(this, n"OnRightMouseReleased");
		PlayerInputComponent.BindKey(EKeys::RightMouseButton, EInputEvent::IE_Released, RightMouseReleasedDelegate);
	}

	UFUNCTION()
	void OnSpacePressed(FKey Key)
	{
		SpaceKeyPressedCount++;
	}

	UFUNCTION()
	void OnWPressed(FKey Key)
	{
		WKeyPressedCount++;
	}

	UFUNCTION()
	void OnLeftMousePressed(FKey Key)
	{
		LeftMousePressedCount++;
	}

	UFUNCTION()
	void OnRightMouseReleased(FKey Key)
	{
		RightMouseReleasedCount++;
	}
}

bool Observe_KeyDirectBinding_DefaultEmpty(AKeyDirectBindingPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_KeyDirectBinding setup: required Pawn is null");
	}
	return Pawn.SpaceKeyPressedCount == 0 && Pawn.WKeyPressedCount == 0 && Pawn.LeftMousePressedCount == 0 && Pawn.RightMouseReleasedCount == 0;
}
