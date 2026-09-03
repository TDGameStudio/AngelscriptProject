/**
 * A block comment spanning two lines placed immediately before a function
 * declaration. The function itself is a no-op; the point is that the comment
 * form compiles.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.BlockCommentBeforeFunction
 * @Harness Function
 * @Tag Language.Syntax.Comments.BlockCommentBeforeFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 2
 * @Provenance sha256=21a4222d526e33adddc7cb47783d28ae5cb40b84461a1b86d5d9b226a10a350c; lines 56-60.
 * @Provenance Oracle: Test() runs after the block comment.
 * @Provenance Extra: calling Test twice is a no-op boundary. DefaultSafe.
 * @Provenance The function keeps the name Test because C++ invokes it by name.
 */

namespace SyntaxTest
{
	/**
	 * A no-op function preceded by a multi-line block comment.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int X = 1;
	}

	/**
	 * Observe that the commented function runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Test()
	 * @Return 1 once the call completes
	 */
	UFUNCTION()
	int BlockCommentedFunctionRuns()
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
	int BlockCommentedFunctionRepeats()
	{
		Test();
		Test();
		return 1;
	}
}
