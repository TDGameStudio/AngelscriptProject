/**
 * A single-line comment placed before a declaration, and another trailing a
 * statement, both compile and leave the code around them working.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.SingleLineComment
 * @Harness Function
 * @Tag Language.Syntax.Comments.SingleLineComment
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 1
 * @Provenance sha256=28dc1bffba9fd1c0511aa0c401d07f50b1ff29661c20e7331bfe02cc343ba261; lines 33-40.
 * @Provenance Oracle: SingleLineComment() == 1.
 * @Provenance Extra: repeat stays 1. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * A function carrying single-line comments around its body.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return 1
	 */
	int SingleLineCommented()
	{
		int Value = 1; // Inline single-line comment.
		return Value;
	}

	/**
	 * Observe that the commented function still returns 1.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs SingleLineCommented()
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool SingleLineCommentCompiles()
	{
		return SingleLineCommented() == 1;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs two calls to SingleLineCommented()
	 * @Return true when both report 1
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool SingleLineCommentRepeatsConsistently()
	{
		if (SingleLineCommented() != 1)
		{
			return false;
		}

		return SingleLineCommented() == 1;
	}
}
