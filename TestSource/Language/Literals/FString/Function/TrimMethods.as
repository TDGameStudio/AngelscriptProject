/**
 * Trimming methods on FString: TrimStart, TrimEnd, TrimStartAndEnd, TrimChar
 * and TrimQuotes. Each helper isolates one trim form, and the quote helpers
 * report their success flag through the returned value.
 *
 * @Theme Language.Literals
 * @Subject Literals.TrimMethods
 * @Harness Function
 * @Tag Language.Literals.TrimMethods
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::TrimMethods
 * @Provenance sha256 from TS-LANG-0152; lines 325-371.
 * @Provenance Oracle: Hello; Hello; Hello; Hello; **Hello**; Quoted; Plain.
 * @Provenance Extra: already-trimmed TrimNone; empty TrimStartAndEnd stays empty.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Trims leading whitespace.
	 *
	 * @Covers Literals.FString
	 * @Inputs "   Hello"
	 * @Return "Hello"
	 */
	FString TrimStart()
	{
		FString s = "   Hello";
		return s.TrimStart();
	}

	/**
	 * Trims trailing whitespace.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello   "
	 * @Return "Hello"
	 */
	FString TrimEnd()
	{
		FString s = "Hello   ";
		return s.TrimEnd();
	}

	/**
	 * Trims whitespace from both ends.
	 *
	 * @Covers Literals.FString
	 * @Inputs "   Hello   "
	 * @Return "Hello"
	 */
	FString TrimStartAndEnd()
	{
		FString s = "   Hello   ";
		return s.TrimStartAndEnd();
	}

	/**
	 * Trims a string that has no surrounding whitespace.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello"
	 * @Return "Hello"
	 */
	FString TrimNone()
	{
		FString s = "Hello";
		return s.TrimStartAndEnd();
	}

	/**
	 * Trims a repeated character from both ends.
	 *
	 * @Covers Literals.FString
	 * @Inputs "***Hello***" trimmed of '*'
	 * @Return "**Hello**"
	 */
	FString TrimCharAsterisk()
	{
		FString s = "***Hello***";
		return s.TrimChar(0x2A);
	}

	/**
	 * Trims surrounding quotes and reports success through the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs "\"Quoted\""
	 * @Return "Quoted", or "failed" when no quotes were removed
	 */
	FString TrimQuotesPresent()
	{
		FString s = "\"Quoted\"";
		bool bQuotesRemoved = false;
		FString Result = s.TrimQuotes(bQuotesRemoved);
		return bQuotesRemoved ? Result : "failed";
	}

	/**
	 * Tries to trim quotes from an unquoted string.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Plain"
	 * @Return "Plain", or "failed" when quotes were wrongly reported as removed
	 */
	FString TrimQuotesAbsent()
	{
		FString s = "Plain";
		bool bQuotesRemoved = false;
		FString Result = s.TrimQuotes(bQuotesRemoved);
		return bQuotesRemoved ? "failed" : Result;
	}

	/**
	 * Observe that every trim form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all trim helpers
	 * @Return true when all seven outcomes match
	 */
	UFUNCTION()
	bool TrimMethodsProduceExpectedValues()
	{
		if (TrimStart() != "Hello")
		{
			return false;
		}

		if (TrimEnd() != "Hello")
		{
			return false;
		}

		if (TrimStartAndEnd() != "Hello")
		{
			return false;
		}

		if (TrimNone() != "Hello")
		{
			return false;
		}

		if (TrimCharAsterisk() != "**Hello**")
		{
			return false;
		}

		if (TrimQuotesPresent() != "Quoted")
		{
			return false;
		}

		return TrimQuotesAbsent() == "Plain";
	}

	/**
	 * Observe that trimming an empty string stays empty.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs TrimStartAndEnd() over an empty string
	 * @Return an empty string
	 * @Boundary empty string
	 */
	UFUNCTION()
	FString TrimEmptyBoundary()
	{
		FString Empty;
		return Empty.TrimStartAndEnd();
	}

	/**
	 * Observe that an incoming quote flag is reset for unquoted input.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs TrimQuotes over "Plain" with the flag preset to true
	 * @Return "Plain", or "failed" when the flag was not reset
	 * @Boundary preset out flag
	 */
	UFUNCTION()
	FString TrimQuotesUnquotedBoundary()
	{
		FString s = "Plain";
		bool bQuotesRemoved = true;
		FString Result = s.TrimQuotes(bQuotesRemoved);
		return bQuotesRemoved ? "failed" : Result;
	}
}
