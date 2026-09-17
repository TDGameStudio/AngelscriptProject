/**
 * @version v1
 * @summary Observe emptiness, length, numeric detection, find/contains, char search, prefix/suffix, and wildcard matching.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe emptiness, length, numeric detection, find/contains, char search, prefix/suffix, and wildcard matching.
 * @topic Baseline
 */
// bool FString.IsNumeric() const;
// int FString.Find(const FString& SubStr, ESearchCase SearchCase = ESearchCase::IgnoreCase, ESearchDir SearchDir = ESearchDir::FromStart, int StartPosition = -1) const;
// bool FString.Contains(const FString& SubStr, ...);
// bool FString.FindChar(int16 Char, int& Index) const;
// bool FString.FindLastChar(int16 Char, int& Index) const;
// bool FString.StartsWith(...); bool FString.EndsWith(...);
// bool FString.MatchesWildcard(...) const;
// Inputs: "", "7", "AlphaBetaAlpha", needle "Alpha", char 65 ('A'), wildcard
// "A*a", and INDEX_NONE as the missing-match sentinel.
// Expected observations: Empty is empty and length 0. "7" is numeric. Find
// returns 0 then a later index from the end. Missing needles return
// INDEX_NONE. FindChar writes Index on success.
// Boundary/ownership: Find does not mutate. Out Index is written only on
// successful FindChar/FindLastChar.

namespace TS_FString_Queries_01
{
	bool Observe_IsEmpty_Nominal()
	{
		FString Empty;
		FString Text = "x";
		return Empty.IsEmpty() && !Text.IsEmpty();
	}

	bool Observe_Len_Nominal()
	{
		FString Empty;
		FString Text = "ab";
		return Empty.Len() == 0 && Text.Len() == 2;
	}

	bool Observe_IsNumeric_Nominal()
	{
		return FString("7").IsNumeric() && !FString("a7").IsNumeric() && !FString("").IsNumeric();
	}

	bool Observe_Find_Nominal()
	{
		FString Text = "AlphaBetaAlpha";
		int First = Text.Find("Alpha");
		int FromEnd = Text.Find("Alpha", ESearchCase::IgnoreCase, ESearchDir::FromEnd);
		int Missing = Text.Find("zzz");
		return First == 0 && FromEnd > First && Missing == INDEX_NONE;
	}

	bool Observe_Contains_Nominal()
	{
		FString Text = "AlphaBeta";
		return Text.Contains("beta") && !Text.Contains("zzz");
	}

	bool Observe_FindChar_Nominal()
	{
		FString Text = "ABA";
		int Index = -2;
		bool bFound = Text.FindChar(65, Index);
		int MissingIndex = -2;
		bool bMissing = Text.FindChar(90, MissingIndex);
		return bFound && Index == 0 && !bMissing;
	}

	bool Observe_FindLastChar_Nominal()
	{
		FString Text = "ABA";
		int Index = -2;
		bool bFound = Text.FindLastChar(65, Index);
		return bFound && Index == 2;
	}

	bool Observe_StartsWith_Nominal()
	{
		FString Text = "AlphaBeta";
		return Text.StartsWith("alpha") && !Text.StartsWith("Beta");
	}

	bool Observe_EndsWith_Nominal()
	{
		FString Text = "AlphaBeta";
		return Text.EndsWith("beta") && !Text.EndsWith("Alpha");
	}

	bool Observe_MatchesWildcard_Nominal()
	{
		FString Text = "AlphaBeta";
		return Text.MatchesWildcard("A*a") && !Text.MatchesWildcard("Z*");
	}

	void ExerciseExpectedFailure()
	{
		FString Text = "a";
		int16 OutOfRange = Text[8];
	}
}
/** @end */
