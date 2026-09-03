/**
 * Building common console command strings, including one assembled by repeated
 * concatenation. Only non-empty commands contribute to the score.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ConsoleCommandStringConstructionCompileBoundary
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ConsoleCommandStringConstructionCompileBoundary
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ConsoleCommandStringConstructionCompileBoundary
 * @Provenance sha256=cd1f257b9585eef083e36b6e522f8923e7fddf4106fa6e5a75bfb76e3b183a1f; lines 1252-1282.
 * @Provenance Oracle: BuildCommonConsoleCommandStrings returns 10. Extra: an empty command
 * @Provenance would not increment Score; constructed r.SetRes 1920x1080w is non-empty.
 * @Provenance DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Builds the list of common command strings and counts the non-empty ones.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 10
	 */
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

	/**
	 * Observe that ten non-empty command strings were built.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BuildCommonConsoleCommandStrings()
	 * @Return true when the count is 10
	 */
	UFUNCTION()
	bool CommandStringsCountTen()
	{
		return BuildCommonConsoleCommandStrings() == 10;
	}

	/**
	 * Observe that an empty command contributes nothing to the score.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a list holding a single empty string
	 * @Return true when the score is 0 and the list still holds one entry
	 * @Boundary empty command
	 */
	UFUNCTION()
	bool CommandStringsEmptyBoundary()
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

		if (Score != 0)
		{
			return false;
		}

		return Commands.Num() == 1;
	}

	/**
	 * Observe that concatenating the resolution pieces yields the full command.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the resolution assembled from four parts
	 * @Return true when the result is "r.SetRes 1920x1080w"
	 * @Boundary concatenated command
	 */
	UFUNCTION()
	bool CommandStringsResolutionConcat()
	{
		FString ResolutionCommand = "1920";
		ResolutionCommand += "x";
		ResolutionCommand += "1080";
		ResolutionCommand += "w";
		FString Full = "r.SetRes " + ResolutionCommand;
		return Full == "r.SetRes 1920x1080w";
	}
}
