/**
 * @version v1
 * @summary The second of two modules in the single-use case. Its body is a valid program that would return 11 if compiled alone, but C++ never materializes it: adding a file after Preprocess has run does not emit a second module.
 * @topic Language
 */
/**
 * @version root
 * @summary The second of two modules in the single-use case. Its body is a valid program that would return 11 if compiled alone, but C++ never materializes it: adding a file after Preprocess has run does not emit a second module.
 * @topic Baseline
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
/** @end */
