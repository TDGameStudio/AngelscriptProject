/**
 * @version v1
 * @summary Substring extraction and trimming methods on FString: Left, Right, Mid in both its forms, LeftChop, RightChop, and the conditional RemoveFromStart and RemoveFromEnd. Each helper isolates one method so a failure names it.
 * @topic Language
 */
/**
 * @version root
 * @summary Substring extraction and trimming methods on FString: Left, Right, Mid in both its forms, LeftChop, RightChop, and the conditional RemoveFromStart and RemoveFromEnd. Each helper isolates one method so a failure names it.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Takes a leading substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" truncated to 5 characters
	 * @Return "Hello"
	 */
	FString LeftSubstring()
	{
		FString s = "Hello World";
		return s.Left(5);
	}

	/**
	 * Takes a trailing substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs the last 5 characters of "Hello World"
	 * @Return "World"
	 */
	FString RightSubstring()
	{
		FString s = "Hello World";
		return s.Right(5);
	}

	/**
	 * Takes a bounded substring from the middle.
	 *
	 * @Covers Literals.FString
	 * @Inputs 5 characters of "Hello World" starting at index 6
	 * @Return "World"
	 */
	FString MidSubstring()
	{
		FString s = "Hello World";
		return s.Mid(6, 5);
	}

	/**
	 * Takes a substring running to the end.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" from index 6 to the end
	 * @Return "World"
	 */
	FString MidToEnd()
	{
		FString s = "Hello World";
		return s.Mid(6);
	}

	/**
	 * Removes a trailing run of characters.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" with the last 6 characters removed
	 * @Return "Hello"
	 */
	FString LeftChopSubstring()
	{
		FString s = "Hello World";
		return s.LeftChop(6);
	}

	/**
	 * Removes a leading run of characters.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" with the first 6 characters removed
	 * @Return "World"
	 */
	FString RightChopSubstring()
	{
		FString s = "Hello World";
		return s.RightChop(6);
	}

	/**
	 * Removes a matching prefix and reports success through the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs "PrefixValue" with "Prefix" removed
	 * @Return "Value", or "failed" when the prefix did not match
	 */
	FString RemoveFromStartPrefix()
	{
		FString s = "PrefixValue";
		bool bRemoved = s.RemoveFromStart("Prefix", ESearchCase::CaseSensitive);
		return bRemoved ? s : "failed";
	}

	/**
	 * Removes a matching suffix and reports success through the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs "ValueSuffix" with "Suffix" removed
	 * @Return "Value", or "failed" when the suffix did not match
	 */
	FString RemoveFromEndSuffix()
	{
		FString s = "ValueSuffix";
		bool bRemoved = s.RemoveFromEnd("Suffix", ESearchCase::CaseSensitive);
		return bRemoved ? s : "failed";
	}

	/**
	 * Observe that every substring method produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all substring helpers
	 * @Return true when all eight outcomes match
	 */
	UFUNCTION()
	bool SubstringMethodsProduceExpectedValues()
	{
		if (LeftSubstring() != "Hello")
		{
			return false;
		}

		if (RightSubstring() != "World")
		{
			return false;
		}

		if (MidSubstring() != "World")
		{
			return false;
		}

		if (MidToEnd() != "World")
		{
			return false;
		}

		if (LeftChopSubstring() != "Hello")
		{
			return false;
		}

		if (RightChopSubstring() != "World")
		{
			return false;
		}

		if (RemoveFromStartPrefix() != "Value")
		{
			return false;
		}

		return RemoveFromEndSuffix() == "Value";
	}

	/**
	 * Observe that taking zero leading characters yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Left(0) over "Hello World"
	 * @Return an empty string
	 * @Boundary zero count
	 */
	UFUNCTION()
	FString LeftZeroCountBoundary()
	{
		FString s = "Hello World";
		return s.Left(0);
	}

	/**
	 * Observe that taking a substring past the end yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Mid(Len()) over "Hello World"
	 * @Return an empty string
	 * @Boundary past-end index
	 */
	UFUNCTION()
	FString MidPastEndBoundary()
	{
		FString s = "Hello World";
		return s.Mid(s.Len());
	}
}
/** @end */
