/**
 * A pawn's full mouse surface: seven button bindings plus two named axes whose
 * handlers store the incoming axis values.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.MouseInput
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.MouseInput
 * @Provenance C++: AngelscriptCoverageInputTests.cpp::MouseInput
 * @Provenance sha256=054b4d94f2861d35bb3f0a95ddc8c542617ec5f5c0360bb13fb294f7eba328d9; lines 677-764.
 * @Provenance Oracle: AMouseInputPawn compiles; MouseXValue/MouseYValue default 0.0f; OnMouseX/OnMouseY write the axis.
 * @Provenance Extra: OnMouseX(0) keeps empty 0; OnMouseY(-1) is the signed boundary.
 * @Provenance DefaultSafe. BindPressedKey uses n"" handler names; pawn owns axis storage.
 */

UCLASS()
class AMouseInputPawn : APawn
{
	UPROPERTY()
	float MouseXValue = 0.0f;

	UPROPERTY()
	float MouseYValue = 0.0f;

	/**
	 * Binds the seven mouse buttons and two axes.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; nine bindings are registered
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
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

	/**
	 * Binds one mouse button on press.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the component, key and handler name
	 * @Return nothing; the key is bound
	 * @Param PlayerInputComponent the component receiving the binding
	 * @Param Key the key to bind
	 * @Param FunctionName the handler's function name
	 */
	UFUNCTION()
	void BindPressedKey(UInputComponent PlayerInputComponent, FKey Key, FName FunctionName)
	{
		FInputActionHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindKey(Key, EInputEvent::IE_Pressed, Delegate);
	}

	/**
	 * Binds one named axis to a handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the component, axis name and handler name
	 * @Return nothing; the axis is bound
	 * @Param PlayerInputComponent the component receiving the binding
	 * @Param AxisName the axis to bind
	 * @Param FunctionName the handler's function name
	 */
	UFUNCTION()
	void BindAxisName(UInputComponent PlayerInputComponent, FName AxisName, FName FunctionName)
	{
		FInputAxisHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, FunctionName);
		PlayerInputComponent.BindAxis(AxisName, Delegate);
	}

	/**
	 * Handles the left mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnLeftMouse(FKey Key)
	{
	}

	/**
	 * Handles the right mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnRightMouse(FKey Key)
	{
	}

	/**
	 * Handles the middle mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnMiddleMouse(FKey Key)
	{
	}

	/**
	 * Handles the first thumb mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnThumbMouse(FKey Key)
	{
	}

	/**
	 * Handles the second thumb mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnThumbMouse2(FKey Key)
	{
	}

	/**
	 * Handles scroll up.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnScrollUp(FKey Key)
	{
	}

	/**
	 * Handles scroll down.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnScrollDown(FKey Key)
	{
	}

	/**
	 * Stores the horizontal mouse axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; MouseXValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnMouseX(float32 Value)
	{
		MouseXValue = Value;
	}

	/**
	 * Stores the vertical mouse axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; MouseYValue is set
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnMouseY(float32 Value)
	{
		MouseYValue = Value;
	}

	/**
	 * Observe that a locally constructed pawn leaves both axes at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed pawn
	 * @Return true when both axis values are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool MouseInputDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(MouseXValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(MouseYValue, 0.0);
	}

	/**
	 * Observe the axis handlers storing zero and a signed boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs OnMouseX(0) and OnMouseY(-1)
	 * @Return true when X stays 0 and Y holds -1
	 * @Boundary signed axis value
	 */
	UFUNCTION()
	bool MouseInputAxisBoundary()
	{
		OnMouseX(float32(0.0));
		OnMouseY(float32(-1.0));

		if (!Math::IsNearlyEqual(MouseXValue, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(MouseYValue, -1.0);
	}
}
