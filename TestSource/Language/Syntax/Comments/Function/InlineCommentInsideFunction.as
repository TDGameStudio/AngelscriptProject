/**
 * Comment forms used inline inside a function body: a single-line comment
 * trailing one declaration, and a block comment sitting between two
 * declarations on the same line.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.InlineCommentInsideFunction
 * @Harness Function
 * @Tag Language.Syntax.Comments.InlineCommentInsideFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 3
 * @Provenance sha256=ca5807eb64816fd1ac154214cb39e5a724e3833d170b7e10d72206e02def1c63; lines 64-70.
 * @Provenance Oracle: Test() runs with X=1, Y=2, Z=3 beside comments.
 * @Provenance Extra: calling Test twice is a no-op boundary. DefaultSafe.
 * @Provenance The function keeps the name Test because C++ invokes it by name.
 */

namespace SyntaxTest
{
	/**
	 * A no-op function whose declarations sit beside inline comments.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		int X = 1; // inline comment
		int Y = 2; /* block */ int Z = 3;
	}

	/**
	 * Observe that the function with inline comments runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs Test()
	 * @Return 1 once the call completes
	 */
	UFUNCTION()
	int InlineCommentedFunctionRuns()
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
	int InlineCommentedFunctionRepeats()
	{
		Test();
		Test();
		return 1;
	}
}
