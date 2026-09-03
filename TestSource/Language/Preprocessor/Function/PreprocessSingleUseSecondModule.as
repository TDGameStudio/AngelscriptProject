/**
 * The second of two modules in the single-use case. Its body is a valid program
 * that would return 11 if compiled alone, but C++ never materializes it: adding
 * a file after Preprocess has run does not emit a second module. CSV marks the
 * case as a negative diagnostic, but that failure belongs to the C++ API
 * contract, so this script follows the value oracle.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.PreprocessSingleUseSecondModule
 * @Harness Function
 * @Tag Language.Preprocessor.PreprocessSingleUseSecondModule
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::PreprocessIsSingleUse Second.as
 * @Provenance lines 282-287;
 * @Provenance sha256=67ea2d9af957d972b12b6de4d51839f0c9a39bf5f620f0c8a1b36ce3e9a5ddcb.
 * @Provenance Oracle: Entry() == 11 if compiled alone. C++ asserts the late module is absent.
 * @Provenance Extra: 11 is the sole return.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace PreprocessorTest
{
	/**
	 * A constant entry point in the second module.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 11
	 */
	int Entry()
	{
		return 11;
	}

	/**
	 * Observe that this module would return 11 if compiled alone.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool SecondModuleWouldReturnEleven()
	{
		return Entry() == 11;
	}
}
