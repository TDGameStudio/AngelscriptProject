/**
 * The first of two modules in the single-use case. This module preprocesses
 * successfully on its own; the C++ test asserts that a late AddFile afterwards
 * does not produce a second module. CSV marks the case as a negative
 * diagnostic, but that failure belongs to the C++ API contract, not to this
 * script, which follows the value oracle.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.PreprocessSingleUseFirstModule
 * @Harness Function
 * @Tag Language.Preprocessor.PreprocessSingleUseFirstModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::PreprocessIsSingleUse First.as
 * @Provenance lines 275-280;
 * @Provenance sha256=64706dfe8cdbb585689bc2f3cb3da74470da6c314cff3f03363ee5e0233b24b0.
 * @Provenance Oracle: Entry() == 7. First Preprocess emits one module.
 * @Provenance Extra: 7 is the sole return.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * A constant entry point in the first module.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	int Entry()
	{
		return 7;
	}

	/**
	 * Observe that the first module preprocesses and returns 7.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool FirstModulePreprocessesToSeven()
	{
		return Entry() == 7;
	}
}
