// Purpose: Observe case-sensitive equality, concatenation, and UTF-16 index
// aliasing, including out-of-range as the diagnostic path.
// AS-facing API: Text == Other; Text + Other; Text[Index]; ConstText[Index];
// Text + ContributedValue; Text + Value;
// Inputs: "alpha"/"alpha" vs "Alpha", empty Other, index 0 and last index,
// integer 7 as contributed concatenation.
// Expected observations: Case-sensitive equality is true only for exact
// contents. + returns a new string. Text[0] aliases the first code unit and
// a write is visible on a later read.
// Boundary/ownership: Index is a zero-based UTF-16 code unit. Out-of-range
// access is the expected failure.

namespace TS_FString_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FString Text = "alpha";
		FString Other = "alpha";
		FString Mixed = "Alpha";
		FString Empty = "";
		return (Text == Other) && !(Text == Mixed) && !(Text == Empty);
	}

	bool Observe_Addition_Nominal()
	{
		FString Left = "alpha";
		FString Right = "beta";
		FString Combined = Left + Right;
		FString WithInt = Left + 7;
		int32 Value = 8;
		FString WithValue = Left + Value;
		return Combined == "alphabeta" && Left == "alpha" && WithInt.Contains("alpha") && WithInt.Contains("7") && WithValue.Contains("8");
	}

	bool Observe_Index_Nominal()
	{
		FString Text = "ab";
		int16 First = Text[0];
		int16 Last = Text[1];
		Text[0] = 99;
		const FString ConstText = "ab";
		int16 ConstFirst = ConstText[0];
		return First == 97 && Last == 98 && Text[0] == 99 && Text.StartsWith("c") && ConstFirst == 97;
	}

	void ExerciseExpectedFailure()
	{
		FString Text = "a";
		int16 OutOfRange = Text[4];
	}
}
