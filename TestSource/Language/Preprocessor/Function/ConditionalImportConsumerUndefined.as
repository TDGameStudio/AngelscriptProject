/**
 * The consumer half of a conditional import, exercised with USESHARED
 * undefined: the guarded import is stripped, so the else branch supplies the
 * sentinel value instead.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ConditionalImportConsumerUndefined
 * @Harness Function
 * @Tag Language.Preprocessor.ConditionalImportConsumerUndefined
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorImportTests.cpp::ImportInsideConditionalBranch block 2
 * @Provenance sha256=e04fc9ed7dadaa43dea81b0b87ed5e46d6a57d2395e4385a2a748ae74d8949d3; lines 623-635.
 * @Provenance Oracle without define: Entry() == 99 (else branch). With USESHARED: Entry() == SharedValue() == 42.
 * @Provenance Extra: else-branch 99 is the default-empty define path. DefaultSafe.
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
