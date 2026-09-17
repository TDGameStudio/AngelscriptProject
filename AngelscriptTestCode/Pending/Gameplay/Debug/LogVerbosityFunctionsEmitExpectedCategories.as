/**
 * @version v1
 * @summary The log verbosity helpers in both their plain and their custom-category forms. C++ executes EmitLogVerbosityMessages expecting 1. The observers cover the nominal run and the empty message.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The log verbosity helpers in both their plain and their custom-category forms. C++ executes EmitLogVerbosityMessages expecting 1. The observers cover the nominal run and the empty message.
 * @topic Baseline
 */
namespace DebugTest
{
	/**
	 * The entrypoint C++ executes, calling each verbosity helper in both forms.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogVerbosityFunctionsEmitExpectedCategories
	 * @Inputs none
	 * @Return 1 once all eight calls have been made
	 */
	UFUNCTION()
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

	/**
	 * Observe that driving every verbosity helper reports success.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogVerbosityFunctionsEmitExpectedCategories
	 * @Inputs none
	 * @Return true when the entrypoint returned 1
	 */
	UFUNCTION()
	bool EmitLogVerbosityMessagesNominal()
	{
		return EmitLogVerbosityMessages() == 1;
	}

	/**
	 * Observe that logging an empty message is accepted as a call of its own.
	 *
	 * @Kind Observe
	 * @Covers Debug.LogVerbosityFunctionsEmitExpectedCategories
	 * @Inputs none
	 * @Return 0, kept separate from the eight-call helper
	 * @Boundary empty message
	 */
	UFUNCTION()
	int EmitLogVerbosityMessagesEmptyMessage()
	{
		Log("");
		return 0;
	}
}
/** @end */
