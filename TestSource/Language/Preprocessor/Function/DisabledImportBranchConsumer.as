/**
 * A consumer whose guarded import is never taken: C++ leaves USE_SHARED false,
 * so the import is ignored entirely, the import count stays zero, and the
 * emitted code returns the else-branch sentinel rather than any imported value.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.DisabledImportBranchConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.DisabledImportBranchConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::DisabledImportBranchIsIgnored
 * @Provenance DisabledConsumer.as; lines 117-130; preprocess flags USE_SHARED=false.
 * @Provenance sha256=90eb196cb3954a086399551d9a1f73affbfb6e8a3020e64a18a4a28f19e375b1.
 * @Provenance Oracle: Entry() == 7; import count 0; processed code has return 7, not SharedValue.
 * @Provenance Extra: USE_SHARED true would return SharedValue() from UnusedShared (40).
 * @Provenance DefaultSafe. Planned SharedValue stays in the skipped #ifdef branch.
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
