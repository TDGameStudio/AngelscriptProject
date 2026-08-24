// Purpose: Observe tab expansion, case conversion, ToBool/ToDisplayName,
// contributed ToString, FromInt/FormatAsNumber, and one/two-argument Format.
// AS-facing API: FString FString.ConvertTabsToSpaces(int32 InSpacesPerTab) const;
// FString FString.ToUpper() const; FString FString.ToLower() const;
// bool FString.ToBool() const; FString FString.ToDisplayName(bool bIsBool = false) const;
// FString ContributedType.ToString() const; FString FString::FromInt(int32 Num);
// FString FString::FormatAsNumber(int32 InNumber);
// FString FString::Format(const FString& Format, const ?& Arg0);
// FString FString::Format(const FString& Format, const ?& Arg0, const ?& Arg1);
// Inputs: "a\tb", "True"/"False"/"0", identifier bHiddenFlag, integers 0 and
// 1000, format "{0}" / "{0}-{1}".
// Expected observations: Tabs become spaces. ToUpper/ToLower copy case.
// "True" ToBool is true, "0" is false. FromInt(7) contains 7. Format substitutes
// ordered arguments.
// Boundary/ownership: Conversion helpers return new strings; the source is
// unchanged. ToBool recognizes common true/false spellings.

namespace TS_FString_ConversionAndFormatting_01
{
	bool Observe_ConvertTabsToSpaces_Nominal()
	{
		FString Text = "a\tb";
		FString Expanded = Text.ConvertTabsToSpaces(4);
		FString Empty = "".ConvertTabsToSpaces(4);
		return Expanded.Len() > Text.Len() && Expanded.Contains(" ") && Empty.IsEmpty();
	}

	bool Observe_ToUpper_Nominal()
	{
		return FString("Alpha").ToUpper() == "ALPHA";
	}

	bool Observe_ToLower_Nominal()
	{
		return FString("Alpha").ToLower() == "alpha";
	}

	bool Observe_ToBool_Nominal()
	{
		return FString("True").ToBool() && !FString("0").ToBool();
	}

	bool Observe_ToDisplayName_Nominal()
	{
		FString Display = FString("bHiddenFlag").ToDisplayName();
		FString BoolDisplay = FString("bHiddenFlag").ToDisplayName(true);
		return Display.Len() > 0 && BoolDisplay.Len() > 0 && Display != "bHiddenFlag";
	}

	bool Observe_ToString_Nominal()
	{
		FVector Vector(1.0, 2.0, 3.0);
		FString Text = Vector.ToString();
		return Text.Len() > 0;
	}

	bool Observe_FromInt_Nominal()
	{
		return FString::FromInt(7) == "7" && FString::FromInt(0) == "0";
	}

	bool Observe_FormatAsNumber_Nominal()
	{
		FString Number = FString::FormatAsNumber(1000);
		FString Zero = FString::FormatAsNumber(0);
		return Number.Len() > 0 && Number.Contains("1") && Zero.Contains("0");
	}

	bool Observe_Format_Nominal()
	{
		FString One = FString::Format("{0}", 7);
		FString Two = FString::Format("{0}-{1}", "a", 2);
		return One.Contains("7") && Two.Contains("a") && Two.Contains("2");
	}
}
