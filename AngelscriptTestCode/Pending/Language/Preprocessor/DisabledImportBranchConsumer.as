/**
 * @version v1
 * @summary A consumer whose guarded import is never taken: C++ leaves USE_SHARED false, so the import is ignored entirely, the import count stays zero, and the emitted code returns the else-branch sentinel rather than any imported.
 * @topic Language
 */
/**
 * @version root
 * @summary A consumer whose guarded import is never taken: C++ leaves USE_SHARED false, so the import is ignored entirely, the import count stays zero, and the emitted code returns the else-branch sentinel rather than any imported.
 * @topic Baseline
 */
#ifdef USE_SHARED
import Tests.Coverage.Preprocessor.UnusedShared;
#endif

namespace PreprocessorTest
{
	/**
	 * Returns the imported value when the flag is set, else a sentinel.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the flag USE_SHARED
	 * @Return the imported value, or 7 from the else branch
	 */
	int Entry()
	{
#ifdef USE_SHARED
		return SharedValue();
#else
		return 7;
#endif
	}

	/**
	 * Observe the disabled path where the import is ignored.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs USE_SHARED=false
	 * @Return true when Entry reports 7
	 * @Boundary disabled import
	 */
	UFUNCTION()
	bool DisabledImportFallsToSentinel()
	{
		return Entry() == 7;
	}
}
/** @end */
