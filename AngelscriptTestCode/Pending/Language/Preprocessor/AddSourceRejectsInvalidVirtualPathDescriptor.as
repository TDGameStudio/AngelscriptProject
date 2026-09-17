/**
 * @version v1
 * @summary The script text for the invalid-descriptor case. The script itself is valid and would execute; the failure this case records is in the C++ AddSource API, which rejects the descriptor before the text is ever compiled. CSV.
 * @topic Language
 */
/**
 * @version root
 * @summary The script text for the invalid-descriptor case. The script itself is valid and would execute; the failure this case records is in the C++ AddSource API, which rejects the descriptor before the text is ever compiled. CSV.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * A constant entry point in the rejected-descriptor script.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 13
	 */
	int Entry()
	{
		return 13;
	}

	/**
	 * Observe that the script text itself is a valid program.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 13
	 */
	UFUNCTION()
	bool DescriptorScriptTextIsValid()
	{
		return Entry() == 13;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs two calls to Entry()
	 * @Return true when both report 13
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool DescriptorScriptRepeatsConsistently()
	{
		if (Entry() != 13)
		{
			return false;
		}

		return Entry() == 13;
	}
}
/** @end */
