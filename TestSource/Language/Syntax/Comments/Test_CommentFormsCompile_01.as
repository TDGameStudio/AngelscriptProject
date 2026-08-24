// Theme: Language.Syntax.Comments. Positive single-line comments compile and return 1.
// C++: AngelscriptCoverageCommentTests.cpp::CommentFormsCompile block 1
// sha256=28dc1bffba9fd1c0511aa0c401d07f50b1ff29661c20e7331bfe02cc343ba261; lines 33-40.
// Oracle: SingleLineComment() == 1.
// Extra: repeat stays 1. DefaultSafe.

// Single-line comment before a declaration.
int SingleLineComment()
{
	int Value = 1; // Inline single-line comment.
	return Value;
}

bool Observe_SingleLineComment_Nominal()
{
	return SingleLineComment() == 1;
}

bool Observe_SingleLineComment_RepeatBoundary()
{
	return SingleLineComment() == 1 && SingleLineComment() == 1;
}
