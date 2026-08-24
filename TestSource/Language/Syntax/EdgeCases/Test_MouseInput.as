// Theme: Language.Syntax.EdgeCases. Positive: mouse key/axis bind surface on a pawn.
// C++: AngelscriptCoverageInputTests.cpp::MouseInput
// sha256=054b4d94f2861d35bb3f0a95ddc8c542617ec5f5c0360bb13fb294f7eba328d9; lines 677-764.
// Oracle: AMouseInputPawn compiles; MouseXValue/MouseYValue default 0.0f; OnMouseX/OnMouseY write the axis.
// Extra: OnMouseX(0) keeps empty 0; OnMouseY(-1) is the signed boundary.
// DefaultSafe. BindPressedKey uses n"" handler names; pawn owns axis storage.

UCLASS()
class AMouseInputPawn : APawn
{
	UPROPERTY()
	float MouseXValue = 0.0f;

	UPROPERTY()
	float MouseYValue = 0.0f;

	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		BindPressedKey(PlayerInputComponent, EKeys::LeftMouseButton, n"OnLeftMouse");
		BindPressedKey(PlayerInputComponent, EKeys::RightMouseButton, n"OnRightMouse");
		BindPressedKey(PlayerInputComponent, EKeys::MiddleMouseButton, n"OnMiddleMouse");
		BindPressedKey(PlayerInputComponent, EKeys::ThumbMouseButton, n"OnThumbMouse");
		BindPressedKey(PlayerInputComponent, EKeys::ThumbMouseButton2, n"OnThumbMouse2");
		BindPressedKey(PlayerInputComponent, EKeys::MouseScrollUp, n"OnScrollUp");
		BindPressedKey(PlayerInputComponent, EKeys::MouseScrollDown, n"OnScrollDown");
		BindAxisName(PlayerInputComponent, n"MouseX", n"OnMouseX");
		BindAxisName(PlayerInputComponent, n"MouseY", n"OnMouseY");
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
	void OnLeftMouse(FKey Key)
	{
	}

	UFUNCTION()
	void OnRightMouse(FKey Key)
	{
	}

	UFUNCTION()
	void OnMiddleMouse(FKey Key)
	{
	}

	UFUNCTION()
	void OnThumbMouse(FKey Key)
	{
	}

	UFUNCTION()
	void OnThumbMouse2(FKey Key)
	{
	}

	UFUNCTION()
	void OnScrollUp(FKey Key)
	{
	}

	UFUNCTION()
	void OnScrollDown(FKey Key)
	{
	}

	UFUNCTION()
	void OnMouseX(float32 Value)
	{
		MouseXValue = Value;
	}

	UFUNCTION()
	void OnMouseY(float32 Value)
	{
		MouseYValue = Value;
	}
}

bool Observe_MouseInput_DefaultEmpty(AMouseInputPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_MouseInput setup: required Pawn is null");
	}
	return Pawn.MouseXValue == 0.0f && Pawn.MouseYValue == 0.0f;
}

bool Observe_MouseInput_AxisBoundary(AMouseInputPawn Pawn)
{
	if (Pawn is null)
	{
		throw("Test_MouseInput setup: required Pawn is null");
	}
	Pawn.OnMouseX(0.0f);
	Pawn.OnMouseY(-1.0f);
	return Pawn.MouseXValue == 0.0f && Pawn.MouseYValue == -1.0f;
}
