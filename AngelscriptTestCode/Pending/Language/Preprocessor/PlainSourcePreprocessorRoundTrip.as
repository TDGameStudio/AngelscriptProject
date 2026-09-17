/**
 * @version v1
 * @summary A plain source module with no directives at all round-trips through the preprocessor unchanged: it compiles, produces no diagnostics, and executes.
 * @topic Language
 */
/**
 * @version root
 * @summary A plain source module with no directives at all round-trips through the preprocessor unchanged: it compiles, produces no diagnostics, and executes.
 * @topic Baseline
 */
namespace PreprocessorTest
{
	/**
	 * A constant entry point with no directives in the module.
	 *
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs none
	 * @Return 42
	 */
	int Entry()
	{
		return 42;
	}

	/**
	 * Observe that the plain module compiles and returns 42.
	 *
	 * @Kind Observe
	 * @Covers Preprocessor.RoundTrip
	 * @Inputs Entry()
	 * @Return true when Entry reports 42
	 */
	UFUNCTION()
	bool PlainSourceRoundTrips()
	{
		return Entry() == 42;
	}
}
/** @end */
