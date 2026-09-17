/**
 * @version v1
 * @summary A pawn binding fifteen keyboard keys through BindKey, one handler per key covering WASD, modifiers, navigation, digits and function keys. The class must compile; the handlers are deliberately empty.
 * @topic Language
 */
/**
 * @version root
 * @summary A pawn binding fifteen keyboard keys through BindKey, one handler per key covering WASD, modifiers, navigation, digits and function keys. The class must compile; the handlers are deliberately empty.
 * @topic Baseline
 */
UCLASS()
class AKeyboardInputPawn : APawn
{
	/**
	 * Binds every keyboard key to its handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; fifteen keys are bound
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
	UFUNCTION()
	void SetupInput(UInputComponent PlayerInputComponent)
	{
		BindPressedKey(PlayerInputComponent, EKeys::W, n"OnW");
		BindPressedKey(PlayerInputComponent, EKeys::A, n"OnA");
		BindPressedKey(PlayerInputComponent, EKeys::S, n"OnS");
		BindPressedKey(PlayerInputComponent, EKeys::D, n"OnD");

		BindPressedKey(PlayerInputComponent, EKeys::SpaceBar, n"OnSpace");
		BindPressedKey(PlayerInputComponent, EKeys::LeftShift, n"OnShift");
		BindPressedKey(PlayerInputComponent, EKeys::LeftControl, n"OnCtrl");
		BindPressedKey(PlayerInputComponent, EKeys::LeftAlt, n"OnAlt");

		BindPressedKey(PlayerInputComponent, EKeys::Tab, n"OnTab");
		BindPressedKey(PlayerInputComponent, EKeys::Escape, n"OnEscape");
		BindPressedKey(PlayerInputComponent, EKeys::Enter, n"OnEnter");

		BindPressedKey(PlayerInputComponent, EKeys::One, n"OnOne");
		BindPressedKey(PlayerInputComponent, EKeys::Two, n"OnTwo");
		BindPressedKey(PlayerInputComponent, EKeys::Nine, n"OnNine");

		BindPressedKey(PlayerInputComponent, EKeys::F1, n"OnF1");
		BindPressedKey(PlayerInputComponent, EKeys::F12, n"OnF12");
	}

	/**
	 * Binds one key to one handler through a dynamic delegate.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the component, key and handler name
	 * @Return nothing; the key is bound on press
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
	 * Counts presses of the W key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnW(FKey Key)
	{
	}

	/**
	 * Counts presses of the A key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnA(FKey Key)
	{
	}

	/**
	 * Counts presses of the S key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnS(FKey Key)
	{
	}

	/**
	 * Counts presses of the D key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnD(FKey Key)
	{
	}

	/**
	 * Counts presses of the space bar.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnSpace(FKey Key)
	{
	}

	/**
	 * Counts presses of the left shift key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnShift(FKey Key)
	{
	}

	/**
	 * Counts presses of the left control key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnCtrl(FKey Key)
	{
	}

	/**
	 * Counts presses of the left alt key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnAlt(FKey Key)
	{
	}

	/**
	 * Counts presses of the tab key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnTab(FKey Key)
	{
	}

	/**
	 * Counts presses of the escape key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnEscape(FKey Key)
	{
	}

	/**
	 * Counts presses of the enter key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnEnter(FKey Key)
	{
	}

	/**
	 * Counts presses of the one key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnOne(FKey Key)
	{
	}

	/**
	 * Counts presses of the two key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnTwo(FKey Key)
	{
	}

	/**
	 * Counts presses of the nine key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnNine(FKey Key)
	{
	}

	/**
	 * Counts presses of the F1 key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnF1(FKey Key)
	{
	}

	/**
	 * Counts presses of the F12 key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnF12(FKey Key)
	{
	}

	/**
	 * Observe that an unset pawn handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AKeyboardInputPawn handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int KeyboardPawnDefaultsToNull()
	{
		AKeyboardInputPawn Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
