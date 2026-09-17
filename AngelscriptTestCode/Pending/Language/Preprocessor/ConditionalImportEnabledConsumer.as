/**
 * @version v1
 * @summary A consumer whose import is guarded by USE_SHARED. With the flag on, the import is kept and the consumer derives from the imported value; with it off, the else branch supplies a sentinel instead.
 * @topic Language
 */
/**
 * @version root
 * @summary A consumer whose import is guarded by USE_SHARED. With the flag on, the import is kept and the consumer derives from the imported value; with it off, the else branch supplies a sentinel instead.
 * @topic Baseline
 */
#ifdef USE_SHARED
import Tests.Coverage.Preprocessor.Shared;
#endif

namespace PreprocessorTest
{
	/**
	 * Derives from the imported value when the flag is set, else a sentinel.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the flag USE_SHARED and the imported SharedValue
	 * @Return the imported value plus 2, or -1 from the else branch
	 */
	int Entry()
	{
#ifdef USE_SHARED
		return SharedValue() + 2;
#else
		return -1;
#endif
	}

	/**
	 * Observe the enabled path where the import is kept.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs USE_SHARED=true
	 * @Return true when Entry reports 42
	 */
	UFUNCTION()
	bool EnabledImportDerivesFromSharedValue()
	{
		return Entry() == 42;
	}
}
/** @end */
