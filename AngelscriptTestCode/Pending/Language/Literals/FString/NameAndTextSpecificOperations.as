/**
 * @version v1
 * @summary Operations specific to FName and FText that FString does not offer: name hashing and plain-name extraction, culture-invariant text, text formatting with ordered and named parameters, and text joining.
 * @topic Language
 */
/**
 * @version root
 * @summary Operations specific to FName and FText that FString does not offer: name hashing and plain-name extraction, culture-invariant text, text formatting with ordered and named parameters, and text joining.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Checks that a default-constructed name reports IsNone.
	 *
	 * @Covers Literals.FString
	 * @Inputs a default-constructed FName
	 * @Return true
	 */
	bool DefaultNameIsNone()
	{
		FName Value;
		return Value.IsNone();
	}

	/**
	 * Extracts the plain portion of a numbered name.
	 *
	 * @Covers Literals.FString
	 * @Inputs FName("Plain_17")
	 * @Return "Plain"
	 */
	FString PlainNameString()
	{
		FName Value = FName("Plain_17");
		return Value.GetPlainNameString();
	}

	/**
	 * Compares two names case-insensitively.
	 *
	 * @Covers Literals.FString
	 * @Inputs FName("display") and FName("DISPLAY")
	 * @Return true
	 */
	bool NameCaseInsensitiveEquality()
	{
		FName Lower = FName("display");
		FName Upper = FName("DISPLAY");
		return Lower.IsEqual(Upper);
	}

	/**
	 * Compares two names case-sensitively and expects a mismatch.
	 *
	 * @Covers Literals.FString
	 * @Inputs FName("display") and FName("DISPLAY")
	 * @Return true, since the comparison must fail
	 */
	bool NameCaseSensitiveInequality()
	{
		FName Lower = FName("display");
		FName Upper = FName("DISPLAY");
		return !Lower.IsEqual(Upper, false);
	}

	/**
	 * Compares two names in both directions.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"Alpha" and n"Beta" compared both ways
	 * @Return true when the ordering is consistent
	 */
	bool NameCompareOrdersValues()
	{
		FName Alpha = n"Alpha";
		FName Beta = n"Beta";

		if (Alpha.Compare(Beta) >= 0)
		{
			return false;
		}

		return Beta.Compare(Alpha) > 0;
	}

	/**
	 * Checks that a name's hash is stable across calls.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"StableHash" hashed twice
	 * @Return true when both hashes match
	 */
	bool NameHashIsStable()
	{
		FName Value = n"StableHash";
		return Value.GetHash() == Value.GetHash();
	}

	/**
	 * Checks the initialization state of text built from a string.
	 *
	 * @Covers Literals.FString
	 * @Inputs FText::FromString("State")
	 * @Return true when initialized from string and non-empty
	 */
	bool TextFromStringState()
	{
		FText Value = FText::FromString("State");

		if (!Value.IsInitializedFromString())
		{
			return false;
		}

		return !Value.IsEmpty();
	}

	/**
	 * Checks the state of culture-invariant text.
	 *
	 * @Covers Literals.FString
	 * @Inputs FText::AsCultureInvariant("Invariant")
	 * @Return true when culture-invariant and stringifying to the input
	 */
	bool CultureInvariantTextState()
	{
		FText Value = FText::AsCultureInvariant("Invariant");

		if (!Value.IsCultureInvariant())
		{
			return false;
		}

		return Value.ToString() == "Invariant";
	}

	/**
	 * Builds text from a name and stringifies it.
	 *
	 * @Covers Literals.FString
	 * @Inputs n"NameText"
	 * @Return "NameText"
	 */
	FString TextFromName()
	{
		return FText::FromName(n"NameText").ToString();
	}

	/**
	 * Formats text with ordered parameters of mixed types.
	 *
	 * @Covers Literals.FString
	 * @Inputs the pattern "{0}:{1}" with "A" and 7
	 * @Return "A:7"
	 */
	FString TextFormatOrdered()
	{
		FText Pattern = FText::FromString("{0}:{1}");
		return FText::Format(Pattern, FText::FromString("A"), 7).ToString();
	}

	/**
	 * Counts the named parameters in a format pattern.
	 *
	 * @Covers Literals.FString
	 * @Inputs the pattern "{First}-{Second}"
	 * @Return 2
	 */
	int TextFormatPatternParameterCount()
	{
		TArray<FString> Names;
		FText::GetFormatPatternParameters(FText::FromString("{First}-{Second}"), Names);
		return Names.Num();
	}

	/**
	 * Joins an array of text with a separator.
	 *
	 * @Covers Literals.FString
	 * @Inputs the text parts "A" and "B"
	 * @Return "A|B"
	 */
	FString TextJoin()
	{
		TArray<FText> Parts;
		Parts.Add(FText::FromString("A"));
		Parts.Add(FText::FromString("B"));
		return FText::Join(FText::FromString("|"), Parts).ToString();
	}

	/**
	 * Observe that every name and text operation matches its oracle.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all name and text helpers
	 * @Return true when all twelve outcomes match
	 */
	UFUNCTION()
	bool NameAndTextOperationsProduceExpectedValues()
	{
		if (!DefaultNameIsNone())
		{
			return false;
		}

		if (PlainNameString() != "Plain")
		{
			return false;
		}

		if (!NameCaseInsensitiveEquality())
		{
			return false;
		}

		if (!NameCaseSensitiveInequality())
		{
			return false;
		}

		if (!NameCompareOrdersValues())
		{
			return false;
		}

		if (!NameHashIsStable())
		{
			return false;
		}

		if (!TextFromStringState())
		{
			return false;
		}

		if (!CultureInvariantTextState())
		{
			return false;
		}

		if (TextFromName() != "NameText")
		{
			return false;
		}

		if (TextFormatOrdered() != "A:7")
		{
			return false;
		}

		if (TextFormatPatternParameterCount() != 2)
		{
			return false;
		}

		return TextJoin() == "A|B";
	}

	/**
	 * Observe that a default-constructed name reports IsNone.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs a default-constructed FName
	 * @Return true
	 * @Boundary NAME_None
	 */
	UFUNCTION()
	bool DefaultNameEmptyNoneBoundary()
	{
		FName Empty;
		return Empty.IsNone();
	}

	/**
	 * Observe that joining no text parts yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs FText::Join over an empty array
	 * @Return an empty string
	 * @Boundary empty array
	 */
	UFUNCTION()
	FString TextJoinEmptyPartsBoundary()
	{
		TArray<FText> Parts;
		return FText::Join(FText::FromString("|"), Parts).ToString();
	}
}
/** @end */
