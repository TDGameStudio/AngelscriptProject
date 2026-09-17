/**
 * @version v1
 * @summary The consumer half of a conditional import, exercised with USESHARED undefined: the guarded import is stripped, so the else branch supplies the sentinel value instead.
 * @topic Language
 */
/**
 * @version root
 * @summary The consumer half of a conditional import, exercised with USESHARED undefined: the guarded import is stripped, so the else branch supplies the sentinel value instead.
 * @topic Baseline
 */
#ifdef USESHARED
import Tests.Preprocessor.ImportConditional.Shared;
#endif

namespace PreprocessorTest
{
	/**
	 * Returns the imported value when USESHARED is defined, else a sentinel.
	 *
	 * @Covers Preprocessor.Imports
	 * @Inputs the flag USESHARED
	 * @Return the imported value, or 99 from the else branch
	 */
	int Entry()
	{
#ifdef USESHARED
		return SharedValue();
#else
		return 99;
#endif
	}

	/**
	 * Observe the else branch taken when the flag is undefined.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs USESHARED undefined
	 * @Return true when the sentinel 99 is returned
	 * @Boundary undefined flag
	 */
	UFUNCTION()
	bool ConditionalImportFallsToElseBranch()
	{
		return Entry() == 99;
	}

	/**
	 * Observe that the sentinel is distinct from a zero value.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs two calls to Entry()
	 * @Return true when both report 99, which is not 0
	 * @Boundary sentinel distinctness
	 */
	UFUNCTION()
	bool ConditionalImportElseSentinelIsNotZero()
	{
		if (Entry() != 99)
		{
			return false;
		}

		return Entry() != 0;
	}
}
/** @end */
