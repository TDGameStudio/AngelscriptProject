/**
 * FString::IsNumeric reports whether a string is numeric. Digits, negative
 * integers, and floating-point forms are numeric, while mixed text, the empty
 * string, and leading whitespace are not. Each classification is a value
 * oracle asserted together.
 *
 * @Theme Language.Literals
 * @Subject Literals.IsNumericMethod
 * @Harness Function
 * @Tag Language.Literals.IsNumericMethod
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::IsNumericMethod
 * @Provenance sha256=51f797d87633a37da7320fb70701db4658d92aea0caaf3cbe840c8d3356b205a; lines 1000-1024.
 * @Provenance Oracle: TestIsNumeric_True true; TestIsNumeric_False false; TestIsNumeric_Negative true; TestIsNumeric_Float true.
 * @Provenance Extra: empty IsNumeric false; leading space is not numeric.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Classify a pure digit string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "12345"
	 * @Return true, since the string is numeric
	 */
	bool IsNumericOnDigits()
	{
		FString S = "12345";
		return S.IsNumeric();
	}

	/**
	 * Classify a mixed text string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello123"
	 * @Return false, since the string mixes text and digits
	 */
	bool IsNumericOnMixed()
	{
		FString S = "Hello123";
		return S.IsNumeric();
	}

	/**
	 * Classify a negative integer string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "-456"
	 * @Return true, since a negative integer is numeric
	 */
	bool IsNumericOnNegative()
	{
		FString S = "-456";
		return S.IsNumeric();
	}

	/**
	 * Classify a floating-point string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "3.14"
	 * @Return true, since a float form is numeric
	 */
	bool IsNumericOnFloat()
	{
		FString S = "3.14";
		return S.IsNumeric();
	}

	/**
	 * Observe that the numeric and non-numeric classifications match.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Digit, mixed, negative, and float strings
	 * @Return true when the digit, negative, and float forms are numeric and the mixed form is not
	 */
	UFUNCTION()
	bool IsNumericProducesExpectedValues()
	{
		if (!IsNumericOnDigits())
		{
			return false;
		}
		if (IsNumericOnMixed())
		{
			return false;
		}
		if (!IsNumericOnNegative())
		{
			return false;
		}
		return IsNumericOnFloat();
	}

	/**
	 * Observe the empty-string boundary of IsNumeric.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs A default-constructed FString
	 * @Return true when the empty string is not numeric
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool IsNumericEmptyBoundary()
	{
		FString Empty;
		return !Empty.IsNumeric();
	}

	/**
	 * Observe the leading-whitespace boundary of IsNumeric.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs " 123"
	 * @Return true when the leading space makes the string non-numeric
	 * @Boundary leading whitespace
	 */
	UFUNCTION()
	bool IsNumericWhitespaceBoundary()
	{
		FString S = " 123";
		return !S.IsNumeric();
	}
}
