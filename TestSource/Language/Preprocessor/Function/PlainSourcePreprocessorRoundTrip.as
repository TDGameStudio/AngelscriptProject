/**
 * A plain source module with no directives at all round-trips through the
 * preprocessor unchanged: it compiles, produces no diagnostics, and executes.
 *
 * @Theme Language.Preprocessor
 * @Subject Preprocessor.PlainSourcePreprocessorRoundTrip
 * @Harness Function
 * @Tag Language.Preprocessor.PlainSourcePreprocessorRoundTrip
 * @Namespace PreprocessorTest
 * @Provenance C++: AngelscriptCompilerExecutionTests.cpp::PlainSourcePreprocessorRoundTrip
 * @Provenance CompileModuleWithSummary + ExecuteIntFunction; lines 118-123;
 * @Provenance sha256=dfc2a901d4a7cff773938db25445810403dcfd6f709134de4c99e23cf9218b74.
 * @Provenance Oracle: Entry() == 42. Summary.bCompileSucceeded, diagnostics empty.
 * @Provenance Extra: constant return has no empty/false branch; 42 is the sole value.
 * @Provenance DefaultSafe. Source owns locals.
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
