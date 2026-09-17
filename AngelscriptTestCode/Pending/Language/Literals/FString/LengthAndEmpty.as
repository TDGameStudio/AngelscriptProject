/**
 * @version v1
 * @summary FString::Len, IsEmpty, and ToBool report length, emptiness, and boolean parsing. The helpers classify short and long strings, empty and non-empty strings, and the "true"/"false" forms, and the observers confirm the.
 * @topic Language
 */
/**
 * @version root
 * @summary FString::Len, IsEmpty, and ToBool report length, emptiness, and boolean parsing. The helpers classify short and long strings, empty and non-empty strings, and the "true"/"false" forms, and the observers confirm the.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Report the length of "Hello".
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello"
	 * @Return 5
	 */
	int StringLength()
	{
		FString S = "Hello";
		return S.Len();
	}

	/**
	 * Classify the empty string.
	 *
	 * @Covers Literals.FString
	 * @Inputs ""
	 * @Return true, since the string is empty
	 */
	bool IsEmptyOnEmptyString()
	{
		FString S = "";
		return S.IsEmpty();
	}

	/**
	 * Classify a non-empty string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Test"
	 * @Return false, since the string is non-empty
	 */
	bool IsEmptyOnNonEmptyString()
	{
		FString S = "Test";
		return S.IsEmpty();
	}

	/**
	 * Report the length of a longer string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "This is a longer string"
	 * @Return 23
	 */
	int LongStringLength()
	{
		FString S = "This is a longer string";
		return S.Len();
	}

	/**
	 * Parse "true" through ToBool.
	 *
	 * @Covers Literals.FString
	 * @Inputs "true"
	 * @Return true
	 */
	bool ToBoolOnTrue()
	{
		FString S = "true";
		return S.ToBool();
	}

	/**
	 * Parse "false" through ToBool.
	 *
	 * @Covers Literals.FString
	 * @Inputs "false"
	 * @Return false
	 */
	bool ToBoolOnFalse()
	{
		FString S = "false";
		return S.ToBool();
	}

	/**
	 * Observe that lengths, emptiness flags, and boolean conversions match.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs All six length/empty/bool classifications
	 * @Return true when every oracle value holds
	 */
	UFUNCTION()
	bool LengthAndEmptyProduceExpectedValues()
	{
		if (StringLength() != 5)
		{
			return false;
		}
		if (!IsEmptyOnEmptyString())
		{
			return false;
		}
		if (IsEmptyOnNonEmptyString())
		{
			return false;
		}
		if (LongStringLength() != 23)
		{
			return false;
		}
		if (!ToBoolOnTrue())
		{
			return false;
		}
		return !ToBoolOnFalse();
	}

	/**
	 * Observe the default empty boundary of length and emptiness.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A default-constructed FString
	 * @Return true when its length is 0 and it reports empty
	 * @Boundary default empty string
	 */
	UFUNCTION()
	bool LengthEmptyDefaultBoundary()
	{
		FString Empty;
		if (Empty.Len() != 0)
		{
			return false;
		}
		return Empty.IsEmpty();
	}

	/**
	 * Observe the empty boundary of ToBool.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs "" parsed through ToBool
	 * @Return true when the empty string parses to false
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool ToBoolEmptyBoundary()
	{
		FString Empty = "";
		return !Empty.ToBool();
	}
}
/** @end */
