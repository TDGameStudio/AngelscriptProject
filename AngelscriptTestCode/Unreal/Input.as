/**
 * @version v1
 * @summary Key, mouse, gamepad, action, and axis bindings on actors.
 * @topic Unreal
 * @topic Input
 *
 * action-binding
 * axis-binding
 * gamepad-input
 * keyboard-keys
 * key-direct-binding
 * legacy-input-priority-and-consume-surface
 * mouse-input
 * touch-state-query-surface
 * override-keyword-on-child-method
 * this-keyword-member-assignment
 * equality
 * container-api
 * add-assign
 * multiply-assign
 * convert-to-type
 * is-non-zero
 * get
 * get-axis-1-d
 * get-axis-2-d
 * get-axis-3-d
 * get-value-type-from-key
 * value-binding
 * execute
 * set-should-fire-with-editor-script-guard
 * equality-host
 * get-handle
 * get-action
 * get-trigger-event
 * is-bound-to-object
 * get-value
 * add-action-mapping
 * add-axis-mapping
 * remove-action-mapping
 * remove-axis-mapping
 * key
 * chord
 * are-caps-locked
 * prevent-throttling
 * capture-mouse
 * use-high-precision-mouse-movement
 * release-mouse-capture
 * lock-mouse-to-widget
 * release-mouse-lock
 * InputEvents-Behavior_02-are-caps-locked
 * assignment
 * get-user-index
 * get-pointer-index
 * get-touchpad-index
 * set-user-focus
 * clear-user-focus
 * set-mouse-pos
 * set-navigation
 * handled
 * unhandled
 * every-bind-ekeys-token
 * equality-host-x
 * is-valid
 * is-modifier-key
 * is-gamepad-key
 * is-touch
 * is-mouse-button
 * is-axis-1-d
 * is-axis-2-d
 * is-axis-3-d
 * get-display-name
 * get-key-name
 * is-repeat
 * is-shift-down
 * is-left-shift-down
 * is-right-shift-down
 * is-control-down
 * is-left-control-down
 * is-right-control-down
 * is-alt-down
 * is-left-alt-down
 * is-right-alt-down
 * is-command-down
 * is-left-command-down
 * is-right-command-down
 * get-platform-userid
 * get-input-device-id
 * get-key
 * get-character
 * get-key-code
 * InputEvents-Queries_03-is-repeat
 * InputEvents-Queries_03-is-shift-down
 * InputEvents-Queries_04-is-left-shift-down
 * InputEvents-Queries_04-is-right-shift-down
 * InputEvents-Queries_04-is-control-down
 * InputEvents-Queries_04-is-left-control-down
 * InputEvents-Queries_04-is-right-control-down
 * InputEvents-Queries_04-is-alt-down
 * InputEvents-Queries_04-is-left-alt-down
 * InputEvents-Queries_04-is-right-alt-down
 * InputEvents-Queries_04-is-command-down
 * InputEvents-Queries_04-is-left-command-down
 * InputEvents-Queries_05-is-right-command-down
 * InputEvents-Queries_05-get-platform-userid
 * InputEvents-Queries_05-get-input-device-id
 * get-screen-space-position
 * get-last-screen-space-position
 * get-cursor-delta
 * get-gesture-delta
 * is-mouse-button-down
 * get-effecting-button
 * get-wheel-delta
 * get-touch-force
 * is-touch-event
 * is-touch-force-changed-event
 * is-touch-first-move-event
 * is-direction-inverted-from-device
 * InputEvents-Queries_06-is-repeat
 * InputEvents-Queries_06-is-shift-down
 * InputEvents-Queries_06-is-left-shift-down
 * InputEvents-Queries_06-is-right-shift-down
 * InputEvents-Queries_06-is-control-down
 * InputEvents-Queries_07-is-left-control-down
 * InputEvents-Queries_07-is-right-control-down
 * InputEvents-Queries_07-is-alt-down
 * InputEvents-Queries_07-is-left-alt-down
 * InputEvents-Queries_07-is-right-alt-down
 * InputEvents-Queries_07-is-command-down
 * InputEvents-Queries_07-is-left-command-down
 * InputEvents-Queries_07-is-right-command-down
 * InputEvents-Queries_07-get-platform-userid
 * InputEvents-Queries_07-get-input-device-id
 * get-navigation-type
 * get-navigation-genesis
 * get-analog-value
 * InputEvents-Queries_08-get-platform-userid
 * InputEvents-Queries_08-get-input-device-id
 * InputEvents-Queries_08-get-key
 * InputEvents-Queries_08-get-key-code
 * get-cause
 * get-user
 * InputEvents-Queries_08-is-repeat
 * InputEvents-Queries_09-is-shift-down
 * InputEvents-Queries_09-is-left-shift-down
 * InputEvents-Queries_09-is-right-shift-down
 * InputEvents-Queries_09-is-control-down
 * InputEvents-Queries_09-is-left-control-down
 * InputEvents-Queries_09-is-right-control-down
 * InputEvents-Queries_09-is-alt-down
 * InputEvents-Queries_09-is-left-alt-down
 * InputEvents-Queries_09-is-right-alt-down
 * InputEvents-Queries_09-is-command-down
 * InputEvents-Queries_10-is-left-command-down
 * InputEvents-Queries_10-is-right-command-down
 * InputEvents-Queries_10-get-platform-userid
 * InputEvents-Queries_10-get-input-device-id
 * InputEvents-Queries_10-get-character
 * get-string
 * should-fire-delegates-in-editor
 * set-should-fire-delegates-in-editor
 * clear-action-event-bindings
 * clear-action-value-bindings
 * clear-debug-key-bindings
 * clear-action-bindings
 * clear-bindings-for-object
 * remove-action-event-binding
 * remove-debug-key-binding
 * remove-action-value-binding
 * remove-binding-by-handle
 * remove-binding
 * bind-action
 * bind-action-value
 * bind-debug-key
 * has-bindings
 * get-bound-action-value
 * mapping
 * map-key
 * unmap-key
 * unmap-all-keys-from-action
 * unmap-all
 * set-value-type
 * set-accumulation-behavior
 * set-action
 * set-key
 * add-modifier
 * clear-modifiers
 * add-trigger
 * clear-triggers
 * equality-host-x-x
 * get-value-type
 * get-accumulation-behavior
 * get-action-host
 * get-key-host
 * get-modifier-count
 * get-trigger-count
 * has-mapping-for-input-action
 * get-mapping-count
 * get-mapping
 * does-action-exist
 * does-axis-exist
 * does-speech-exist
 * get-unique-action-name
 * get-unique-axis-name
 * get-action-mappings
 * get-axis-mappings
 * get-speech-mappings
 */
/**
 * @begin action-binding
 * @summary A pawn that binds four action handlers through BindUFunction, one per input event kind. The class must compile; the counters stay zero until input actually fires.
 * @topic Input
 */
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

	/**
	 * Binds one handler per input event kind.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; four actions are bound
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
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

	/**
	 * Counts presses of the jump action.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the key that triggered the action
	 * @Return nothing; JumpPressedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnJumpPressed(FKey Key)
	{
		JumpPressedCount++;
	}

	/**
	 * Counts releases of the jump action.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the key that triggered the action
	 * @Return nothing; JumpReleasedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnJumpReleased(FKey Key)
	{
		JumpReleasedCount++;
	}

	/**
	 * Counts repeats of the fire action.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the key that triggered the action
	 * @Return nothing; FireRepeatCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnFireRepeat(FKey Key)
	{
		FireRepeatCount++;
	}

	/**
	 * Counts double clicks of the select action.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the key that triggered the action
	 * @Return nothing; SelectDoubleClickCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnSelectDoubleClick(FKey Key)
	{
		SelectDoubleClickCount++;
	}

	/**
	 * Observe that all counters start at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed pawn
	 * @Return true when all four counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool ActionBindingCountersDefaultToZero()
	{
		if (JumpPressedCount != 0)
		{
			return false;
		}

		if (JumpReleasedCount != 0)
		{
			return false;
		}

		if (FireRepeatCount != 0)
		{
			return false;
		}

		return SelectDoubleClickCount == 0;
	}
}
/** @end */
/**
 * @begin axis-binding
 * @summary A pawn binding four axis handlers through BindUFunction. The class must compile, and each handler stores its axis value and bumps a shared call counter.
 * @topic Input
 */
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

	/**
	 * Binds one handler per axis.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; four axes are bound
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
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

	/**
	 * Stores the forward axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; MoveForwardValue is set and the counter bumped
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnMoveForward(float32 Value)
	{
		MoveForwardValue = Value;
		AxisCallCount++;
	}

	/**
	 * Stores the right axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; MoveRightValue is set and the counter bumped
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnMoveRight(float32 Value)
	{
		MoveRightValue = Value;
		AxisCallCount++;
	}

	/**
	 * Stores the look-up axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; LookUpValue is set and the counter bumped
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnLookUp(float32 Value)
	{
		LookUpValue = Value;
		AxisCallCount++;
	}

	/**
	 * Stores the turn axis value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the current axis value
	 * @Return nothing; TurnValue is set and the counter bumped
	 * @Param Value the axis value
	 */
	UFUNCTION()
	void OnTurn(float32 Value)
	{
		TurnValue = Value;
		AxisCallCount++;
	}

	/**
	 * Observe that all axis values and the counter start at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed pawn
	 * @Return true when all four values are 0 and the counter is 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool AxisBindingValuesDefaultToZero()
	{
		if (!Math::IsNearlyEqual(MoveForwardValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(MoveRightValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(LookUpValue, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(TurnValue, 0.0))
		{
			return false;
		}

		return AxisCallCount == 0;
	}

	/**
	 * Observe that two handler calls store their values and count twice.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs OnMoveForward(1.0) and OnMoveRight(-1.0)
	 * @Return true when both values landed and the counter reads 2
	 * @Boundary signed axis values
	 */
	UFUNCTION()
	bool AxisBindingHandlersStoreValues()
	{
		OnMoveForward(float32(1.0));
		OnMoveRight(float32(-1.0));

		if (!Math::IsNearlyEqual(MoveForwardValue, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(MoveRightValue, -1.0))
		{
			return false;
		}

		return AxisCallCount == 2;
	}
}
/** @end */
/**
 * @begin gamepad-input
 * @summary The gamepad bind surface on a pawn: fourteen pressed-key bindings and four stick-axis bindings. The stick handlers store their axis values, so the observers confirm the defaults and that each stick writes independently.
 * @topic Input
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
/**
 * @begin keyboard-keys
 * @summary A pawn binding fifteen keyboard keys through BindKey, one handler per key covering WASD, modifiers, navigation, digits and function keys. The class must compile; the handlers are deliberately empty.
 * @topic Input
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
/**
 * @begin key-direct-binding
 * @summary A pawn binding keys and mouse buttons directly through BindKey, mixing pressed and released events across keyboard and mouse buttons.
 * @topic Input
 */
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

	/**
	 * Binds four keys mixing pressed and released events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to bind against
	 * @Return nothing; four keys are bound
	 * @Param PlayerInputComponent the component receiving the bindings
	 */
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

	/**
	 * Counts presses of the space bar.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing; SpaceKeyPressedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnSpacePressed(FKey Key)
	{
		SpaceKeyPressedCount++;
	}

	/**
	 * Counts presses of the W key.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing; WKeyPressedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnWPressed(FKey Key)
	{
		WKeyPressedCount++;
	}

	/**
	 * Counts presses of the left mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing; LeftMousePressedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnLeftMousePressed(FKey Key)
	{
		LeftMousePressedCount++;
	}

	/**
	 * Counts releases of the right mouse button.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key
	 * @Return nothing; RightMouseReleasedCount is incremented
	 * @Param Key the triggering key
	 */
	UFUNCTION()
	void OnRightMouseReleased(FKey Key)
	{
		RightMouseReleasedCount++;
	}

	/**
	 * Observe that a locally constructed pawn leaves every count at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed pawn
	 * @Return true when all four counters are 0
	 * @Boundary default values
	 */
	UFUNCTION()
	bool KeyDirectBindingDefaultEmpty()
	{
		if (SpaceKeyPressedCount != 0)
		{
			return false;
		}

		if (WKeyPressedCount != 0)
		{
			return false;
		}

		if (LeftMousePressedCount != 0)
		{
			return false;
		}

		return RightMouseReleasedCount == 0;
	}
}
/** @end */
/**
 * @begin legacy-input-priority-and-consume-surface
 * @summary Legacy input priority surface: BindKey's consume flag in both states plus an EnhancedInput debug-key bind. Priority and block-input stay native-owned; the script only supplies the two consume-flagged bindings.
 * @topic Input
 */
UCLASS()
class ALegacyInputPriorityActor : AActor
{
	/**
	 * Binds two keys with opposite consume flags.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an input component to configure
	 * @Return nothing; two bindings with differing consume flags exist
	 * @Param InputComponent the component receiving the bindings
	 */
	UFUNCTION()
	void Configure(UInputComponent InputComponent)
	{
		FInputActionHandlerDynamicSignature Delegate;
		InputComponent.BindKey(EKeys::One, EInputEvent::IE_Pressed, Delegate, false);
		InputComponent.BindKey(EKeys::Two, EInputEvent::IE_Pressed, Delegate, true);
	}

	/**
	 * The debug-key handler bound through EnhancedInput.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the triggering key and action value
	 * @Return nothing
	 * @Param Key the triggering key
	 * @Param Value the action value
	 */
	UFUNCTION()
	void OnDebug(FKey Key, FInputActionValue Value)
	{
	}

	/**
	 * Binds a debug key through EnhancedInput.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an enhanced input component to configure
	 * @Return nothing; the debug-key binding exists
	 * @Param InputComponent the component receiving the binding
	 */
	UFUNCTION()
	void ConfigureDebug(UEnhancedInputComponent InputComponent)
	{
		FInputDebugKeyHandlerDynamicSignature Delegate;
		Delegate.BindUFunction(this, n"OnDebug");
		InputComponent.BindDebugKey(FInputChord(EKeys::Three), EInputEvent::IE_Pressed, Delegate, false);
	}

	/**
	 * Observe that a locally constructed actor has no input component effects.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed actor
	 * @Return true once construction completes
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool LegacyInputPriorityLocalConstruct()
	{
		ALegacyInputPriorityActor Actor;
		return true;
	}
}
/** @end */
/**
 * @begin mouse-input
 * @summary A pawn's full mouse surface: seven button bindings plus two named axes whose handlers store the incoming axis values.
 * @topic Input
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
/** @end */
/**
 * @begin touch-state-query-surface
 * @summary A player controller's touch query surface: CaptureTouch forwards a finger index into GetInputTouchState with out parameters for position and press state.
 * @topic Input
 */
UCLASS()
class ATouchStateQueryController : APlayerController
{
	UPROPERTY()
	float32 TouchX = 0.0f;

	UPROPERTY()
	float32 TouchY = 0.0f;

	UPROPERTY()
	bool bTouchPressed = false;

