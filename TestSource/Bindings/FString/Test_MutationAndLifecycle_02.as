// Purpose: Observe removal helpers and generic Append of contributed/type-erased
// values.
// AS-facing API: void FString.RemoveAt(int Index, int Count);
// void FString.RemoveSpacesInline();
// bool FString.RemoveFromStart(const FString& Prefix, ESearchCase SearchCase = ESearchCase::IgnoreCase);
// bool FString.RemoveFromEnd(const FString& Suffix, ESearchCase SearchCase = ESearchCase::IgnoreCase);
// Text.Append(ContributedValue); FString& FString.Append(const ?& Value);
// Inputs: "a b c", "AlphaBeta", prefixes/suffixes "alpha"/"beta", contributed
// int 7, Count 0 as a no-op remove.
// Expected observations: RemoveAt(2,1) drops one code unit. RemoveSpacesInline
// yields "abc". Matching RemoveFromStart/End return true and mutate; missing
// prefixes return false.
// Boundary/ownership: RemoveAt past Len is the diagnostic path. Append of a
// type-erased value copies formatted text.

namespace TS_FString_MutationAndLifecycle_02
{
	bool Observe_RemoveAt_Nominal()
	{
		FString Text = "abcd";
		Text.RemoveAt(1, 2);
		Text.RemoveAt(0, 0);
		return Text == "ad";
	}

	bool Observe_RemoveSpacesInline_Nominal()
	{
		FString Text = "a b c";
		Text.RemoveSpacesInline();
		Text.RemoveSpacesInline();
		return Text == "abc";
	}

	bool Observe_RemoveFromStart_Nominal()
	{
		FString Text = "AlphaBeta";
		bool bRemoved = Text.RemoveFromStart("alpha");
		bool bMissing = Text.RemoveFromStart("zzz");
		return bRemoved && Text.StartsWith("Beta") && !bMissing;
	}

	bool Observe_RemoveFromEnd_Nominal()
	{
		FString Text = "AlphaBeta";
		bool bRemoved = Text.RemoveFromEnd("beta");
		bool bMissing = Text.RemoveFromEnd("zzz");
		return bRemoved && Text.EndsWith("Alpha") && !bMissing;
	}

	bool Observe_Append_Nominal()
	{
		FString Text = "n";
		int32 Value = 7;
		Text.Append(Value);
		FString& Alias = Text.Append(8);
		Alias.Append("x");
		return Text.Contains("7") && Text.Contains("8") && Text.EndsWith("x");
	}

	void ExerciseExpectedFailure()
	{
		FString Text = "ab";
		Text.RemoveAt(8, 1);
	}
}
