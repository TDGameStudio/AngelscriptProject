/**
 * @version v1
 * @summary The first of two modules in the single-use case. This module preprocesses successfully on its own; the C++ test asserts that a late AddFile afterwards does not produce a second module. CSV marks the case as a negative.
 * @topic Language
 */
/**
 * @version root
 * @summary The first of two modules in the single-use case. This module preprocesses successfully on its own; the C++ test asserts that a late AddFile afterwards does not produce a second module. CSV marks the case as a negative.
 * @topic Baseline
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
/** @end */
