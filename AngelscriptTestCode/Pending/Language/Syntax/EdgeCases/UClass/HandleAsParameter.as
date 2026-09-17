/**
 * @version v1
 * @summary Actor handles flowing through all three parameter directions: by value, as a return value, and through an out parameter.
 * @topic Language
 */
/**
 * @version root
 * @summary Actor handles flowing through all three parameter directions: by value, as a return value, and through an out parameter.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandleParameterActor : AActor
{
	UPROPERTY()
	bool InputParamWorked = false;

	UPROPERTY()
	bool ReturnValueWorked = false;

	UPROPERTY()
	bool OutParamWorked = false;

	/**
	 * Receives a handle by value and compares it to this actor.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an actor handle
	 * @Return nothing; InputParamWorked records the match
	 * @Param InActor the handle received by value
	 */
	void ProcessActor(AActor InActor)
	{
		if (InActor != nullptr && InActor == this)
		{
			InputParamWorked = true;
		}
	}

	/**
	 * Returns this actor's own handle.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return this actor
	 */
	AActor GetSelf()
	{
		return this;
	}

	/**
	 * Writes this actor's handle through an out parameter.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the out parameter to write
	 * @Return nothing; OutActor receives this actor
	 * @Param OutActor the out parameter
	 */
	void GetActorOut(AActor&out OutActor)
	{
		OutActor = this;
	}

	/**
	 * Exercises all three parameter directions.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three flags record their outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test input parameter
		ProcessActor(this);

		// Test return value
		AActor Returned = GetSelf();
		if (Returned == this)
		{
			ReturnValueWorked = true;
		}

		// Test out parameter
		AActor OutResult;
		GetActorOut(OutResult);
		if (OutResult == this)
		{
			OutParamWorked = true;
		}
	}

	/**
	 * Observe that a locally constructed actor has run no direction.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three flags are still false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleAsParameterFlagsDefaultToFalse()
	{
		if (InputParamWorked)
		{
			return false;
		}

		if (ReturnValueWorked)
		{
			return false;
		}

		return !OutParamWorked;
	}
}
/** @end */
