// Theme: Language.Syntax.Comments. Positive documentation comments compile and return 3.
// C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 3
// sha256=2a214e008960300fb76a0212f2df7ed69d349b33b9e45534e0dc83b119a4b8f8; lines 65-73.
// Oracle: DocumentationComment() == 3.
// Extra: repeat stays 3. DefaultSafe.

/**
 * Documentation-style comment before a function.
 */
int DocumentationComment()
{
	return 3;
}

bool Observe_DocumentationComment_Nominal()
{
	return DocumentationComment() == 3;
}

bool Observe_DocumentationComment_RepeatBoundary()
{
	return DocumentationComment() == 3 && DocumentationComment() == 3;
}
