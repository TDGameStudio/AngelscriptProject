/**
 * @version v1
 * @summary FString case conversion: ToUpper and ToLower map a string to a single case. Both are idempotent, so converting an already-converted string returns it unchanged, and an empty string stays empty rather than failing. This.
 * @topic Language
 */
/**
 * @version root
 * @summary FString case conversion: ToUpper and ToLower map a string to a single case. Both are idempotent, so converting an already-converted string returns it unchanged, and an empty string stays empty rather than failing. This.
 * @topic Baseline
 */
namespace CastingTest
{
	/**
	 * Observe that ToUpper maps a lowercase string to uppercase.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs ToUpper on "hello world"
	 * @Return "HELLO WORLD"
	 */
	UFUNCTION()
	FString ToUpperMapsLowercaseToUpper()
	{
		FString s = "hello world";
		return s.ToUpper();
	}

	/**
	 * Observe that ToLower maps an uppercase string to lowercase.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs ToLower on "HELLO WORLD"
	 * @Return "hello world"
	 */
	UFUNCTION()
	FString ToLowerMapsUppercaseToLower()
	{
		FString s = "HELLO WORLD";
		return s.ToLower();
	}

	/**
	 * Observe that ToUpper normalizes a mixed-case string.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs ToUpper on "HeLLo WoRLd"
	 * @Return "HELLO WORLD"
	 */
	UFUNCTION()
	FString ToUpperNormalizesMixedCase()
	{
		FString s = "HeLLo WoRLd";
		return s.ToUpper();
	}

	/**
	 * Observe the empty default: converting an empty string leaves it empty.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs ToUpper and ToLower on an empty string
	 * @Return true when both results are empty
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool CaseConversionEmptyDefault()
	{
		FString Empty;
		if (Empty.ToUpper().Len() != 0)
		{
			return false;
		}
		return Empty.ToLower().Len() == 0;
	}

	/**
	 * Observe the idempotence boundary: converting an already-upper string
	 * returns it unchanged.
	 *
	 * @Kind Observe
	 * @Covers Casting.FStringConversion
	 * @Inputs ToUpper on "HELLO WORLD"
	 * @Return true when the result is unchanged
	 * @Boundary already converted
	 */
	UFUNCTION()
	bool ToUpperIsIdempotent()
	{
		FString Upper = "HELLO WORLD";
		return Upper.ToUpper() == "HELLO WORLD";
	}
}
/** @end */
