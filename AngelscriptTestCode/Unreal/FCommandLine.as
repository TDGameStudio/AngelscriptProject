/**
 * @version v1
 * @summary FCommandLine host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FCommandLine
 *
 * parse
 * get
 */
/**
 * @begin parse
 * @summary own the command-line string.
 * @topic Unreal
 */
/**
 * @function ObserveParseNominal
 * @summary own the command-line string.
 * @covers FCommandLine.parse
 * @inputs FCommandLine values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParseNominal()
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
/** @end */
/**
 * @begin get
 * @summary command-line storage.
 * @topic Unreal
 */
/**
 * @function ObserveGetNominal
 * @summary command-line storage.
 * @covers FCommandLine.get
 * @inputs FCommandLine values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetNominal()
{
	FString First = FCommandLine::Get();
	FString Second = FCommandLine::Get();
	int FirstLen = First.Len();
	First += "_mutated";
	FString Third = FCommandLine::Get();
	return Second == Third && First.Len() > FirstLen;
}
/** @end */
