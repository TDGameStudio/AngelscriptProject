// Theme: Language.Syntax.EdgeCases. Positive: gamepad face/stick bind surface on a pawn.
// C++: AngelscriptCoverageInputTests.cpp::GamepadInput
// sha256=22548c58bdeaa0b578ffbe62da11370dc04d5a329b3467f13f2519cbba8fd7aa; lines 788-937.
// Oracle: AGamepadInputPawn compiles; stick UPROPERTY defaults are 0.0f; stick handlers write the axis.
// Extra: OnLeftStickX(0) empty; OnRightStickY(-1) signed boundary. Sticks are independently writable.
// DefaultSafe. BindPressedKey uses n"" handler names; pawn owns stick storage.

UCLASS()
class AGamepadInputPawn : APawn
{
	UPROPERTY()
	float LeftStickXValue = 0.0f;

	UPROPERTY()
	float LeftStickYValue = 0.0f;

	UPROPERTY()
	float RightStickXValue = 0.0f;

	UPROPERTY()
	float RightStickYValue = 0.0f;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_FaceButton_Bottom, n"OnFaceBottom");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_FaceButton_Right, n"OnFaceRight");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_FaceButton_Left, n"OnFaceLeft");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_FaceButton_Top, n"OnFaceTop");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_LeftShoulder, n"OnLeftShoulder");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_RightShoulder, n"OnRightShoulder");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_LeftTrigger, n"OnLeftTrigger");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_RightTrigger, n"OnRightTrigger");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_DPad_Up, n"OnDPadUp");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_DPad_Down, n"OnDPadDown");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_DPad_Left, n"OnDPadLeft");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_DPad_Right, n"OnDPadRight");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_Special_Left, n"OnSpecialLeft");
		BindPressedKey(PlayerInputComponent, EKeys::Gamepad_Special_Right, n"OnSpecialRight");
		BindAxisName(PlayerInputComponent, n"Gamepad_LeftX", n"OnLeftStickX");
		BindAxisName(PlayerInputComponent, n"Gamepad_LeftY", n"OnLeftStickY");
		BindAxisName(PlayerInputComponent, n"Gamepad_RightX", n"OnRightStickX");
		BindAxisName(PlayerInputComponent, n"Gamepad_RightY", n"OnRightStickY");
	}

	UFUNCTION()
	void BindPressedKey(UInputComponent PlayerInputComponent, FKey Key, FName FunctionName)
	{
		FInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindKey(Key, EInputEvent::IE_Pressed, Delegate);
	}

	UFUNCTION()
	void BindAxisName(UInputComponent PlayerInputComponent, FName AxisName, FName FunctionName)
	{
		FInputAxisHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindAxis(AxisName, Delegate);
	}

	UFUNCTION()
	void OnFaceBottom(FKey Key)
	{
	}

	UFUNCTION()
	void OnFaceRight(FKey Key)
	{
	}

	UFUNCTION()
	void OnFaceLeft(FKey Key)
	{
	}

	UFUNCTION()
	void OnFaceTop(FKey Key)
	{
	}

	UFUNCTION()
	void OnLeftShoulder(FKey Key)
	{
	}

	UFUNCTION()
	void OnRightShoulder(FKey Key)
	{
	}

	UFUNCTION()
	void OnLeftTrigger(FKey Key)
	{
	}

	UFUNCTION()
	void OnRightTrigger(FKey Key)
	{
	}

	UFUNCTION()
	void OnDPadUp(FKey Key)
	{
	}

	UFUNCTION()
	void OnDPadDown(FKey Key)
	{
	}

	UFUNCTION()
	void OnDPadLeft(FKey Key)
	{
	}

	UFUNCTION()
	void OnDPadRight(FKey Key)
	{
	}

	UFUNCTION()
	void OnSpecialLeft(FKey Key)
	{
	}

	UFUNCTION()
	void OnSpecialRight(FKey Key)
	{
	}

	UFUNCTION()
	void OnLeftStickX(float32 Value)
	{
		LeftStickXValue = Value;
	}

	UFUNCTION()
	void OnLeftStickY(float32 Value)
	{
		LeftStickYValue = Value;
	}

	UFUNCTION()
	void OnRightStickX(float32 Value)
	{
		RightStickXValue = Value;
	}

	UFUNCTION()
	void OnRightStickY(float32 Value)
	{
		RightStickYValue = Value;
	}
}

bool Observe_GamepadInput_DefaultEmpty(AGamepadInputPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_GamepadInput setup: required Pawn is null");
	}
	return Pawn.LeftStickXValue == 0.0f && Pawn.LeftStickYValue == 0.0f && Pawn.RightStickXValue == 0.0f && Pawn.RightStickYValue == 0.0f;
}

bool Observe_GamepadInput_StickBoundaryIndependent(AGamepadInputPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_GamepadInput setup: required Pawn is null");
	}
	Pawn.OnLeftStickX(0.0f);
	Pawn.OnLeftStickY(1.0f);
	Pawn.OnRightStickX(0.5f);
	Pawn.OnRightStickY(-1.0f);
	return Pawn.LeftStickXValue == 0.0f && Pawn.LeftStickYValue == 1.0f && Pawn.RightStickXValue == 0.5f && Pawn.RightStickYValue == -1.0f;
}
