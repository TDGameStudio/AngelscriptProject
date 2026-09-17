/**
 * @version v1
 * @summary Boundary cases for the in-place string mutations: inserting at index 0 and at Len(), removing the first and last characters, whitespace handling, case-sensitive replacement counts, and interleaved capacity calls.
 * @topic Language
 */
/**
 * @version root
 * @summary Boundary cases for the in-place string mutations: inserting at index 0 and at Len(), removing the first and last characters, whitespace handling, case-sensitive replacement counts, and interleaved capacity calls.
 * @topic Baseline
 */
namespace LiteralsTest
{
	/**
	 * Inserts at index 0, at Len(), and into the middle.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Center" with prefix, suffix and a mid-string character
	 * @Return "Start-|Center-End"
	 */
	FString InsertAtBoundaries()
	{
		FString s = "Center";
		s.InsertAt(0, "Start-");
		s.InsertAt(s.Len(), "-End");
		s.InsertAt(6, 0x7C);
		return s;
	}

	/**
	 * Removes the first and last characters of a bracketed payload.
	 *
	 * @Covers Literals.FString
	 * @Inputs "[payload]"
	 * @Return "payload"
	 */
	FString RemoveAtFirstAndLast()
	{
		FString s = "[payload]";
		s.RemoveAt(0, 1);
		s.RemoveAt(s.Len() - 1, 1);
		return s;
	}

	/**
	 * Strips space characters while preserving other whitespace kinds.
	 *
	 * @Covers Literals.FString
	 * @Inputs " A\tB C "
	 * @Return "A\tBC"
	 */
	FString RemoveSpacesInlinePreservesWhitespaceKinds()
	{
		FString s = " A\tB C ";
		s.RemoveSpacesInline();
		return s;
	}

	/**
	 * Reports the case-sensitive replacement count alongside the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Token token TOKEN" with "Token" replaced by "Hit"
	 * @Return the count and the resulting string, formatted as "{count}:{text}"
	 */
	FString ReplaceInlineCaseSensitiveCount()
	{
		FString s = "Token token TOKEN";
		int Count = s.ReplaceInline("Token", "Hit", ESearchCase::CaseSensitive);
		return FString::Format("{0}:{1}", Count, s);
	}

	/**
	 * Interleaves the capacity methods with appends and reports the result.
	 *
	 * @Covers Literals.FString
	 * @Inputs Reserve, Empty, Reset, Shrink and Append over a short string
	 * @Return the length and contents, formatted as "{len}:{text}"
	 */
	FString MemoryMethodsRemainUsable()
	{
		FString s = "carry";
		s.Reserve(128);
		s.Empty(16);
		s.Append("A");
		s.Reset(32);
		s.Append("B");
		s.Shrink();
		return FString::Format("{0}:{1}", s.Len(), s);
	}

	/**
	 * Observe that every boundary case produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all edge-case helpers
	 * @Return true when all five outcomes match
	 */
	UFUNCTION()
	bool MutableStringEdgeCasesProduceExpectedValues()
	{
		if (InsertAtBoundaries() != "Start-|Center-End")
		{
			return false;
		}

		if (RemoveAtFirstAndLast() != "payload")
		{
			return false;
		}

		if (RemoveSpacesInlinePreservesWhitespaceKinds() != "A\tBC")
		{
			return false;
		}

		if (ReplaceInlineCaseSensitiveCount() != "1:Hit token TOKEN")
		{
			return false;
		}

		return MemoryMethodsRemainUsable() == "1:B";
	}

	/**
	 * Observe that inserting at index 0 on an empty string works.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs InsertAt(0, "Start-") over a default-constructed string
	 * @Return the resulting string
	 * @Boundary empty string
	 */
	UFUNCTION()
	FString InsertAtEmptyBoundary()
	{
		FString s;
		s.InsertAt(0, "Start-");
		return s;
	}

	/**
	 * Observe that stripping spaces from an empty string is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs RemoveSpacesInline() over a default-constructed string
	 * @Return the resulting string, expected to be empty
	 * @Boundary empty string
	 */
	UFUNCTION()
	FString RemoveSpacesEmptyBoundary()
	{
		FString s;
		s.RemoveSpacesInline();
		return s;
	}
}
/** @end */
