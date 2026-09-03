/**
 * A minimal parse: a module holding one function and no directives round-trips
 * through the preprocessor and keeps its function in the processed output.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.BasicParse
 * @Harness Function
 * @Tag Language.Preprocessor.BasicParse
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptPreprocessorBasicTests.cpp::BasicParse
 * @Provenance lines 39-44;
 * @Provenance sha256=bcfe9538d7b203ef7225623991f39a3de7795a2b9c494ecf53a765b3212837dd.
 * @Provenance Oracle: ReturnSeven() == 7. Processed code contains ReturnSeven.
 * @Provenance Extra: 7 is the sole return; no empty branch.
 * @Provenance DefaultSafe. Source owns locals.
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
