// Purpose: Observe FCommandLine::Parse splitting text into tokens and
// switches, including empty input and writeback into existing arrays.
// AS-facing API: void FCommandLine::Parse(const FString& CommandLine,
// TArray<FString>&out Tokens, TArray<FString>&out Switches);
// Inputs: Non-empty "-foo Alpha Beta", empty command line, and arrays that
// already contain a sentinel.
// Expected observations: Tokens receive positional words and Switches
// receive switch names without the leading dash. Empty input leaves both
// arrays empty when they started empty. Pre-seeded entries remain at index 0.
// Boundary/ownership: Parse writes through Tokens and Switches. It does not
// own the command-line string.

namespace TS_FCommandLine_ConversionAndFormatting_01
{
	bool Observe_Parse_Nominal()
	{
		TArray<FString> Tokens;
		TArray<FString> Switches;
		FCommandLine::Parse("-foo Alpha Beta", Tokens, Switches);
		bool bHasAlpha = false;
		bool bHasBeta = false;
		for (int Index = 0; Index < Tokens.Num(); Index++)
		{
			if (Tokens[Index] == "Alpha")
			{
				bHasAlpha = true;
			}
			if (Tokens[Index] == "Beta")
			{
				bHasBeta = true;
			}
		}

		TArray<FString> EmptyTokens;
		TArray<FString> EmptySwitches;
		FCommandLine::Parse("", EmptyTokens, EmptySwitches);

		TArray<FString> SeededTokens;
		TArray<FString> SeededSwitches;
		SeededTokens.Add("Sentinel");
		int SeededCountBefore = SeededTokens.Num();
		FCommandLine::Parse("-bar", SeededTokens, SeededSwitches);

		return Tokens.Num() >= 2 && Switches.Num() == 1 && Switches[0] == "foo" && bHasAlpha && bHasBeta && EmptyTokens.Num() == 0 && EmptySwitches.Num() == 0 && SeededTokens.Num() > SeededCountBefore && SeededTokens[0] == "Sentinel" && SeededSwitches.Num() == 1 && SeededSwitches[0] == "bar";
	}
}
