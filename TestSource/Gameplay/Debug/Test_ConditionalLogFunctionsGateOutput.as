// Theme: Gameplay.Debug. Conditional LogIf/WarningIf/ErrorIf gate output.
// C++: AngelscriptCoverageLoggingTests.cpp::ConditionalLogFunctionsGateOutput
// CSV NegativeDiagnostic; C++ compiles. ExecuteAndExpectInt EmitConditionalLogs == 1.
// True branches emit; false branches stay silent. Extra: false is the empty/gated vector.
// DefaultSafe.

int EmitConditionalLogs()
{
	LogIf(true, "CoverageConditional_LogTrue");
	LogIf(false, "CoverageConditional_LogFalse");
	LogInfoIf(true, "CoverageConditional_InfoTrue");
	LogInfoIf(false, "CoverageConditional_InfoFalse");
	WarningIf(true, "CoverageConditional_WarningTrue");
	WarningIf(false, "CoverageConditional_WarningFalse");
	ErrorIf(true, "CoverageConditional_Error");
	ErrorIf(false, "CoverageConditional_ErrorFalse");

	LogIf(true, n"CoverageConditionalCategory", "CoverageConditional_CategoryLogTrue");
	LogIf(false, n"CoverageConditionalCategory", "CoverageConditional_CategoryLogFalse");
	LogInfoIf(true, n"CoverageConditionalCategory", "CoverageConditional_CategoryInfoTrue");
	LogInfoIf(false, n"CoverageConditionalCategory", "CoverageConditional_CategoryInfoFalse");
	LogDisplayIf(true, n"CoverageConditionalCategory", "CoverageConditional_DisplayTrue");
	LogDisplayIf(false, n"CoverageConditionalCategory", "CoverageConditional_DisplayFalse");
	WarningIf(true, n"CoverageConditionalCategory", "CoverageConditional_CategoryWarningTrue");
	WarningIf(false, n"CoverageConditionalCategory", "CoverageConditional_CategoryWarningFalse");
	ErrorIf(true, n"CoverageConditionalCategory", "CoverageConditional_CategoryErrorTrue");
	ErrorIf(false, n"CoverageConditionalCategory", "CoverageConditional_CategoryErrorFalse");

	return 1;
}

bool Observe_EmitConditionalLogs_Nominal()
{
	return EmitConditionalLogs() == 1;
}

int Observe_EmitConditionalLogs_AllFalse()
{
	LogIf(false, "");
	LogInfoIf(false, "");
	WarningIf(false, "");
	ErrorIf(false, "");
	return 0;
}
