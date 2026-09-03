/**
 * Splitting and joining methods on FString: ParseIntoArray in its plain,
 * empty-keeping, line and whitespace variants, the two-way Split, and the
 * static Join. Each helper isolates one variant so a failure names the method.
 *
 * @Theme Language.Literals
 * @Subject Literals.SplitMethods
 * @Harness Function
 * @Tag Language.Literals.SplitMethods
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::SplitMethods
 * @Provenance sha256 from TS-LANG-0157; lines 706-771.
 * @Provenance Oracle: count 3; apple; cherry; left|right; 3:; lines 2; 3:Gamma; A|B|C.
 * @Provenance Extra: empty ParseIntoArray count 0; Join of empty array.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Counts the parts produced by a comma split.
	 *
	 * @Covers Literals.FString
	 * @Inputs "apple,banana,cherry" split on ","
	 * @Return 3
	 */
	int SplitCount()
	{
		FString s = "apple,banana,cherry";
		TArray<FString> parts;
		s.ParseIntoArray(parts, ",");
		return parts.Num();
	}

	/**
	 * Reads the first part of a comma split.
	 *
	 * @Covers Literals.FString
	 * @Inputs "apple,banana,cherry" split on ","
	 * @Return "apple"
	 */
	FString SplitFirst()
	{
		FString s = "apple,banana,cherry";
		TArray<FString> parts;
		s.ParseIntoArray(parts, ",");
		return parts[0];
	}

	/**
	 * Reads the last part of a comma split.
	 *
	 * @Covers Literals.FString
	 * @Inputs "apple,banana,cherry" split on ","
	 * @Return "cherry"
	 */
	FString SplitLast()
	{
		FString s = "apple,banana,cherry";
		TArray<FString> parts;
		s.ParseIntoArray(parts, ",");
		return parts[2];
	}

	/**
	 * Splits a string into left and right halves around a delimiter.
	 *
	 * @Covers Literals.FString
	 * @Inputs "left:right" split on ":"
	 * @Return "left|right", or "failed" when the delimiter is absent
	 */
	FString SplitLeftRight()
	{
		FString s = "left:right";
		FString left;
		FString right;
		bool bSplit = s.Split(":", left, right);
		return bSplit ? left + "|" + right : "failed";
	}

	/**
	 * Splits while keeping empty parts, reporting count and a chosen part.
	 *
	 * @Covers Literals.FString
	 * @Inputs "a,,b" split on "," with empty parts kept
	 * @Return the count and the empty part, formatted as "{count}:{text}"
	 */
	FString ParseIntoArrayKeepsEmpty()
	{
		FString s = "a,,b";
		TArray<FString> parts;
		int Count = s.ParseIntoArray(parts, ",", false);
		return FString::Format("{0}:{1}", Count, parts[1]);
	}

	/**
	 * Splits a trailing-newline terminated text into lines.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Line1\nLine2\n"
	 * @Return 2
	 */
	int ParseIntoArrayLines()
	{
		FString s = "Line1\nLine2\n";
		TArray<FString> parts;
		return s.ParseIntoArrayLines(parts);
	}

	/**
	 * Splits on whitespace runs, reporting count and the last token.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Alpha Beta\tGamma"
	 * @Return the count and last token, formatted as "{count}:{text}"
	 */
	FString ParseIntoArrayWhitespace()
	{
		FString s = "Alpha Beta\tGamma";
		TArray<FString> parts;
		int Count = s.ParseIntoArrayWS(parts);
		return FString::Format("{0}:{1}", Count, parts[2]);
	}

	/**
	 * Joins an array of strings with a separator.
	 *
	 * @Covers Literals.FString
	 * @Inputs the parts "A", "B" and "C"
	 * @Return "A|B|C"
	 */
	FString JoinParts()
	{
		TArray<FString> parts;
		parts.Add("A");
		parts.Add("B");
		parts.Add("C");
		return FString::Join(parts, "|");
	}

	/**
	 * Observe that every split and join variant matches its oracle.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all split and join helpers
	 * @Return true when all eight outcomes match
	 */
	UFUNCTION()
	bool SplitMethodsProduceExpectedValues()
	{
		if (SplitCount() != 3)
		{
			return false;
		}

		if (SplitFirst() != "apple")
		{
			return false;
		}

		if (SplitLast() != "cherry")
		{
			return false;
		}

		if (SplitLeftRight() != "left|right")
		{
			return false;
		}

		if (ParseIntoArrayKeepsEmpty() != "3:")
		{
			return false;
		}

		if (ParseIntoArrayLines() != 2)
		{
			return false;
		}

		if (ParseIntoArrayWhitespace() != "3:Gamma")
		{
			return false;
		}

		return JoinParts() == "A|B|C";
	}

	/**
	 * Observe that splitting an empty string yields no parts.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs ParseIntoArray over an empty string
	 * @Return 0
	 * @Boundary empty haystack
	 */
	UFUNCTION()
	int ParseIntoArrayEmptyBoundary()
	{
		FString Empty;
		TArray<FString> parts;
		Empty.ParseIntoArray(parts, ",");
		return parts.Num();
	}

	/**
	 * Observe that joining an empty array yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FString::Join over an empty array
	 * @Return an empty string
	 * @Boundary empty array
	 */
	UFUNCTION()
	FString JoinEmptyArrayBoundary()
	{
		TArray<FString> parts;
		return FString::Join(parts, "|");
	}
}
