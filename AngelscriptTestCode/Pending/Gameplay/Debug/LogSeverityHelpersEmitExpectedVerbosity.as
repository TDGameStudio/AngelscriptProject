/**
 * @version v1
 * @summary The debug log severity helpers in both their plain and their category-taking forms. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes EmitDebugLogSeverity expecting 9, so this is a value.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The debug log severity helpers in both their plain and their category-taking forms. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes EmitDebugLogSeverity expecting 9, so this is a value.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * The entrypoint C++ executes, calling each severity helper in both forms.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogSeverityHelpersEmitExpectedVerbosity
	 * @Inputs none
	 * @Return 9 once all nine calls have been made
	 */
	UFUNCTION()
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

	/**
	 * Observe that driving every severity helper reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogSeverityHelpersEmitExpectedVerbosity
	 * @Inputs none
	 * @Return true when the entrypoint returned 9
	 */
	UFUNCTION()
	bool EmitDebugLogSeverityNominal()
	{
		return EmitDebugLogSeverity() == 9;
	}

	/**
	 * Observe that logging an empty message is accepted as a call of its own.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogSeverityHelpersEmitExpectedVerbosity
	 * @Inputs none
	 * @Return 0, kept separate from the nine-call helper
	 * @Boundary empty message
	 */
	UFUNCTION()
	int EmitDebugLogSeverityEmptyMessage()
	{
		Log("");
		return 0;
	}
}
/** @end */
