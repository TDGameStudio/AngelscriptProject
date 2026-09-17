/**
 * @version v1
 * @summary A fixture for PostProcessCode replacement: the C++ hook rewrites the CACHE_EXTERNAL_VALUE token into a literal before compilation, so the function that reads it must observe the substituted value.
 * @topic Language
 */
/**
 * @version root
 * @summary A fixture for PostProcessCode replacement: the C++ hook rewrites the CACHE_EXTERNAL_VALUE token into a literal before compilation, so the function that reads it must observe the substituted value.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	class FCachePayload
	{
		int Count;
	}

	/**
	 * Reads the value that the post-process hook substitutes.
	 *
	 * @Covers Preprocessor.Rewrites
	 * @Inputs the token CACHE_EXTERNAL_VALUE
	 * @Return 7 after substitution
	 */
	int GetCacheAnswer()
	{
		return CACHE_EXTERNAL_VALUE;
	}

	/**
	 * Observe that the hook replaced the token with 7.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs GetCacheAnswer()
	 * @Return true when the value is 7
	 */
	UFUNCTION()
	bool PostProcessReplacementYieldsSeven()
	{
		return GetCacheAnswer() == 7;
	}

	/**
	 * Observe the default state of the payload struct.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs a default-constructed FCachePayload
	 * @Return true when Count is 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool CachePayloadDefaultsToZero()
	{
		FCachePayload Payload;
		return Payload.Count == 0;
	}

	/**
	 * Observe that two payload instances do not share state.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.Rewrites
	 * @Inputs two payloads, one written to
	 * @Return true when the write is local and the answer stays 7
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool CachePayloadInstancesAreIndependent()
	{
		FCachePayload First;
		FCachePayload Second;
		First.Count = 7;

		if (First.Count != 7)
		{
			return false;
		}

		if (Second.Count != 0)
		{
			return false;
		}

		return GetCacheAnswer() == 7;
	}
}
/** @end */
