/**
 * @version v1
 * @summary The gamepad bind surface on a pawn: fourteen pressed-key bindings and four stick-axis bindings. The stick handlers store their axis values, so the observers confirm the defaults and that each stick writes independently.
 * @topic Language
 */
/**
 * @version root
 * @summary The gamepad bind surface on a pawn: fourteen pressed-key bindings and four stick-axis bindings. The stick handlers store their axis values, so the observers confirm the defaults and that each stick writes independently.
 * @topic Baseline
 */
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

	/**
	 * Binds the face, shoulder, trigger, D-pad and special keys plus all four sticks.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; every gamepad control is bound
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
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

	/**
	 * Binds one pressed key through a dynamic delegate.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the component, key and handler name
	 * @Return nothing; the key is bound
	 * @Param PlayerInputComponent the component receiving the binding
	 * @Param Key the key to bind
	 * @Param FunctionName the handler's name
	 */
	UFUNCTION()
	void BindPressedKey(UInputComponent PlayerInputComponent, FKey Key, FName FunctionName)
	{
		FInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindKey(Key, EInputEvent::IE_Pressed, Delegate);
	}

	/**
	 * Binds one axis name through a dynamic delegate.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the component, axis name and handler name
	 * @Return nothing; the axis is bound
	 * @Param PlayerInputComponent the component receiving the binding
	 * @Param AxisName the axis to bind
	 * @Param FunctionName the handler's name
	 */
	UFUNCTION()
	void BindAxisName(UInputComponent PlayerInputComponent, FName AxisName, FName FunctionName)
	{
		FInputAxisHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindAxis(AxisName, Delegate);
	}

	/**
	 * Handler for the bottom face button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnFaceBottom(FKey Key)
	{
	}

	/**
	 * Handler for the right face button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnFaceRight(FKey Key)
	{
	}

	/**
	 * Handler for the left face button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnFaceLeft(FKey Key)
	{
	}

	/**
	 * Handler for the top face button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnFaceTop(FKey Key)
	{
	}

	/**
	 * Handler for the left shoulder button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnLeftShoulder(FKey Key)
	{
	}

	/**
	 * Handler for the right shoulder button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnRightShoulder(FKey Key)
	{
	}

	/**
	 * Handler for the left trigger.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnLeftTrigger(FKey Key)
	{
	}

	/**
	 * Handler for the right trigger.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnRightTrigger(FKey Key)
	{
	}

	/**
	 * Handler for the D-pad up button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnDPadUp(FKey Key)
	{
	}

	/**
	 * Handler for the D-pad down button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnDPadDown(FKey Key)
	{
	}

	/**
	 * Handler for the D-pad left button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnDPadLeft(FKey Key)
	{
	}

	/**
	 * Handler for the D-pad right button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnDPadRight(FKey Key)
	{
	}

	/**
	 * Handler for the special left button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnSpecialLeft(FKey Key)
	{
	}

	/**
	 * Handler for the special right button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnSpecialRight(FKey Key)
	{
	}

	/**
	 * Stores the left stick X axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; LeftStickXValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnLeftStickX(float32 Value)
	{
		LeftStickXValue = Value;
	}

	/**
	 * Stores the left stick Y axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; LeftStickYValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnLeftStickY(float32 Value)
	{
		LeftStickYValue = Value;
	}

	/**
	 * Stores the right stick X axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; RightStickXValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnRightStickX(float32 Value)
	{
		RightStickXValue = Value;
	}

	/**
	 * Stores the right stick Y axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; RightStickYValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnRightStickY(float32 Value)
	{
		RightStickYValue = Value;
	}

	/**
	 * Observe that all four stick values start at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed pawn
	 * @Return true when all four stick values are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool GamepadInputStickDefaultsEmpty()
	{
		if (!Math::IsNearlyEqual(LeftStickXValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(LeftStickYValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(RightStickXValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(RightStickYValue, 0.0);
	}

	/**
	 * Observe that each stick writes its own axis independently.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four stick handlers with distinct axis values
	 * @Return true when every stick reads back its written value
	 * @Boundary signed axis values
	 */
	UFUNCTION()
	bool GamepadInputSticksWriteIndependently()
	{
		OnLeftStickX(float32(0.0));
		OnLeftStickY(float32(1.0));
		OnRightStickX(float32(0.5));
		OnRightStickY(float32(-1.0));

		if (!Math::IsNearlyEqual(LeftStickXValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(LeftStickYValue, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(RightStickXValue, 0.5))
		{
			return false;
		}

		return Math::IsNearlyEqual(RightStickYValue, -1.0);
	}
}
/** @end */
