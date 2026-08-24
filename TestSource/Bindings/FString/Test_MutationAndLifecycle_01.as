// Purpose: Observe append/insert/empty/reset/reserve/shrink mutations and the
// returned FString& alias from Append.
// AS-facing API: FString& FString.Append(const FString& Other);
// FString& FString.AppendChar(int16 Character); void FString.AppendInt(int32 InNum);
// void FString.InsertAt(int32 Index, int16 Character);
// void FString.InsertAt(int32 Index, const FString& Characters);
// void FString.Empty(); void FString.Empty(int Slack);
// void FString.Reset(int NewReservedSize = 0); void FString.Reserve(int Count);
// void FString.Shrink();
// Inputs: Seeded "ab", Other "c", char 100 ('d'), int 7, insert at 1, Empty
// then restore via Append, Reserve(16), Shrink.
// Expected observations: Append returns this and the later read sees the
// suffix. InsertAt shifts characters. Empty yields length 0. Reset also
// yields length 0 while remaining usable.
// Boundary/ownership: Append returns an alias to this string. Empty releases
// storage; Reset may retain capacity.

namespace TS_FString_MutationAndLifecycle_01
{
	bool Observe_Append_Nominal()
	{
		FString Text = "ab";
		FString& Alias = Text.Append("c");
		Alias.Append("d");
		return Text == "abcd";
	}

	bool Observe_AppendChar_Nominal()
	{
		FString Text = "ab";
		Text.AppendChar(99);
		return Text == "abc";
	}

	bool Observe_AppendInt_Nominal()
	{
		FString Text = "n";
		Text.AppendInt(7);
		Text.AppendInt(0);
		return Text.Contains("7") && Text.Contains("0");
	}

	bool Observe_InsertAt_Nominal()
	{
		FString Text = "ac";
		Text.InsertAt(1, 98);
		Text.InsertAt(1, "XY");
		return Text == "aXYbc";
	}

	bool Observe_Empty_Nominal()
	{
		FString Text = "abc";
		Text.Empty();
		bool bEmptyNoSlack = Text.IsEmpty();
		Text = "abc";
		Text.Empty(8);
		return bEmptyNoSlack && Text.IsEmpty();
	}

	bool Observe_Reset_Nominal()
	{
		FString Text = "abc";
		Text.Reset();
		bool bDefaultResetEmpty = Text.IsEmpty();
		Text = "abc";
		Text.Reset(4);
		return bDefaultResetEmpty && Text.IsEmpty();
	}

	bool Observe_Reserve_Nominal()
	{
		FString Text = "ab";
		int Before = Text.Len();
		Text.Reserve(16);
		return Before == 2 && Text.Len() == 2 && Text == "ab";
	}

	bool Observe_Shrink_Nominal()
	{
		FString Text = "ab";
		Text.Reserve(32);
		Text.Shrink();
		return Text == "ab";
	}

	void ExerciseExpectedFailure()
	{
		FString Text = "ab";
		Text.InsertAt(8, 65);
	}
}
