/**
 * FString case conversion: ToUpper and ToLower map a string to a single case.
 * Both are idempotent, so converting an already-converted string returns it
 * unchanged, and an empty string stays empty rather than failing.
 * This is an FString method rather than a cast, so it belongs with the string
 * subject; it sits here until moved to ../Literals/FString/.
 *
 * @Theme Language.Casting
 * @Subject Casting.FStringCaseConversion
 * @Harness Function
 * @Tag Language.Casting.FStringCaseConversion
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::CaseConversion
 * @Provenance Oracle: TestToUpper "HELLO WORLD"; TestToLower "hello world"; mixed ToUpper "HELLO WORLD".
 * @Provenance Extra: empty string stays empty; already-upper ToUpper is idempotent.
 * @Provenance DefaultSafe. Source owns locals.
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