	/**
	 * Queries the engine for one finger's touch state.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a finger index
	 * @Return nothing; the position and press state are stored
	 * @Param FingerIndex the finger being queried
	 */
	UFUNCTION()
	void CaptureTouch(ETouchIndex FingerIndex)
	{
		GetInputTouchState(FingerIndex, TouchX, TouchY, bTouchPressed);
	}

	/**
	 * Reports whether the storage still holds its zeroed defaults.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three touch UPROPERTYs
	 * @Return true when position is 0,0 and not pressed
	 */
	UFUNCTION()
	bool HasTouchStateStorage()
	{
		if (TouchX != 0.0f)
		{
			return false;
		}

		if (TouchY != 0.0f)
		{
			return false;
		}

		return !bTouchPressed;
	}

	/**
	 * Observe the default zeroed storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed controller
	 * @Return true when HasTouchStateStorage holds
	 * @Boundary default values
	 */
	UFUNCTION()
	bool TouchStateQueryDefaultEmpty()
	{
		return HasTouchStateStorage();
	}

	/**
	 * Observe the written boundary of the storage.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the three UPROPERTYs written with signed values
	 * @Return true when the writes landed and the zero check no longer holds
	 * @Boundary written values
	 */
	UFUNCTION()
	bool TouchStateQueryWrittenBoundary()
	{
		TouchX = 1.0f;
		TouchY = -1.0f;
		bTouchPressed = true;

		if (!Math::IsNearlyEqual(TouchX, 1.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(TouchY, -1.0))
		{
			return false;
		}

		if (!bTouchPressed)
		{
			return false;
		}

		return !HasTouchStateStorage();
	}
}
/** @end */
/**
 * @begin override-keyword-on-child-method
 * @summary The override keyword applied to a child method that shadows a parent method. Both the empty parent body and the empty child body must complete.
 * @topic Input
 */
class ABaseActorOvrd : AActor
{
	/**
	 * The parent method that the child overrides.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo()
	{
	}
}

class AChildActorOvrd : ABaseActorOvrd
{
	/**
	 * The child method carrying the override keyword.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo() override
	{
	}

	/**
	 * Observe that the overriding method completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs Foo() on the child
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int OverrideMethodCompletes()
	{
		Foo();
		return 0;
	}

	/**
	 * Observe that the parent method also completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs Foo() on the base
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int BaseMethodCompletes()
	{
		ABaseActorOvrd Base;
		Base.Foo();
		return 0;
	}

	/**
	 * Observe that assigning one handle to another aliases them.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs two handles, one assigned from the other
	 * @Return true when both refer to the same object
	 * @Boundary handle aliasing
	 */
	UFUNCTION()
	bool ChildHandleAssignAliases()
	{
		AChildActorOvrd First;
		AChildActorOvrd Second;
		First = Second;
		return First is Second;
	}
}
/** @end */
/**
 * @begin this-keyword-member-assignment
 * @summary The this keyword used to disambiguate a member assignment from a parameter of the same role. The observers confirm the write lands on the member, that the member starts at zero, and that instances do not share state.
 * @topic Input
 */
class AActorThis : AActor
{
	int X = 0;

	/**
	 * Assigns the member through the this keyword.
	 *
	 * @Covers Syntax.Keywords
	 * @Inputs a new value for X
	 * @Return nothing; this.X receives the value
	 * @Param Val the value to assign
	 */
	void SetX(int Val)
	{
		this.X = Val;
	}

	/**
	 * Observe that a write through this lands on the member.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs SetX(5) then this.X
	 * @Return 5
	 */
	UFUNCTION()
	int ThisWriteLandsOnMember()
	{
		SetX(5);
		return X;
	}

	/**
	 * Observe that the member starts at zero.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default value
	 */
	UFUNCTION()
	int ThisMemberDefaultsToZero()
	{
		return X;
	}

