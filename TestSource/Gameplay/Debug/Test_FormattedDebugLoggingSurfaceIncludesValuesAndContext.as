// Theme: Gameplay.Debug. Positive formatted debug log surface.
// C++: AngelscriptCoverageDebugTests.cpp::FormattedDebugLoggingSurfaceIncludesValuesAndContext
// ExecuteAndExpectInt 3. LogCapture contains "CoverageDebugFormatted Value=42 Branch=High".
// Extra: Value 0 keeps Branch Low; Value 20 is the false side of > 20. DefaultSafe.

int EmitFormattedDebugLogSurface()
{
	FString FunctionName = "EmitFormattedDebugLogSurface";
	FString ObjectName = "CoverageDebugObject";
	int Value = 42;
	FString Branch = "Low";

	if (Value > 20)
	{
		Branch = "High";
	}

	Log(n"CoverageDebugFormat", "Enter " + FunctionName + " Object=" + ObjectName);
	LogDisplay(n"CoverageDebugFormat", "CoverageDebugFormatted Value=" + Value + " Branch=" + Branch);
	Log(n"CoverageDebugFormat", "Exit " + FunctionName);
	return 3;
}

bool Observe_EmitFormattedDebugLogSurface_Nominal()
{
	return EmitFormattedDebugLogSurface() == 3;
}

bool Observe_FormattedBranch_EmptyZero()
{
	int Value = 0;
	FString Branch = "Low";
	if (Value > 20)
	{
		Branch = "High";
	}
	return Value == 0 && Branch == "Low";
}

bool Observe_FormattedBranch_Boundary20()
{
	int Value = 20;
	FString Branch = "Low";
	if (Value > 20)
	{
		Branch = "High";
	}
	return Value == 20 && Branch == "Low";
}
