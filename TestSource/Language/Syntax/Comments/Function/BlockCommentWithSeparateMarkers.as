/**
 * A block comment containing the * and / characters as separate, unpaired
 * characters. The lexer must not treat them as a nested comment terminator.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.BlockCommentWithSeparateMarkers
 * @Harness Function
 * @Tag Language.Syntax.Comments.BlockCommentWithSeparateMarkers
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 4
 * @Provenance sha256=7c35629ab2cdfb1a0b0dc8d5a317c4630304647563d8ca50f4a05f2b317ec89f; lines 74-77.
 * @Provenance Oracle: empty Test() runs after "/* Comment with * and / separately *\/".
 * @Provenance Extra: calling Test twice is a no-op boundary. DefaultSafe.
 * @Provenance The function keeps the name Test because C++ invokes it by name.
 */

namespace SyntaxTest
{
	/**
	 * An empty function preceded by a block comment holding separate markers.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
	}

	/**
	 * Observe that the function after the tricky comment runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Test()
	 * @Return 1 once the call completes
	 */
	UFUNCTION()
	int SeparateMarkerCommentFunctionRuns()
	{
		Test();
		return 1;
	}

	/**
	 * Observe that calling the function twice is still a no-op.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs two calls to Test()
	 * @Return 1 once both calls complete
	 * @Boundary repeat
	 */
	UFUNCTION()
	int SeparateMarkerCommentFunctionRepeats()
	{
		Test();
		Test();
		return 1;
	}
}