	/**
	 * Observe the zero boundary of the this write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs SetX(0) then this.X
	 * @Return 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	int ThisWriteZeroBoundary()
	{
		SetX(0);
		return X;
	}

	/**
	 * Observe that writing this instance leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Keywords
	 * @Inputs this actor written to, compared against a second actor
	 * @Return true when this actor holds 8 and the other stays 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool ThisWriteIsIndependentAcrossInstances()
	{
		AActorThis Other;
		SetX(8);

		if (X != 8)
		{
			return false;
		}

		return Other.X == 0;
	}
}
/** @end */
/**
 * @begin equality
 * @summary after assignment.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary after assignment.
 * @covers FInputActionKeyMapping.equality
 * @inputs FInputActionKeyMapping values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FInputActionKeyMapping Left;
	FInputActionKeyMapping Right;
	bool bDefaultsEqual = Left == Right;

	Left.ActionName = n"Jump";
	Left.Key = n"SpaceBar";
	bool bNamedDiffersFromDefault = !(Left == Right);

	FInputActionKeyMapping Copy = Left;
	bool bCopyEqualsSource = Copy == Left;

	Copy.bShift = true;
	bool bShiftDiffers = !(Copy == Left);

	FInputActionKeyMapping Other;
	Other.ActionName = n"Fire";
	Other.Key = n"SpaceBar";
	bool bActionNameDiffers = !(Left == Other);

	FInputActionKeyMapping DifferentKey;
	DifferentKey.ActionName = n"Jump";
	DifferentKey.Key = n"Enter";
	bool bKeyDiffers = !(Left == DifferentKey);

	return bDefaultsEqual && bNamedDiffersFromDefault && bCopyEqualsSource && bShiftDiffers && bActionNameDiffers && bKeyDiffers;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers FInputActionValue.container-api
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FInputActionValue Value(FVector2D InValue);
// FInputActionValue Value(FVector InValue);
// FInputActionValue Value(EInputActionValueType InValueType, FVector InValue);
// Inputs: 5.0, FVector2D(3,4), FVector(1,2,3), Boolean with (1,0,0), Axis3D
// with the same vector, and a default-constructed value.
// Expected observations: Each constructor stores the supplied components.
// Boolean typed construction reports Get true. Default construction is zero.
// Boundary/ownership: Constructors copy the supplied numbers into a new
// value. The source vectors remain independent.
bool ObserveValueNominal()
{
	FInputActionValue Empty;
	FInputActionValue Axis1D(5.0);
	float32 One = Axis1D.GetAxis1D();

	FVector2D Source2D(3.0, 4.0);
	FInputActionValue Axis2D(Source2D);
	FVector2D Two = Axis2D.GetAxis2D();

	FVector Source3D(1.0, 2.0, 3.0);
	FInputActionValue Axis3D(Source3D);
	FVector Three = Axis3D.GetAxis3D();

	FInputActionValue BooleanValue(EInputActionValueType::Boolean, FVector(1.0, 0.0, 0.0));
	FInputActionValue TypedAxis(EInputActionValueType::Axis3D, FVector(1.0, 2.0, 3.0));
	FVector Typed = TypedAxis.GetAxis3D();
	return !Empty.IsNonZero() &&
		One > 4.9 && One < 5.1 &&
		Two.X > 2.9 && Two.X < 3.1 && Two.Y > 3.9 && Two.Y < 4.1 &&
		Source2D.X == 3.0 && Source2D.Y == 4.0 &&
		Three.X > 0.9 && Three.X < 1.1 && Three.Z > 2.9 && Three.Z < 3.1 &&
		Source3D.X == 1.0 && Source3D.Z == 3.0 &&
		BooleanValue.Get() &&
		Typed.Y > 1.9 && Typed.Y < 2.1;
}
/** @end */
/**
 * @begin add-assign
 * @summary alias to it.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary alias to it.
 * @covers FInputActionValue.add-assign
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FInputActionValue Value(1.0);
	FInputActionValue Other(2.0);
	FInputActionValue Copied = Other;
	Value += Other;
	float32 AfterAdd = Value.GetAxis1D();
	FInputActionValue& Alias = Value.opAddAssign(Other);
	float32 AfterAlias = Value.GetAxis1D();
	FInputActionValue Empty;
	Empty += Value;
	return AfterAdd > 2.9 && AfterAdd < 3.1 &&
		Alias.GetAxis1D() == AfterAlias &&
		Copied.GetAxis1D() > 1.9 && Copied.GetAxis1D() < 2.1 &&
		Empty.IsNonZero();
}
/** @end */
/**
 * @begin multiply-assign
 * @summary alias to it.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary alias to it.
 * @covers FInputActionValue.multiply-assign
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FInputActionValue Value(2.0);
	FInputActionValue Copied = Value;
	Value *= 2.0;
	float32 AfterScale = Value.GetAxis1D();
	FInputActionValue& Alias = Value.opMulAssign(0.5);
	float32 AfterAlias = Value.GetAxis1D();
	Value *= 0.0;
	return AfterScale > 3.9 && AfterScale < 4.1 &&
		Alias.GetAxis1D() == AfterAlias && AfterAlias > 1.9 && AfterAlias < 2.1 &&
		Copied.GetAxis1D() > 1.9 && Copied.GetAxis1D() < 2.1 &&
		!Value.IsNonZero();
}
/** @end */
/**
 * @begin convert-to-type
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveConvertToTypeNominal
 * @summary Observe the container API.
 * @covers FInputActionValue.convert-to-type
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: FVector(7,8,9) as the non-empty source, a default zero value, Axis1D
// and Axis2D target types, and another 2D value as the type donor.
// Expected observations: ConvertToType(Axis1D) keeps X as the 1D axis.
// ConvertToType(Other) adopts Other's type. Follow-up *= through the returned
// reference mutates the original value.
// Boundary/ownership: ConvertToType mutates this value and returns an alias.
// Other is borrowed as a type source.
bool ObserveConvertToTypeNominal()
{
	FInputActionValue Value(FVector(7.0, 8.0, 9.0));
	FInputActionValue& Converted1D = Value.ConvertToType(EInputActionValueType::Axis1D);
	float32 Axis1 = Converted1D.GetAxis1D();
	Converted1D *= 2.0;

	FInputActionValue Empty;
	FInputActionValue& ConvertedEmpty = Empty.ConvertToType(EInputActionValueType::Axis2D);
	FVector2D EmptyAxis = ConvertedEmpty.GetAxis2D();

	FInputActionValue Donor(FVector2D(1.0, 2.0));
	FInputActionValue& ConvertedFromOther = Value.ConvertToType(Donor);
	FVector2D FromOther = ConvertedFromOther.GetAxis2D();
	return Axis1 > 6.9 && Axis1 < 7.1 &&
		Value.GetAxis1D() == Converted1D.GetAxis1D() &&
		EmptyAxis.X == 0.0 && EmptyAxis.Y == 0.0 &&
		FromOther.X == Value.GetAxis2D().X &&
		Donor.GetAxis2D().X > 0.9 && Donor.GetAxis2D().X < 1.1;
}
/** @end */
/**
 * @begin is-non-zero
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveIsNonZeroNominal
 * @summary borrows the key.
 * @covers FInputActionValue.is-non-zero
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNonZeroNominal()
{
	FInputActionValue Empty;
	FInputActionValue One(1.0);
	FInputActionValue Tiny(KINDA_SMALL_NUMBER * 0.5);
	return !Empty.IsNonZero() &&
		One.IsNonZero() &&
		One.IsNonZero(KINDA_SMALL_NUMBER) &&
		!Tiny.IsNonZero() &&
		Tiny.IsNonZero(0.0);
}
/** @end */
/**
 * @begin get
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary borrows the key.
 * @covers FInputActionValue.get
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNominal()
{
	FInputActionValue Empty;
	FInputActionValue One(1.0);
	FInputActionValue Zero(0.0);
	return !Empty.Get() && One.Get() && !Zero.Get();
}
/** @end */
/**
 * @begin get-axis-1-d
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxis1DNominal
 * @summary borrows the key.
 * @covers FInputActionValue.get-axis-1-d
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxis1DNominal()
{
	FInputActionValue Empty;
	FInputActionValue One(5.0);
	return Empty.GetAxis1D() == 0.0 && One.GetAxis1D() > 4.9 && One.GetAxis1D() < 5.1;
}
/** @end */
/**
 * @begin get-axis-2-d
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxis2DNominal
 * @summary borrows the key.
 * @covers FInputActionValue.get-axis-2-d
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxis2DNominal()
{
	FInputActionValue Empty;
	FVector2D EmptyAxis = Empty.GetAxis2D();
	FInputActionValue Value(FVector2D(3.0, 4.0));
	FVector2D Axis = Value.GetAxis2D();
	return EmptyAxis.X == 0.0 &&
		EmptyAxis.Y == 0.0 &&
		Axis.X > 2.9 &&
		Axis.X < 3.1 &&
		Axis.Y > 3.9 &&
		Axis.Y < 4.1;
}
/** @end */
/**
 * @begin get-axis-3-d
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxis3DNominal
 * @summary borrows the key.
 * @covers FInputActionValue.get-axis-3-d
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxis3DNominal()
{
	FInputActionValue Empty;
	FVector EmptyAxis = Empty.GetAxis3D();
	FInputActionValue Value(FVector(1.0, 2.0, 3.0));
	FVector Axis = Value.GetAxis3D();
	return EmptyAxis.X == 0.0 &&
		EmptyAxis.Y == 0.0 &&
		EmptyAxis.Z == 0.0 &&
		Axis.X > 0.9 &&
		Axis.X < 1.1 &&
		Axis.Y > 1.9 &&
		Axis.Y < 2.1 &&
		Axis.Z > 2.9 &&
		Axis.Z < 3.1;
}
/** @end */
/**
 * @begin get-value-type-from-key
 * @summary borrows the key.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueTypeFromKeyNominal
 * @summary borrows the key.
 * @covers FInputActionValue.get-value-type-from-key
 * @inputs FInputActionValue values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueTypeFromKeyNominal()
{
	FKey EmptyKey;
	FKey SpaceBar = n"SpaceBar";
	FKey MouseX = n"MouseX";
	EInputActionValueType EmptyType = FInputActionValue::GetValueTypeFromKey(EmptyKey);
	EInputActionValueType SpaceType = FInputActionValue::GetValueTypeFromKey(SpaceBar);
	EInputActionValueType MouseType = FInputActionValue::GetValueTypeFromKey(MouseX);
	return SpaceType == EInputActionValueType::Boolean &&
		MouseType == EInputActionValueType::Axis1D &&
		EmptyType == EInputActionValueType::Boolean;
}
/** @end */
/**
 * @begin value-binding
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueBindingNominal
 * @summary Observe the container API.
 * @covers FInputBindingHandle.value-binding
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FEnhancedInputActionValueBinding ValueBinding(const UInputAction InAction);
// Inputs: Default construction, a null UInputAction, and the UInputAction CDO
// as the non-null boundary.
// Expected observations: Default and null-action bindings report a null
// GetAction and a zero GetValue. A CDO action is stored as the associated
// action when the constructor accepts it.
// Boundary/ownership: The binding does not own InAction. A null InAction is
// a valid unassociated binding.
bool ObserveValueBindingNominal()
{
	FEnhancedInputActionValueBinding DefaultBinding;
	UInputAction DefaultAction = DefaultBinding.GetAction();
	FInputActionValue DefaultValue = DefaultBinding.GetValue();

	UInputAction NullAction;
	FEnhancedInputActionValueBinding NullBinding(NullAction);
	UInputAction NullBoundAction = NullBinding.GetAction();

	TSubclassOf<UInputAction> ActionClass = UInputAction::StaticClass();
	UInputAction ActionCdo = ActionClass.GetDefaultObject();
	if (ActionCdo is null)
	{
		throw("TS_FInputBindingHandle_Behavior_01 setup: required UInputAction CDO is null");
	}
	FEnhancedInputActionValueBinding CdoBinding(ActionCdo);
	UInputAction BoundAction = CdoBinding.GetAction();
	return DefaultAction is null &&
		!DefaultValue.IsNonZero() &&
		NullBoundAction is null &&
		BoundAction == ActionCdo;
}
/** @end */
/**
 * @begin execute
 * @summary bindings do not own a callback target.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteNominal
 * @summary bindings do not own a callback target.
 * @covers FInputBindingHandle.execute
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveExecuteNominal()
{
	FEnhancedInputActionEventBinding EventBinding;
	FInputActionInstance ActionData;
	EventBinding.Execute(ActionData);
	EventBinding.Execute(ActionData);
	FInputDebugKeyBinding DebugBinding;
	FInputActionValue ActionValue;
	DebugBinding.Execute(ActionValue);
	FInputActionValue NonZero(1.0);
	DebugBinding.Execute(NonZero);
	return EventBinding.GetHandle() == 0 && DebugBinding.GetHandle() == 0;
}
/** @end */
/**
 * @begin set-should-fire-with-editor-script-guard
 * @summary bindings do not own a callback target.
 * @topic Unreal
 */
/**
 * @function ObserveSetShouldFireWithEditorScriptGuardNominal
 * @summary bindings do not own a callback target.
 * @covers FInputBindingHandle.set-should-fire-with-editor-script-guard
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetShouldFireWithEditorScriptGuardNominal()
{
	FEnhancedInputActionEventBinding EventBinding;
	EventBinding.SetShouldFireWithEditorScriptGuard(true);
	EventBinding.SetShouldFireWithEditorScriptGuard(false);
	EventBinding.SetShouldFireWithEditorScriptGuard(false);
	return EventBinding.GetHandle() == 0;
}
/** @end */
/**
 * @begin equality-host
 * @summary independent values.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary independent values.
 * @covers FInputBindingHandle.equality
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FInputBindingHandle LeftHandle;
	FInputBindingHandle RightHandle;
	FEnhancedInputActionEventBinding LeftEventBinding;
	FEnhancedInputActionEventBinding RightEventBinding;
	FEnhancedInputActionValueBinding LeftValueBinding;
	FEnhancedInputActionValueBinding RightValueBinding;
	UInputAction Action;
	FEnhancedInputActionValueBinding FromNullAction(Action);
	FInputDebugKeyBinding LeftDebugBinding;
	FInputDebugKeyBinding RightDebugBinding;
	return (LeftHandle == RightHandle) &&
		(LeftEventBinding == RightEventBinding) &&
		(LeftValueBinding == RightValueBinding) &&
		(FromNullAction == LeftValueBinding) &&
		(LeftDebugBinding == RightDebugBinding);
}
/** @end */
/**
 * @begin get-handle
 * @summary returns a copied FInputActionValue.
 * @topic Unreal
 */
/**
 * @function ObserveGetHandleNominal
 * @summary returns a copied FInputActionValue.
 * @covers FInputBindingHandle.get-handle
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHandleNominal()
{
	FInputBindingHandle BindingHandle;
	FEnhancedInputActionEventBinding EventBinding;
	FEnhancedInputActionValueBinding ValueBinding;
	FInputDebugKeyBinding DebugBinding;
	return BindingHandle.GetHandle() == 0 &&
		EventBinding.GetHandle() == 0 &&
		ValueBinding.GetHandle() == 0 &&
		DebugBinding.GetHandle() == 0;
}
/** @end */
/**
 * @begin get-action
 * @summary returns a copied FInputActionValue.
 * @topic Unreal
 */
/**
 * @function ObserveGetActionNominal
 * @summary returns a copied FInputActionValue.
 * @covers FInputBindingHandle.get-action
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetActionNominal()
{
	FEnhancedInputActionEventBinding EventBinding;
	FEnhancedInputActionValueBinding ValueBinding;
	UInputAction NullAction;
	FEnhancedInputActionValueBinding FromNull(NullAction);
	return EventBinding.GetAction() is null &&
		ValueBinding.GetAction() is null &&
		FromNull.GetAction() is null;
}
/** @end */
/**
 * @begin get-trigger-event
 * @summary returns a copied FInputActionValue.
 * @topic Unreal
 */
/**
 * @function ObserveGetTriggerEventNominal
 * @summary returns a copied FInputActionValue.
 * @covers FInputBindingHandle.get-trigger-event
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTriggerEventNominal()
{
	FEnhancedInputActionEventBinding EventBinding;
	ETriggerEvent DefaultTrigger;
	return EventBinding.GetTriggerEvent() == DefaultTrigger;
}
/** @end */
/**
 * @begin is-bound-to-object
 * @summary returns a copied FInputActionValue.
 * @topic Unreal
 */
/**
 * @function ObserveIsBoundToObjectNominal
 * @summary returns a copied FInputActionValue.
 * @covers FInputBindingHandle.is-bound-to-object
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsBoundToObjectNominal()
{
	FEnhancedInputActionEventBinding EventBinding;
	UObject NullObject;
	TSubclassOf<UObject> ObjectClass = UObject::StaticClass();
	UObject LiveCdo = ObjectClass.GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TS_FInputBindingHandle_Queries_01 setup: required UObject CDO is null");
	}
	return !EventBinding.IsBoundToObject(NullObject) && !EventBinding.IsBoundToObject(LiveCdo);
}
/** @end */
/**
 * @begin get-value
 * @summary returns a copied FInputActionValue.
 * @topic Unreal
 */
/**
 * @function ObserveGetValueNominal
 * @summary returns a copied FInputActionValue.
 * @covers FInputBindingHandle.get-value
 * @inputs FInputBindingHandle values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetValueNominal()
{
	FEnhancedInputActionValueBinding ValueBinding;
	FInputActionValue EmptyValue = ValueBinding.GetValue();
	UInputAction Action;
	FEnhancedInputActionValueBinding FromNull(Action);
	FInputActionValue FromNullValue = FromNull.GetValue();
	return !EmptyValue.IsNonZero() && !FromNullValue.IsNonZero();
}
/** @end */
/**
 * @begin add-action-mapping
 * @summary borrowed and not retained by a null receiver.
 * @topic Unreal
 */
/**
 * @function ObserveAddActionMappingNominal
 * @summary borrowed and not retained by a null receiver.
 * @covers InputComponentScriptMixins.add-action-mapping
 * @inputs InputComponentScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddActionMappingNominal()
{
	APlayerController PlayerController;
	UPlayerInput PlayerInput;
	FInputActionKeyMapping Mapping;
	Mapping.ActionName = n"Jump";
	Mapping.Key = n"SpaceBar";
	PlayerInput.AddActionMapping(Mapping);
	PlayerInput.AddActionMapping(Mapping);
	return PlayerController is null && PlayerInput is null && Mapping.ActionName == n"Jump";
}
/** @end */
/**
 * @begin add-axis-mapping
 * @summary borrowed and not retained by a null receiver.
 * @topic Unreal
 */
/**
 * @function ObserveAddAxisMappingNominal
 * @summary borrowed and not retained by a null receiver.
 * @covers InputComponentScriptMixins.add-axis-mapping
 * @inputs InputComponentScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAxisMappingNominal()
{
	UPlayerInput PlayerInput;
	FInputAxisKeyMapping Mapping;
	Mapping.AxisName = n"MoveForward";
	Mapping.Key = n"W";
	Mapping.Scale = 1.0;
	PlayerInput.AddAxisMapping(Mapping);
	PlayerInput.AddAxisMapping(Mapping);
	return PlayerInput is null && Mapping.AxisName == n"MoveForward" && Mapping.Scale == 1.0;
}
/** @end */
/**
 * @begin remove-action-mapping
 * @summary borrowed and not retained by a null receiver.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveActionMappingNominal
 * @summary borrowed and not retained by a null receiver.
 * @covers InputComponentScriptMixins.remove-action-mapping
 * @inputs InputComponentScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveActionMappingNominal()
{
	UPlayerInput PlayerInput;
	FInputActionKeyMapping Mapping;
	Mapping.ActionName = n"Jump";
	Mapping.Key = n"SpaceBar";
	PlayerInput.AddActionMapping(Mapping);
	PlayerInput.RemoveActionMapping(Mapping);
	PlayerInput.RemoveActionMapping(Mapping);
	return PlayerInput is null && Mapping.ActionName == n"Jump";
}
/** @end */
/**
 * @begin remove-axis-mapping
 * @summary borrowed and not retained by a null receiver.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveAxisMappingNominal
 * @summary borrowed and not retained by a null receiver.
 * @covers InputComponentScriptMixins.remove-axis-mapping
 * @inputs InputComponentScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRemoveAxisMappingNominal()
{
	UPlayerInput PlayerInput;
	FInputAxisKeyMapping Mapping;
	Mapping.AxisName = n"MoveForward";
	Mapping.Key = n"W";
	Mapping.Scale = 1.0;
	PlayerInput.AddAxisMapping(Mapping);
	PlayerInput.RemoveAxisMapping(Mapping);
	PlayerInput.RemoveAxisMapping(Mapping);
	return PlayerInput is null && Mapping.AxisName == n"MoveForward";
}
/** @end */
/**
 * @begin key
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveKeyNominal
 * @summary Observe the container API.
 * @covers InputEvents.key
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FInputChord Chord(const FKey& Key);
// FInputChord Chord(const FKey& Key, bool bShift, bool bCtrl, bool bAlt, bool bCmd);
// bool KeyEvent.AreCapsLocked() const; bool PointerEvent.AreCapsLocked() const;
// Reply.PreventThrottling(); Reply.CaptureMouse(UWidget Widget);
// Reply.UseHighPrecisionMouseMovement(UWidget Widget);
// Reply.ReleaseMouseCapture(); Reply.LockMouseToWidget(UWidget Widget);
// Inputs: n"SpaceBar", EKeys::Enter, modifier chord (true,false,true,true) on
// LeftMouseButton, default events for Caps Lock, FEventReply::Handled(), a
// transient UTextBlock, and Unhandled as the empty reply.
// Expected observations: Named construction equals EKeys::SpaceBar. Plain chord
// uses Enter without modifiers. Modified chord preserves Shift/Alt/Cmd and not
// Ctrl. Caps Lock is false on empty events. Fluent mouse methods return an
// alias of the seeded handled reply.
// Boundary/ownership: FKey construction copies the registered key identity.
// Reply methods do not take ownership of the widget. Capture/lock apply only
// when the widget has a cached Slate widget.
bool ObserveKeyNominal()
{
	FKey Space(n"SpaceBar");
	FKey Empty(NAME_None);
	return Space == EKeys::SpaceBar && Space.IsValid() && !Empty.IsValid();
}
/** @end */
/**
 * @begin chord
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveChordNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.chord
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveChordNominal()
{
	FInputChord Plain(EKeys::Enter);
	FInputChord Modified(EKeys::LeftMouseButton, true, false, true, true);
	FInputChord Empty(EKeys::Invalid);
	bool bPlainKey = Plain.Key == EKeys::Enter && !Plain.bShift && !Plain.bCtrl && !Plain.bAlt && !Plain.bCmd;
	bool bModifiedKey =
		Modified.Key == EKeys::LeftMouseButton &&
		Modified.bShift &&
		!Modified.bCtrl &&
		Modified.bAlt &&
		Modified.bCmd;
	return bPlainKey && bModifiedKey && Empty.Key == EKeys::Invalid;
}
/** @end */
/**
 * @begin are-caps-locked
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveAreCapsLockedNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.are-caps-locked
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAreCapsLockedNominal()
{
	FKeyEvent KeyEvent;
	FPointerEvent PointerEvent;
	return !KeyEvent.AreCapsLocked() && !PointerEvent.AreCapsLocked();
}
/** @end */
/**
 * @begin prevent-throttling
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObservePreventThrottlingNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.prevent-throttling
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePreventThrottlingNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.PreventThrottling();
	Alias.PreventThrottling();
	FEventReply Unhandled = FEventReply::Unhandled();
	Unhandled.PreventThrottling();
	return true;
}
/** @end */
/**
 * @begin capture-mouse
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveCaptureMouseNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.capture-mouse
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCaptureMouseNominal()
{
	UWidget CaptureWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.CaptureWidget", true));
	if (CaptureWidget is null)
	{
		throw("TS_InputEvents_Behavior_01 setup: required CaptureWidget is null");
	}
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.CaptureMouse(CaptureWidget);
	Alias.CaptureMouse(CaptureWidget);
	return CaptureWidget.GetName() == n"TestSource.InputEvents.CaptureWidget";
}
/** @end */
/**
 * @begin use-high-precision-mouse-movement
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveUseHighPrecisionMouseMovementNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.use-high-precision-mouse-movement
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveUseHighPrecisionMouseMovementNominal()
{
	UWidget CaptureWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.HighPrecisionWidget", true));
	if (CaptureWidget is null)
	{
		throw("TS_InputEvents_Behavior_01 setup: required CaptureWidget is null");
	}
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.UseHighPrecisionMouseMovement(CaptureWidget);
	Alias.UseHighPrecisionMouseMovement(CaptureWidget);
	return CaptureWidget.GetName() == n"TestSource.InputEvents.HighPrecisionWidget";
}
/** @end */
/**
 * @begin release-mouse-capture
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveReleaseMouseCaptureNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.release-mouse-capture
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveReleaseMouseCaptureNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.ReleaseMouseCapture();
	Alias.ReleaseMouseCapture();
	return true;
}
/** @end */
/**
 * @begin lock-mouse-to-widget
 * @summary when the widget has a cached Slate widget.
 * @topic Unreal
 */
/**
 * @function ObserveLockMouseToWidgetNominal
 * @summary when the widget has a cached Slate widget.
 * @covers InputEvents.lock-mouse-to-widget
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLockMouseToWidgetNominal()
{
	UWidget LockWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.LockWidget", true));
	if (LockWidget is null)
	{
		throw("TS_InputEvents_Behavior_01 setup: required LockWidget is null");
	}
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.LockMouseToWidget(LockWidget);
	Alias.LockMouseToWidget(LockWidget);
	return LockWidget.GetName() == n"TestSource.InputEvents.LockWidget";
}
/** @end */
/**
 * @begin release-mouse-lock
 * @summary require a widget.
 * @topic Unreal
 */
/**
 * @function ObserveReleaseMouseLockNominal
 * @summary require a widget.
 * @covers InputEvents.release-mouse-lock
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveReleaseMouseLockNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.ReleaseMouseLock();
	Alias.ReleaseMouseLock();
	FEventReply Unhandled = FEventReply::Unhandled();
	Unhandled.ReleaseMouseLock();
	return true;
}
/** @end */
/**
 * @begin InputEvents-Behavior_02-are-caps-locked
 * @summary require a widget.
 * @topic Unreal
 */
/**
 * @function ObserveAreCapsLockedNominal
 * @summary require a widget.
 * @covers InputEvents.are-caps-locked
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAreCapsLockedNominal()
{
	FNavigationEvent NavigationEvent;
	FCharacterEvent CharacterEvent;
	return !NavigationEvent.AreCapsLocked() && !CharacterEvent.AreCapsLocked();
}
/** @end */
/**
 * @begin assignment
 * @summary returns a new FString and does not own the key.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary returns a new FString and does not own the key.
 * @covers InputEvents.assignment
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FName Name = n"SpaceBar";
	FKey Key = Name;
	FKey Copied = Key;
	FKey Empty;
	FString Text = f"{Key}";
	FString CopiedText = f"{Copied}";
	FString EmptyText = f"{Empty}";
	FKey Assigned;
	Assigned = Name;
	FString AssignedText = f"{Assigned}";
	return Text.Contains("SpaceBar") && CopiedText == Text && AssignedText == Text && EmptyText == "None";
}
/** @end */
/**
 * @begin get-user-index
 * @summary diagnostic on these getters.
 * @topic Unreal
 */
/**
 * @function ObserveGetUserIndexNominal
 * @summary diagnostic on these getters.
 * @covers InputEvents.get-user-index
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUserIndexNominal()
{
	FKeyEvent KeyEvent;
	FPointerEvent PointerEvent;
	FNavigationEvent NavigationEvent;
	FAnalogInputEvent AnalogInputEvent;
	FCharacterEvent CharacterEvent;
	return KeyEvent.GetUserIndex() == 0 &&
		PointerEvent.GetUserIndex() == 0 &&
		NavigationEvent.GetUserIndex() == 0 &&
		AnalogInputEvent.GetUserIndex() == 0 &&
		CharacterEvent.GetUserIndex() == 0;
}
/** @end */
/**
 * @begin get-pointer-index
 * @summary diagnostic on these getters.
 * @topic Unreal
 */
/**
 * @function ObserveGetPointerIndexNominal
 * @summary diagnostic on these getters.
 * @covers InputEvents.get-pointer-index
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPointerIndexNominal()
{
	FPointerEvent PointerEvent;
	return PointerEvent.GetPointerIndex() == 0;
}
/** @end */
/**
 * @begin get-touchpad-index
 * @summary diagnostic on these getters.
 * @topic Unreal
 */
/**
 * @function ObserveGetTouchpadIndexNominal
 * @summary diagnostic on these getters.
 * @covers InputEvents.get-touchpad-index
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTouchpadIndexNominal()
{
	FPointerEvent PointerEvent;
	return PointerEvent.GetTouchpadIndex() == 0;
}
/** @end */
/**
 * @begin set-user-focus
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @topic Unreal
 */
/**
 * @function ObserveSetUserFocusNominal
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @covers InputEvents.set-user-focus
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetUserFocusNominal()
{
	UWidget FocusWidget = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.FocusWidget", true));
	if (FocusWidget is null)
	{
		throw("TS_InputEvents_MutationAndLifecycle_01 setup: required FocusWidget is null");
	}
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.SetUserFocus(FocusWidget);
	Alias.SetUserFocus(FocusWidget, EFocusCause::SetDirectly);
	Alias.SetUserFocus(FocusWidget, EFocusCause::Mouse, true);
	FEventReply& Again = Alias.SetUserFocus(FocusWidget, EFocusCause::SetDirectly, false);
	return FocusWidget.GetName() == n"TestSource.InputEvents.FocusWidget";
}
/** @end */
/**
 * @begin clear-user-focus
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @topic Unreal
 */
/**
 * @function ObserveClearUserFocusNominal
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @covers InputEvents.clear-user-focus
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearUserFocusNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.ClearUserFocus();
	Alias.ClearUserFocus(false);
	FEventReply& AllUsers = Alias.ClearUserFocus(true);
	return true;
}
/** @end */
/**
 * @begin set-mouse-pos
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @topic Unreal
 */
/**
 * @function ObserveSetMousePosNominal
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @covers InputEvents.set-mouse-pos
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetMousePosNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FIntPoint Requested(10, 20);
	FEventReply& Alias = Reply.SetMousePos(Requested);
	FIntPoint Origin;
	Alias.SetMousePos(Origin);
	FIntPoint Repeat(10, 20);
	FEventReply& Again = Alias.SetMousePos(Repeat);
	return Requested.X == 10 && Requested.Y == 20 && Origin.X == 0 && Origin.Y == 0 && Repeat.X == 10;
}
/** @end */
/**
 * @begin set-navigation
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @topic Unreal
 */
/**
 * @function ObserveSetNavigationNominal
 * @summary a NewObject text block is a valid null-slate no-op destination.
 * @covers InputEvents.set-navigation
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetNavigationNominal()
{
	UWidget Destination = Cast<UWidget>(NewObject(GetTransientPackage(), UTextBlock::StaticClass(), n"TestSource.InputEvents.NavWidget", true));
	if (Destination is null)
	{
		throw("TS_InputEvents_MutationAndLifecycle_01 setup: required Destination is null");
	}
	FEventReply Reply = FEventReply::Handled();
	FEventReply& DirectionAlias = Reply.SetNavigation(EUINavigation::Next, ENavigationGenesis::Keyboard);
	DirectionAlias.SetNavigation(EUINavigation::Down, ENavigationGenesis::Controller, ENavigationSource::FocusedWidget);
	FEventReply& WidgetAlias = DirectionAlias.SetNavigation(Destination, ENavigationGenesis::User);
	WidgetAlias.SetNavigation(Destination, ENavigationGenesis::Keyboard, ENavigationSource::FocusedWidget);
	return Destination.GetName() == n"TestSource.InputEvents.NavWidget";
}
/** @end */
/**
 * @begin handled
 * @summary FEventReply::Handled() returns a reply that accepts fluent PreventThrottling/ReleaseMouseCapture aliases.
 * @topic Unreal
 */
/**
 * @function ObserveHandledNominal
 * @summary FEventReply::Handled() returns a reply that accepts fluent PreventThrottling/ReleaseMouseCapture aliases.
 * @covers InputEvents.handled
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHandledNominal()
{
	FEventReply Reply = FEventReply::Handled();
	FEventReply& Alias = Reply.PreventThrottling();
	Alias.ReleaseMouseCapture();
	return true;
}
/** @end */
/**
 * @begin unhandled
 * @summary FEventReply::Unhandled() is independently mutable
 * @topic Unreal
 */
/**
 * @function ObserveUnhandledNominal
 * @summary FEventReply::Unhandled() is independently mutable
 * @covers InputEvents.unhandled
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
 from Handled() via ReleaseMouseLock.
bool ObserveUnhandledNominal()
{
	FEventReply Reply = FEventReply::Unhandled();
	FEventReply Handled = FEventReply::Handled();
	Reply.ReleaseMouseLock();
	return true;
}
/** @end */
/**
 * @begin every-bind-ekeys-token
 * @summary Every BIND_EKEYS token plus Virtual_Accept/Virtual_Back is valid.
 * @topic Unreal
 */
/**
 * @function ObserveSurface127Nominal
 * @summary Every BIND_EKEYS token plus Virtual_Accept/Virtual_Back is valid.
 * @covers InputEvents.every-bind-ekeys-token
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface127Nominal()
{
	bool bAny = EKeys::AnyKey.IsValid();

	bool bMouse =
		EKeys::MouseX.IsAxis1D() &&
		EKeys::MouseY.IsAxis1D() &&
		EKeys::Mouse2D.IsAxis2D() &&
		EKeys::MouseScrollUp.IsValid() &&
		EKeys::MouseScrollDown.IsValid() &&
		EKeys::MouseWheelAxis.IsValid() &&
		EKeys::LeftMouseButton.IsMouseButton() &&
		EKeys::RightMouseButton.IsMouseButton() &&
		EKeys::MiddleMouseButton.IsMouseButton() &&
		EKeys::ThumbMouseButton.IsMouseButton() &&
		EKeys::ThumbMouseButton2.IsMouseButton();

	bool bTyping =
		EKeys::BackSpace.IsValid() &&
		EKeys::Tab.IsValid() &&
		EKeys::Enter.IsValid() &&
		EKeys::Pause.IsValid() &&
		EKeys::CapsLock.IsValid() &&
		EKeys::Escape.IsValid() &&
		EKeys::SpaceBar.GetKeyName() == n"SpaceBar" &&
		EKeys::PageUp.IsValid() &&
		EKeys::PageDown.IsValid() &&
		EKeys::End.IsValid() &&
		EKeys::Home.IsValid() &&
		EKeys::Left.IsValid() &&
		EKeys::Up.IsValid() &&
		EKeys::Right.IsValid() &&
		EKeys::Down.IsValid() &&
		EKeys::Insert.IsValid() &&
		EKeys::Delete.IsValid();

	bool bDigits =
		EKeys::Zero.IsValid() &&
		EKeys::One.IsValid() &&
		EKeys::Two.IsValid() &&
		EKeys::Three.IsValid() &&
		EKeys::Four.IsValid() &&
		EKeys::Five.IsValid() &&
		EKeys::Six.IsValid() &&
		EKeys::Seven.IsValid() &&
		EKeys::Eight.IsValid() &&
		EKeys::Nine.IsValid();

	bool bLetters =
		EKeys::A.IsValid() &&
		EKeys::B.IsValid() &&
		EKeys::C.IsValid() &&
		EKeys::D.IsValid() &&
		EKeys::E.IsValid() &&
		EKeys::F.IsValid() &&
		EKeys::G.IsValid() &&
		EKeys::H.IsValid() &&
		EKeys::I.IsValid() &&
		EKeys::J.IsValid() &&
		EKeys::K.IsValid() &&
		EKeys::L.IsValid() &&
		EKeys::M.IsValid() &&
		EKeys::N.IsValid() &&
		EKeys::O.IsValid() &&
		EKeys::P.IsValid() &&
		EKeys::Q.IsValid() &&
		EKeys::R.IsValid() &&
		EKeys::S.IsValid() &&
		EKeys::T.IsValid() &&
		EKeys::U.IsValid() &&
		EKeys::V.IsValid() &&
		EKeys::W.IsValid() &&
		EKeys::X.IsValid() &&
		EKeys::Y.IsValid() &&
		EKeys::Z.IsValid();

	bool bNumPad =
		EKeys::NumPadZero.IsValid() &&
		EKeys::NumPadOne.IsValid() &&
		EKeys::NumPadTwo.IsValid() &&
		EKeys::NumPadThree.IsValid() &&
		EKeys::NumPadFour.IsValid() &&
		EKeys::NumPadFive.IsValid() &&
		EKeys::NumPadSix.IsValid() &&
		EKeys::NumPadSeven.IsValid() &&
		EKeys::NumPadEight.IsValid() &&
		EKeys::NumPadNine.IsValid() &&
		EKeys::Multiply.IsValid() &&
		EKeys::Add.IsValid() &&
		EKeys::Subtract.IsValid() &&
		EKeys::Decimal.IsValid() &&
		EKeys::Divide.IsValid();

	bool bFunction =
		EKeys::F1.IsValid() &&
		EKeys::F2.IsValid() &&
		EKeys::F3.IsValid() &&
		EKeys::F4.IsValid() &&
		EKeys::F5.IsValid() &&
		EKeys::F6.IsValid() &&
		EKeys::F7.IsValid() &&
		EKeys::F8.IsValid() &&
		EKeys::F9.IsValid() &&
		EKeys::F10.IsValid() &&
		EKeys::F11.IsValid() &&
		EKeys::F12.IsValid() &&
		EKeys::NumLock.IsValid() &&
		EKeys::ScrollLock.IsValid();

	bool bModifiers =
		EKeys::LeftShift.IsModifierKey() &&
		EKeys::RightShift.IsModifierKey() &&
		EKeys::LeftControl.IsModifierKey() &&
		EKeys::RightControl.IsModifierKey() &&
		EKeys::LeftAlt.IsModifierKey() &&
		EKeys::RightAlt.IsModifierKey() &&
		EKeys::LeftCommand.IsModifierKey() &&
		EKeys::RightCommand.IsModifierKey();

	bool bPunctuation =
		EKeys::Semicolon.IsValid() &&
		EKeys::Equals.IsValid() &&
		EKeys::Comma.IsValid() &&
		EKeys::Underscore.IsValid() &&
		EKeys::Hyphen.IsValid() &&
		EKeys::Period.IsValid() &&
		EKeys::Slash.IsValid() &&
		EKeys::Tilde.IsValid() &&
		EKeys::LeftBracket.IsValid() &&
		EKeys::Backslash.IsValid() &&
		EKeys::RightBracket.IsValid() &&
		EKeys::Apostrophe.IsValid() &&
		EKeys::Ampersand.IsValid() &&
		EKeys::Asterix.IsValid() &&
		EKeys::Caret.IsValid() &&
		EKeys::Colon.IsValid() &&
		EKeys::Dollar.IsValid() &&
		EKeys::Exclamation.IsValid() &&
		EKeys::LeftParantheses.IsValid() &&
		EKeys::RightParantheses.IsValid() &&
		EKeys::Quote.IsValid() &&
		EKeys::A_AccentGrave.IsValid() &&
		EKeys::E_AccentGrave.IsValid() &&
		EKeys::E_AccentAigu.IsValid() &&
		EKeys::C_Cedille.IsValid() &&
		EKeys::Section.IsValid() &&
		EKeys::Platform_Delete.IsValid();

	bool bGamepad =
		EKeys::Gamepad_Left2D.IsAxis2D() &&
		EKeys::Gamepad_LeftX.IsAxis1D() &&
		EKeys::Gamepad_LeftY.IsAxis1D() &&
		EKeys::Gamepad_Right2D.IsAxis2D() &&
		EKeys::Gamepad_RightX.IsAxis1D() &&
		EKeys::Gamepad_RightY.IsAxis1D() &&
		EKeys::Gamepad_LeftTriggerAxis.IsValid() &&
		EKeys::Gamepad_RightTriggerAxis.IsValid() &&
		EKeys::Gamepad_LeftThumbstick.IsGamepadKey() &&
		EKeys::Gamepad_RightThumbstick.IsGamepadKey() &&
		EKeys::Gamepad_Special_Left.IsGamepadKey() &&
		EKeys::Gamepad_Special_Left_X.IsValid() &&
		EKeys::Gamepad_Special_Left_Y.IsValid() &&
		EKeys::Gamepad_Special_Right.IsGamepadKey() &&
		EKeys::Gamepad_FaceButton_Bottom.IsGamepadKey() &&
		EKeys::Gamepad_FaceButton_Right.IsGamepadKey() &&
		EKeys::Gamepad_FaceButton_Left.IsGamepadKey() &&
		EKeys::Gamepad_FaceButton_Top.IsGamepadKey() &&
		EKeys::Gamepad_LeftShoulder.IsGamepadKey() &&
		EKeys::Gamepad_RightShoulder.IsGamepadKey() &&
		EKeys::Gamepad_LeftTrigger.IsGamepadKey() &&
		EKeys::Gamepad_RightTrigger.IsGamepadKey() &&
		EKeys::Gamepad_DPad_Up.IsGamepadKey() &&
		EKeys::Gamepad_DPad_Down.IsGamepadKey() &&
		EKeys::Gamepad_DPad_Right.IsGamepadKey() &&
		EKeys::Gamepad_DPad_Left.IsGamepadKey() &&
		EKeys::Gamepad_LeftStick_Up.IsValid() &&
		EKeys::Gamepad_LeftStick_Down.IsValid() &&
		EKeys::Gamepad_LeftStick_Right.IsValid() &&
		EKeys::Gamepad_LeftStick_Left.IsValid() &&
		EKeys::Gamepad_RightStick_Up.IsValid() &&
		EKeys::Gamepad_RightStick_Down.IsValid() &&
		EKeys::Gamepad_RightStick_Right.IsValid() &&
		EKeys::Gamepad_RightStick_Left.IsValid();

	bool bMotion =
		EKeys::Tilt.IsAxis3D() &&
		EKeys::RotationRate.IsAxis3D() &&
		EKeys::Gravity.IsAxis3D() &&
		EKeys::Acceleration.IsAxis3D() &&
		EKeys::Gesture_Pinch.IsValid() &&
		EKeys::Gesture_Flick.IsValid() &&
		EKeys::Gesture_Rotate.IsValid();

	bool bPlatform =
		EKeys::Steam_Touch_0.IsValid() &&
		EKeys::Steam_Touch_1.IsValid() &&
		EKeys::Steam_Touch_2.IsValid() &&
		EKeys::Steam_Touch_3.IsValid() &&
		EKeys::Steam_Back_Left.IsValid() &&
		EKeys::Steam_Back_Right.IsValid() &&
		EKeys::Global_Menu.IsValid() &&
		EKeys::Global_View.IsValid() &&
		EKeys::Global_Pause.IsValid() &&
		EKeys::Global_Play.IsValid() &&
		EKeys::Global_Back.IsValid() &&
		EKeys::Android_Back.IsValid() &&
		EKeys::Android_Volume_Up.IsValid() &&
		EKeys::Android_Volume_Down.IsValid() &&
		EKeys::Android_Menu.IsValid() &&
		EKeys::Virtual_Accept.IsValid() &&
		EKeys::Virtual_Back.IsValid();

	bool bInvalid = !EKeys::Invalid.IsValid();
	return bAny &&
		bMouse &&
		bTyping &&
		bDigits &&
		bLetters &&
		bNumPad &&
		bFunction &&
		bModifiers &&
		bPunctuation &&
		bGamepad &&
		bMotion &&
		bPlatform &&
		bInvalid;
}
/** @end */
/**
 * @begin equality-host-x
 * @summary values.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary values.
 * @covers InputEvents.equality
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FKey Left = n"SpaceBar";
	FKey Right = n"SpaceBar";
	FKey Other = n"Enter";
	FKey Empty;
	FKey OtherEmpty;
	return (Left == Right) && !(Left == Other) && !(Left == Empty) && (Empty == OtherEmpty);
}
/** @end */
/**
 * @begin is-valid
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary FText.
 * @covers InputEvents.is-valid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FKey Empty;
	return !Empty.IsValid() && !EKeys::Invalid.IsValid() && EKeys::SpaceBar.IsValid() && EKeys::AnyKey.IsValid();
}
/** @end */
/**
 * @begin is-modifier-key
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsModifierKeyNominal
 * @summary FText.
 * @covers InputEvents.is-modifier-key
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsModifierKeyNominal()
{
	FKey Empty;
	return EKeys::LeftShift.IsModifierKey() && !EKeys::SpaceBar.IsModifierKey() && !Empty.IsModifierKey();
}
/** @end */
/**
 * @begin is-gamepad-key
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsGamepadKeyNominal
 * @summary FText.
 * @covers InputEvents.is-gamepad-key
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsGamepadKeyNominal()
{
	FKey Empty;
	return EKeys::Gamepad_FaceButton_Bottom.IsGamepadKey() && !EKeys::SpaceBar.IsGamepadKey() && !Empty.IsGamepadKey();
}
/** @end */
/**
 * @begin is-touch
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsTouchNominal
 * @summary FText.
 * @covers InputEvents.is-touch
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTouchNominal()
{
	FKey NamedTouch(n"Touch");
	FKey Touch1(n"Touch1");
	FKey Empty;
	return !NamedTouch.IsValid() &&
		!NamedTouch.IsTouch() &&
		Touch1.IsValid() &&
		Touch1.IsTouch() &&
		!EKeys::SpaceBar.IsTouch() &&
		!Empty.IsTouch() &&
		!EKeys::Steam_Touch_0.IsTouch();
}
/** @end */
/**
 * @begin is-mouse-button
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsMouseButtonNominal
 * @summary FText.
 * @covers InputEvents.is-mouse-button
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsMouseButtonNominal()
{
	FKey Empty;
	return EKeys::LeftMouseButton.IsMouseButton() && !EKeys::SpaceBar.IsMouseButton() && !Empty.IsMouseButton();
}
/** @end */
/**
 * @begin is-axis-1-d
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsAxis1DNominal
 * @summary FText.
 * @covers InputEvents.is-axis-1-d
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAxis1DNominal()
{
	FKey Empty;
	return EKeys::MouseX.IsAxis1D() && EKeys::Gamepad_LeftX.IsAxis1D() && !EKeys::SpaceBar.IsAxis1D() && !Empty.IsAxis1D();
}
/** @end */
/**
 * @begin is-axis-2-d
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsAxis2DNominal
 * @summary FText.
 * @covers InputEvents.is-axis-2-d
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAxis2DNominal()
{
	FKey Empty;
	return EKeys::Mouse2D.IsAxis2D() && EKeys::Gamepad_Left2D.IsAxis2D() && !EKeys::SpaceBar.IsAxis2D() && !Empty.IsAxis2D();
}
/** @end */
/**
 * @begin is-axis-3-d
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveIsAxis3DNominal
 * @summary FText.
 * @covers InputEvents.is-axis-3-d
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAxis3DNominal()
{
	FKey Empty;
	return EKeys::Tilt.IsAxis3D() && EKeys::Gravity.IsAxis3D() && !EKeys::SpaceBar.IsAxis3D() && !Empty.IsAxis3D();
}
/** @end */
/**
 * @begin get-display-name
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveGetDisplayNameNominal
 * @summary FText.
 * @covers InputEvents.get-display-name
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDisplayNameNominal()
{
	FString LongText = EKeys::SpaceBar.GetDisplayName().ToString();
	FString ShortText = EKeys::SpaceBar.GetDisplayName(false).ToString();
	FString EmptyText = FKey().GetDisplayName().ToString();
	return LongText.Contains("Space") && ShortText.Contains("Space") && EmptyText == "None";
}
/** @end */
/**
 * @begin get-key-name
 * @summary FText.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyNameNominal
 * @summary FText.
 * @covers InputEvents.get-key-name
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetKeyNameNominal()
{
	return EKeys::SpaceBar.GetKeyName() == n"SpaceBar" && FKey().GetKeyName().IsNone() && EKeys::Invalid.GetKeyName().IsNone();
}
/** @end */
/**
 * @begin is-repeat
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsRepeatNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-repeat
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRepeatNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsRepeat();
}
/** @end */
/**
 * @begin is-shift-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsShiftDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsShiftDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsShiftDown();
}
/** @end */
/**
 * @begin is-left-shift-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftShiftDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-left-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftShiftDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsLeftShiftDown();
}
/** @end */
/**
 * @begin is-right-shift-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightShiftDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-right-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightShiftDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsRightShiftDown();
}
/** @end */
/**
 * @begin is-control-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsControlDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsControlDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsControlDown();
}
/** @end */
/**
 * @begin is-left-control-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftControlDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-left-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftControlDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsLeftControlDown();
}
/** @end */
/**
 * @begin is-right-control-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightControlDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-right-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightControlDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsRightControlDown();
}
/** @end */
/**
 * @begin is-alt-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsAltDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAltDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsAltDown();
}
/** @end */
/**
 * @begin is-left-alt-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftAltDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-left-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftAltDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsLeftAltDown();
}
/** @end */
/**
 * @begin is-right-alt-down
 * @summary the native event payload, not to a copied FKey.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightAltDownNominal
 * @summary the native event payload, not to a copied FKey.
 * @covers InputEvents.is-right-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightAltDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsRightAltDown();
}
/** @end */
/**
 * @begin is-command-down
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveIsCommandDownNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.is-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsCommandDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsCommandDown();
}
/** @end */
/**
 * @begin is-left-command-down
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftCommandDownNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.is-left-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftCommandDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsLeftCommandDown();
}
/** @end */
/**
 * @begin is-right-command-down
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightCommandDownNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.is-right-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightCommandDownNominal()
{
	FKeyEvent KeyEvent;
	return !KeyEvent.IsRightCommandDown();
}
/** @end */
/**
 * @begin get-platform-userid
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlatformUseridNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.get-platform-userid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlatformUseridNominal()
{
	FKeyEvent KeyEvent;
	FPlatformUserId PlatformUser = KeyEvent.GetPlatformUserid();
	FPlatformUserId Again = KeyEvent.GetPlatformUserid();
	return PlatformUser == Again;
}
/** @end */
/**
 * @begin get-input-device-id
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputDeviceIdNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.get-input-device-id
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInputDeviceIdNominal()
{
	FKeyEvent KeyEvent;
	FInputDeviceId InputDevice = KeyEvent.GetInputDeviceId();
	FInputDeviceId Again = KeyEvent.GetInputDeviceId();
	return InputDevice == Again;
}
/** @end */
/**
 * @begin get-key
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.get-key
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetKeyNominal()
{
	FKeyEvent KeyEvent;
	FKey Key = KeyEvent.GetKey();
	return !Key.IsValid() && Key == FKey();
}
/** @end */
/**
 * @begin get-character
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveGetCharacterNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.get-character
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCharacterNominal()
{
	FKeyEvent KeyEvent;
	return KeyEvent.GetCharacter() == 0;
}
/** @end */
/**
 * @begin get-key-code
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyCodeNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.get-key-code
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetKeyCodeNominal()
{
	FKeyEvent KeyEvent;
	return KeyEvent.GetKeyCode() == 0;
}
/** @end */
/**
 * @begin InputEvents-Queries_03-is-repeat
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveIsRepeatNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.is-repeat
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRepeatNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsRepeat();
}
/** @end */
/**
 * @begin InputEvents-Queries_03-is-shift-down
 * @summary identify the event source and do not own hardware.
 * @topic Unreal
 */
/**
 * @function ObserveIsShiftDownNominal
 * @summary identify the event source and do not own hardware.
 * @covers InputEvents.is-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsShiftDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-left-shift-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftShiftDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-left-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftShiftDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsLeftShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-right-shift-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightShiftDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-right-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightShiftDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsRightShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-control-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsControlDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-left-control-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-left-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftControlDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsLeftControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-right-control-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-right-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightControlDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsRightControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-alt-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAltDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-left-alt-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-left-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftAltDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsLeftAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-right-alt-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-right-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightAltDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsRightAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-command-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsCommandDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_04-is-left-command-down
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the pointer event.
 * @covers InputEvents.is-left-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftCommandDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsLeftCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_05-is-right-command-down
 * @summary consumed 2D values.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightCommandDownNominal
 * @summary consumed 2D values.
 * @covers InputEvents.is-right-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

 deltas are (0,0) on the empty event.
// IsMouseButtonDown is false for LeftMouseButton and Invalid. Effecting button
// is invalid. Wheel delta is 0.
// Boundary/ownership: Positions are desktop-space Slate units. Queries do not
// mutate the pointer event. IsMouseButtonDown borrows MouseButton by value.
bool ObserveIsRightCommandDownNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsRightCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_05-get-platform-userid
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlatformUseridNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-platform-userid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetPlatformUseridNominal()
{
	FPointerEvent PointerEvent;
	FPlatformUserId PlatformUser = PointerEvent.GetPlatformUserid();
	FPlatformUserId Again = PointerEvent.GetPlatformUserid();
	return PlatformUser == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_05-get-input-device-id
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputDeviceIdNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-input-device-id
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetInputDeviceIdNominal()
{
	FPointerEvent PointerEvent;
	FInputDeviceId InputDevice = PointerEvent.GetInputDeviceId();
	FInputDeviceId Again = PointerEvent.GetInputDeviceId();
	return InputDevice == Again;
}
/** @end */
/**
 * @begin get-screen-space-position
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetScreenSpacePositionNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-screen-space-position
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetScreenSpacePositionNominal()
{
	FPointerEvent PointerEvent;
	FVector2D Position = PointerEvent.GetScreenSpacePosition();
	return Position.X == 0.0 && Position.Y == 0.0;
}
/** @end */
/**
 * @begin get-last-screen-space-position
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetLastScreenSpacePositionNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-last-screen-space-position
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetLastScreenSpacePositionNominal()
{
	FPointerEvent PointerEvent;
	FVector2D LastPosition = PointerEvent.GetLastScreenSpacePosition();
	return LastPosition.X == 0.0 && LastPosition.Y == 0.0;
}
/** @end */
/**
 * @begin get-cursor-delta
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetCursorDeltaNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-cursor-delta
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetCursorDeltaNominal()
{
	FPointerEvent PointerEvent;
	FVector2D Delta = PointerEvent.GetCursorDelta();
	return Delta.X == 0.0 && Delta.Y == 0.0;
}
/** @end */
/**
 * @begin get-gesture-delta
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetGestureDeltaNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-gesture-delta
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetGestureDeltaNominal()
{
	FPointerEvent PointerEvent;
	FVector2D Gesture = PointerEvent.GetGestureDelta();
	return Gesture.X == 0.0 && Gesture.Y == 0.0;
}
/** @end */
/**
 * @begin is-mouse-button-down
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveIsMouseButtonDownNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.is-mouse-button-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveIsMouseButtonDownNominal()
{
	FPointerEvent PointerEvent;
	FKey Empty;
	return !PointerEvent.IsMouseButtonDown(EKeys::LeftMouseButton) &&
		!PointerEvent.IsMouseButtonDown(EKeys::Invalid) &&
		!PointerEvent.IsMouseButtonDown(Empty);
}
/** @end */
/**
 * @begin get-effecting-button
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetEffectingButtonNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-effecting-button
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetEffectingButtonNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.GetEffectingButton().IsValid();
}
/** @end */
/**
 * @begin get-wheel-delta
 * @summary mutate the pointer event.
 * @topic Unreal
 */
/**
 * @function ObserveGetWheelDeltaNominal
 * @summary mutate the pointer event.
 * @covers InputEvents.get-wheel-delta
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
// consumed 2D values. Cursor and gesture

bool ObserveGetWheelDeltaNominal()
{
	FPointerEvent PointerEvent;
	return PointerEvent.GetWheelDelta() == 0.0;
}
/** @end */
/**
 * @begin get-touch-force
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveGetTouchForceNominal
 * @summary not mutate either event.
 * @covers InputEvents.get-touch-force
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTouchForceNominal()
{
	FPointerEvent PointerEvent;
	return PointerEvent.GetTouchForce() == 1.0;
}
/** @end */
/**
 * @begin is-touch-event
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsTouchEventNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-touch-event
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTouchEventNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsTouchEvent();
}
/** @end */
/**
 * @begin is-touch-force-changed-event
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsTouchForceChangedEventNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-touch-force-changed-event
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTouchForceChangedEventNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsTouchForceChangedEvent();
}
/** @end */
/**
 * @begin is-touch-first-move-event
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsTouchFirstMoveEventNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-touch-first-move-event
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsTouchFirstMoveEventNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsTouchFirstMoveEvent();
}
/** @end */
/**
 * @begin is-direction-inverted-from-device
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsDirectionInvertedFromDeviceNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-direction-inverted-from-device
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsDirectionInvertedFromDeviceNominal()
{
	FPointerEvent PointerEvent;
	return !PointerEvent.IsDirectionInvertedFromDevice();
}
/** @end */
/**
 * @begin InputEvents-Queries_06-is-repeat
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRepeatNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-repeat
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRepeatNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsRepeat();
}
/** @end */
/**
 * @begin InputEvents-Queries_06-is-shift-down
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsShiftDownNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsShiftDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_06-is-left-shift-down
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftShiftDownNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-left-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftShiftDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsLeftShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_06-is-right-shift-down
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightShiftDownNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-right-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightShiftDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsRightShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_06-is-control-down
 * @summary not mutate either event.
 * @topic Unreal
 */
/**
 * @function ObserveIsControlDownNominal
 * @summary not mutate either event.
 * @covers InputEvents.is-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsControlDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-left-control-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-left-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftControlDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsLeftControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-right-control-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-right-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightControlDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsRightControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-alt-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAltDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-left-alt-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-left-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftAltDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsLeftAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-right-alt-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-right-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightAltDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsRightAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-command-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsCommandDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-left-command-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-left-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftCommandDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsLeftCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-is-right-command-down
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.is-right-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightCommandDownNominal()
{
	FNavigationEvent NavigationEvent;
	return !NavigationEvent.IsRightCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_07-get-platform-userid
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlatformUseridNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.get-platform-userid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlatformUseridNominal()
{
	FNavigationEvent NavigationEvent;
	FPlatformUserId PlatformUser = NavigationEvent.GetPlatformUserid();
	FPlatformUserId Again = NavigationEvent.GetPlatformUserid();
	return PlatformUser == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_07-get-input-device-id
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputDeviceIdNominal
 * @summary Boundary/ownership: Queries do not mutate the navigation event.
 * @covers InputEvents.get-input-device-id
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInputDeviceIdNominal()
{
	FNavigationEvent NavigationEvent;
	FInputDeviceId InputDevice = NavigationEvent.GetInputDeviceId();
	FInputDeviceId Again = NavigationEvent.GetInputDeviceId();
	return InputDevice == Again;
}
/** @end */
/**
 * @begin get-navigation-type
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetNavigationTypeNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-navigation-type
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNavigationTypeNominal()
{
	FNavigationEvent NavigationEvent;
	return NavigationEvent.GetNavigationType() == EUINavigation::Invalid;
}
/** @end */
/**
 * @begin get-navigation-genesis
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetNavigationGenesisNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-navigation-genesis
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNavigationGenesisNominal()
{
	FNavigationEvent NavigationEvent;
	return NavigationEvent.GetNavigationGenesis() == ENavigationGenesis::User;
}
/** @end */
/**
 * @begin get-analog-value
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetAnalogValueNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-analog-value
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAnalogValueNominal()
{
	FAnalogInputEvent AnalogInputEvent;
	return AnalogInputEvent.GetAnalogValue() == 0.0;
}
/** @end */
/**
 * @begin InputEvents-Queries_08-get-platform-userid
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlatformUseridNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-platform-userid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlatformUseridNominal()
{
	FAnalogInputEvent AnalogInputEvent;
	FPlatformUserId PlatformUser = AnalogInputEvent.GetPlatformUserid();
	FPlatformUserId Again = AnalogInputEvent.GetPlatformUserid();
	return PlatformUser == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_08-get-input-device-id
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputDeviceIdNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-input-device-id
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInputDeviceIdNominal()
{
	FAnalogInputEvent AnalogInputEvent;
	FInputDeviceId InputDevice = AnalogInputEvent.GetInputDeviceId();
	FInputDeviceId Again = AnalogInputEvent.GetInputDeviceId();
	return InputDevice == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_08-get-key
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-key
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetKeyNominal()
{
	FAnalogInputEvent AnalogInputEvent;
	return !AnalogInputEvent.GetKey().IsValid();
}
/** @end */
/**
 * @begin InputEvents-Queries_08-get-key-code
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyCodeNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-key-code
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetKeyCodeNominal()
{
	FAnalogInputEvent AnalogInputEvent;
	return AnalogInputEvent.GetKeyCode() == 0;
}
/** @end */
/**
 * @begin get-cause
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetCauseNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-cause
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCauseNominal()
{
	FFocusEvent FocusEvent;
	return FocusEvent.GetCause() == EFocusCause::SetDirectly;
}
/** @end */
/**
 * @begin get-user
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetUserNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.get-user
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUserNominal()
{
	FFocusEvent FocusEvent;
	return FocusEvent.GetUser() == 0;
}
/** @end */
/**
 * @begin InputEvents-Queries_08-is-repeat
 * @summary is a scalar, not a 2D stick vector.
 * @topic Unreal
 */
/**
 * @function ObserveIsRepeatNominal
 * @summary is a scalar, not a 2D stick vector.
 * @covers InputEvents.is-repeat
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRepeatNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsRepeat();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-shift-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsShiftDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsShiftDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-left-shift-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftShiftDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-left-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftShiftDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsLeftShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-right-shift-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightShiftDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-right-shift-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightShiftDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsRightShiftDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-control-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsControlDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-left-control-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-left-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftControlDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsLeftControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-right-control-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightControlDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-right-control-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightControlDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsRightControlDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-alt-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAltDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-left-alt-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-left-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftAltDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsLeftAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-right-alt-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightAltDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-right-alt-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightAltDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsRightAltDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_09-is-command-down
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @topic Unreal
 */
/**
 * @function ObserveIsCommandDownNominal
 * @summary Boundary/ownership: Queries do not mutate the character event.
 * @covers InputEvents.is-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsCommandDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_10-is-left-command-down
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveIsLeftCommandDownNominal
 * @summary event.
 * @covers InputEvents.is-left-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLeftCommandDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsLeftCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_10-is-right-command-down
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveIsRightCommandDownNominal
 * @summary event.
 * @covers InputEvents.is-right-command-down
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsRightCommandDownNominal()
{
	FCharacterEvent CharacterEvent;
	return !CharacterEvent.IsRightCommandDown();
}
/** @end */
/**
 * @begin InputEvents-Queries_10-get-platform-userid
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveGetPlatformUseridNominal
 * @summary event.
 * @covers InputEvents.get-platform-userid
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetPlatformUseridNominal()
{
	FCharacterEvent CharacterEvent;
	FPlatformUserId PlatformUser = CharacterEvent.GetPlatformUserid();
	FPlatformUserId Again = CharacterEvent.GetPlatformUserid();
	return PlatformUser == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_10-get-input-device-id
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveGetInputDeviceIdNominal
 * @summary event.
 * @covers InputEvents.get-input-device-id
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetInputDeviceIdNominal()
{
	FCharacterEvent CharacterEvent;
	FInputDeviceId InputDevice = CharacterEvent.GetInputDeviceId();
	FInputDeviceId Again = CharacterEvent.GetInputDeviceId();
	return InputDevice == Again;
}
/** @end */
/**
 * @begin InputEvents-Queries_10-get-character
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveGetCharacterNominal
 * @summary event.
 * @covers InputEvents.get-character
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetCharacterNominal()
{
	FCharacterEvent CharacterEvent;
	return CharacterEvent.GetCharacter() == 0;
}
/** @end */
/**
 * @begin get-string
 * @summary event.
 * @topic Unreal
 */
/**
 * @function ObserveGetStringNominal
 * @summary event.
 * @covers InputEvents.get-string
 * @inputs InputEvents values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetStringNominal()
{
	FCharacterEvent CharacterEvent;
	return CharacterEvent.GetString().Len() == 1;
}
/** @end */
/**
 * @begin should-fire-delegates-in-editor
 * @summary mutate bindings.
 * @topic Unreal
 */
/**
 * @function ObserveShouldFireDelegatesInEditorNominal
 * @summary mutate bindings.
 * @covers UEnhancedInputComponent.should-fire-delegates-in-editor
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
// component

bool ObserveShouldFireDelegatesInEditorNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_Behavior_01 setup: required Component is null");
	}
	bool bDefault = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(true);
	bool bEnabled = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(false);
	bool bDisabled = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(bDefault);
	return bEnabled && !bDisabled;
}
/** @end */
/**
 * @begin set-should-fire-delegates-in-editor
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveSetShouldFireDelegatesInEditorNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.set-should-fire-delegates-in-editor
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveSetShouldFireDelegatesInEditorNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	bool bDefault = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(true);
	bool bEnabled = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(true);
	bool bRepeated = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(false);
	bool bDisabled = Component.ShouldFireDelegatesInEditor();
	Component.SetShouldFireDelegatesInEditor(bDefault);
	return bEnabled && bRepeated && !bDisabled;
}
/** @end */
/**
 * @begin clear-action-event-bindings
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveClearActionEventBindingsNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.clear-action-event-bindings
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveClearActionEventBindingsNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearEventsAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
	bool bBefore = Component.HasBindings();
	Component.ClearActionEventBindings();
	bool bAfter = Component.HasBindings();
	Component.ClearActionEventBindings();
	return bBefore && !bAfter && !Component.HasBindings();
}
/** @end */
/**
 * @begin clear-action-value-bindings
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveClearActionValueBindingsNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.clear-action-value-bindings
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveClearActionValueBindingsNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearValuesAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	Component.BindActionValue(Action);
	bool bBefore = Component.HasBindings();
	Component.ClearActionValueBindings();
	bool bAfter = Component.HasBindings();
	Component.ClearActionValueBindings();
	return bBefore && !bAfter;
}
/** @end */
/**
 * @begin clear-debug-key-bindings
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveClearDebugKeyBindingsNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.clear-debug-key-bindings
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveClearDebugKeyBindingsNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	FInputDebugKeyHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnDebug");
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, Delegate);
	bool bBefore = Component.HasBindings();
	Component.ClearDebugKeyBindings();
	bool bAfter = Component.HasBindings();
	Component.ClearDebugKeyBindings();
	return bBefore && !bAfter;
}
/** @end */
/**
 * @begin clear-action-bindings
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveClearActionBindingsNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.clear-action-bindings
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveClearActionBindingsNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearActionsAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	Component.BindAction(Action, ETriggerEvent::Started, Delegate);
	Component.BindActionValue(Action);
	bool bBefore = Component.HasBindings();
	Component.ClearActionBindings();
	bool bAfter = Component.HasBindings();
	Component.ClearActionBindings();
	return bBefore && !bAfter;
}
/** @end */
/**
 * @begin clear-bindings-for-object
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveClearBindingsForObjectNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.clear-bindings-for-object
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveClearBindingsForObjectNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.ClearForObjectAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
	bool bBefore = Component.HasBindings();
	UObject NullOwner = nullptr;
	Component.ClearBindingsForObject(NullOwner);
	bool bAfterNull = Component.HasBindings();
	Component.ClearBindingsForObject(Host);
	bool bAfterHost = Component.HasBindings();
	Component.ClearBindingsForObject(Host);
	return bBefore && bAfterNull && !bAfterHost;
}
/** @end */
/**
 * @begin remove-action-event-binding
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveActionEventBindingNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.remove-action-event-binding
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveRemoveActionEventBindingNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveEventAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionEventBindings();
	Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
	bool bRemovedFirst = Component.RemoveActionEventBinding(0);
	bool bRemovedEmpty = Component.RemoveActionEventBinding(0);
	bool bRemovedNegative = Component.RemoveActionEventBinding(-1);
	return bRemovedFirst && !bRemovedEmpty && !bRemovedNegative;
}
/** @end */
/**
 * @begin remove-debug-key-binding
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveDebugKeyBindingNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.remove-debug-key-binding
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveRemoveDebugKeyBindingNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	FInputDebugKeyHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnDebug");
	Component.ClearDebugKeyBindings();
	Component.BindDebugKey(FInputChord(EKeys::F), EInputEvent::IE_Pressed, Delegate, true);
	bool bRemovedFirst = Component.RemoveDebugKeyBinding(0);
	bool bRemovedEmpty = Component.RemoveDebugKeyBinding(0);
	return bRemovedFirst && !bRemovedEmpty;
}
/** @end */
/**
 * @begin remove-action-value-binding
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveActionValueBindingNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.remove-action-value-binding
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveRemoveActionValueBindingNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveValueAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	Component.ClearActionValueBindings();
	Component.BindActionValue(Action);
	bool bRemovedFirst = Component.RemoveActionValueBinding(0);
	bool bRemovedEmpty = Component.RemoveActionValueBinding(0);
	return bRemovedFirst && !bRemovedEmpty;
}
/** @end */
/**
 * @begin remove-binding-by-handle
 * @summary object; clears do not destroy the host.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveBindingByHandleNominal
 * @summary object; clears do not destroy the host.
 * @covers UEnhancedInputComponent.remove-binding-by-handle
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputMutationHost : UObject
{

bool ObserveRemoveBindingByHandleNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Component is null");
	}
	UTSEnhancedInputMutationHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveHandleAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionEventBindings();
	FEnhancedInputActionEventBinding& EventBinding = Component.BindAction(Action, ETriggerEvent::Started, Delegate);
	uint32 Handle = EventBinding.GetHandle();
	bool bRemovedHandle = Component.RemoveBindingByHandle(Handle);
	bool bRemovedAgain = Component.RemoveBindingByHandle(Handle);
	bool bRemovedZero = Component.RemoveBindingByHandle(0);
	return Handle != 0 && bRemovedHandle && !bRemovedAgain && !bRemovedZero;
}
/** @end */
/**
 * @begin remove-binding
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveRemoveBindingNominal
 * @summary SetupOwner=Runner.
 * @covers UEnhancedInputComponent.remove-binding
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputBindHost : UObject
{

bool ObserveRemoveBindingNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
	}
	UTSEnhancedInputBindHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.RemoveBindingAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature ActionDelegate;
	ActionDelegate.BindUFunction(Host, n"OnAction");
	FInputDebugKeyHandlerDynamicSignature DebugDelegate;
	DebugDelegate.BindUFunction(Host, n"OnDebug");

	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();

	FInputBindingHandle EmptyHandle;
	bool bEmptyHandleRemoved = Component.RemoveBinding(EmptyHandle);

	FEnhancedInputActionEventBinding& EventBinding = Component.BindAction(Action, ETriggerEvent::Started, ActionDelegate);
	uint32 EventHandle = EventBinding.GetHandle();
	bool bEventRemoved = Component.RemoveBinding(EventBinding);

	FEnhancedInputActionValueBinding EmptyValue;
	bool bEmptyValueRemoved = Component.RemoveBinding(EmptyValue);
	FEnhancedInputActionValueBinding& ValueBinding = Component.BindActionValue(Action);
	uint32 ValueHandle = ValueBinding.GetHandle();
	bool bValueRemoved = Component.RemoveBinding(ValueBinding);

	FInputDebugKeyBinding EmptyDebug;
	bool bEmptyDebugRemoved = Component.RemoveBinding(EmptyDebug);
	FInputDebugKeyBinding& DebugBinding = Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, DebugDelegate);
	uint32 DebugHandle = DebugBinding.GetHandle();
	bool bDebugRemoved = Component.RemoveBinding(DebugBinding);

	return !bEmptyHandleRemoved &&
		EventHandle != 0 &&
		bEventRemoved &&
		!bEmptyValueRemoved &&
		ValueHandle != 0 &&
		bValueRemoved &&
		!bEmptyDebugRemoved &&
		DebugHandle != 0 &&
		bDebugRemoved;
}
/** @end */
/**
 * @begin bind-action
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveBindActionNominal
 * @summary SetupOwner=Runner.
 * @covers UEnhancedInputComponent.bind-action
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputBindHost : UObject
{

bool ObserveBindActionNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
	}
	UTSEnhancedInputBindHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BindActionAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
	}
	FEnhancedInputActionHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnAction");
	Component.ClearActionEventBindings();
	FEnhancedInputActionEventBinding& Started = Component.BindAction(Action, ETriggerEvent::Started, Delegate);
	FEnhancedInputActionEventBinding& Triggered = Component.BindAction(Action, ETriggerEvent::Triggered, Delegate);
	uint32 StartedHandle = Started.GetHandle();
	UInputAction StartedAction = Started.GetAction();
	ETriggerEvent StartedTrigger = Started.GetTriggerEvent();
	uint32 TriggeredHandle = Triggered.GetHandle();
	bool bHasBindings = Component.HasBindings();
	return StartedAction == Action &&
		StartedTrigger == ETriggerEvent::Started &&
		StartedHandle != TriggeredHandle &&
		bHasBindings;
}
/** @end */
/**
 * @begin bind-action-value
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveBindActionValueNominal
 * @summary SetupOwner=Runner.
 * @covers UEnhancedInputComponent.bind-action-value
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputBindHost : UObject
{

bool ObserveBindActionValueNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
	}
	UTSEnhancedInputBindHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BindActionValueAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Action is null");
	}
	Component.ClearActionValueBindings();
	FEnhancedInputActionValueBinding& ValueBinding = Component.BindActionValue(Action);
	UInputAction BoundAction = ValueBinding.GetAction();
	uint32 Handle = ValueBinding.GetHandle();
	FInputActionValue Value = ValueBinding.GetValue();
	FEnhancedInputActionValueBinding& Alias = Component.BindActionValue(Action);
	uint32 AliasHandle = Alias.GetHandle();
	return BoundAction == Action &&
		!Value.IsNonZero() &&
		Component.HasBindings() &&
		Handle == AliasHandle;
}
/** @end */
/**
 * @begin bind-debug-key
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveBindDebugKeyNominal
 * @summary SetupOwner=Runner.
 * @covers UEnhancedInputComponent.bind-debug-key
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputBindHost : UObject
{

bool ObserveBindDebugKeyNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_MutationAndLifecycle_02 setup: required Component is null");
	}
	UTSEnhancedInputBindHost Host;
	FInputDebugKeyHandlerDynamicSignature Delegate;
	Delegate.BindUFunction(Host, n"OnDebug");
	Component.ClearDebugKeyBindings();
	FInputDebugKeyBinding& DefaultPaused = Component.BindDebugKey(FInputChord(EKeys::SpaceBar), EInputEvent::IE_Pressed, Delegate);
	FInputDebugKeyBinding& ExplicitPaused = Component.BindDebugKey(FInputChord(EKeys::F), EInputEvent::IE_Pressed, Delegate, true);
	FInputDebugKeyBinding& Unpaused = Component.BindDebugKey(FInputChord(EKeys::G), EInputEvent::IE_Released, Delegate, false);
	uint32 DefaultHandle = DefaultPaused.GetHandle();
	uint32 ExplicitHandle = ExplicitPaused.GetHandle();
	uint32 UnpausedHandle = Unpaused.GetHandle();
	return Component.HasBindings() &&
		DefaultHandle != ExplicitHandle &&
		ExplicitHandle != UnpausedHandle &&
		DefaultHandle != UnpausedHandle;
}
/** @end */
/**
 * @begin has-bindings
 * @summary HasBindings does not mutate the component.
 * @topic Unreal
 */
/**
 * @function ObserveHasBindingsNominal
 * @summary HasBindings does not mutate the component.
 * @covers UEnhancedInputComponent.has-bindings
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputQueryHost : UObject
{

bool ObserveHasBindingsNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_Queries_01 setup: required Component is null");
	}
	UTSEnhancedInputQueryHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.HasBindingsAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_Queries_01 setup: required Action is null");
	}
	Component.ClearActionBindings();
	Component.ClearDebugKeyBindings();
	bool bEmptyHasBindings = Component.HasBindings();
	Component.BindActionValue(Action);
	bool bBoundHasBindings = Component.HasBindings();
	Component.ClearActionValueBindings();
	bool bClearedHasBindings = Component.HasBindings();
	return !bEmptyHasBindings && bBoundHasBindings && !bClearedHasBindings;
}
/** @end */
/**
 * @begin get-bound-action-value
 * @summary HasBindings does not mutate the component.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoundActionValueNominal
 * @summary HasBindings does not mutate the component.
 * @covers UEnhancedInputComponent.get-bound-action-value
 * @inputs UEnhancedInputComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSEnhancedInputQueryHost : UObject
{

bool ObserveGetBoundActionValueNominal(UEnhancedInputComponent Component)
{
	if (Component is null)
	{
		throw("TS_UEnhancedInputComponent_Queries_01 setup: required Component is null");
	}
	UTSEnhancedInputQueryHost Host;
	UInputAction Action = Cast<UInputAction>(NewObject(Host, UInputAction::StaticClass(), n"TestSource.EnhancedInput.BoundValueAction", true));
	if (Action is null)
	{
		throw("TS_UEnhancedInputComponent_Queries_01 setup: required Action is null");
	}
	UInputAction NullAction = nullptr;
	FInputActionValue EmptyValue = Component.GetBoundActionValue(Action);
	FInputActionValue NullValue = Component.GetBoundActionValue(NullAction);
	Component.BindActionValue(Action);
	FInputActionValue BoundValue = Component.GetBoundActionValue(Action);
	Component.ClearActionValueBindings();
	return !EmptyValue.IsNonZero() &&
		!EmptyValue.Get() &&
		!NullValue.IsNonZero() &&
		!BoundValue.IsNonZero() &&
		BoundValue.GetAxis1D() == 0.0;
}
/** @end */
/**
 * @begin mapping
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveMappingNominal
 * @summary failure.
 * @covers UInputMappingContext.mapping
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMappingNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Construct", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
	UInputAction NullAction = nullptr;
	FEnhancedActionKeyMapping Empty(NullAction, EKeys::Invalid);
	return Mapping.GetAction() == Action &&
		Mapping.GetKey() == EKeys::W &&
		Empty.GetAction() is null &&
		!Empty.GetKey().IsValid();
}
/** @end */
/**
 * @begin map-key
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveMapKeyNominal
 * @summary failure.
 * @covers UInputMappingContext.map-key
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMapKeyNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.MapKey", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.MapKeyContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapped = Context.MapKey(Action, EKeys::W);
	int32 AfterFirst = Context.GetMappingCount();
	UInputAction MappedAction = Mapped.GetAction();
	FKey MappedKey = Mapped.GetKey();
	Mapped.SetKey(EKeys::A);
	FEnhancedActionKeyMapping& Alias = Context.GetMapping(0);
	FKey AliasKey = Alias.GetKey();
	Context.MapKey(Action, EKeys::S);
	int32 AfterSecond = Context.GetMappingCount();
	return AfterFirst == 1 &&
		MappedAction == Action &&
		MappedKey == EKeys::W &&
		AliasKey == EKeys::A &&
		AfterSecond == 2;
}
/** @end */
/**
 * @begin unmap-key
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveUnmapKeyNominal
 * @summary failure.
 * @covers UInputMappingContext.unmap-key
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnmapKeyNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapKey", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapKeyContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
	}
	Context.MapKey(Action, EKeys::W);
	Context.MapKey(Action, EKeys::S);
	Context.UnmapKey(Action, EKeys::W);
	int32 AfterUnmap = Context.GetMappingCount();
	Context.UnmapKey(Action, EKeys::W);
	int32 AfterMissing = Context.GetMappingCount();
	return AfterUnmap == 1 && AfterMissing == 1;
}
/** @end */
/**
 * @begin unmap-all-keys-from-action
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveUnmapAllKeysFromActionNominal
 * @summary failure.
 * @covers UInputMappingContext.unmap-all-keys-from-action
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnmapAllKeysFromActionNominal()
{
	UInputAction Move = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapActionMove", true));
	UInputAction Confirm = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapActionConfirm", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapActionContext", true));
	if (Move is null || Confirm is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
	}
	Context.MapKey(Move, EKeys::W);
	Context.MapKey(Move, EKeys::S);
	Context.MapKey(Confirm, EKeys::Enter);
	Context.UnmapAllKeysFromAction(Move);
	int32 AfterMove = Context.GetMappingCount();
	bool bConfirmRemains = Context.HasMappingForInputAction(Confirm);
	Context.UnmapAllKeysFromAction(Move);
	int32 AfterRepeat = Context.GetMappingCount();
	return AfterMove == 1 && bConfirmRemains && AfterRepeat == 1;
}
/** @end */
/**
 * @begin unmap-all
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveUnmapAllNominal
 * @summary failure.
 * @covers UInputMappingContext.unmap-all
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnmapAllNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.UnmapAll", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.UnmapAllContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Behavior_01 setup: required Context is null");
	}
	Context.MapKey(Action, EKeys::W);
	Context.MapKey(Action, EKeys::S);
	Context.UnmapAll();
	int32 AfterClear = Context.GetMappingCount();
	Context.UnmapAll();
	int32 AfterRepeat = Context.GetMappingCount();
	return AfterClear == 0 && AfterRepeat == 0;
}
/** @end */
/**
 * @begin set-value-type
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveSetValueTypeNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.set-value-type
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetValueTypeNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetValueType", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	Action.SetValueType(EInputActionValueType::Axis1D);
	EInputActionValueType AfterFirst = Action.GetValueType();
	Action.SetValueType(EInputActionValueType::Axis1D);
	EInputActionValueType AfterRepeat = Action.GetValueType();
	Action.SetValueType(EInputActionValueType::Boolean);
	EInputActionValueType Restored = Action.GetValueType();
	return AfterFirst == EInputActionValueType::Axis1D &&
		AfterRepeat == EInputActionValueType::Axis1D &&
		Restored == EInputActionValueType::Boolean;
}
/** @end */
/**
 * @begin set-accumulation-behavior
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveSetAccumulationBehaviorNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.set-accumulation-behavior
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetAccumulationBehaviorNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetAccumulation", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
	EInputActionAccumulationBehavior AfterFirst = Action.GetAccumulationBehavior();
	Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
	EInputActionAccumulationBehavior AfterRepeat = Action.GetAccumulationBehavior();
	Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::TakeHighestAbsoluteValue);
	EInputActionAccumulationBehavior Restored = Action.GetAccumulationBehavior();
	return AfterFirst == EInputActionAccumulationBehavior::Cumulative &&
		AfterRepeat == EInputActionAccumulationBehavior::Cumulative &&
		Restored == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue;
}
/** @end */
/**
 * @begin set-action
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveSetActionNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.set-action
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetActionNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetAction", true));
	UInputAction Other = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetActionOther", true));
	if (Action is null || Other is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
	Mapping.SetAction(Other);
	UInputAction AfterFirst = Mapping.GetAction();
	Mapping.SetAction(Other);
	UInputAction AfterRepeat = Mapping.GetAction();
	Mapping.SetAction(Action);
	UInputAction Restored = Mapping.GetAction();
	UInputAction NullAction = nullptr;
	Mapping.SetAction(NullAction);
	UInputAction AfterNull = Mapping.GetAction();
	return AfterFirst == Other && AfterRepeat == Other && Restored == Action && AfterNull is null;
}
/** @end */
/**
 * @begin set-key
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveSetKeyNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.set-key
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetKeyNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.SetKey", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
	Mapping.SetKey(EKeys::S);
	FKey AfterFirst = Mapping.GetKey();
	Mapping.SetKey(EKeys::S);
	FKey AfterRepeat = Mapping.GetKey();
	Mapping.SetKey(EKeys::W);
	FKey Restored = Mapping.GetKey();
	Mapping.SetKey(EKeys::Invalid);
	FKey AfterInvalid = Mapping.GetKey();
	return AfterFirst == EKeys::S && AfterRepeat == EKeys::S && Restored == EKeys::W && !AfterInvalid.IsValid();
}
/** @end */
/**
 * @begin add-modifier
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveAddModifierNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.add-modifier
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddModifierNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.AddModifier", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.AddModifierContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.AddNegate", true));
	UInputModifierScalar Scalar = Cast<UInputModifierScalar>(NewObject(Context, UInputModifierScalar::StaticClass(), n"TestSource.Mapping.AddScalar", true));
	if (Negate is null || Scalar is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Modifier is null");
	}
	Mapping.AddModifier(Negate);
	int32 AfterFirst = Mapping.GetModifierCount();
	Mapping.AddModifier(Negate);
	int32 AfterRepeat = Mapping.GetModifierCount();
	Mapping.AddModifier(Scalar);
	int32 AfterSecond = Mapping.GetModifierCount();
	UInputModifier NullModifier = nullptr;
	Mapping.AddModifier(NullModifier);
	int32 AfterNull = Mapping.GetModifierCount();
	return AfterFirst == 1 && AfterRepeat == 2 && AfterSecond == 3 && AfterNull == 3;
}
/** @end */
/**
 * @begin clear-modifiers
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveClearModifiersNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.clear-modifiers
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearModifiersNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ClearModifiers", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ClearModifiersContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.ClearNegate", true));
	if (Negate is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Modifier is null");
	}
	Mapping.AddModifier(Negate);
	Mapping.ClearModifiers();
	int32 AfterClear = Mapping.GetModifierCount();
	Mapping.ClearModifiers();
	int32 AfterRepeat = Mapping.GetModifierCount();
	return AfterClear == 0 && AfterRepeat == 0;
}
/** @end */
/**
 * @begin add-trigger
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveAddTriggerNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.add-trigger
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddTriggerNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.AddTrigger", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.AddTriggerContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.AddDown", true));
	UInputTriggerPressed Pressed = Cast<UInputTriggerPressed>(NewObject(Context, UInputTriggerPressed::StaticClass(), n"TestSource.Mapping.AddPressed", true));
	if (Down is null || Pressed is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Trigger is null");
	}
	Mapping.AddTrigger(Down);
	int32 AfterFirst = Mapping.GetTriggerCount();
	Mapping.AddTrigger(Down);
	int32 AfterRepeat = Mapping.GetTriggerCount();
	Mapping.AddTrigger(Pressed);
	int32 AfterSecond = Mapping.GetTriggerCount();
	UInputTrigger NullTrigger = nullptr;
	Mapping.AddTrigger(NullTrigger);
	int32 AfterNull = Mapping.GetTriggerCount();
	return AfterFirst == 1 && AfterRepeat == 2 && AfterSecond == 3 && AfterNull == 3;
}
/** @end */
/**
 * @begin clear-triggers
 * @summary results are setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveClearTriggersNominal
 * @summary results are setup failure.
 * @covers UInputMappingContext.clear-triggers
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClearTriggersNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ClearTriggers", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ClearTriggersContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.ClearDown", true));
	if (Down is null)
	{
		throw("TS_UInputMappingContext_MutationAndLifecycle_01 setup: required Trigger is null");
	}
	Mapping.AddTrigger(Down);
	Mapping.ClearTriggers();
	int32 AfterClear = Mapping.GetTriggerCount();
	Mapping.ClearTriggers();
	int32 AfterRepeat = Mapping.GetTriggerCount();
	return AfterClear == 0 && AfterRepeat == 0;
}
/** @end */
/**
 * @begin equality-host-x-x
 * @summary take ownership of the action.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary take ownership of the action.
 * @covers UInputMappingContext.equality
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.EqualityAction", true));
	UInputAction OtherAction = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.EqualityOtherAction", true));
	if (Action is null || OtherAction is null)
	{
		throw("TS_UInputMappingContext_Operators_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Left(Action, EKeys::W);
	FEnhancedActionKeyMapping Right(Action, EKeys::W);
	FEnhancedActionKeyMapping DifferentKey(Action, EKeys::S);
	FEnhancedActionKeyMapping DifferentAction(OtherAction, EKeys::W);
	FEnhancedActionKeyMapping EmptyLeft;
	FEnhancedActionKeyMapping EmptyRight;
	return Left == Right &&
		!(Left == DifferentKey) &&
		!(Left == DifferentAction) &&
		!(Left == EmptyLeft) &&
		EmptyLeft == EmptyRight;
}
/** @end */
/**
 * @begin get-value-type
 * @summary a
 * @topic Unreal
 */
/**
 * @function ObserveGetValueTypeNominal
 * @summary a
 * @covers UInputMappingContext.get-value-type
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

 later GetMapping(0).
// Boundary/ownership: GetMapping returns a reference into the context. Invalid
// indices follow the native TArray bounds policy. Null NewObject results are
// setup failure.
bool ObserveGetValueTypeNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ValueType", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	EInputActionValueType DefaultType = Action.GetValueType();
	Action.SetValueType(EInputActionValueType::Axis2D);
	EInputActionValueType AxisType = Action.GetValueType();
	Action.SetValueType(EInputActionValueType::Boolean);
	EInputActionValueType BooleanType = Action.GetValueType();
	return DefaultType == EInputActionValueType::Boolean &&
		AxisType == EInputActionValueType::Axis2D &&
		BooleanType == EInputActionValueType::Boolean;
}
/** @end */
/**
 * @begin get-accumulation-behavior
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetAccumulationBehaviorNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-accumulation-behavior
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetAccumulationBehaviorNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Accumulation", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	EInputActionAccumulationBehavior DefaultBehavior = Action.GetAccumulationBehavior();
	Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::Cumulative);
	EInputActionAccumulationBehavior Cumulative = Action.GetAccumulationBehavior();
	Action.SetAccumulationBehavior(EInputActionAccumulationBehavior::TakeHighestAbsoluteValue);
	EInputActionAccumulationBehavior Highest = Action.GetAccumulationBehavior();
	return DefaultBehavior == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue &&
		Cumulative == EInputActionAccumulationBehavior::Cumulative &&
		Highest == EInputActionAccumulationBehavior::TakeHighestAbsoluteValue;
}
/** @end */
/**
 * @begin get-action-host
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetActionNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-action
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetActionNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetAction", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
	FEnhancedActionKeyMapping Empty;
	return Mapping.GetAction() == Action && Empty.GetAction() is null;
}
/** @end */
/**
 * @begin get-key-host
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetKeyNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-key
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetKeyNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetKey", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	FEnhancedActionKeyMapping Mapping(Action, EKeys::W);
	FEnhancedActionKeyMapping Empty;
	return Mapping.GetKey() == EKeys::W && !Empty.GetKey().IsValid();
}
/** @end */
/**
 * @begin get-modifier-count
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetModifierCountNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-modifier-count
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetModifierCountNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.ModifierCount", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.ModifierCountContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	int32 EmptyCount = Mapping.GetModifierCount();
	UInputModifierNegate Negate = Cast<UInputModifierNegate>(NewObject(Context, UInputModifierNegate::StaticClass(), n"TestSource.Mapping.Negate", true));
	if (Negate is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Modifier is null");
	}
	Mapping.AddModifier(Negate);
	int32 PopulatedCount = Mapping.GetModifierCount();
	return EmptyCount == 0 && PopulatedCount == 1;
}
/** @end */
/**
 * @begin get-trigger-count
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetTriggerCountNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-trigger-count
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetTriggerCountNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.TriggerCount", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.TriggerCountContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
	}
	FEnhancedActionKeyMapping& Mapping = Context.MapKey(Action, EKeys::SpaceBar);
	int32 EmptyCount = Mapping.GetTriggerCount();
	UInputTriggerDown Down = Cast<UInputTriggerDown>(NewObject(Context, UInputTriggerDown::StaticClass(), n"TestSource.Mapping.Down", true));
	if (Down is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Trigger is null");
	}
	Mapping.AddTrigger(Down);
	int32 PopulatedCount = Mapping.GetTriggerCount();
	return EmptyCount == 0 && PopulatedCount == 1;
}
/** @end */
/**
 * @begin has-mapping-for-input-action
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveHasMappingForInputActionNominal
 * @summary setup failure.
 * @covers UInputMappingContext.has-mapping-for-input-action
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveHasMappingForInputActionNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.HasMapping", true));
	UInputAction Other = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.HasMappingOther", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.HasMappingContext", true));
	if (Action is null || Other is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
	}
	UInputAction NullAction = nullptr;
	bool bEmpty = Context.HasMappingForInputAction(Action);
	bool bNull = Context.HasMappingForInputAction(NullAction);
	Context.MapKey(Action, EKeys::W);
	bool bMapped = Context.HasMappingForInputAction(Action);
	bool bOther = Context.HasMappingForInputAction(Other);
	return !bEmpty && !bNull && bMapped && !bOther;
}
/** @end */
/**
 * @begin get-mapping-count
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetMappingCountNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-mapping-count
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetMappingCountNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.Count", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.CountContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
	}
	int32 EmptyCount = Context.GetMappingCount();
	Context.MapKey(Action, EKeys::W);
	int32 FirstCount = Context.GetMappingCount();
	Context.MapKey(Action, EKeys::S);
	int32 LastCount = Context.GetMappingCount();
	return EmptyCount == 0 && FirstCount == 1 && LastCount == 2;
}
/** @end */
/**
 * @begin get-mapping
 * @summary setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetMappingNominal
 * @summary setup failure.
 * @covers UInputMappingContext.get-mapping
 * @inputs UInputMappingContext values exercised by this observe
 * @return true when the observe comparison holds
 */
// a

bool ObserveGetMappingNominal()
{
	UInputAction Action = Cast<UInputAction>(NewObject(GetTransientPackage(), UInputAction::StaticClass(), n"TestSource.Mapping.GetMapping", true));
	UInputMappingContext Context = Cast<UInputMappingContext>(NewObject(GetTransientPackage(), UInputMappingContext::StaticClass(), n"TestSource.Mapping.GetMappingContext", true));
	if (Action is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Action is null");
	}
	if (Context is null)
	{
		throw("TS_UInputMappingContext_Queries_01 setup: required Context is null");
	}
	Context.MapKey(Action, EKeys::W);
	Context.MapKey(Action, EKeys::S);
	FEnhancedActionKeyMapping& First = Context.GetMapping(0);
	FKey FirstKey = First.GetKey();
	First.SetKey(EKeys::A);
	FEnhancedActionKeyMapping& Alias = Context.GetMapping(0);
	FKey AliasKey = Alias.GetKey();
	FEnhancedActionKeyMapping& Last = Context.GetMapping(1);
	FKey LastKey = Last.GetKey();
	return FirstKey == EKeys::W && AliasKey == EKeys::A && LastKey == EKeys::S;
}
/** @end */
/**
 * @begin does-action-exist
 * @summary lookup is the legacy speech-mapping table.
 * @topic Unreal
 */
/**
 * @function ObserveDoesActionExistNominal
 * @summary lookup is the legacy speech-mapping table.
 * @covers UInputSettings.does-action-exist
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDoesActionExistNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
	}
	bool bMissing = Settings.DoesActionExist(n"TestSource.MissingAction");
	bool bNone = Settings.DoesActionExist(NAME_None);
	const TArray<FInputActionKeyMapping>& Mappings = Settings.GetActionMappings();
	if (Mappings.Num() > 0)
	{
		return !bMissing && !bNone && Settings.DoesActionExist(Mappings[0].ActionName);
	}
	return !bMissing && !bNone;
}
/** @end */
/**
 * @begin does-axis-exist
 * @summary lookup is the legacy speech-mapping table.
 * @topic Unreal
 */
/**
 * @function ObserveDoesAxisExistNominal
 * @summary lookup is the legacy speech-mapping table.
 * @covers UInputSettings.does-axis-exist
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDoesAxisExistNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
	}
	bool bMissing = Settings.DoesAxisExist(n"TestSource.MissingAxis");
	bool bNone = Settings.DoesAxisExist(NAME_None);
	const TArray<FInputAxisKeyMapping>& Mappings = Settings.GetAxisMappings();
	if (Mappings.Num() > 0)
	{
		return !bMissing && !bNone && Settings.DoesAxisExist(Mappings[0].AxisName);
	}
	return !bMissing && !bNone;
}
/** @end */
/**
 * @begin does-speech-exist
 * @summary lookup is the legacy speech-mapping table.
 * @topic Unreal
 */
/**
 * @function ObserveDoesSpeechExistNominal
 * @summary lookup is the legacy speech-mapping table.
 * @covers UInputSettings.does-speech-exist
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDoesSpeechExistNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Behavior_01 setup: required Settings is null");
	}
	bool bMissing = Settings.DoesSpeechExist(n"TestSource.MissingSpeech");
	bool bNone = Settings.DoesSpeechExist(NAME_None);
	return !bMissing && !bNone;
}
/** @end */
/**
 * @begin get-unique-action-name
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetUniqueActionNameNominal
 * @summary failure.
 * @covers UInputSettings.get-unique-action-name
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUniqueActionNameNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
	}
	FName Unique = Settings.GetUniqueActionName(n"TestSource.Action");
	FName Again = Settings.GetUniqueActionName(n"TestSource.Action");
	FName FromNone = Settings.GetUniqueActionName(NAME_None);
	return !Unique.IsNone() && !Again.IsNone() && FromNone != Unique;
}
/** @end */
/**
 * @begin get-unique-axis-name
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetUniqueAxisNameNominal
 * @summary failure.
 * @covers UInputSettings.get-unique-axis-name
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetUniqueAxisNameNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
	}
	FName Unique = Settings.GetUniqueAxisName(n"TestSource.Axis");
	FName Again = Settings.GetUniqueAxisName(n"TestSource.Axis");
	FName FromNone = Settings.GetUniqueAxisName(NAME_None);
	return !Unique.IsNone() && !Again.IsNone() && FromNone != Unique;
}
/** @end */
/**
 * @begin get-action-mappings
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetActionMappingsNominal
 * @summary failure.
 * @covers UInputSettings.get-action-mappings
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetActionMappingsNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
	}
	const TArray<FInputActionKeyMapping>& Mappings = Settings.GetActionMappings();
	const TArray<FInputActionKeyMapping>& Alias = Settings.GetActionMappings();
	int32 Count = Mappings.Num();
	if (Count > 0)
	{
		return Count == Alias.Num() && Mappings[0].ActionName == Alias[0].ActionName;
	}
	return Count == Alias.Num();
}
/** @end */
/**
 * @begin get-axis-mappings
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetAxisMappingsNominal
 * @summary failure.
 * @covers UInputSettings.get-axis-mappings
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAxisMappingsNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
	}
	const TArray<FInputAxisKeyMapping>& Mappings = Settings.GetAxisMappings();
	const TArray<FInputAxisKeyMapping>& Alias = Settings.GetAxisMappings();
	int32 Count = Mappings.Num();
	if (Count > 0)
	{
		return Count == Alias.Num() && Mappings[0].AxisName == Alias[0].AxisName;
	}
	return Count == Alias.Num();
}
/** @end */
/**
 * @begin get-speech-mappings
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetSpeechMappingsNominal
 * @summary failure.
 * @covers UInputSettings.get-speech-mappings
 * @inputs UInputSettings values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSpeechMappingsNominal()
{
	UInputSettings Settings = UInputSettings::GetInputSettings();
	if (Settings is null)
	{
		throw("TS_UInputSettings_Queries_01 setup: required Settings is null");
	}
	const TArray<FInputActionSpeechMapping>& Mappings = Settings.GetSpeechMappings();
	const TArray<FInputActionSpeechMapping>& Alias = Settings.GetSpeechMappings();
	int32 Count = Mappings.Num();
	return Count == Alias.Num();
}
/** @end */
