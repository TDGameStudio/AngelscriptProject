// Purpose: Observe Split, Replace/ReplaceInline, Join, SanitizeFloat, and
// Chr/ChrN helpers.
// AS-facing API: bool FString.Split(...);
// FString FString.Replace(...); int FString.ReplaceInline(...);
// FString FString::Join(const TArray<FString>& StringArray, const FString& Separator);
// FString FString::SanitizeFloat(float64 InFloat, int32 InMinFractionalDigits = 1);
// FString FString::Chr(int16 Ch); FString FString::ChrN(int32 NumCharacters, int16 Char);
// Inputs: "left-mid-right" needle "-", Replace "mid"->"MID", array {a,b},
// float 2.5 default digits, Chr 65, ChrN(3, 46).
// Expected observations: Split writes OutLeft/OutRight and returns true.
// Missing needle returns false. ReplaceInline returns replacement count.
// Join uses the separator. ChrN(0) is empty. SanitizeFloat of 2.5 is non-empty.
// Boundary/ownership: Split writes outs only on success. Replace returns a
// copy; ReplaceInline mutates this.

namespace TS_FString_NamespaceAndGlobalFunctions_01
{
	bool Observe_Split_Nominal()
	{
		FString Text = "left-mid-right";
		FString OutLeft;
		FString OutRight;
		bool bSplit = Text.Split("-", OutLeft, OutRight);
		FString MissingLeft;
		FString MissingRight;
		bool bMissing = Text.Split("zzz", MissingLeft, MissingRight);
		return bSplit && OutLeft == "left" && OutRight == "mid-right" && !bMissing;
	}

	bool Observe_Replace_Nominal()
	{
		FString Text = "mid-mid";
		FString Replaced = Text.Replace("mid", "MID");
		FString EmptyReplaced = Text.Replace("zzz", "Q");
		return Replaced == "MID-MID" && Text == "mid-mid" && EmptyReplaced == "mid-mid";
	}

	bool Observe_ReplaceInline_Nominal()
	{
		FString Text = "mid-mid";
		int Count = Text.ReplaceInline("mid", "MID");
		int Missing = Text.ReplaceInline("zzz", "Q");
		return Count == 2 && Text == "MID-MID" && Missing == 0;
	}

	bool Observe_Join_Nominal()
	{
		TArray<FString> Parts;
		Parts.Add("a");
		Parts.Add("b");
		FString Joined = FString::Join(Parts, ",");
		TArray<FString> Empty;
		FString EmptyJoined = FString::Join(Empty, ",");
		return Joined == "a,b" && EmptyJoined.IsEmpty();
	}

	bool Observe_SanitizeFloat_Nominal()
	{
		FString DefaultDigits = FString::SanitizeFloat(2.5);
		FString TwoDigits = FString::SanitizeFloat(2.5, 2);
		FString Zero = FString::SanitizeFloat(0.0);
		return DefaultDigits.Contains("2") && TwoDigits.Len() > 0 && Zero.Contains("0");
	}

	bool Observe_Chr_Nominal()
	{
		FString A = FString::Chr(65);
		return A == "A" && A.Len() == 1;
	}

	bool Observe_ChrN_Nominal()
	{
		FString Dots = FString::ChrN(3, 46);
		FString Empty = FString::ChrN(0, 46);
		return Dots == "..." && Empty.IsEmpty();
	}
}
