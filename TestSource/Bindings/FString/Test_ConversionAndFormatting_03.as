// Purpose: Observe ApplyFormat for remaining scalar types and ParseIntoArray
// family splits, including empty-token culling.
// AS-facing API: FString FString::ApplyFormat(uint8/bool/float32/float64/FString/? Value, const FString& Specifier);
// int FString.ParseIntoArray(TArray<FString>& OutArray, const FString& Delimiter, bool bCullEmpty = true) const;
// int FString.ParseIntoArray(TArray<FString>& OutArray, const TArray<FString>& Delimiters, bool bCullEmpty = true) const;
// int FString.ParseIntoArrayLines(TArray<FString>& OutArray, bool bCullEmpty = true) const;
// int FString.ParseIntoArrayWS(TArray<FString>& OutArray, bool bCullEmpty = true) const;
// Inputs: Specifier "x", bool true, floats 1.5, string "ab", "a,b,,c" with
// delimiter ",", line text "a\nb\n", whitespace "a b  c", bCullEmpty true/false.
// Expected observations: ApplyFormat results are non-empty. ParseIntoArray
// count matches tokens; culling omits empties. OutArray preserves order.
// Boundary/ownership: OutArray is filled by the parser; existing entries may
// be replaced depending on implementation, so this source starts from empty.

namespace TS_FString_ConversionAndFormatting_03
{
	bool Observe_ApplyFormat_Nominal()
	{
		FString FromUint8 = FString::ApplyFormat(uint8(7), "x");
		FString FromBool = FString::ApplyFormat(true, "x");
		FString FromFloat32 = FString::ApplyFormat(float32(1.5), "x");
		FString FromFloat64 = FString::ApplyFormat(float64(1.5), "x");
		FString FromString = FString::ApplyFormat(FString("ab"), "x");
		int32 Erased = 9;
		FString FromErased = FString::ApplyFormat(Erased, "x");
		return FromUint8.Len() > 0 && FromBool.Len() > 0 && FromFloat32.Len() > 0 && FromFloat64.Len() > 0 && FromString.Len() > 0 && FromErased.Len() > 0;
	}

	bool Observe_ParseIntoArray_Nominal()
	{
		FString Text = "a,b,,c";
		TArray<FString> Culled;
		int CulledCount = Text.ParseIntoArray(Culled, ",");
		TArray<FString> Kept;
		int KeptCount = Text.ParseIntoArray(Kept, ",", false);
		TArray<FString> Delimiters;
		Delimiters.Add(",");
		Delimiters.Add(";");
		FString Multi = "a;b,c";
		TArray<FString> MultiOut;
		int MultiCount = Multi.ParseIntoArray(MultiOut, Delimiters);
		return CulledCount == 3 && Culled.Num() == 3 && Culled[0] == "a" && Culled[2] == "c" && KeptCount >= CulledCount && MultiCount == 3 && MultiOut[1] == "b";
	}

	bool Observe_ParseIntoArrayLines_Nominal()
	{
		FString Text = "a\nb\n\nc";
		TArray<FString> Lines;
		int Count = Text.ParseIntoArrayLines(Lines);
		TArray<FString> Kept;
		int KeptCount = Text.ParseIntoArrayLines(Kept, false);
		return Count >= 2 && Lines[0] == "a" && KeptCount >= Count;
	}

	bool Observe_ParseIntoArrayWS_Nominal()
	{
		FString Text = "a b  c";
		TArray<FString> Tokens;
		int Count = Text.ParseIntoArrayWS(Tokens);
		TArray<FString> EmptySource;
		int EmptyCount = FString("").ParseIntoArrayWS(EmptySource);
		return Count == 3 && Tokens[2] == "c" && EmptyCount == 0;
	}
}
