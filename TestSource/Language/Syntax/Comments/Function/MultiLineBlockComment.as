/**
 * A block comment placed before a declaration, and another sitting inline
 * between statements, both compile and leave the code around them working.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.MultiLineBlockComment
 * @Harness Function
 * @Tag Language.Syntax.Comments.MultiLineBlockComment
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 2
 * @Provenance sha256=93dd89816d670a5f223dc661c197d8c3b5078746f508b06ad1d578eae3eaaf2e; lines 48-57.
 * @Provenance Oracle: MultiLineComment() == 2.
 * @Provenance Extra: repeat stays 2. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * A function carrying block comments before and inside its body.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return 2
	 */
	int MultiLineCommented()
	{
		int Value = 2;
		/* Inline block comment */ return Value;
	}

	/**
	 * Observe that the commented function still returns 2.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs MultiLineCommented()
	 * @Return true when the value is 2
	 */
	UFUNCTION()
	bool MultiLineBlockCommentCompiles()
	{
		return MultiLineCommented() == 2;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs two calls to MultiLineCommented()
	 * @Return true when both report 2
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool MultiLineBlockCommentRepeatsConsistently()
	{
		if (MultiLineCommented() != 2)
		{
			return false;
		}

		return MultiLineCommented() == 2;
	}
}
