/**
 * @version v1
 * @summary ThrowIf, where a false condition lets execution continue and a true condition raises a script exception. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes ThrowIfFalseContinues expecting 11.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary ThrowIf, where a false condition lets execution continue and a true condition raises a script exception. The CSV NegativeDiagnostic label is a heuristic: C++ compiles this and executes ThrowIfFalseContinues expecting 11.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * The entrypoint C++ executes for the no-throw path.
	 *
	 * @Kind Observe
	 * @Covers Debug.ThrowIfReportsScriptException
	 * @Inputs none
	 * @Return 11 once the false condition has been passed through
	 */
	UFUNCTION()
	int ThrowIfFalseContinues()
	{
		ThrowIf(false, "CoverageThrowIfSkipped");
		return 11;
	}

	/**
	 * Raise the script exception the throwing path is named after. C++ invokes this and
	 * expects the error; no observer calls it.
	 *
	 * @Kind Action
	 * @Covers Debug.ThrowIfReportsScriptException
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 */
	UFUNCTION()
	void TriggerThrowIf()
	{
		ThrowIf(true, "CoverageThrowIfTriggered");
	}

	/**
	 * Observe that a false condition lets execution reach the return.
	 *
	 * @Kind Observe
	 * @Covers Debug.ThrowIfReportsScriptException
	 * @Inputs none
	 * @Return true when the entrypoint returned 11
	 */
	UFUNCTION()
	bool ThrowIfFalseContinuesNominal()
	{
		return ThrowIfFalseContinues() == 11;
	}
}
/** @end */
