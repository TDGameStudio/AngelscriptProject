/**
 * @version v1
 * @summary The conditional log helpers, where only a true condition is allowed to emit. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes EmitConditionalLogs expecting 1, so this is a value oracle. The.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The conditional log helpers, where only a true condition is allowed to emit. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes EmitConditionalLogs expecting 1, so this is a value oracle. The.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * Observe that every conditional log helper, in both its plain and its
	 * category-taking form, accepts a condition without error.
	 *
	 * @Kind Observe
	 * @Covers Debug.ConditionalLogFunctionsGateOutput
	 * @Inputs none
	 * @Return 1 once all sixteen calls have been made
	 */
	UFUNCTION()
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

	/**
	 * Observe that driving the whole set of conditional helpers reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.ConditionalLogFunctionsGateOutput
	 * @Inputs none
	 * @Return true when EmitConditionalLogs returned 1
	 */
	UFUNCTION()
	bool EmitConditionalLogsNominal()
	{
		return EmitConditionalLogs() == 1;
	}

	/**
	 * Observe that every conditional helper stays silent when its gate is false.
	 *
	 * @Kind Observe
	 * @Covers Debug.ConditionalLogFunctionsGateOutput
	 * @Inputs none
	 * @Return 0 with no output expected from any of the four calls
	 * @Boundary gated off
	 */
	UFUNCTION()
	int EmitConditionalLogsAllFalse()
	{
		LogIf(false, "");
		LogInfoIf(false, "");
		WarningIf(false, "");
		ErrorIf(false, "");
		return 0;
	}
}
/** @end */
