// Theme: Language.Syntax.EdgeCases. Positive command-string construction.
// C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandStringConstructionCompileBoundary
// sha256=cd1f257b9585eef083e36b6e522f8923e7fddf4106fa6e5a75bfb76e3b183a1f; lines 1252-1282.
// Oracle: BuildCommonConsoleCommandStrings returns 10. Extra: an empty command
// would not increment Score; constructed r.SetRes 1920x1080w is non-empty.
// DefaultSafe.

int BuildCommonConsoleCommandStrings()
{
	TArray<FString> Commands;
	Commands.Add("stat fps");
	Commands.Add("stat unit");
	Commands.Add("stat game");
	Commands.Add("stat gpu");
	Commands.Add("r.SetRes 1920x1080w");
	Commands.Add("show collision");
	Commands.Add("show bounds");
	Commands.Add("viewmode wireframe");
	Commands.Add("viewmode unlit");

	FString ResolutionCommand = "1920";
	ResolutionCommand += "x";
	ResolutionCommand += "1080";
	ResolutionCommand += "w";
	Commands.Add("r.SetRes " + ResolutionCommand);

	int Score = 0;
	for (int Index = 0; Index < Commands.Num(); ++Index)
	{
		if (Commands[Index].Len() > 0)
		{
			Score += 1;
		}
	}
	return Score;
}

bool Observe_CommandStrings_Nominal()
{
	return BuildCommonConsoleCommandStrings() == 10;
}

bool Observe_CommandStrings_EmptyBoundary()
{
	TArray<FString> Commands;
	FString Empty;
	Commands.Add(Empty);
	int Score = 0;
	for (int Index = 0; Index < Commands.Num(); ++Index)
	{
		if (Commands[Index].Len() > 0)
		{
			Score += 1;
		}
	}
	return Score == 0 && Commands.Num() == 1;
}

bool Observe_CommandStrings_ResolutionConcat()
{
	FString ResolutionCommand = "1920";
	ResolutionCommand += "x";
	ResolutionCommand += "1080";
	ResolutionCommand += "w";
	FString Full = "r.SetRes " + ResolutionCommand;
	return Full == "r.SetRes 1920x1080w";
}
