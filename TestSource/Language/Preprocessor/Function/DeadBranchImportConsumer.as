/**
 * A consumer whose import sits in a dead branch: the module is never imported
 * because C++ leaves USESHARED false, so the guarded call is stripped and the
 * else branch supplies the sentinel.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DeadBranchImportConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.DeadBranchImportConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 6
 * @Provenance sha256=64c563786fd00f5ecdef071527c55ad8cf38a8e67b42735c7a797c9984987579; lines 687-699.
 * @Provenance Oracle: Entry() == 99; import Tests.Preprocessor.ImportConditional.Shared2 is ignored; SharedValue is stripped.
 * @Provenance Extra: 99 is the empty-define else path. DefaultSafe.
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
