/**
 * @version v1
 * @summary Source supplied purely in memory, with no physical filename, still preprocesses into a single code section and executes.
 * @topic Language
 */
/**
 * @version root
 * @summary Source supplied purely in memory, with no physical filename, still preprocesses into a single code section and executes.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * A constant entry point in a memory-only module.
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
	 * Observe that the memory-only module reports 11.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when the value is 11
	 */
	UFUNCTION()
	bool MemoryTextPreprocessesToEleven()
	{
		return Entry() == 11;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs two calls to Entry()
	 * @Return true when both report 11
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool MemoryTextRepeatsConsistently()
	{
		if (Entry() != 11)
		{
			return false;
		}

		return Entry() == 11;
	}
}
/** @end */
