/**
 * @version v1
 * @summary A consumer whose import sits in a dead branch: the module is never imported because C++ leaves USESHARED false, so the guarded call is stripped and the else branch supplies the sentinel.
 * @topic Language
 */
/**
 * @version root
 * @summary A consumer whose import sits in a dead branch: the module is never imported because C++ leaves USESHARED false, so the guarded call is stripped and the else branch supplies the sentinel.
 * @topic Baseline
 */
#ifdef USESHARED
import Tests.Preprocessor.ImportConditional.Shared2;
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
	 * Observe the else branch taken through the dead branch.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Imports
	 * @Inputs USESHARED false, so the import is ignored
	 * @Return true when the sentinel 99 is returned
	 * @Boundary dead import branch
	 */
	UFUNCTION()
	bool DeadBranchImportFallsToElse()
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
	bool DeadBranchImportSentinelIsNotZero()
	{
		if (Entry() != 99)
		{
			return false;
		}

		return Entry() != 0;
	}
}
/** @end */
