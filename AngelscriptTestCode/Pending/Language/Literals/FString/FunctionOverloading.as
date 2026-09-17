/**
 * @version v1
 * @summary Overload resolution across the string family: Process() is declared three times for FString, FName and FText, so each call site proves which overload the compiler picked.
 * @topic Language
 */
/**
 * @version root
 * @summary Overload resolution across the string family: Process() is declared three times for FString, FName and FText, so each call site proves which overload the compiler picked.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * FString overload of Process.
	 *
	 * @Covers Literals.FString
	 * @Param x the string to tag
	 * @Return "String: " followed by the value
	 */
	FString Process(FString x)
	{
		return "String: " + x;
	}

	/**
	 * FName overload of Process.
	 *
	 * @Covers Literals.FString
	 * @Param x the name to tag
	 * @Return "Name: " followed by the value
	 */
	FString Process(FName x)
	{
		return "Name: " + x.ToString();
	}

	/**
	 * FText overload of Process.
	 *
	 * @Covers Literals.FString
	 * @Param x the text to tag
	 * @Return "Text: " followed by the value
	 */
	FString Process(FText x)
	{
		return "Text: " + x.ToString();
	}

	/**
	 * Dispatches to the FString overload.
	 *
	 * @Covers Literals.FString
	 * @Inputs Process("Test")
	 * @Return "String: Test"
	 */
	FString CallProcessString()
	{
		return Process("Test");
	}

	/**
	 * Dispatches to the FName overload.
	 *
	 * @Covers Literals.FString
	 * @Inputs Process(n"Test")
	 * @Return "Name: Test"
	 */
	FString CallProcessName()
	{
		return Process(n"Test");
	}

	/**
	 * Dispatches to the FText overload.
	 *
	 * @Covers Literals.FString
	 * @Inputs Process(FText::FromString("Test"))
	 * @Return "Text: Test"
	 */
	FString CallProcessText()
	{
		return Process(FText::FromString("Test"));
	}

	/**
	 * Observe that each call site resolves to the matching overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Process("Test"), Process(n"Test"), Process(FText)
	 * @Return true when all three prefixes match
	 */
	UFUNCTION()
	bool FunctionOverloadingResolvesExpectedTypes()
	{
		if (CallProcessString() != "String: Test")
		{
			return false;
		}

		if (CallProcessName() != "Name: Test")
		{
			return false;
		}

		return CallProcessText() == "Text: Test";
	}

	/**
	 * Observe the empty-argument boundary of the FString overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Process("")
	 * @Return true when the result is "String: "
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool ProcessStringEmptyBoundary()
	{
		return Process("") == "String: ";
	}

	/**
	 * Observe the default-constructed boundary of the FText overload.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Process(FText())
	 * @Return true when the result is "Text: "
	 * @Boundary default-constructed FText
	 */
	UFUNCTION()
	bool ProcessTextEmptyBoundary()
	{
		FText Empty;
		return Process(Empty) == "Text: ";
	}
}
/** @end */
