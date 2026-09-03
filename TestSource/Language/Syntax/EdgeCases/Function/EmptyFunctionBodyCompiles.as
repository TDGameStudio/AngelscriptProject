/**
 * An empty function body compiles and can be invoked. The observers confirm a
 * single call completes and that repeated calls share no state.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EmptyFunctionBodyCompiles
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.EmptyFunctionBodyCompiles
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive ASSyntaxMiscEmptyFunc AssertCompiles
 * @Provenance sha256=8bd1e6fa92effb44b49d763fab5135e033d1d1cfa7f6ce2fdfcc450342610523; lines 229-231.
 * @Provenance Oracle: DoNothing compiles and can be invoked.
 * @Provenance Extra: a second call is independent of the first (no state).
 * @Provenance DefaultSafe. Source owns nothing.
 */

namespace SyntaxTest
{
	/**
	 * A function with an empty body.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void DoNothing()
	{
	}

	/**
	 * Observe that a single call completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs DoNothing()
	 * @Return true once the call completes
	 */
	UFUNCTION()
	bool EmptyFunctionInvokesOnce()
	{
		DoNothing();
		return true;
	}

	/**
	 * Observe that repeated calls complete and share no state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two calls to DoNothing()
	 * @Return true once both calls complete
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool EmptyFunctionInvokesRepeatedly()
	{
		DoNothing();
		DoNothing();
		return true;
	}
}
