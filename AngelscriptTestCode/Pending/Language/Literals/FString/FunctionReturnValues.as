/**
 * @version v1
 * @summary Return values across the string family. Each helper returns a literal of a different string type, so the oracle proves the value survives the return without being truncated or defaulted.
 * @topic Language
 */
/**
 * @version root
 * @summary Return values across the string family. Each helper returns a literal of a different string type, so the oracle proves the value survives the return without being truncated or defaulted.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Returns a non-empty string literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return "Hello World"
	 */
	FString ReturnString()
	{
		return "Hello World";
	}

	/**
	 * Returns a name literal.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return n"MyName"
	 */
	FName ReturnName()
	{
		return n"MyName";
	}

	/**
	 * Returns an empty string.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return an empty FString
	 */
	FString ReturnEmpty()
	{
		return "";
	}

	/**
	 * Returns constructed text.
	 *
	 * @Covers Literals.FString
	 * @Inputs none
	 * @Return FText wrapping "ReturnText"
	 */
	FText ReturnText()
	{
		return FText::FromString("ReturnText");
	}

	/**
	 * Observe that each returned value survives the return unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs the four return helpers
	 * @Return true when all three non-empty returns match
	 */
	UFUNCTION()
	bool FunctionReturnValuesProduceExpectedValues()
	{
		if (ReturnString() != "Hello World")
		{
			return false;
		}

		if (ReturnName() != n"MyName")
		{
			return false;
		}

		return ReturnText().ToString() == "ReturnText";
	}

	/**
	 * Observe that the empty return is both empty and zero-length.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReturnEmpty()
	 * @Return true when the value is empty and Len() is 0
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool ReturnEmptyBoundary()
	{
		if (ReturnEmpty() != "")
		{
			return false;
		}

		return ReturnEmpty().Len() == 0;
	}

	/**
	 * Observe that the returned name is not NAME_None.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReturnName() compared against a default FName
	 * @Return true when the returned name differs from NAME_None
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool ReturnNameNotNoneBoundary()
	{
		FName Empty;
		return ReturnName() != Empty;
	}
}
/** @end */
