// Theme: Containers.TMap. Positive supported log-level wrappers return 1.
// C++ ExecuteAndExpectInt EmitSupportedLogLevels==1 and captures Log/Info/Display/Warning/Error
// plus category overloads. Extra: empty is not a log helper; the function still returns 1
// when invoked again (copy of the success code). DefaultSafe.

int EmitSupportedLogLevels()
{
	Log("CoverageSeverity_Log");
	LogInfo("CoverageSeverity_Info");
	LogDisplay("CoverageSeverity_Display");
	Warning("CoverageSeverity_Warning");
	Error("CoverageLogLevel_Error");

	Log(n"CoverageSeverityCategory", "CoverageSeverity_CategoryLog");
	LogInfo(n"CoverageSeverityCategory", "CoverageSeverity_CategoryInfo");
	LogDisplay(n"CoverageSeverityCategory", "CoverageSeverity_CategoryDisplay");
	Warning(n"CoverageSeverityCategory", "CoverageSeverity_CategoryWarning");
	Error(n"CoverageCustomCategory", "CoverageCategory_Error");

	return 1;
}

int Observe_EmitSupportedLogLevels_Nominal()
{
	return EmitSupportedLogLevels();
}

int Observe_EmitSupportedLogLevels_RepeatCopy()
{
	int First = EmitSupportedLogLevels();
	int Second = EmitSupportedLogLevels();
	return First == 1 && Second == 1 ? 1 : 0;
}
