/**
 * @version v1
 * @summary A pawn binding four axis handlers through BindUFunction. The class must compile, and each handler stores its axis value and bumps a shared call counter.
 * @topic Language
 */
/**
 * @version root
 * @summary A pawn binding four axis handlers through BindUFunction. The class must compile, and each handler stores its axis value and bumps a shared call counter.
 * @topic Baseline
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
