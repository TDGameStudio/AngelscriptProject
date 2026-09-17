/**
 * @version v1
 * @summary A pawn binding keys and mouse buttons directly through BindKey, mixing pressed and released events across keyboard and mouse buttons.
 * @topic Language
 */
/**
 * @version root
 * @summary A pawn binding keys and mouse buttons directly through BindKey, mixing pressed and released events across keyboard and mouse buttons.
 * @topic Baseline
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
