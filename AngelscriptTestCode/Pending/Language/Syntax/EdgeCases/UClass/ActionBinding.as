/**
 * @version v1
 * @summary A pawn that binds four action handlers through BindUFunction, one per input event kind. The class must compile; the counters stay zero until input actually fires.
 * @topic Language
 */
/**
 * @version root
 * @summary A pawn that binds four action handlers through BindUFunction, one per input event kind. The class must compile; the counters stay zero until input actually fires.
 * @topic Baseline
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
