// Theme: Gameplay.Debug. Value oracle: debug log severity helpers execute.
// C++: AngelscriptCoverageDebugTests.cpp::LogSeverityHelpersEmitExpectedVerbosity
// ExecuteAndExpectInt 9. CSV NegativeDiagnostic; C++ compiles. n"" category overloads.
// Extra: empty message is a distinct call, not mixed into the 9-count helper. DefaultSafe.

int EmitDebugLogSeverity()
{
	Log("CoverageDebugLog_Log");
	LogInfo("CoverageDebugLog_Info");
	LogDisplay("CoverageDebugLog_Display");
	Warning("CoverageDebugLog_Warning");
	Error("CoverageDebugLog_Error");

	Log(n"CoverageDebugLogCategory", "CoverageDebugLog_CategoryLog");
	LogDisplay(n"CoverageDebugLogCategory", "CoverageDebugLog_CategoryDisplay");
	Warning(n"CoverageDebugLogCategory", "CoverageDebugLog_CategoryWarning");
	Error(n"CoverageDebugLogCategory", "CoverageDebugLog_CategoryError");

	return 9;
}

bool Observe_EmitDebugLogSeverity_Nominal()
{
	return EmitDebugLogSeverity() == 9;
}

int Observe_EmitDebugLogSeverity_EmptyMessage()
{
	Log("");
	return 0;
}
