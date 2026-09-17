/**
 * @version v1
 * @summary FString numeric conversion: IsNumeric reports whether a string parses as a number, and FString::FromInt formats an int back into a string. IsNumeric accepts a leading sign and a decimal point, and rejects an empty.
 * @topic Language
 */
/**
 * @version root
 * @summary FString numeric conversion: IsNumeric reports whether a string parses as a number, and FString::FromInt formats an int back into a string. IsNumeric accepts a leading sign and a decimal point, and rejects an empty.
 * @topic Baseline
 */
namespace CastingTest
{
	/**
	 * Observe that a positive numeric string is recognised as numeric.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs IsNumeric on "123"
	 * @Return 123 when the string parses as a number
	 */
	UFUNCTION()
	int PositiveNumericStringIsNumeric()
	{
		FString s = "123";
		return s.IsNumeric() ? 123 : 0;
	}

	/**
	 * Observe that a leading minus sign is accepted, so negative strings are
	 * numeric too.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs IsNumeric on "-456"
	 * @Return -456 when the sign is accepted
	 * @Boundary negative value
	 */
	UFUNCTION()
	int NegativeNumericStringIsNumeric()
	{
		FString s = "-456";
		return s.IsNumeric() ? -456 : 0;
	}

	/**
	 * Observe that a decimal point is accepted, so a float string is numeric.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs IsNumeric on "3.14"
	 * @Return true when the decimal point is accepted
	 */
	UFUNCTION()
	bool FloatStringIsNumeric()
	{
		FString s = "3.14";
		return s.IsNumeric();
	}

	/**
	 * Observe that FromInt formats an int back into its decimal text.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(999)
	 * @Return 999 when the text is "999"
	 */
	UFUNCTION()
	int FromIntFormatsDecimalText()
	{
		FString s = FString::FromInt(999);
		return s == "999" ? 999 : 0;
	}

	/**
	 * Observe the empty default: an empty string is not numeric.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs IsNumeric on an empty string
	 * @Return true when the result is false
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool EmptyStringIsNotNumeric()
	{
		FString Empty;
		return !Empty.IsNumeric();
	}

	/**
	 * Observe the zero boundary: FromInt(0) round-trips back to zero.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs FString::FromInt(0)
	 * @Return 0 when the text is "0"
	 * @Boundary zero
	 */
	UFUNCTION()
	int FromIntZeroRoundTrips()
	{
		FString s = FString::FromInt(0);
		return s == "0" ? 0 : -1;
	}
}
/** @end */
