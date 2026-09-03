/**
 * A single-line comment placed immediately before a function declaration. The
 * function itself is a no-op; the point is that the comment form compiles.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.CommentBeforeFunction
 * @Harness Function
 * @Tag Language.Syntax.Comments.CommentBeforeFunction
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptSyntaxMiscTests.cpp::Comments_Positive block 1
 * @Provenance sha256=f00695e9ef1ffce160959b7c4c392fd03917e6742fdfadad3b529d8390ccf4a0; lines 49-52.
 * @Provenance Oracle: Test() runs after "// This is a comment".
 * @Provenance Extra: calling Test twice is a no-op boundary. DefaultSafe.
 * @Provenance The function keeps the name Test because C++ invokes it by name.
 */

namespace SyntaxTest
{
	/**
	 * A no-op function preceded by a single-line comment.
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
	int CommentedFunctionRuns()
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
	int CommentedFunctionRepeats()
	{
		Test();
		Test();
		return 1;
	}
}
