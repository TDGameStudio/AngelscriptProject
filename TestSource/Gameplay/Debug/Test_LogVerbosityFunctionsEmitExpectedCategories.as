// Theme: Gameplay.Debug. Positive log verbosity helpers emit expected categories.
// C++: AngelscriptCoverageLoggingTests.cpp::LogVerbosityFunctionsEmitExpectedCategories
// ExecuteAndExpectInt EmitLogVerbosityMessages == 1. n"" custom category overloads.
// Extra: empty message is a distinct call. DefaultSafe.

int EmitLogVerbosityMessages()
{
	Log("CoverageLogLevel_Log");
	LogInfo("CoverageLogLevel_Info");
	LogDisplay("CoverageLogLevel_Display");
	Warning("CoverageLogLevel_Warning");
	Error("CoverageLogLevel_Error");

	Log(n"CoverageCustomCategory", "CoverageCategory_Log");
	Warning(n"CoverageCustomCategory", "CoverageCategory_Warning");
	Error(n"CoverageCustomCategory", "CoverageCategory_Error");

	return 1;
}

bool Observe_EmitLogVerbosityMessages_Nominal()
{
	return EmitLogVerbosityMessages() == 1;
}

int Observe_EmitLogVerbosityMessages_EmptyMessage()
{
	Log("");
	return 0;
}
