/**
 * Bidirectional `&inout` reference parameters across the string family. Each
 * helper mutates the caller's variable, so the oracle checks the caller's
 * variable after the call rather than any return value.
 *
 * @Theme Language.Literals
 * @Subject Literals.FunctionParametersInOut
 * @Harness Function
 * @Tag Language.Literals.FunctionParametersInOut
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringFunctionTests.cpp::FunctionParametersInOut
 * @Provenance sha256=31860af3aecd615ea6c904a5be709bcf1c1e26de9278b816ebc7590de3c8dd62; lines 303-324.
 * @Provenance Oracle: AppendToString "Original Appended"; ReplaceName n"UpdatedName"; ReplaceText "UpdatedText".
 * @Provenance Extra: unmatched name/text leave values unchanged; empty append still adds suffix.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Appends a suffix to the caller's string in place.
	 *
	 * @Covers Literals.FString
	 * @Param x bidirectional string reference
	 * @Return none; x gains " Appended"
	 */
	void AppendToString(FString&inout x)
	{
		x += " Appended";
	}

	/**
	 * Replaces the caller's name only when it matches the original.
	 *
	 * @Covers Literals.FString
	 * @Param x bidirectional name reference
	 * @Return none; x becomes n"UpdatedName" when it was n"OriginalName"
	 */
	void ReplaceName(FName&inout x)
	{
		if (x == n"OriginalName")
		{
			x = n"UpdatedName";
		}
	}

	/**
	 * Replaces the caller's text only when it matches the original.
	 *
	 * @Covers Literals.FString
	 * @Param x bidirectional text reference
	 * @Return none; x becomes "UpdatedText" when it was "OriginalText"
	 */
	void ReplaceText(FText&inout x)
	{
		if (x.ToString() == "OriginalText")
		{
			x = FText::FromString("UpdatedText");
		}
	}

	/**
	 * Observe that all three `&inout` helpers write back to the caller.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs local FString, FName and FText variables
	 * @Return true when all three variables were mutated as expected
	 */
	UFUNCTION()
	bool FunctionParametersInOutWriteBackExpectedValues()
	{
		FString Value = "Original";
		AppendToString(Value);

		FName NameValue = n"OriginalName";
		ReplaceName(NameValue);

		FText TextValue = FText::FromString("OriginalText");
		ReplaceText(TextValue);

		if (Value != "Original Appended")
		{
			return false;
		}

		if (NameValue != n"UpdatedName")
		{
			return false;
		}

		return TextValue.ToString() == "UpdatedText";
	}

	/**
	 * Observe that appending to an empty string still adds the suffix.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs AppendToString over an empty string
	 * @Return true when the result is " Appended"
	 * @Boundary empty string
	 */
	UFUNCTION()
	bool AppendToStringEmptyBoundary()
	{
		FString Empty = "";
		AppendToString(Empty);
		return Empty == " Appended";
	}

	/**
	 * Observe that a non-matching name is left unchanged.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ReplaceName over n"OtherName"
	 * @Return true when the name is unchanged
	 * @Boundary unmatched name
	 */
	UFUNCTION()
	bool ReplaceNameUnchangedBoundary()
	{
		FName Value = n"OtherName";
		ReplaceName(Value);
		return Value == n"OtherName";
	}
}
