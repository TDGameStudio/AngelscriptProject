/**
 * A consumer whose import is guarded by USE_SHARED. With the flag on, the
 * import is kept and the consumer derives from the imported value; with it off,
 * the else branch supplies a sentinel instead.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.ConditionalImportEnabledConsumer
 * @Harness Function
 * @Tag Language.Preprocessor.ConditionalImportEnabledConsumer
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCoveragePreprocessorTests.cpp::ImportDependencyAndConditionalBranches
 * @Provenance Consumer.as; lines 52-65; preprocess flags USE_SHARED=true.
 * @Provenance sha256=bcb991d88afe14e241f1f2899311646884fcc44c751d3685ae53777861eec20e.
 * @Provenance Oracle: with USE_SHARED, Entry() == SharedValue() + 2 == 42; import kept.
 * @Provenance Without USE_SHARED, Entry() == -1 (the #else). C++ keeps the +2 path.
 * @Provenance Extra: -1 is the disabled-import false path recorded in the source.
 * @Provenance DefaultSafe. Import identity: Tests.Coverage.Preprocessor.Shared.
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
