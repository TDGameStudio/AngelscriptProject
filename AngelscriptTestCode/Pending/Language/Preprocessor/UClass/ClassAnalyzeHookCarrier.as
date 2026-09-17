/**
 * @version v1
 * @summary A carrier for the class-analyze hook. C++ injects a generated static that returns 31, but that value is hook injection rather than anything authored here; this script's own Entry returns 5, which is the authored oracle.
 * @topic Language
 */
/**
 * @version root
 * @summary A carrier for the class-analyze hook. C++ injects a generated static that returns 31, but that value is hook injection rather than anything authored here; this script's own Entry returns 5, which is the authored oracle.
 * @topic Baseline
 */
UCLASS()
class UClassAnalyzeHookCarrier : UObject
{
	/**
	 * The authored entry point whose value the hook does not alter.
	 *
	 * @Covers Preprocessor.Events
	 * @Inputs none
	 * @Return 5
	 */
	UFUNCTION()
	int Entry()
	{
		return 5;
	}

	/**
	 * Observe that the authored return survives the analyze hook.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Events
	 * @Inputs Entry()
	 * @Return true when the value is 5
	 */
	UFUNCTION()
	bool ClassAnalyzeHookKeepsAuthoredReturn()
	{
		return Entry() == 5;
	}
}
/** @end */
