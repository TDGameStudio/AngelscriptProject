/**
 * @version v1
 * @summary Bool UFUNCTION echo and toggle with LastInput and LastOutput. EchoBool(true) is true and LastInput true. ToggleBool(true) is false and LastOutput false. EchoBool(false) is the empty/false vector, and a nullptr actor is.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Bool UFUNCTION echo and toggle with LastInput and LastOutput. EchoBool(true) is true and LastInput true. ToggleBool(true) is false and LastOutput false. EchoBool(false) is the empty/false vector, and a nullptr actor is.
 * @topic Baseline
 */
UCLASS()
class ACoverageBoolFunctionActor : AActor
{
	UPROPERTY()
	bool LastInput = false;

	UPROPERTY()
	bool LastOutput = false;

	/**
	 * Echo b into LastInput and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param b Value echoed
	 * @Inputs b
	 * @Return b after writing LastInput
	 */
	UFUNCTION()
	bool EchoBool(bool b)
	{
		LastInput = b;
		return b;
	}

	/**
	 * Toggle b into LastOutput and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param b Value inverted
	 * @Inputs b
	 * @Return !b after writing LastInput and LastOutput
	 */
	UFUNCTION()
	bool ToggleBool(bool b)
	{
		LastInput = b;
		LastOutput = !b;
		return LastOutput;
	}

	/**
	 * Observe EchoBool(true).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs EchoBool(true)
	 * @Return true when the echo and LastInput are true
	 */
	UFUNCTION()
	bool TrueEcho()
	{
		if (!EchoBool(true))
		{
			return false;
		}
		return LastInput;
	}

	/**
	 * Observe EchoBool(false) as the empty vector.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs EchoBool(false)
	 * @Return true when the echo and LastInput are false
	 * @Boundary false
	 */
	UFUNCTION()
	bool FalseEmpty()
	{
		if (EchoBool(false))
		{
			return false;
		}
		return !LastInput;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageBoolFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageBoolFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe ToggleBool(true) then ToggleBool(false).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ToggleBool(true) then ToggleBool(false)
	 * @Return true when the first toggle is false and the second is true
	 */
	UFUNCTION()
	bool ToggleBoundary()
	{
		if (ToggleBool(true) != false)
		{
			return false;
		}
		if (LastOutput != false)
		{
			return false;
		}
		return ToggleBool(false) == true;
	}
}
/** @end */
