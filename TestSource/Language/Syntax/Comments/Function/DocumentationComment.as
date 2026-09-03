/**
 * A documentation-style comment placed before a function. The comment form is
 * the subject here, so the function it documents is deliberately trivial.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Comments.DocumentationComment
 * @Harness Function
 * @Tag Language.Syntax.Comments.DocumentationComment
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 3
 * @Provenance sha256=2a214e008960300fb76a0212f2df7ed69d349b33b9e45534e0dc83b119a4b8f8; lines 65-73.
 * @Provenance Oracle: DocumentationComment() == 3.
 * @Provenance Extra: repeat stays 3. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * A function carrying a documentation-style comment.
	 *
	 * @Covers Syntax.Comments
	 * @Inputs none
	 * @Return 3
	 */
	int DocumentationCommented()
	{
		return 3;
	}

	/**
	 * Observe that the documented function still returns 3.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs DocumentationCommented()
	 * @Return true when the value is 3
	 */
	UFUNCTION()
	bool DocumentationCommentCompiles()
	{
		return DocumentationCommented() == 3;
	}

	/**
	 * Observe that repeated calls agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Comments
	 * @Inputs two calls to DocumentationCommented()
	 * @Return true when both report 3
	 * @Boundary repeat
	 */
	UFUNCTION()
	bool DocumentationCommentRepeatsConsistently()
	{
		if (DocumentationCommented() != 3)
		{
			return false;
		}

		return DocumentationCommented() == 3;
	}
}
