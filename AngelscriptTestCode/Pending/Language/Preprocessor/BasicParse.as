/**
 * @version v1
 * @summary A minimal parse: a module holding one function and no directives round-trips through the preprocessor and keeps its function in the processed output.
 * @topic Language
 */
/**
 * @version root
 * @summary A minimal parse: a module holding one function and no directives round-trips through the preprocessor and keeps its function in the processed output.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * A constant entry point in an otherwise empty module.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 7
	 */
	int ReturnSeven()
	{
		return 7;
	}

	/**
	 * Observe that the minimal module parses and returns 7.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs ReturnSeven()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool BasicParseProducesReturnSeven()
	{
		return ReturnSeven() == 7;
	}
}
/** @end */
